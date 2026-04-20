import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/result_crypto_service.dart';
import '../models/patient_model.dart';
import '../models/session_model.dart';

class PatientProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final ResultCryptoService _cryptoService = ResultCryptoService();
  static const _secure = FlutterSecureStorage();

  bool _isLoading = false;
  String? _error;
  List<Patient> _patients = [];
  Patient? _selectedPatient;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Patient> get patients => List.unmodifiable(_patients);
  bool get hasPatients => _patients.isNotEmpty;
  Patient? get selectedPatient => _selectedPatient;

  Future<void> init() async {
    final loaded = await _storageService.loadPatients();
    final byId = <String, Patient>{};
    for (final p in loaded) {
      byId[p.patientId] = p;
    }
    _patients = byId.values.toList();
    if (_patients.isNotEmpty) {
      _selectedPatient = _patients.first;
    }
    notifyListeners();
    if (_patients.isNotEmpty) {
      await refresh();
    }
  }

  void selectPatient(String patientId) {
    final match = _patients.where((p) => p.patientId == patientId);
    if (match.isNotEmpty) {
      _selectedPatient = match.first;
      notifyListeners();
      refresh();
    }
  }

  Future<void> addPatient(String patientId, String displayName, {String? existingPassword}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final existingIndex = _patients.indexWhere((p) => p.patientId == patientId);
      final reg = await _apiService.registerPatient(patientId: patientId);

      if (reg != null) {
        await _secure.write(key: 'pwd_$patientId', value: reg.password);
        await _secure.write(key: 'rk_$patientId', value: reg.resultKeyB64);

        final auth = await _apiService.authenticatePatient(
          patientId: patientId,
          password: reg.password,
        );
        await _secure.write(key: 'tok_$patientId', value: auth.token);
        if (auth.resultKeyB64 != null) {
          await _secure.write(key: 'rk_$patientId', value: auth.resultKeyB64!);
        }
      } else {
        final passwordToUse = existingPassword ?? await _secure.read(key: 'pwd_$patientId');
        if (passwordToUse == null) {
          throw Exception('existing_patient_needs_password');
        }
        final auth = await _apiService.authenticatePatient(
          patientId: patientId,
          password: passwordToUse,
        );
        await _secure.write(key: 'tok_$patientId', value: auth.token);
        if (auth.resultKeyB64 != null) {
          await _secure.write(key: 'rk_$patientId', value: auth.resultKeyB64!);
        }
        if (existingPassword != null) {
          await _secure.write(key: 'pwd_$patientId', value: existingPassword);
        }
      }

      final patient = Patient(
        patientId: patientId,
        displayName: displayName,
        sessions: existingIndex >= 0 ? _patients[existingIndex].sessions : [],
      );

      if (existingIndex >= 0) {
        _patients[existingIndex] = patient;
      } else {
        _patients.add(patient);
      }

      _selectedPatient = patient;
      await _storageService.savePatients(_patients);
      await _storageService.savePatientMapping(patientId, displayName);
    } on DioException catch (e) {
      final body = e.response?.data;
      final detail = body is Map ? body['detail']?.toString() : null;
      _error = detail ?? e.message ?? 'Network error';
      rethrow;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removePatient(String patientId) async {
    _patients.removeWhere((p) => p.patientId == patientId);
    if (_selectedPatient?.patientId == patientId) {
      _selectedPatient = _patients.isNotEmpty ? _patients.first : null;
    }
    await _storageService.savePatients(_patients);
    await _storageService.removePatientMapping(patientId);
    await _secure.delete(key: 'pwd_$patientId');
    await _secure.delete(key: 'rk_$patientId');
    await _secure.delete(key: 'tok_$patientId');
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_patients.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedPatients = <Patient>[];
      for (final patient in _patients) {
        var token = await _secure.read(key: 'tok_${patient.patientId}');
        final resultKeyB64 = await _secure.read(key: 'rk_${patient.patientId}');

        if (token == null || resultKeyB64 == null) {
          updatedPatients.add(patient);
          continue;
        }

        try {
          List<EncryptedResultPayload> payloads;
          try {
            payloads = await _apiService.fetchResultHistory(
              patientId: patient.patientId,
              token: token,
            );
          } on DioException catch (e) {
            if (e.response?.statusCode == 401) {
              final newToken = await _reauthenticate(patient.patientId);
              if (newToken != null) {
                token = newToken;
                payloads = await _apiService.fetchResultHistory(
                  patientId: patient.patientId,
                  token: token,
                );
              } else {
                updatedPatients.add(patient);
                continue;
              }
            } else {
              rethrow;
            }
          }

          if (payloads.isEmpty) {
            updatedPatients.add(patient);
            continue;
          }

          final sessionsByKey = <String, Session>{};
          for (final payload in payloads) {
            try {
              final decrypted = _cryptoService.decryptResult(
                payload: payload,
                resultKeyB64: resultKeyB64,
              );
              final session = Session.fromJson(decrypted);

              final key = session.sessionId.isNotEmpty
                  ? session.sessionId
                  : '${payload.createdAt}|${payload.wrappedResultKeyB64.substring(0, payload.wrappedResultKeyB64.length > 16 ? 16 : payload.wrappedResultKeyB64.length)}';

              if (!sessionsByKey.containsKey(key)) {
                sessionsByKey[key] = session;
              }
            } catch (e) {
              debugPrint('Failed to decrypt result for ${patient.patientId}: $e');
            }
          }

          final syncedSessions = sessionsByKey.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          updatedPatients.add(
            Patient(
              patientId: patient.patientId,
              displayName: patient.displayName,
              sessions: syncedSessions.isNotEmpty ? syncedSessions : patient.sessions,
            ),
          );
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            await _secure.delete(key: 'tok_${patient.patientId}');
          }
          debugPrint('Refresh failed for ${patient.patientId}: $e');
          updatedPatients.add(patient);
        } catch (e) {
          debugPrint('Refresh failed for ${patient.patientId}: $e');
          updatedPatients.add(patient);
        }
      }

      final byId = <String, Patient>{};
      for (final p in updatedPatients) {
        byId[p.patientId] = p;
      }

      _patients = byId.values.toList();
      final selectedId = _selectedPatient?.patientId;
      _selectedPatient = selectedId != null ? byId[selectedId] : null;
      _selectedPatient ??= _patients.isNotEmpty ? _patients.first : null;
      await _storageService.savePatients(_patients);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _reauthenticate(String patientId) async {
    final password = await _secure.read(key: 'pwd_$patientId');
    if (password == null) return null;
    try {
      final auth = await _apiService.authenticatePatient(
        patientId: patientId,
        password: password,
      );
      await _secure.write(key: 'tok_$patientId', value: auth.token);
      if (auth.resultKeyB64 != null) {
        await _secure.write(key: 'rk_$patientId', value: auth.resultKeyB64!);
      }
      return auth.token;
    } catch (e) {
      debugPrint('Reauthentication failed for $patientId: $e');
      return null;
    }
  }
}