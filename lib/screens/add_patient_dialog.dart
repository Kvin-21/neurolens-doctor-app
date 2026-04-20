import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';

enum _DialogStep { patientId, displayName, password }

/// Multi-step dialog for registering a new patient via the backend.
///
/// The doctor enters a patient ID; the backend creates the account and returns
/// one-time credentials (password + result key) which are stored securely.
/// The generated password should be shared with the patient for their login.
class AddPatientDialog extends StatefulWidget {
  final Function(String patientId, String displayName, {String? existingPassword}) onAdd;

  const AddPatientDialog({super.key, required this.onAdd});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  _DialogStep _currentStep = _DialogStep.patientId;
  bool _isLoading = false;
  String? _errorMessage;
  String _validatedPatientId = '';

  @override
  void dispose() {
    _patientIdController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePatientId() {
    final patientId = _patientIdController.text.trim().toUpperCase();

    if (patientId.isEmpty) {
      setState(() => _errorMessage = 'Please enter a Patient ID');
      return;
    }

    if (patientId.length < 3) {
      setState(() => _errorMessage = 'Patient ID must be at least 3 characters');
      return;
    }

    setState(() {
      _validatedPatientId = patientId;
      _currentStep = _DialogStep.displayName;
      _errorMessage = null;
    });
  }

  Future<void> _addPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final existingPassword = _currentStep == _DialogStep.password
          ? _passwordController.text.trim()
          : null;
      await widget.onAdd(
        _validatedPatientId,
        _displayNameController.text.trim(),
        existingPassword: existingPassword,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg == 'existing_patient_needs_password' && _currentStep == _DialogStep.displayName) {
        setState(() {
          _currentStep = _DialogStep.password;
          _errorMessage = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = msg;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.primaryStart.withValues(alpha: 0.05)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        padding: const EdgeInsets.all(24),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Patient',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.cardText,
                  ),
            ),
            const SizedBox(height: 24),
            _buildStepContent(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case _DialogStep.patientId:
        return _buildPatientIdForm();
      case _DialogStep.displayName:
        return _buildDisplayNameForm();
      case _DialogStep.password:
        return _buildPasswordForm();
    }
  }

  Widget _buildPatientIdForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter Patient ID:', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        TextField(
          controller: _patientIdController,
          decoration: InputDecoration(
            labelText: 'Patient ID',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.characters,
          onSubmitted: (_) => _validatePatientId(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient ID: $_validatedPatientId',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This patient already exists. Enter their password to authenticate:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Patient Password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            obscureText: true,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Password is required' : null,
            onFieldSubmitted: (_) => _addPatient(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildDisplayNameForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient ID: $_validatedPatientId',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Enter display name:', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _displayNameController,
            decoration: InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: Validators.validateDisplayName,
            onFieldSubmitted: (_) => _addPatient(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _getPrimaryAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_getPrimaryButtonText()),
          ),
        ),
      ],
    );
  }

  VoidCallback? _getPrimaryAction() {
    switch (_currentStep) {
      case _DialogStep.patientId:
        return _validatePatientId;
      case _DialogStep.displayName:
        return _addPatient;
      case _DialogStep.password:
        return _addPatient;
    }
  }

  String _getPrimaryButtonText() {
    switch (_currentStep) {
      case _DialogStep.patientId:
        return 'Next';
      case _DialogStep.displayName:
        return 'Add Patient';
      case _DialogStep.password:
        return 'Add Patient';
    }
  }
}
