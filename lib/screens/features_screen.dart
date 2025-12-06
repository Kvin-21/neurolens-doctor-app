import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../models/session_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Displays all 75 cognitive features for a patient's latest session.
class FeaturesScreen extends StatelessWidget {
  final Patient patient;

  const FeaturesScreen({super.key, required this.patient});

  Session? get _latestSession {
    if (patient.sessions.isEmpty) return null;
    return patient.sessions.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final session = _latestSession;
    if (session == null) return _buildEmptyState(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryStart.withValues(alpha: 0.08),
            AppColors.primaryEnd.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Acoustic Features (42)', Icons.graphic_eq),
            const SizedBox(height: 16),
            _buildAcousticFeatures(session),
            const SizedBox(height: 32),
            _buildSectionHeader('Linguistic Features (15)', Icons.text_fields),
            const SizedBox(height: 16),
            _buildLinguisticFeatures(session),
            const SizedBox(height: 32),
            _buildSectionHeader('LLM Clinical Scores (18)', Icons.psychology),
            const SizedBox(height: 16),
            _buildLLMScores(session),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.data_usage, size: 80, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(
              'No Session Data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'No assessment data available for this patient yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryEnd.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAcousticFeatures(Session session) {
    final f = session.acousticFeatures;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildFeatureCard('Mean F0', '${f.meanF0.toStringAsFixed(1)} Hz', Icons.tune),
        _buildFeatureCard('STD F0', '${f.stdF0.toStringAsFixed(1)} Hz', Icons.show_chart),
        _buildFeatureCard('Min F0', '${f.minF0.toStringAsFixed(1)} Hz', Icons.arrow_downward),
        _buildFeatureCard('Max F0', '${f.maxF0.toStringAsFixed(1)} Hz', Icons.arrow_upward),
        _buildFeatureCard('Mean Energy', f.meanEnergy.toStringAsFixed(4), Icons.battery_full),
        _buildFeatureCard('STD Energy', f.stdEnergy.toStringAsFixed(4), Icons.battery_charging_full),
        _buildFeatureCard('Dynamic Range', f.dynamicRange.toStringAsFixed(4), Icons.straighten),
        _buildFeatureCard('Syllables/sec', f.syllablesPerSec.toStringAsFixed(2), Icons.speed),
        _buildFeatureCard('Words/sec', f.wordsPerSec.toStringAsFixed(2), Icons.record_voice_over),
        _buildFeatureCard('Pause Count', f.pauseCount.toString(), Icons.pause_circle_outline),
        _buildFeatureCard('Total Pause Duration', '${f.totalPauseDuration.toStringAsFixed(2)}s', Icons.timer),
        _buildFeatureCard('Pause Ratio', f.pauseRatio.toStringAsFixed(3), Icons.pie_chart),
        ...List.generate(
          13,
          (i) => _buildFeatureCard('MFCC${i + 1} Mean', f.mfccFeatures[i * 2].toStringAsFixed(2), Icons.graphic_eq),
        ),
        ...List.generate(
          13,
          (i) => _buildFeatureCard('MFCC${i + 1} STD', f.mfccFeatures[i * 2 + 1].toStringAsFixed(2), Icons.bar_chart),
        ),
        _buildFeatureCard('Spectral Centroid Mean', '${f.spectralCentroidMean.toStringAsFixed(1)} Hz', Icons.brightness_medium),
        _buildFeatureCard('Spectral Centroid STD', '${f.spectralCentroidStd.toStringAsFixed(1)} Hz', Icons.brightness_auto),
        _buildFeatureCard('Spectral Bandwidth Mean', '${f.spectralBandwidthMean.toStringAsFixed(1)} Hz', Icons.settings_ethernet),
        _buildFeatureCard('Spectral Bandwidth STD', '${f.spectralBandwidthStd.toStringAsFixed(1)} Hz', Icons.device_hub),
      ],
    );
  }

  Widget _buildLinguisticFeatures(Session session) {
    final f = session.linguisticFeatures;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildFeatureCard('Total Tokens', f.totalTokens.toString(), Icons.confirmation_number),
        _buildFeatureCard('Unique Tokens', f.uniqueTokens.toString(), Icons.stars),
        _buildFeatureCard('Type-Token Ratio', f.typeTokenRatio.toStringAsFixed(3), Icons.functions),
        _buildFeatureCard('Mean Words/Utterance', f.meanWordsPerUtterance.toStringAsFixed(1), Icons.short_text),
        _buildFeatureCard('Max Utterance Length', f.maxUtteranceLength.toString(), Icons.height),
        _buildFeatureCard('Sentence Count', f.sentenceCount.toString(), Icons.format_list_numbered),
        _buildFeatureCard('Content Words Ratio', f.contentWordsRatio.toStringAsFixed(3), Icons.article),
        _buildFeatureCard('Function Words Ratio', f.functionWordsRatio.toStringAsFixed(3), Icons.font_download),
        _buildFeatureCard('Rare Words Ratio', f.rareWordsRatio.toStringAsFixed(3), Icons.auto_awesome),
        _buildFeatureCard('Filler Count', f.fillerCount.toString(), Icons.speaker_notes_off),
        _buildFeatureCard('Repetition Score', f.repetitionScore.toStringAsFixed(3), Icons.repeat),
        _buildFeatureCard('Bigram Repetition', f.bigramRepetitionRatio.toStringAsFixed(3), Icons.repeat_one),
        _buildFeatureCard('Self-Correction Count', f.selfCorrectionCount.toString(), Icons.edit),
        _buildFeatureCard('Semantic Coherence Mean', f.semanticCoherenceMean.toStringAsFixed(3), Icons.link),
        _buildFeatureCard('Coherence Variance', f.semanticCoherenceVariance.toStringAsFixed(3), Icons.scatter_plot),
      ],
    );
  }

  Widget _buildLLMScores(Session session) {
    final s = session.llmClinicalScores;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildScoreCard('Semantic Memory Degradation', s.semanticMemoryDegradation),
        _buildScoreCard('Narrative Structure Disintegration', s.narrativeStructureDisintegration),
        _buildScoreCard('Pragmatic Appropriateness', s.pragmaticAppropriateness),
        _buildScoreCard('Topic Maintenance', s.topicMaintenance),
        _buildScoreCard('Perseveration Types', s.perseverationTypes),
        _buildScoreCard('Disorientation Types', s.disorientationTypes),
        _buildScoreCard('Executive Dysfunction', s.executiveDysfunctionPatterns),
        _buildScoreCard('Abstract Reasoning', s.abstractReasoning),
        _buildScoreCard('Semantic Clustering', s.semanticClusteringVsFragmentation),
        _buildScoreCard('Emotional Appropriateness', s.emotionalAppropriateness),
        _buildScoreCard('Novel Information Content', s.novelInformationContent),
        _buildScoreCard('Ambiguity & Vagueness', s.ambiguityVagueness),
        _buildScoreCard('Instruction Following', s.instructionFollowing),
        _buildScoreCard('Logical Self-Consistency', s.logicalSelfConsistency),
        _buildScoreCard('Confabulation', s.confabulation),
        _buildScoreCard('Clinical Impression', s.clinicalImpression),
        _buildScoreCard('Error Type Classification', s.errorTypeClassification),
        _buildScoreCard('Compensation Strategies', s.compensationStrategies),
      ],
    );
  }
  Widget _buildScoreCard(String label, int score) {
    final colour = _scoreColour(score);
    return GlassmorphicCard(
      width: 280,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.cardText, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('$score', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colour)),
              const Text('/4', style: TextStyle(fontSize: 20, color: Colors.grey)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colour.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colour.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _scoreLabel(score),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colour),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(colour),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColour(int score) {
    if (score >= 3) return AppColors.success;
    if (score >= 2) return AppColors.warning;
    return AppColors.danger;
  }

  String _scoreLabel(int score) {
    if (score >= 3) return 'Good';
    if (score >= 2) return 'Fair';
    if (score >= 1) return 'Poor';
    return 'Critical';
  }
}