import 'package:flutter/material.dart';
import '../services/security_service.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';

enum _DialogStep { patientId, password, displayName }

/// Multi-step dialog for adding a new patient with password verification.
class AddPatientDialog extends StatefulWidget {
  final Function(String patientId, String displayName) onAdd;

  const AddPatientDialog({super.key, required this.onAdd});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  static const _validPatientIds = ['P001', 'P002', 'P003'];

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _patientIdController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _security = SecurityService();

  _DialogStep _currentStep = _DialogStep.patientId;
  bool _isLoading = false;
  String? _errorMessage;
  String _validatedPatientId = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _patientIdController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _validatePatientId() {
    final patientId = _patientIdController.text.trim().toUpperCase();

    if (patientId.isEmpty) {
      setState(() => _errorMessage = 'Please enter a Patient ID');
      return;
    }

    if (!_validPatientIds.contains(patientId)) {
      setState(() => _errorMessage = 'Invalid Patient ID. Valid IDs: P001, P002, P003');
      return;
    }

    setState(() {
      _validatedPatientId = patientId;
      _currentStep = _DialogStep.password;
      _errorMessage = null;
    });
  }

  Future<void> _verifyPassword() async {
    if (_security.isLockedOut()) {
      final remaining = _security.getRemainingLockoutSeconds();
      setState(() => _errorMessage = 'Too many failed attempts. Try again in ${remaining}s');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isValid = await _security.validatePassword(_passwordController.text);

    setState(() {
      _isLoading = false;
      if (isValid) {
        _currentStep = _DialogStep.displayName;
        _errorMessage = null;
      } else {
        final remaining = _security.getRemainingAttempts();
        _errorMessage = remaining > 0
            ? 'Invalid password. $remaining attempt(s) remaining'
            : 'Too many failed attempts. Locked out for 30s';
      }
    });
  }

  Future<void> _addPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onAdd(_validatedPatientId, _displayNameController.text.trim());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
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
      case _DialogStep.password:
        return _buildPasswordForm();
      case _DialogStep.displayName:
        return _buildDisplayNameForm();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient ID: $_validatedPatientId',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Enter password to continue:', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _verifyPassword(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
      ],
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
      case _DialogStep.password:
        return _verifyPassword;
      case _DialogStep.displayName:
        return _addPatient;
    }
  }

  String _getPrimaryButtonText() {
    switch (_currentStep) {
      case _DialogStep.patientId:
        return 'Next';
      case _DialogStep.password:
        return 'Verify';
      case _DialogStep.displayName:
        return 'Add Patient';
    }
  }
}
