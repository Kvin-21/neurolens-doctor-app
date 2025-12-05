import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Displays the most recent assessment sessions with MMSE scores.
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
            itemBuilder: (_, index) => _buildSessionTile(displayed[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(Session session) {
    final colour = AppColors.getMMSEColour(session.mmseScore);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(session.timestamp);

    return Padding(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.sessionId,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.cardText),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: AppColors.cardText.withValues(alpha: 0.6)),
                ),
              ],
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
    );
  }
}