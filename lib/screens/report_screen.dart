import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../services/neurolens_api_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class ReportScreen extends StatefulWidget {
  final Patient patient;

  const ReportScreen({super.key, required this.patient});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final NeurolensApiService _api = NeurolensApiService();

  bool _isLoading = false;
  String? _error;
  String? _reportMarkdown;
  int _windowDays = 7;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _api.loadBaseUrl();
    await _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final markdown = await _api.fetchReport(
        patientId: widget.patient.patientId,
        windowDays: _windowDays,
      );
      setState(() {
        _reportMarkdown = markdown;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch report. Ensure the Neurolens AI server is running.';
        _isLoading = false;
      });
    }
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
      child: Column(
        children: [
          _buildControls(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Patient Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(width: 24),
          _buildDaySelector(7, '7D'),
          const SizedBox(width: 8),
          _buildDaySelector(14, '14D'),
          const SizedBox(width: 8),
          _buildDaySelector(30, '30D'),
          const SizedBox(width: 8),
          _buildDaySelector(90, '90D'),
          const Spacer(),
          IconButton(
            onPressed: _isLoading ? null : _fetchReport,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Report',
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(int days, String label) {
    final isSelected = _windowDays == days;
    return GestureDetector(
      onTap: () {
        if (_windowDays != days) {
          setState(() => _windowDays = days);
          _fetchReport();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryStart : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Generating report...',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: _fetchReport,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_reportMarkdown == null || _reportMarkdown!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(
              'No Report Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Report data is not yet available for this patient',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(28),
        child: _renderMarkdown(_reportMarkdown!),
      ),
    );
  }

  Widget _renderMarkdown(String markdown) {
    final lines = markdown.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            line.substring(2),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.cardText,
            ),
          ),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            line.substring(3),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryStart,
            ),
          ),
        ));
      } else if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            line.substring(4),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.cardText,
            ),
          ),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14, color: AppColors.cardText)),
              Expanded(
                child: _buildRichText(line.substring(2)),
              ),
            ],
          ),
        ));
      } else if (line.startsWith('---') || line.startsWith('***')) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Colors.grey.shade300),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: _buildRichText(line),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichText(String text) {
    final spans = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: AppColors.cardText, height: 1.6),
        children: spans,
      ),
    );
  }
}
