import 'session_model.dart';
import 'feature_models.dart';

/// Represents a patient with their assessment history.
class Patient {
  final String patientId;
  final String displayName;
  final List<Session> sessions;

  Patient({
    required this.patientId,
    required this.displayName,
    required this.sessions,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final sessionsList = (json['sessions'] as List<dynamic>?)
            ?.map((s) => Session.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return Patient(
      patientId: json['patient_id'] ?? '',
      displayName: json['display_name'] ?? '',
      sessions: sessionsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'display_name': displayName,
        'sessions': sessions.map((s) => s.toJson()).toList(),
      };

  Session? get _latestSession {
    if (sessions.isEmpty) return null;
    return sessions.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  int getLatestMMSE() => _latestSession?.mmseScore ?? 0;

  String getLatestSeverity() =>
      _latestSession?.diagnosisProbabilities.getSeverity() ?? 'N/A';

  DiagnosisProbabilities? getLatestDiagnosisProbabilities() =>
      _latestSession?.diagnosisProbabilities;

  DateTime? getLatestSessionDate() => _latestSession?.timestamp;

  int getTotalSessions() => sessions.length;

  /// Returns trend arrow based on MMSE change over recent sessions.
  /// Note: In this implementation, ↓ indicates MMSE score rising, ↑ indicates falling.
  String getTrendIndicator() {
    if (sessions.length < 2) return '—';

    final sortedSessions = List<Session>.from(sessions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final recentCount = sortedSessions.length > 5 ? 5 : sortedSessions.length;
    final recent = sortedSessions.sublist(sortedSessions.length - recentCount);

    if (recent.length < 2) return '—';

    final firstMMSE = recent.first.mmseScore;
    final lastMMSE = recent.last.mmseScore;
    final diff = lastMMSE - firstMMSE;

    // Needs >2 point change to count as meaningful trend
    if (diff > 2) return '↓'; // Lower MMSE = cognitive decline
    if (diff < -2) return '↑'; // Higher MMSE = improvement
    return '—';
  }
}