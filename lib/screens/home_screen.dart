import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';
import '../utils/constants.dart';
import 'patient_dashboard_screen.dart';
import 'add_patient_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Consumer<PatientProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  _buildAppBar(context, provider),
                  Expanded(child: _buildBody(context, provider)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PatientProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Loading patient data...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    if (!provider.hasPatients) {
      return _buildEmptyState(context);
    }

    return _buildHomeContent(context, provider);
  }

  Widget _buildAppBar(BuildContext context, PatientProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          if (provider.hasPatients) ...[
            _buildRefreshButton(provider),
            const SizedBox(width: 12),
            _buildAddPatientButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildRefreshButton(PatientProvider provider) {
    return Container(
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
        tooltip: 'Refresh Data',
      ),
    );
  }

  Widget _buildAddPatientButton(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryStart.withValues(alpha: 0.2),
                  AppColors.primaryEnd.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Icon(
              Icons.people_outline,
              size: 120,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to NeuroLens',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'No patients in your list yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add a patient to view their cognitive assessment data',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 48),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF3F4F6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showAddPatientDialog(context),
              icon: const Icon(Icons.person_add, size: 28),
              label: const Text(
                'Add Patient',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.primaryStart,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, PatientProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        const Color(0xFF00D9FF),
                        const Color(0xFF00F5FF),
                        const Color(0xFF00FF66),
                        const Color(0xFF00F5FF),
                        const Color(0xFF00D9FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    "Hi, how's your day?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a patient to view their summary and scores',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Expanded(child: _buildPatientList(context, provider)),
        ],
      ),
    );
  }

  Widget _buildPatientList(BuildContext context, PatientProvider provider) {
    final hasManyPatients = provider.patients.length >= 7;

    return ListView.separated(
      physics: hasManyPatients
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: provider.patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final patient = provider.patients[index];
        return _buildPatientCard(context, provider, patient);
      },
    );
  }

  Widget _buildPatientCard(BuildContext context, PatientProvider provider, Patient patient) {
    final severity = patient.getLatestSeverity();
    final mmse = patient.getLatestMMSE();
    final mmseText = mmse > 0 ? mmse.toString() : '—';

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PatientDashboardScreen(patient: patient),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cardText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${patient.patientId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.cardText.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildSeverityChip(severity),
            const SizedBox(width: 8),
            _buildMetricChip('MMSE', mmseText),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'remove') {
                  _showRemovePatientDialog(context, provider, patient);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove patient'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityChip(String severity) {
    final color = _severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        severity,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryStart.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: AppColors.primaryStart,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'HC':
        return const Color(0xFF2E8B57);
      case 'MCI':
        return const Color(0xFFD08700);
      case 'AD':
        return const Color(0xFFC0392B);
      default:
        return const Color(0xFF7F8C8D);
    }
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

  void _showRemovePatientDialog(
    BuildContext context,
    PatientProvider provider,
    Patient patient,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Patient'),
        content: Text(
          'Are you sure you want to remove ${patient.displayName} (${patient.patientId})?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.removePatient(patient.patientId);
              if (context.mounted) Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}