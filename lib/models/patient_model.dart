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
      patientId: json['patient_id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
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

  String getTrendIndicator({int? days}) {
    if (sessions.length < 2) return '—';

    final sortedSessions = List<Session>.from(sessions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final List<Session> scoped;
    if (days != null && days > 0) {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      scoped = sortedSessions.where((s) => s.timestamp.isAfter(cutoff)).toList();
    } else {
      scoped = sortedSessions;
    }

    final recentCount = scoped.length > 5 ? 5 : scoped.length;
    final recent = scoped.sublist(scoped.length - recentCount);

    if (recent.length < 2) return '—';

    final firstMMSE = recent.first.mmseScore;
    final lastMMSE = recent.last.mmseScore;
    final diff = lastMMSE - firstMMSE;

    if (diff > 2) return '↑';
    if (diff < -2) return '↓';
    return '—';
  }
}