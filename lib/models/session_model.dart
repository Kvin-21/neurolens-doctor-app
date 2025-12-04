import 'feature_models.dart';

/// A single cognitive assessment session with all extracted features.
class Session {
  final String sessionId;
  final DateTime timestamp;
  final int mmseScore;
  final DiagnosisProbabilities diagnosisProbabilities;
  final SeverityEstimate severityEstimate;
  final AcousticFeatures acousticFeatures;
  final LinguisticFeatures linguisticFeatures;
  final LLMClinicalScores llmClinicalScores;

  Session({
    required this.sessionId,
    required this.timestamp,
    required this.mmseScore,
    required this.diagnosisProbabilities,
    required this.severityEstimate,
    required this.acousticFeatures,
    required this.linguisticFeatures,
    required this.llmClinicalScores,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['session_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      mmseScore: json['mmse_score'] ?? 0,
      diagnosisProbabilities:
          DiagnosisProbabilities.fromJson(json['diagnosis_probabilities'] ?? {}),
      severityEstimate:
          SeverityEstimate.fromJson(json['severity_estimate'] ?? {}),
      acousticFeatures:
          AcousticFeatures.fromJson(json['acoustic_features'] ?? {}),
      linguisticFeatures:
          LinguisticFeatures.fromJson(json['linguistic_features'] ?? {}),
      llmClinicalScores:
          LLMClinicalScores.fromJson(json['llm_clinical_scores'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'timestamp': timestamp.toIso8601String(),
        'mmse_score': mmseScore,
        'diagnosis_probabilities': diagnosisProbabilities.toJson(),
        'severity_estimate': severityEstimate.toJson(),
        'acoustic_features': acousticFeatures.toJson(),
        'linguistic_features': linguisticFeatures.toJson(),
        'llm_clinical_scores': llmClinicalScores.toJson(),
      };
}