/// 42 acoustic features extracted from speech signal analysis.
class AcousticFeatures {
  // Pitch (F0) metrics
  final double meanF0;
  final double stdF0;
  final double minF0;
  final double maxF0;

  // Energy metrics
  final double meanEnergy;
  final double stdEnergy;
  final double dynamicRange;

  // Speech rate
  final double syllablesPerSec;
  final double wordsPerSec;

  // Pause characteristics
  final int pauseCount;
  final double totalPauseDuration;
  final double pauseRatio;

  // MFCC coefficients (13 means + 13 standard deviations)
  final List<double> mfccFeatures;

  // Spectral characteristics
  final double spectralCentroidMean;
  final double spectralCentroidStd;
  final double spectralBandwidthMean;
  final double spectralBandwidthStd;

  AcousticFeatures({
    required this.meanF0,
    required this.stdF0,
    required this.minF0,
    required this.maxF0,
    required this.meanEnergy,
    required this.stdEnergy,
    required this.dynamicRange,
    required this.syllablesPerSec,
    required this.wordsPerSec,
    required this.pauseCount,
    required this.totalPauseDuration,
    required this.pauseRatio,
    required this.mfccFeatures,
    required this.spectralCentroidMean,
    required this.spectralCentroidStd,
    required this.spectralBandwidthMean,
    required this.spectralBandwidthStd,
  });

