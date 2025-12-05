import 'package:flutter/material.dart';

/// Application-wide constants.
class AppConstants {
  static const appTitle = 'NeuroLens Doctor Portal';
  static const defaultPassword = '1234';
  static const maxPasswordAttempts = 3;
  static const lockoutDurationSeconds = 30;

  // Window dimensions
  static const minWindowWidth = 1200.0;
  static const minWindowHeight = 800.0;
  static const defaultWindowWidth = 1400.0;
  static const defaultWindowHeight = 900.0;

  // UI styling
  static const cardBorderRadius = 20.0;
  static const gridSpacing = 16.0;

  // Storage keys
  static const storageKeyPatients = 'patients_data';
  static const storageKeyMappings = 'patient_mappings';
  static const storageKeyLockout = 'password_lockout';

  // Chart time ranges (days, -1 = all)
  static const timeRanges = [7, 30, 90, -1];
  static const timeRangeLabels = ['7D', '30D', '90D', 'All'];
}

/// Application colour palette.
class AppColors {
  static const primaryStart = Color(0xFF5B7FE8);
  static const primaryMid = Color(0xFF7B68D9);
  static const primaryEnd = Color(0xFF9B59B6);

  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFEF4444);

  static const cardText = Color(0xFF1F2937);
  static const cardBackground = Colors.white;
  static const onGradient = Colors.white;

  /// Returns colour based on MMSE score thresholds.
  static Color getMMSEColour(int mmse) {
    if (mmse >= 24) return success;
    if (mmse >= 18) return warning;
    return danger;
  }

  /// Returns colour based on cognitive risk index.
  static Color getRiskColour(int riskIndex) {
    if (riskIndex < 30) return success;
    if (riskIndex < 60) return warning;
    return danger;
  }

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [primaryStart, primaryMid, primaryEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      );

  static LinearGradient get primaryGradientVertical => const LinearGradient(
        colors: [primaryStart, primaryMid, primaryEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5, 1.0],
      );
}