import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../models/patient_model.dart';
import '../services/neurolens_api_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class ImageScreen extends StatefulWidget {
  final Patient patient;

  const ImageScreen({super.key, required this.patient});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final NeurolensApiService _api = NeurolensApiService();
  static const _secure = FlutterSecureStorage();

  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAuthenticated = false;
  String? _error;
  List<ImageSummary> _summaries = [];

  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _api.loadBaseUrl();
    _urlController.text = _api.baseUrl;
    final token = await _secure.read(key: 'ngrok_tok_${widget.patient.patientId}');
    if (token != null && token.isNotEmpty) {
      setState(() => _isAuthenticated = true);
      await _loadSummaries();
    }
  }

  Future<void> _login() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _error = 'Please enter the caregiver password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _api.login(
        patientId: widget.patient.patientId,
        password: password,
        role: 'caregiver',
      );
      await _secure.write(
        key: 'ngrok_tok_${widget.patient.patientId}',
        value: result.accessToken,
      );
      await _secure.write(
        key: 'ngrok_rt_${widget.patient.patientId}',
        value: result.refreshToken,
      );
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      _passwordController.clear();
      await _loadSummaries();
    } catch (e) {
      setState(() {
        _error = 'Login failed. Check the server URL and credentials.';
        _isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    var token = await _secure.read(key: 'ngrok_tok_${widget.patient.patientId}');
    if (token == null) return null;
    return token;
  }

  Future<void> _loadSummaries() async {
    final token = await _getToken();
    if (token == null) return;

    setState(() => _isLoading = true);

    try {
      final summaries = await _api.fetchImageSummaries(token: token);
      setState(() {
        _summaries = summaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load summaries';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    Uint8List? bytes;
    if (file.bytes != null) {
      bytes = file.bytes!;
    } else if (file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }

    if (bytes == null) {
      setState(() => _error = 'Could not read selected file');
      return;
    }

    final token = await _getToken();
    if (token == null) {
      setState(() {
        _isAuthenticated = false;
        _error = 'Session expired. Please log in again.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final newSummaries = await _api.uploadImages(
        token: token,
        images: [(filename: file.name, bytes: bytes)],
      );
      setState(() {
        _summaries.insertAll(0, newSummaries);
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Upload failed. Check the server connection.';
        _isUploading = false;
      });
    }
  }

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    await _api.setBaseUrl(url);
    setState(() => _showSettings = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryStart.withValues(alpha: 0.08),
            AppColors.primaryEnd.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: _isAuthenticated ? _buildMainContent() : _buildLoginForm(),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStart.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_search, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Connect to Neurolens AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cardText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Server URL (ngrok)',
                hintText: 'https://xxxx.ngrok-free.app',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.link),
              ),
              onSubmitted: (_) => _saveUrl(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _saveUrl,
                child: const Text('Save URL'),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Caregiver Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: true,
              onSubmitted: (_) => _login(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Connect', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickAndUploadImage,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add_photo_alternate),
                  label: Text(_isUploading ? 'Processing...' : 'Upload Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _loadSummaries,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Refresh',
              ),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _showSettings = !_showSettings),
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: 'Settings',
              ),
            ],
          ),
        ),
        if (_showSettings)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'ngrok URL',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _saveUrl,
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () async {
                    await _secure.delete(key: 'ngrok_tok_${widget.patient.patientId}');
                    await _secure.delete(key: 'ngrok_rt_${widget.patient.patientId}');
                    setState(() {
                      _isAuthenticated = false;
                      _summaries = [];
                    });
                  },
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
                    onPressed: () => setState(() => _error = null),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _summaries.isEmpty
                  ? _buildEmptyState()
                  : _buildSummariesList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(
            'No Image Summaries',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload an image to generate an AI summary',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummariesList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _summaries.length,
      itemBuilder: (context, index) {
        final summary = _summaries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassmorphicCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Image #${summary.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cardText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      summary.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  summary.summary,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.cardText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
