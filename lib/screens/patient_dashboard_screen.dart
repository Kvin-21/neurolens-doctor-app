import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';
import '../widgets/overview_cards.dart';
import '../widgets/mmse_chart.dart';
import '../widgets/feature_cards.dart';
import '../widgets/clinical_scores_widget.dart';
import '../widgets/session_history_list.dart';
import '../utils/constants.dart';
import 'add_patient_dialog.dart';
import 'features_screen.dart';
import 'report_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  final Patient patient;

  const PatientDashboardScreen({super.key, required this.patient});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedRangeIndex = 3;

  int? get _selectedDays {
    final days = AppConstants.timeRanges[_selectedRangeIndex];
    return days == -1 ? null : days;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Column(
              key: ValueKey(widget.patient.patientId),
              children: [
                _buildTopBar(context),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboard(),
                      FeaturesScreen(patient: widget.patient),
                      ReportScreen(patient: widget.patient),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final provider = context.watch<PatientProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Text(
            AppConstants.appTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home, color: Colors.white, size: 20),
              tooltip: 'Back to home',
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh data',
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF3F4F6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showAddPatientDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Patient', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.primaryStart,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddPatientDialog(
        onAdd: (patientId, displayName, {String? existingPassword}) async {
          final provider = Provider.of<PatientProvider>(context, listen: false);
          await provider.addPatient(patientId, displayName, existingPassword: existingPassword);
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Material(
      color: Colors.transparent,
      child: Container(
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
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.primaryStart,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.9),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Detailed Features'),
            Tab(text: 'Reports'),
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
          OverviewCards(patient: widget.patient, trendDays: _selectedDays),
          const SizedBox(height: AppConstants.gridSpacing * 3),
          MMSEChart(
            sessions: widget.patient.sessions,
            initialRangeIndex: _selectedRangeIndex,
            onRangeChanged: (index) => setState(() => _selectedRangeIndex = index),
          ),
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