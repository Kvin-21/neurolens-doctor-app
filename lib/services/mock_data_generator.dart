import 'dart:math';
import '../models/patient_model.dart';
import '../models/session_model.dart';
import '../models/feature_models.dart';

/// Disease progression patterns for mock data.
enum ProgressionType { declining, stable, improving }

/// Generates realistic mock patient data for testing and demo purposes.
class MockDataGenerator {
  /// Creates a patient with mock assessment sessions based on their ID seed.
  static Patient generatePatient(String patientId, String displayName) {
    final seed = patientId.hashCode;
    final random = Random(seed);

    final progression = ProgressionType.values[random.nextInt(3)];
    final sessionCount = 30 + random.nextInt(20);

    return _buildPatient(patientId, displayName, sessionCount, progression, random);
  }

  static Patient _buildPatient(
    String patientId,
    String displayName,
    int sessionCount,
    ProgressionType progression,
    Random random,
  ) {
    final sessions = <Session>[];
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 120 + random.nextInt(60)));
    final totalDays = endDate.difference(startDate).inDays;

    for (var i = 0; i < sessionCount; i++) {
      final dayOffset = (i * totalDays / sessionCount).round();
      final sessionDate = startDate.add(Duration(days: dayOffset));
      final baseMMSE = _calculateBaseMMSE(i, sessionCount, progression, random);

      sessions.add(_buildSession(sessionDate, baseMMSE, i, random));
    }

    return Patient(
      patientId: patientId,
      displayName: displayName,
      sessions: sessions,
    );
  }

  static int _calculateBaseMMSE(
    int index,
    int total,
    ProgressionType progression,
    Random random,
  ) {
    final progress = index / total;

    switch (progression) {
      case ProgressionType.declining:
        return 28 - (progress * 10).toInt() + random.nextInt(3);
      case ProgressionType.stable:
        return 24 + random.nextInt(4);
      case ProgressionType.improving:
        return 18 + (progress * 8).toInt() + random.nextInt(3);
    }
  }

  static Session _buildSession(
    DateTime timestamp,
    int baseMMSE,
    int index,
    Random random,
  ) {
    final mmse = baseMMSE.clamp(0, 30);

    return Session(
      diagnosisProbabilities: _buildDiagnosisProbabilities(mmse, random),
      severityEstimate: _buildSeverityEstimate(mmse, random),
      acousticFeatures: _buildAcousticFeatures(mmse, random),
      linguisticFeatures: _buildLinguisticFeatures(mmse, random),
      llmClinicalScores: _buildClinicalScores(mmse, random),
    );
  }

  static DiagnosisProbabilities _buildDiagnosisProbabilities(int mmse, Random random) {
    // Higher MMSE = healthier, lower = more likely AD
    if (mmse >= 24) {
      return DiagnosisProbabilities(
        hc: 0.7 + random.nextDouble() * 0.2,
        mci: 0.15 + random.nextDouble() * 0.1,
        ad: 0.05 + random.nextDouble() * 0.05,
      );
    } else if (mmse >= 18) {
      return DiagnosisProbabilities(
        hc: 0.1 + random.nextDouble() * 0.15,
        mci: 0.6 + random.nextDouble() * 0.2,
        ad: 0.15 + random.nextDouble() * 0.15,
      );
    } else {
      return DiagnosisProbabilities(
        hc: 0.05 + random.nextDouble() * 0.1,
        mci: 0.2 + random.nextDouble() * 0.15,
        ad: 0.6 + random.nextDouble() * 0.25,
      );
    }
  }

  static SeverityEstimate _buildSeverityEstimate(int mmse, Random random) {
    return SeverityEstimate(
      mmse: mmse,
      uncertainty: 1 + random.nextInt(3),
    );
  }

  static AcousticFeatures _buildAcousticFeatures(int mmse, Random random) {
    final normalised = mmse / 30.0;

    return AcousticFeatures(
      meanF0: 150 + random.nextDouble() * 80,
      stdF0: 15 + random.nextDouble() * 20,
      minF0: 100 + random.nextDouble() * 30,
      maxF0: 250 + random.nextDouble() * 50,
      meanEnergy: 0.02 + random.nextDouble() * 0.03,
      stdEnergy: 0.01 + random.nextDouble() * 0.02,
      dynamicRange: 0.08 + random.nextDouble() * 0.04,
      syllablesPerSec: 2.5 * normalised + random.nextDouble() * 0.5,
      wordsPerSec: 1.5 * normalised + random.nextDouble() * 0.3,
      pauseCount: (20 - (normalised * 10)).toInt() + random.nextInt(5),
      totalPauseDuration: 5.0 - (normalised * 2) + random.nextDouble() * 2,
      pauseRatio: 0.3 - (normalised * 0.1) + random.nextDouble() * 0.1,
      mfccFeatures: List.generate(26, (_) => -10 + random.nextDouble() * 20),
      spectralCentroidMean: 1000 + random.nextDouble() * 500,
      spectralCentroidStd: 200 + random.nextDouble() * 150,
      spectralBandwidthMean: 800 + random.nextDouble() * 400,
      spectralBandwidthStd: 150 + random.nextDouble() * 100,
    );
  }

  static LinguisticFeatures _buildLinguisticFeatures(int mmse, Random random) {
    final normalised = mmse / 30.0;

    return LinguisticFeatures(
      totalTokens: (80 + normalised * 40).toInt() + random.nextInt(20),
      uniqueTokens: (50 + normalised * 30).toInt() + random.nextInt(15),
      typeTokenRatio: 0.5 + normalised * 0.3 + random.nextDouble() * 0.1,
      meanWordsPerUtterance: 10 + normalised * 5 + random.nextDouble() * 3,
      maxUtteranceLength: (20 + normalised * 10).toInt() + random.nextInt(5),
      sentenceCount: (5 + normalised * 3).toInt() + random.nextInt(3),
      contentWordsRatio: 0.4 + normalised * 0.2 + random.nextDouble() * 0.1,
      functionWordsRatio: 0.3 + random.nextDouble() * 0.1,
      rareWordsRatio: normalised * 0.15 + random.nextDouble() * 0.05,
      fillerCount: (10 - normalised * 5).toInt() + random.nextInt(5),
      repetitionScore: 0.3 - normalised * 0.2 + random.nextDouble() * 0.1,
      bigramRepetitionRatio: 0.2 - normalised * 0.1 + random.nextDouble() * 0.05,
      selfCorrectionCount: (5 - normalised * 3).toInt() + random.nextInt(3),
      semanticCoherenceMean: 0.5 + normalised * 0.4 + random.nextDouble() * 0.1,
      semanticCoherenceVariance: 0.2 - normalised * 0.1 + random.nextDouble() * 0.05,
    );
  }

  static LLMClinicalScores _buildClinicalScores(int mmse, Random random) {
    final baseScore = (mmse / 7.5).floor().clamp(0, 4);

    return LLMClinicalScores(
      semanticMemoryDegradation: (baseScore + random.nextInt(2)).clamp(0, 4),
      narrativeStructureDisintegration: (baseScore + random.nextInt(2)).clamp(0, 4),
      pragmaticAppropriateness: (baseScore + random.nextInt(2)).clamp(0, 4),
      topicMaintenance: (baseScore + random.nextInt(2)).clamp(0, 4),
      perseverationTypes: (4 - baseScore + random.nextInt(2)).clamp(0, 4),
      disorientationTypes: (4 - baseScore + random.nextInt(2)).clamp(0, 4),
      executiveDysfunctionPatterns: (4 - baseScore + random.nextInt(2)).clamp(0, 4),
      abstractReasoning: (baseScore + random.nextInt(2)).clamp(0, 4),
      semanticClusteringVsFragmentation: (baseScore + random.nextInt(2)).clamp(0, 4),
      emotionalAppropriateness: (baseScore + random.nextInt(2)).clamp(0, 4),
      novelInformationContent: (baseScore + random.nextInt(2)).clamp(0, 4),
      ambiguityVagueness: (baseScore + random.nextInt(2)).clamp(0, 4),
      instructionFollowing: (baseScore + random.nextInt(2)).clamp(0, 4),
      logicalSelfConsistency: (baseScore + random.nextInt(2)).clamp(0, 4),
      confabulation: (4 - baseScore + random.nextInt(2)).clamp(0, 4),
      clinicalImpression: (baseScore + random.nextInt(2)).clamp(0, 4),
      errorTypeClassification: (4 - baseScore + random.nextInt(2)).clamp(0, 4),
      compensationStrategies: (4 - baseScore + random.nextInt(2)).clamp(0, 4),
    );
  }
}