import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_model.dart';

/// Handles secure local storage for patient data.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> savePatients(List<Patient> patients) async {
    try {
      final jsonData = patients.map((p) => p.toJson()).toList();
      await _secureStorage.write(key: _patientsKey, value: jsonEncode(jsonData));
    } catch (e) {
      print('Error saving patient data: $e');
    }
  }

  Future<List<Patient>> loadPatients() async {
    try {
      final jsonString = await _secureStorage.read(key: _patientsKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      return jsonData.map((json) => Patient.fromJson(json)).toList();
    } catch (e) {
      print('Error loading patient data: $e');
      return [];
    }
  }

  Future<void> savePatientMapping(String patientId, String displayName) async {
    try {
      final mappings = await loadPatientMappings();
      mappings[patientId] = displayName;
      await _secureStorage.write(key: _mappingsKey, value: jsonEncode(mappings));
    } catch (e) {
      print('Error saving patient mapping: $e');
    }
  }

  Future<Map<String, String>> loadPatientMappings() async {
    try {
      final jsonString = await _secureStorage.read(key: _mappingsKey);
      if (jsonString == null || jsonString.isEmpty) return {};

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return jsonData.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print('Error loading patient mappings: $e');
      return {};
    }
  }

  Future<void> removePatientMapping(String patientId) async {
    try {
      final mappings = await loadPatientMappings();
      mappings.remove(patientId);
      await _secureStorage.write(key: _mappingsKey, value: jsonEncode(mappings));
    } catch (e) {
      print('Error removing patient mapping: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _secureStorage.deleteAll();
      await _prefs?.clear();
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}