  factory AcousticFeatures.fromJson(Map<String, dynamic> json) {
    return AcousticFeatures(
      meanF0: (json['mean_f0'] ?? 0).toDouble(),
      stdF0: (json['std_f0'] ?? 0).toDouble(),
      minF0: (json['min_f0'] ?? 0).toDouble(),
      maxF0: (json['max_f0'] ?? 0).toDouble(),
      meanEnergy: (json['mean_energy'] ?? 0).toDouble(),
      stdEnergy: (json['std_energy'] ?? 0).toDouble(),
      dynamicRange: (json['dynamic_range'] ?? 0).toDouble(),
      syllablesPerSec: (json['syllables_per_sec'] ?? 0).toDouble(),
      wordsPerSec: (json['words_per_sec'] ?? 0).toDouble(),
      pauseCount: json['pause_count'] ?? 0,
      totalPauseDuration: (json['total_pause_duration'] ?? 0).toDouble(),
      pauseRatio: (json['pause_ratio'] ?? 0).toDouble(),
      mfccFeatures: (json['mfcc_features'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          List.filled(26, 0.0),
      spectralCentroidMean: (json['spectral_centroid_mean'] ?? 0).toDouble(),
      spectralCentroidStd: (json['spectral_centroid_std'] ?? 0).toDouble(),
      spectralBandwidthMean: (json['spectral_bandwidth_mean'] ?? 0).toDouble(),
      spectralBandwidthStd: (json['spectral_bandwidth_std'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'mean_f0': meanF0,
        'std_f0': stdF0,
        'min_f0': minF0,
        'max_f0': maxF0,
        'mean_energy': meanEnergy,
        'std_energy': stdEnergy,
        'dynamic_range': dynamicRange,
        'syllables_per_sec': syllablesPerSec,
        'words_per_sec': wordsPerSec,
        'pause_count': pauseCount,
        'total_pause_duration': totalPauseDuration,
        'pause_ratio': pauseRatio,
        'mfcc_features': mfccFeatures,
        'spectral_centroid_mean': spectralCentroidMean,
        'spectral_centroid_std': spectralCentroidStd,
        'spectral_bandwidth_mean': spectralBandwidthMean,
        'spectral_bandwidth_std': spectralBandwidthStd,
      };
}

/// 15 linguistic features from natural language analysis.
class LinguisticFeatures {
  // Text statistics
  final int totalTokens;
  final int uniqueTokens;
  final double typeTokenRatio;
  final double meanWordsPerUtterance;
  final int maxUtteranceLength;
  final int sentenceCount;

  // Lexical richness
  final double contentWordsRatio;
  final double functionWordsRatio;
  final double rareWordsRatio;

  // Repetition and disfluency
  final int fillerCount;
  final double repetitionScore;
  final double bigramRepetitionRatio;
  final int selfCorrectionCount;

  // Semantic coherence
  final double semanticCoherenceMean;
  final double semanticCoherenceVariance;

  LinguisticFeatures({
    required this.totalTokens,
    required this.uniqueTokens,
    required this.typeTokenRatio,
    required this.meanWordsPerUtterance,
    required this.maxUtteranceLength,
    required this.sentenceCount,
    required this.contentWordsRatio,
    required this.functionWordsRatio,
    required this.rareWordsRatio,
    required this.fillerCount,
    required this.repetitionScore,
    required this.bigramRepetitionRatio,
    required this.selfCorrectionCount,
    required this.semanticCoherenceMean,
    required this.semanticCoherenceVariance,
  });

  factory LinguisticFeatures.fromJson(Map<String, dynamic> json) {
    return LinguisticFeatures(
      totalTokens: json['total_tokens'] ?? 0,
      uniqueTokens: json['unique_tokens'] ?? 0,
      typeTokenRatio: (json['type_token_ratio'] ?? 0).toDouble(),
      meanWordsPerUtterance: (json['mean_words_per_utterance'] ?? 0).toDouble(),
      maxUtteranceLength: json['max_utterance_length'] ?? 0,
      sentenceCount: json['sentence_count'] ?? 0,
      contentWordsRatio: (json['content_words_ratio'] ?? 0).toDouble(),
      functionWordsRatio: (json['function_words_ratio'] ?? 0).toDouble(),
      rareWordsRatio: (json['rare_words_ratio'] ?? 0).toDouble(),
      fillerCount: json['filler_count'] ?? 0,
      repetitionScore: (json['repetition_score'] ?? 0).toDouble(),
      bigramRepetitionRatio: (json['bigram_repetition_ratio'] ?? 0).toDouble(),
      selfCorrectionCount: json['self_correction_count'] ?? 0,
      semanticCoherenceMean: (json['semantic_coherence_mean'] ?? 0).toDouble(),
      semanticCoherenceVariance: (json['semantic_coherence_variance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_tokens': totalTokens,
        'unique_tokens': uniqueTokens,
        'type_token_ratio': typeTokenRatio,
        'mean_words_per_utterance': meanWordsPerUtterance,
        'max_utterance_length': maxUtteranceLength,
        'sentence_count': sentenceCount,
        'content_words_ratio': contentWordsRatio,
        'function_words_ratio': functionWordsRatio,
        'rare_words_ratio': rareWordsRatio,
        'filler_count': fillerCount,
        'repetition_score': repetitionScore,
        'bigram_repetition_ratio': bigramRepetitionRatio,
        'self_correction_count': selfCorrectionCount,
        'semantic_coherence_mean': semanticCoherenceMean,
        'semantic_coherence_variance': semanticCoherenceVariance,
      };
}

/// 18 clinical scores from LLM-based cognitive assessment (0-4 scale).
class LLMClinicalScores {
  final int semanticMemoryDegradation;
  final int narrativeStructureDisintegration;
  final int pragmaticAppropriateness;
  final int topicMaintenance;
  final int perseverationTypes;
  final int disorientationTypes;
  final int executiveDysfunctionPatterns;
  final int abstractReasoning;
  final int semanticClusteringVsFragmentation;
  final int emotionalAppropriateness;
  final int novelInformationContent;
  final int ambiguityVagueness;
  final int instructionFollowing;
  final int logicalSelfConsistency;
  final int confabulation;
  final int clinicalImpression;
  final int errorTypeClassification;
  final int compensationStrategies;

  LLMClinicalScores({
    required this.semanticMemoryDegradation,
    required this.narrativeStructureDisintegration,
    required this.pragmaticAppropriateness,
    required this.topicMaintenance,
    required this.perseverationTypes,
    required this.disorientationTypes,
    required this.executiveDysfunctionPatterns,
    required this.abstractReasoning,
    required this.semanticClusteringVsFragmentation,
    required this.emotionalAppropriateness,
    required this.novelInformationContent,
    required this.ambiguityVagueness,
    required this.instructionFollowing,
    required this.logicalSelfConsistency,
    required this.confabulation,
    required this.clinicalImpression,
    required this.errorTypeClassification,
    required this.compensationStrategies,
  });

  factory LLMClinicalScores.fromJson(Map<String, dynamic> json) {
    return LLMClinicalScores(
      semanticMemoryDegradation: json['semantic_memory_degradation'] ?? 0,
      narrativeStructureDisintegration: json['narrative_structure_disintegration'] ?? 0,
      pragmaticAppropriateness: json['pragmatic_appropriateness'] ?? 0,
      topicMaintenance: json['topic_maintenance'] ?? 0,
      perseverationTypes: json['perseveration_types'] ?? 0,
      disorientationTypes: json['disorientation_types'] ?? 0,
      executiveDysfunctionPatterns: json['executive_dysfunction_patterns'] ?? 0,
      abstractReasoning: json['abstract_reasoning'] ?? 0,
      semanticClusteringVsFragmentation: json['semantic_clustering_vs_fragmentation'] ?? 0,
      emotionalAppropriateness: json['emotional_appropriateness'] ?? 0,
      novelInformationContent: json['novel_information_content'] ?? 0,
      ambiguityVagueness: json['ambiguity_vagueness'] ?? 0,
      instructionFollowing: json['instruction_following'] ?? 0,
      logicalSelfConsistency: json['logical_self_consistency'] ?? 0,
      confabulation: json['confabulation'] ?? 0,
      clinicalImpression: json['clinical_impression'] ?? 0,
      errorTypeClassification: json['error_type_classification'] ?? 0,
      compensationStrategies: json['compensation_strategies'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'semantic_memory_degradation': semanticMemoryDegradation,
        'narrative_structure_disintegration': narrativeStructureDisintegration,
        'pragmatic_appropriateness': pragmaticAppropriateness,
        'topic_maintenance': topicMaintenance,
        'perseveration_types': perseverationTypes,
        'disorientation_types': disorientationTypes,
        'executive_dysfunction_patterns': executiveDysfunctionPatterns,
        'abstract_reasoning': abstractReasoning,
        'semantic_clustering_vs_fragmentation': semanticClusteringVsFragmentation,
        'emotional_appropriateness': emotionalAppropriateness,
        'novel_information_content': novelInformationContent,
        'ambiguity_vagueness': ambiguityVagueness,
        'instruction_following': instructionFollowing,
        'logical_self_consistency': logicalSelfConsistency,
        'confabulation': confabulation,
        'clinical_impression': clinicalImpression,
        'error_type_classification': errorTypeClassification,
        'compensation_strategies': compensationStrategies,
      };
}

/// Probability distribution across diagnostic categories.
/// HC = Healthy Control, MCI = Mild Cognitive Impairment, AD = Alzheimer's Disease.
class DiagnosisProbabilities {
  final double hc;
  final double mci;
  final double ad;

  DiagnosisProbabilities({
    required this.hc,
    required this.mci,
    required this.ad,
  });

  factory DiagnosisProbabilities.fromJson(Map<String, dynamic> json) {
    return DiagnosisProbabilities(
      hc: (json['HC'] ?? 0).toDouble(),
      mci: (json['MCI'] ?? 0).toDouble(),
      ad: (json['AD'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'HC': hc, 'MCI': mci, 'AD': ad};

  /// Returns the most likely diagnosis based on highest probability.
  String getSeverity() {
    if (hc > mci && hc > ad) return 'HC';
    if (mci > ad) return 'MCI';
    return 'AD';
  }
}

/// MMSE severity estimate with uncertainty bounds.
class SeverityEstimate {
  final int mmse;
  final int uncertainty;

  SeverityEstimate({
    required this.mmse,
    required this.uncertainty,
  });

  factory SeverityEstimate.fromJson(Map<String, dynamic> json) {
    return SeverityEstimate(
      mmse: json['mmse'] ?? 0,
      uncertainty: json['uncertainty'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'mmse': mmse, 'uncertainty': uncertainty};
}