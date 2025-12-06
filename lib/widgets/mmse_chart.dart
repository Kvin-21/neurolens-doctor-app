import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Interactive line chart showing MMSE score trends over time.
class MMSEChart extends StatefulWidget {
  final List<Session> sessions;

  const MMSEChart({super.key, required this.sessions});

  @override
  State<MMSEChart> createState() => _MMSEChartState();
}

class _MMSEChartState extends State<MMSEChart> {
  int _selectedRangeIndex = 3; // Default to 'All'

  List<Session> get _filteredSessions {
    if (widget.sessions.isEmpty) return [];

    final sorted = List<Session>.from(widget.sessions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final days = AppConstants.timeRanges[_selectedRangeIndex];
    if (days == -1) return sorted;

    final cutoff = DateTime.now().subtract(Duration(days: days));
    return sorted.where((s) => s.timestamp.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _filteredSessions;

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MMSE Score Over Time',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.cardText,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              _buildTimeRangeSelector(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: sessions.isEmpty
                ? Center(
                    child: Text(
                      'No data available for selected time range',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.cardText.withValues(alpha: 0.5),
                          ),
                    ),
                  )
                : _buildChart(sessions),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      children: List.generate(
        AppConstants.timeRangeLabels.length,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: InkWell(
            onTap: () => setState(() => _selectedRangeIndex = index),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: _selectedRangeIndex == index ? AppColors.primaryGradient : null,
                color: _selectedRangeIndex == index ? null : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppConstants.timeRangeLabels[index],
                style: TextStyle(
                  color: _selectedRangeIndex == index ? Colors.white : AppColors.cardText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<Session> sessions) {
    final spots = sessions.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.mmseScore.toDouble());
    }).toList();

    final verticalInterval = sessions.length > 10 ? sessions.length / 10 : 1.0;
    final bottomInterval = sessions.length > 10 ? sessions.length / 5 : 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: verticalInterval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.cardText.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (_) => FlLine(
            color: AppColors.cardText.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 5,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: TextStyle(color: AppColors.cardText.withValues(alpha: 0.6), fontSize: 12),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: bottomInterval,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= sessions.length) return const SizedBox.shrink();

                final date = sessions[idx].timestamp;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MMM d').format(date),
                    style: TextStyle(color: AppColors.cardText.withValues(alpha: 0.6), fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.cardText.withValues(alpha: 0.1)),
        ),
        minX: 0,
        maxX: (sessions.length - 1).toDouble(),
        minY: 0,
        maxY: 30,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: AppColors.primaryGradient,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.getMMSEColour(spot.y.toInt()),
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryStart.withValues(alpha: 0.3),
                  AppColors.primaryStart.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppColors.primaryEnd,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final session = sessions[spot.x.toInt()];
                final date = DateFormat('dd MMM yyyy').format(session.timestamp);
                return LineTooltipItem(
                  'MMSE: ${spot.y.toInt()}/30\n$date',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}