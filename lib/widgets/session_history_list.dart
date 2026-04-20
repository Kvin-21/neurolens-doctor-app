import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/sgt.dart';

class SessionHistoryList extends StatelessWidget {
  static const _maxDisplayed = 10;

  final List<Session> sessions;

  const SessionHistoryList({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return GlassmorphicCard(
        child: Center(
          child: Text(
            'No session history',
            style: TextStyle(color: AppColors.cardText.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    final sorted = List<Session>.from(sessions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final displayed = sorted.take(_maxDisplayed).toList();

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Session History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.cardText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayed.length,
            separatorBuilder: (_, __) => Divider(
              height: 24,
              color: AppColors.cardText.withValues(alpha: 0.1),
            ),
            itemBuilder: (_, index) => _buildSessionTile(context, displayed[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, Session session) {
    final colour = AppColors.getMMSEColour(session.mmseScore);
    final formattedDate = formatSGT(session.timestamp);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _showSessionDetail(context, session),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colour, colour.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  session.mmseScore.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formattedDate,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.cardText),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colour.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colour.withValues(alpha: 0.3)),
              ),
              child: Text(
                session.diagnosisProbabilities.getSeverity(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colour),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDetail(BuildContext context, Session session) {
    final colour = AppColors.getMMSEColour(session.mmseScore);
    final probs = session.diagnosisProbabilities;
    final severity = session.severityEstimate;
    final acoustic = session.acousticFeatures;
    final linguistic = session.linguisticFeatures;
    final clinical = session.llmClinicalScores;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [colour, colour.withValues(alpha: 0.7)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          session.mmseScore.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatSGT(session.timestamp),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.cardText),
                          ),
                          Text(
                            'MMSE ${session.mmseScore}/30 ± ${severity.uncertainty}',
                            style: TextStyle(fontSize: 14, color: AppColors.cardText.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailSection('Classification', [
                          _detailRow('Severity', probs.getSeverity()),
                          _detailRow('HC', '${(probs.hc * 100).toStringAsFixed(1)}%'),
                          _detailRow('MCI', '${(probs.mci * 100).toStringAsFixed(1)}%'),
                          _detailRow('AD', '${(probs.ad * 100).toStringAsFixed(1)}%'),
                        ]),
                        _detailSection('Acoustic Features', [
                          _detailRow('Speech Rate', '${acoustic.wordsPerSec.toStringAsFixed(2)} w/s'),
                          _detailRow('Mean Pitch', '${acoustic.meanF0.toStringAsFixed(1)} Hz'),
                          _detailRow('Pause Count', acoustic.pauseCount.toString()),
                          _detailRow('Pause Ratio', acoustic.pauseRatio.toStringAsFixed(3)),
                        ]),
                        _detailSection('Linguistic Features', [
                          _detailRow('Total Tokens', linguistic.totalTokens.toString()),
                          _detailRow('Type-Token Ratio', linguistic.typeTokenRatio.toStringAsFixed(3)),
                          _detailRow('Filler Count', linguistic.fillerCount.toString()),
                          _detailRow('Repetition', linguistic.repetitionScore.toStringAsFixed(3)),
                          _detailRow('Coherence', linguistic.semanticCoherenceMean.toStringAsFixed(3)),
                          _detailRow('Sentence Count', linguistic.sentenceCount.toString()),
                        ]),
                        _detailSection('LLM Clinical Scores', [
                          _detailRow('Clinical Impression', '${clinical.clinicalImpression}/4'),
                          _detailRow('Semantic Memory', '${clinical.semanticMemoryDegradation}/4'),
                          _detailRow('Narrative Structure', '${clinical.narrativeStructureDisintegration}/4'),
                          _detailRow('Executive Dysfunction', '${clinical.executiveDysfunctionPatterns}/4'),
                          _detailRow('Abstract Reasoning', '${clinical.abstractReasoning}/4'),
                          _detailRow('Instruction Following', '${clinical.instructionFollowing}/4'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryStart),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.cardText.withValues(alpha: 0.7))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.cardText)),
        ],
      ),
    );
  }
}