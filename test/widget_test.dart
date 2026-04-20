import 'package:flutter_test/flutter_test.dart';
import 'package:neurolens_doctor/models/patient_model.dart';
import 'package:neurolens_doctor/models/session_model.dart';
import 'package:neurolens_doctor/models/feature_models.dart';
import 'package:neurolens_doctor/utils/validators.dart';
import 'package:neurolens_doctor/utils/sgt.dart';

/// Creates minimal acoustic features for testing.
AcousticFeatures _sampleAcousticFeatures() {
  return AcousticFeatures(
    meanF0: 180.0,
    stdF0: 25.0,
    minF0: 120.0,
    maxF0: 280.0,
    meanEnergy: 0.03,
    stdEnergy: 0.01,
    dynamicRange: 0.10,
    syllablesPerSec: 3.0,
    wordsPerSec: 2.0,
    pauseCount: 10,
    totalPauseDuration: 4.0,
    pauseRatio: 0.25,
    mfccFeatures: List.filled(26, 0.0),
    spectralCentroidMean: 1200.0,
    spectralCentroidStd: 250.0,
    spectralBandwidthMean: 1000.0,
    spectralBandwidthStd: 200.0,
  );
}

/// Creates minimal linguistic features for testing.
LinguisticFeatures _sampleLinguisticFeatures() {
  return LinguisticFeatures(
    totalTokens: 100,
    uniqueTokens: 70,
    typeTokenRatio: 0.70,
    meanWordsPerUtterance: 12.0,
    maxUtteranceLength: 20,
    sentenceCount: 8,
    contentWordsRatio: 0.55,
    functionWordsRatio: 0.35,
    rareWordsRatio: 0.10,
    fillerCount: 5,
    repetitionScore: 0.15,
    bigramRepetitionRatio: 0.08,
    selfCorrectionCount: 2,
    semanticCoherenceMean: 0.80,
    semanticCoherenceVariance: 0.10,
  );
}

/// Creates minimal LLM clinical scores for testing.
LLMClinicalScores _sampleClinicalScores() {
  return LLMClinicalScores(
    semanticMemoryDegradation: 3,
    narrativeStructureDisintegration: 3,
    pragmaticAppropriateness: 3,
    topicMaintenance: 3,
    perseverationTypes: 1,
    disorientationTypes: 1,
    executiveDysfunctionPatterns: 1,
    abstractReasoning: 3,
    semanticClusteringVsFragmentation: 3,
    emotionalAppropriateness: 3,
    novelInformationContent: 3,
    ambiguityVagueness: 3,
    instructionFollowing: 3,
    logicalSelfConsistency: 3,
    confabulation: 1,
    clinicalImpression: 3,
    errorTypeClassification: 1,
    compensationStrategies: 2,
  );
}

