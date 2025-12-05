import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Displays key LLM clinical scores for the latest session.
class ClinicalScoresWidget extends StatelessWidget {
  final Patient patient;

  const ClinicalScoresWidget({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    if (patient.sessions.isEmpty) {
      return GlassmorphicCard(
        child: Center(
          child: Text(
            'No clinical data available',
            style: TextStyle(color: AppColors.cardText.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    final latestSession = patient.sessions.reduce(
      (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
    );
    final scores = latestSession.llmClinicalScores;

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LLM Clinical Scores',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.cardText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          _buildScoreBar('Clinical Impression', scores.clinicalImpression),
          const SizedBox(height: 12),
          _buildScoreBar('Semantic Memory', scores.semanticMemoryDegradation),
          const SizedBox(height: 12),
          _buildScoreBar('Narrative Structure', scores.narrativeStructureDisintegration),
          const SizedBox(height: 12),
          _buildScoreBar('Executive Function', scores.executiveDysfunctionPatterns),
          const SizedBox(height: 12),
          _buildScoreBar('Abstract Reasoning', scores.abstractReasoning),
          const SizedBox(height: 12),
          _buildScoreBar('Instruction Following', scores.instructionFollowing),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int score) {
    final colour = _scoreColour(score);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cardText,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colour.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$score/4',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colour),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: score / 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(colour),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _scoreColour(int score) {
    if (score >= 3) return AppColors.success;
    if (score >= 2) return AppColors.warning;
    return AppColors.danger;
  }
}