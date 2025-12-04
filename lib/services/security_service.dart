import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Handles password validation with rate limiting and lockout.
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  SharedPreferences? _prefs;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadLockoutState();
  }

  void _loadLockoutState() {
    final lockoutTimestamp = _prefs?.getInt('lockout_timestamp');
    if (lockoutTimestamp == null) return;

    _lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
    if (_lockoutUntil!.isAfter(DateTime.now())) {
      _failedAttempts = AppConstants.maxPasswordAttempts;
    } else {
      _resetLockout();
    }
  }

  void _resetLockout() {
    _failedAttempts = 0;
    _lockoutUntil = null;
    _prefs?.remove('lockout_timestamp');
  }

  Future<void> _saveLockoutState() async {
    if (_lockoutUntil != null) {
      await _prefs?.setInt('lockout_timestamp', _lockoutUntil!.millisecondsSinceEpoch);
    } else {
      await _prefs?.remove('lockout_timestamp');
    }
  }

  bool isLockedOut() {
    if (_lockoutUntil == null) return false;

    if (DateTime.now().isBefore(_lockoutUntil!)) {
      return true;
    }

    _resetLockout();
    _saveLockoutState();
    return false;
  }

  int getRemainingLockoutSeconds() {
    if (_lockoutUntil == null) return 0;

    final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  Future<bool> validatePassword(String password) async {
    if (isLockedOut()) return false;

    if (password == AppConstants.defaultPassword) {
      _failedAttempts = 0;
      _lockoutUntil = null;
      await _saveLockoutState();
      return true;
    }

    _failedAttempts++;

    if (_failedAttempts >= AppConstants.maxPasswordAttempts) {
      _lockoutUntil = DateTime.now().add(
        const Duration(seconds: AppConstants.lockoutDurationSeconds),
      );
      await _saveLockoutState();
    }

    return false;
  }

  int getFailedAttempts() => _failedAttempts;

  int getRemainingAttempts() {
    return (AppConstants.maxPasswordAttempts - _failedAttempts)
        .clamp(0, AppConstants.maxPasswordAttempts);
  }

  Future<void> resetAttempts() async {
    _failedAttempts = 0;
    _lockoutUntil = null;
    await _saveLockoutState();
  }
}
