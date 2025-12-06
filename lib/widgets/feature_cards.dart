import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../models/session_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Summary cards for acoustic, linguistic, and assessment data.
class FeatureCards extends StatelessWidget {
  final Patient patient;

  const FeatureCards({super.key, required this.patient});

  Session? get _latestSession {
    if (patient.sessions.isEmpty) return null;
    return patient.sessions.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final session = _latestSession;
    if (session == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(child: _buildAcousticCard(session)),
        const SizedBox(width: AppConstants.gridSpacing),
        Expanded(child: _buildLinguisticCard(session)),
        const SizedBox(width: AppConstants.gridSpacing),
        Expanded(child: _buildSeverityCard(session)),
      ],
    );
  }

  Widget _buildAcousticCard(Session session) {
    final a = session.acousticFeatures;
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('Acoustic Summary', Icons.graphic_eq),
          const SizedBox(height: 16),
          _buildMetricRow('Speech Rate', '${a.wordsPerSec.toStringAsFixed(1)} w/s'),
          _buildMetricRow('Pause Count', a.pauseCount.toString()),
          _buildMetricRow('Mean Pitch', '${a.meanF0.toStringAsFixed(0)} Hz'),
        ],
      ),
    );
  }

  Widget _buildLinguisticCard(Session session) {
    final l = session.linguisticFeatures;
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('Linguistic Summary', Icons.text_fields),
          const SizedBox(height: 16),
          _buildMetricRow('Total Tokens', l.totalTokens.toString()),
          _buildMetricRow('Type-Token Ratio', l.typeTokenRatio.toStringAsFixed(2)),
          _buildMetricRow('Filler Count', l.fillerCount.toString()),
        ],
      ),
    );
  }

  Widget _buildSeverityCard(Session session) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('Assessment Summary', Icons.assessment),
          const SizedBox(height: 16),
          _buildMetricRow('MMSE Score', '${session.mmseScore}/30'),
          _buildMetricRow('Uncertainty', session.severityEstimate.uncertainty.toString()),
          _buildMetricRow('Classification', session.diagnosisProbabilities.getSeverity()),
        ],
      ),
    );
  }

  Widget _buildCardHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cardText),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.cardText.withValues(alpha: 0.7))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.cardText)),
        ],
      ),
    );
  }
}