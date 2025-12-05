/// Input validation utilities.
class Validators {
  static final _alphanumericPattern = RegExp(r'^[a-zA-Z0-9]+$');

  /// Checks if patient ID is 3-10 alphanumeric characters.
  static bool isValidPatientId(String id) {
    if (id.isEmpty || id.length < 3 || id.length > 10) return false;
    return _alphanumericPattern.hasMatch(id);
  }

  static String? validatePatientId(String? value) {
    if (value == null || value.isEmpty) return 'Patient ID is required';
    if (!isValidPatientId(value)) return 'ID must be 3-10 alphanumeric characters';
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) return 'Display name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    if (value.length > 50) return 'Name must be less than 50 characters';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }
}
