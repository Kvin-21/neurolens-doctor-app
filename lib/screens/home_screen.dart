import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../utils/constants.dart';
import 'patient_dashboard_screen.dart';
import 'add_patient_dialog.dart';

/// Main application screen with patient selection and dashboard.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Consumer<PatientProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (!provider.hasPatients || provider.selectedPatient == null) {
                      return _buildEmptyState(context);
                    }

                    return PatientDashboardScreen(patient: provider.selectedPatient!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          Consumer<PatientProvider>(
            builder: (context, provider, _) {
              if (!provider.hasPatients) return const SizedBox.shrink();

              return Row(
                children: [
                  _buildPatientSelector(context, provider),
                  const SizedBox(width: 16),
                  _buildRemovePatientButton(context, provider),
                  const SizedBox(width: 16),
                  _buildRefreshButton(provider),
                ],
              );
            },
          ),
          const SizedBox(width: 16),
          _buildAddPatientButton(context),
        ],
      ),
    );
  }

  Widget _buildPatientSelector(BuildContext context, PatientProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
      child: DropdownButton<String>(
        value: provider.selectedPatient?.patientId,
        dropdownColor: AppColors.primaryEnd,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        items: provider.patients.map((patient) {
          return DropdownMenuItem<String>(
            value: patient.patientId,
            child: Text(
              '${patient.displayName} (${patient.patientId})',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (patientId) {
          if (patientId != null) provider.selectPatient(patientId);
        },
      ),
    );
  }

  Widget _buildRemovePatientButton(BuildContext context, PatientProvider provider) {
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
        onPressed: () => _showRemovePatientDialog(context, provider),
        icon: const Icon(Icons.person_remove, color: Colors.white),
        tooltip: 'Remove Patient',
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

  void _showAddPatientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddPatientDialog(
        onAdd: (patientId, displayName) async {
          final provider = Provider.of<PatientProvider>(context, listen: false);
          await provider.addPatient(patientId, displayName);
        },
      ),
    );
  }

  void _showRemovePatientDialog(BuildContext context, PatientProvider provider) {
    final patient = provider.selectedPatient;
    if (patient == null) return;

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
