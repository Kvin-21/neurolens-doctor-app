import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Top-level summary cards showing MMSE, severity, session count, and trend.
class OverviewCards extends StatelessWidget {
  final Patient patient;

  const OverviewCards({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final latestDate = patient.getLatestSessionDate();
    final formattedDate = latestDate != null ? DateFormat('dd MMM yyyy').format(latestDate) : 'N/A';

    return Row(
      children: [
        Expanded(child: _buildMMSECard(context)),
        const SizedBox(width: AppConstants.gridSpacing),
        Expanded(child: _buildSeverityCard(context)),
        const SizedBox(width: AppConstants.gridSpacing),
        Expanded(child: _buildSessionsCard(context, formattedDate)),
        const SizedBox(width: AppConstants.gridSpacing),
        Expanded(child: _buildTrendCard(context)),
      ],
    );
  }

  Widget _buildMMSECard(BuildContext context) {
    final mmse = patient.getLatestMMSE();
    final colour = AppColors.getMMSEColour(mmse);

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MMSE Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.cardText,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                mmse.toString(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: colour,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '/ 30',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.cardText.withValues(alpha: 0.6),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityCard(BuildContext context) {
    final severity = patient.getLatestSeverity();
    final probs = patient.getLatestDiagnosisProbabilities();

    final severityColour = switch (severity) {
      'HC' => AppColors.success,
      'MCI' => AppColors.warning,
      'AD' => AppColors.danger,
      _ => AppColors.cardText,
    };

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Severity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.cardText,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            severity,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: severityColour,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
          ),
          if (probs != null) ...[
            const SizedBox(height: 8),
            Text(
              'HC: ${(probs.hc * 100).toStringAsFixed(0)}% | MCI: ${(probs.mci * 100).toStringAsFixed(0)}% | AD: ${(probs.ad * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.cardText.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsCard(BuildContext context, String formattedDate) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Sessions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.cardText,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            patient.getTotalSessions().toString(),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.primaryStart,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Latest: $formattedDate',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.cardText.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(BuildContext context) {
    final trend = patient.getTrendIndicator();

    final (trendColour, trendText) = switch (trend) {
      '↑' => (AppColors.success, 'Improving'),
      '↓' => (AppColors.danger, 'Declining'),
      _ => (AppColors.warning, 'Stable'),
    };

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.cardText,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                trend,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: trendColour,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                trendText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: trendColour,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}