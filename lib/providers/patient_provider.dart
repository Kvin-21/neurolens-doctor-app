import 'package:flutter/foundation.dart';
import '../models/patient_model.dart';
import '../services/storage_service.dart';
import '../services/mock_data_generator.dart';

/// Manages patient data and selection state.
class PatientProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  bool _isLoading = false;

  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;
  bool get hasPatients => _patients.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _patients = await _storage.loadPatients();
      if (_patients.isNotEmpty) {
        _selectedPatient = _patients.first;
      }
    } catch (e) {
      debugPrint('Error initialising patient provider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPatient(String patientId, String displayName) async {
    final exists = _patients.any((p) => p.patientId == patientId);
    if (exists) {
      throw Exception('Patient with ID $patientId already exists');
    }

    final newPatient = MockDataGenerator.generatePatient(patientId, displayName);
    _patients.add(newPatient);
    _selectedPatient = newPatient;

    await _storage.savePatients(_patients);
    notifyListeners();
  }

  Future<void> removePatient(String patientId) async {
    _patients.removeWhere((p) => p.patientId == patientId);

    if (_selectedPatient?.patientId == patientId) {
      _selectedPatient = _patients.isNotEmpty ? _patients.first : null;
    }

    await _storage.savePatients(_patients);
    notifyListeners();
  }

  void selectPatient(String patientId) {
    _selectedPatient = _patients.firstWhere(
      (p) => p.patientId == patientId,
      orElse: () => _patients.first,
    );
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }
}