void main() {
  group('Validators', () {
    test('accepts valid patient IDs', () {
      expect(Validators.isValidPatientId('P123'), true);
      expect(Validators.isValidPatientId('ABC'), true);
      expect(Validators.isValidPatientId('P001'), true);
      expect(Validators.isValidPatientId('Test123'), true);
    });

    test('rejects invalid patient IDs', () {
      expect(Validators.isValidPatientId('AB'), false); // too short
      expect(Validators.isValidPatientId('12345678901'), false); // too long
      expect(Validators.isValidPatientId('P@123'), false); // special chars
      expect(Validators.isValidPatientId(''), false); // empty
    });
  });

  group('Patient Model', () {
    test('creates patient from JSON', () {
      final json = {
        'patient_id': 'P001',
        'display_name': 'Test Patient',
        'sessions': <Map<String, dynamic>>[],
      };

      final patient = Patient.fromJson(json);
      expect(patient.patientId, 'P001');
      expect(patient.displayName, 'Test Patient');
      expect(patient.sessions.length, 0);
    });

    test('calculates trend indicator correctly', () {
      final sessions = <Session>[
        Session(
          sessionId: 'S1',
          timestamp: DateTime.now().subtract(const Duration(days: 30)),
          mmseScore: 28,
          diagnosisProbabilities: DiagnosisProbabilities(hc: 0.8, mci: 0.15, ad: 0.05),
          severityEstimate: SeverityEstimate(mmse: 28, uncertainty: 1),
          acousticFeatures: _sampleAcousticFeatures(),
          linguisticFeatures: _sampleLinguisticFeatures(),
          llmClinicalScores: _sampleClinicalScores(),
        ),
        Session(
          sessionId: 'S2',
          timestamp: DateTime.now(),
          mmseScore: 26,
          diagnosisProbabilities: DiagnosisProbabilities(hc: 0.6, mci: 0.3, ad: 0.1),
          severityEstimate: SeverityEstimate(mmse: 26, uncertainty: 2),
          acousticFeatures: _sampleAcousticFeatures(),
          linguisticFeatures: _sampleLinguisticFeatures(),
          llmClinicalScores: _sampleClinicalScores(),
        ),
      ];

      final patient = Patient(
        patientId: 'P001',
        displayName: 'Test',
        sessions: sessions,
      );

      // MMSE dropped from 28 to 26 (diff = -2), but threshold is diff < -2, so trend is stable
      final trend = patient.getTrendIndicator();
      expect(trend, '—');
    });
  });

  group('DiagnosisProbabilities', () {
    test('determines correct severity from probabilities', () {
      final hcDiagnosis = DiagnosisProbabilities(hc: 0.8, mci: 0.15, ad: 0.05);
      expect(hcDiagnosis.getSeverity(), 'HC');

      final mciDiagnosis = DiagnosisProbabilities(hc: 0.1, mci: 0.7, ad: 0.2);
      expect(mciDiagnosis.getSeverity(), 'MCI');

      final adDiagnosis = DiagnosisProbabilities(hc: 0.05, mci: 0.25, ad: 0.7);
      expect(adDiagnosis.getSeverity(), 'AD');
    });
  });

  group('Trend direction', () {
    Session _makeSession(int mmse, int daysAgo) {
      return Session(
        sessionId: 'S_$daysAgo',
        timestamp: DateTime.now().subtract(Duration(days: daysAgo)),
        mmseScore: mmse,
        diagnosisProbabilities: DiagnosisProbabilities(hc: 0.5, mci: 0.3, ad: 0.2),
        severityEstimate: SeverityEstimate(mmse: mmse, uncertainty: 1),
        acousticFeatures: _sampleAcousticFeatures(),
        linguisticFeatures: _sampleLinguisticFeatures(),
        llmClinicalScores: _sampleClinicalScores(),
      );
    }

    test('MMSE increasing returns improving', () {
      final patient = Patient(
        patientId: 'P002',
        displayName: 'Improving',
        sessions: [_makeSession(18, 30), _makeSession(22, 20), _makeSession(26, 0)],
      );
      expect(patient.getTrendIndicator(), '↑');
    });

    test('MMSE decreasing returns declining', () {
      final patient = Patient(
        patientId: 'P003',
        displayName: 'Declining',
        sessions: [_makeSession(28, 30), _makeSession(24, 15), _makeSession(20, 0)],
      );
      expect(patient.getTrendIndicator(), '↓');
    });

    test('small change returns stable', () {
      final patient = Patient(
        patientId: 'P004',
        displayName: 'Stable',
        sessions: [_makeSession(24, 30), _makeSession(25, 15), _makeSession(24, 0)],
      );
      expect(patient.getTrendIndicator(), '—');
    });

    test('respects days parameter for range filtering', () {
      final patient = Patient(
        patientId: 'P005',
        displayName: 'RangeTest',
        sessions: [
          _makeSession(18, 60),
          _makeSession(20, 45),
          _makeSession(26, 5),
          _makeSession(27, 2),
          _makeSession(28, 0),
        ],
      );
      expect(patient.getTrendIndicator(days: 10), '—');
      expect(patient.getTrendIndicator(), '↑');
    });
  });

  group('SGT formatting', () {
    test('converts UTC to SGT (UTC+8)', () {
      final utcTime = DateTime.utc(2026, 4, 14, 0, 0);
      final sgt = toSGT(utcTime);
      expect(sgt.hour, 8);
      expect(sgt.day, 14);
    });

    test('formatSGT produces expected string', () {
      final utcTime = DateTime.utc(2026, 4, 13, 17, 40);
      final formatted = formatSGT(utcTime);
      expect(formatted, '14 April 2026, 01:40');
    });

    test('formatSGTShort produces expected string', () {
      final utcTime = DateTime.utc(2026, 4, 13, 17, 40);
      final formatted = formatSGTShort(utcTime);
      expect(formatted, '14 Apr 2026, 01:40');
    });
  });
}
