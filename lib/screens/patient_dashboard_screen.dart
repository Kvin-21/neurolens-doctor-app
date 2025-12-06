import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../widgets/overview_cards.dart';
import '../widgets/mmse_chart.dart';
import '../widgets/feature_cards.dart';
import '../widgets/clinical_scores_widget.dart';
import '../widgets/session_history_list.dart';
import '../utils/constants.dart';
import 'features_screen.dart';

/// Dashboard with overview and detailed feature tabs for a patient.
class PatientDashboardScreen extends StatefulWidget {
  final Patient patient;

  const PatientDashboardScreen({super.key, required this.patient});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboard(),
              FeaturesScreen(patient: widget.patient),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverviewCards(patient: widget.patient),
          const SizedBox(height: AppConstants.gridSpacing * 3),
          MMSEChart(sessions: widget.patient.sessions),
          const SizedBox(height: AppConstants.gridSpacing * 3),
          FeatureCards(patient: widget.patient),
          const SizedBox(height: AppConstants.gridSpacing * 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SessionHistoryList(sessions: widget.patient.sessions),
              ),
              const SizedBox(width: AppConstants.gridSpacing),
              Expanded(child: ClinicalScoresWidget(patient: widget.patient)),
            ],
          ),
        ],
      ),
    );
  }
}