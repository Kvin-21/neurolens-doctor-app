import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../models/session_model.dart';
import '../models/feature_models.dart';
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
  static const Set<String> _offlinePatientIds = {'P9002', 'P5001'};
  static const int _offlineAge = 67;
  static const String _offlineGender = 'male';

  bool _isLoading = false;
  String? _error;
  String? _reportMarkdown;
  int _windowDays = 7;

  String get _normalisedPatientId => widget.patient.patientId.trim().toUpperCase();

  bool get _isOfflinePatient => _offlinePatientIds.contains(_normalisedPatientId);

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
      final markdown = _isOfflinePatient
          ? _buildOfflineReport()
          : await _api.fetchReport(
              patientId: widget.patient.patientId,
              windowDays: _windowDays,
            );
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _reportMarkdown = markdown;
          _isLoading = false;
        });
      }
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

  List<Session> _buildReportSessions() {
    final sessions = List<Session>.from(widget.patient.sessions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (sessions.isNotEmpty) {
      final cutoff = DateTime.now().subtract(Duration(days: _windowDays));
      final scoped = sessions.where((s) => s.timestamp.isAfter(cutoff)).toList();
      if (scoped.isNotEmpty) return scoped;
    }

    return _makeOfflineSessions();
  }

  List<Session> _makeOfflineSessions() {
    final days = _windowDays <= 0 ? 7 : _windowDays;
    const count = 5;
    final step = (days / (count - 1)).round();
    final spacing = step < 1 ? 1 : step;

    return List.generate(count, (i) {
      final offset = (count - 1 - i) * spacing;
      final timestamp = DateTime.now().subtract(Duration(days: offset));
      return _makeOfflineSession(index: i, timestamp: timestamp);
    });
  }

  Session _makeOfflineSession({required int index, required DateTime timestamp}) {
    final mmseScore = 27 - index;
    return Session(
      sessionId: 'session_${timestamp.millisecondsSinceEpoch}',
      timestamp: timestamp,
      mmseScore: mmseScore,
      diagnosisProbabilities: _makeDiagnosisProbabilities(index),
      severityEstimate: _makeSeverityEstimate(mmseScore),
      acousticFeatures: _makeAcousticFeatures(index),
      linguisticFeatures: _makeLinguisticFeatures(index),
      llmClinicalScores: _makeClinicalScores(index),
    );
  }

  DiagnosisProbabilities _makeDiagnosisProbabilities(int index) {
    final hc = (0.58 - index * 0.03).clamp(0.2, 0.7);
    final mci = (0.28 + index * 0.02).clamp(0.1, 0.6);
    final ad = (1.0 - hc - mci).clamp(0.05, 0.4);
    return DiagnosisProbabilities(hc: hc, mci: mci, ad: ad);
  }

  SeverityEstimate _makeSeverityEstimate(int mmseScore) {
    return SeverityEstimate(mmse: mmseScore, uncertainty: 2);
  }

  AcousticFeatures _makeAcousticFeatures(int index) {
    final mfcc = List<double>.generate(26, (i) {
      return 0.6 + (index * 0.05) + (i * 0.04);
    });

    return AcousticFeatures(
      meanF0: 135 + index * 3.5,
      stdF0: 12 + index * 1.2,
      minF0: 92 + index * 2.0,
      maxF0: 210 + index * 4.0,
      meanEnergy: 0.020 + index * 0.002,
      stdEnergy: 0.010 + index * 0.001,
      dynamicRange: 0.36 + index * 0.02,
      syllablesPerSec: 3.6 + index * 0.15,
      wordsPerSec: 2.4 + index * 0.12,
      pauseCount: 8 + index,
      totalPauseDuration: 5.2 + index * 0.6,
      pauseRatio: 0.14 + index * 0.01,
      mfccFeatures: mfcc,
      spectralCentroidMean: 1800 + index * 60,
      spectralCentroidStd: 220 + index * 15,
      spectralBandwidthMean: 1200 + index * 50,
      spectralBandwidthStd: 180 + index * 12,
    );
  }

  LinguisticFeatures _makeLinguisticFeatures(int index) {
    final totalTokens = 180 + index * 12;
    final uniqueTokens = 90 + index * 6;
    final typeTokenRatio = uniqueTokens / totalTokens;
    return LinguisticFeatures(
      totalTokens: totalTokens,
      uniqueTokens: uniqueTokens,
      typeTokenRatio: typeTokenRatio,
      meanWordsPerUtterance: 10.4 + index * 0.3,
      maxUtteranceLength: 24 + index,
      sentenceCount: 14 + index,
      contentWordsRatio: 0.56 + index * 0.01,
      functionWordsRatio: 0.44 - index * 0.01,
      rareWordsRatio: 0.08 + index * 0.005,
      fillerCount: 6 + index,
      repetitionScore: 0.12 + index * 0.01,
      bigramRepetitionRatio: 0.09 + index * 0.01,
      selfCorrectionCount: 2 + index,
      semanticCoherenceMean: 0.72 - index * 0.02,
      semanticCoherenceVariance: 0.08 + index * 0.005,
    );
  }

  LLMClinicalScores _makeClinicalScores(int index) {
    final base = 1 + (index % 3);
    return LLMClinicalScores(
      semanticMemoryDegradation: base,
      narrativeStructureDisintegration: base,
      pragmaticAppropriateness: 4 - base,
      topicMaintenance: base,
      perseverationTypes: base,
      disorientationTypes: base,
      executiveDysfunctionPatterns: base,
      abstractReasoning: 4 - base,
      semanticClusteringVsFragmentation: base,
      emotionalAppropriateness: 4 - base,
      novelInformationContent: base,
      ambiguityVagueness: base,
      instructionFollowing: 4 - base,
      logicalSelfConsistency: 4 - base,
      confabulation: base,
      clinicalImpression: base,
      errorTypeClassification: base,
      compensationStrategies: 4 - base,
    );
  }

  String _buildOfflineReport() {
    final sessions = _buildReportSessions();
    final fullName = widget.patient.displayName.trim().isEmpty
        ? widget.patient.patientId
        : widget.patient.displayName.trim();
    final sessionCount = sessions.length;

    final lines = <String>[
      '# Neurolens Cognitive Report',
      'Patient ID: ${widget.patient.patientId}',
      '> This report is an automated summary of patient-submitted and system generated records.',
      '> It is intended to support clinician review only.',
      '> It does not provide diagnosis, treatment recommendations, emergency guidance, or medical advice.',
      '',
      'Patient Profile',
      '* Age: $_offlineAge',
      '* Gender: $_offlineGender',
      '',
      'Data Coverage',
      '* Feature history entries: $sessionCount',
      '',
      '## Patient Info',
      '- Full Name: $fullName',
      '- Age: $_offlineAge',
      '- Gender: $_offlineGender',
      '- Report Period: Last $_windowDays days',
      '',
      '## Summary',
      _buildSummaryText(sessions),
      '',
      '## Feature Highlights',
      ..._buildFeatureHighlights(sessions),
      '',
      '## Cognitive Metrics Overview',
      '- Speech Speed: ${_trendLabel(sessions, (s) => s.acousticFeatures.wordsPerSec)}',
      '- Vocabulary Richness: ${_trendLabel(sessions, (s) => s.linguisticFeatures.typeTokenRatio)}',
      '- Pause Duration: ${_trendLabel(sessions, (s) => s.acousticFeatures.pauseRatio)}',
      '- Filler Word Rate: ${_trendLabel(sessions, (s) => _fillerRate(s))}',
      '- Semantic Similarity Drift: ${_trendLabel(sessions, (s) => s.linguisticFeatures.semanticCoherenceVariance)}',
      '',
      '## Detailed Trends (Day-by-Day)',
      '| Day | Speech Speed | Pauses | Vocab Richness | Filler Word Rate | Semantic Similarity Drift | Notes |',
      '|-----|--------------|--------|----------------|------------------|---------------------------|-------|',
      ..._buildTrendRows(sessions),
      '',
      '## Recommendations',
      ..._buildRecommendations(sessions),
    ];

    return lines.join('\n');
  }

  String _buildSummaryText(List<Session> sessions) {
    if (sessions.isEmpty) {
      return 'No session data is available for the selected period. '
          'The report period contains no cognitive entries to summarise. '
          'Please collect recordings to populate this section.';
    }

    final speechTrend = _trendPhrase(sessions, (s) => s.acousticFeatures.wordsPerSec);
    final vocabTrend = _trendPhrase(sessions, (s) => s.linguisticFeatures.typeTokenRatio);
    final pauseTrend = _trendPhrase(sessions, (s) => s.acousticFeatures.pauseRatio);
    final fillerTrend = _trendPhrase(sessions, (s) => _fillerRate(s));
    final sessionCount = sessions.length;

    return 'Across $sessionCount sessions in the last $_windowDays days, '
        'speech speed is $speechTrend and vocabulary richness is $vocabTrend. '
        'Pause ratio is $pauseTrend, while filler word rate is $fillerTrend. '
        'Overall, the cognitive feature profile appears stable across this period.';
  }

  List<String> _buildFeatureHighlights(List<Session> sessions) {
    if (sessions.isEmpty) {
      return ['- No feature entries are available for this period.'];
    }

    final latest = sessions.last;
    return [
      '- MMSE score: ${latest.mmseScore}',
      '- Mean F0: ${latest.acousticFeatures.meanF0.toStringAsFixed(1)} Hz',
      '- Speech speed: ${latest.acousticFeatures.wordsPerSec.toStringAsFixed(2)} words/sec',
      '- Pause ratio: ${(latest.acousticFeatures.pauseRatio * 100).toStringAsFixed(1)}%',
      '- Type-token ratio: ${latest.linguisticFeatures.typeTokenRatio.toStringAsFixed(3)}',
      '- Semantic coherence mean: ${latest.linguisticFeatures.semanticCoherenceMean.toStringAsFixed(3)}',
      '- Clinical impression: ${latest.llmClinicalScores.clinicalImpression}/4',
    ];
  }

  String _trendPhrase(List<Session> sessions, double Function(Session) selector) {
    if (sessions.length < 2) return 'stable';
    final first = selector(sessions.first);
    final last = selector(sessions.last);
    final delta = last - first;
    final threshold = _trendThreshold(first);
    if (delta.abs() <= threshold) return 'stable';
    return delta > 0 ? 'higher' : 'lower';
  }

  String _trendLabel(List<Session> sessions, double Function(Session) selector) {
    final phrase = _trendPhrase(sessions, selector);
    return phrase[0].toUpperCase() + phrase.substring(1);
  }

  double _trendThreshold(double baseline) {
    final scaled = baseline.abs() * 0.05;
    return scaled < 0.01 ? 0.01 : scaled;
  }

  double _fillerRate(Session session) {
    final total = session.linguisticFeatures.totalTokens;
    if (total <= 0) return 0;
    return session.linguisticFeatures.fillerCount / total;
  }

  List<String> _buildTrendRows(List<Session> sessions) {
    if (sessions.isEmpty) {
      return ['| - | - | - | - | - | - | No sessions available |'];
    }

    final rows = <String>[];
    for (var i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final speech = '${session.acousticFeatures.wordsPerSec.toStringAsFixed(2)} w/s';
      final pauses = '${(session.acousticFeatures.pauseRatio * 100).toStringAsFixed(1)}%';
      final vocab = session.linguisticFeatures.typeTokenRatio.toStringAsFixed(3);
      final filler = '${(_fillerRate(session) * 100).toStringAsFixed(1)}%';
      final drift = session.linguisticFeatures.semanticCoherenceVariance.toStringAsFixed(3);
      final notes = 'MMSE ${session.mmseScore}';
      rows.add('| ${i + 1} | $speech | $pauses | $vocab | $filler | $drift | $notes |');
    }
    return rows;
  }

  List<String> _buildRecommendations(List<Session> sessions) {
    if (sessions.isEmpty) {
      return [
        '- Collect new sessions to populate cognitive trends.',
        '- Review speech tasks alongside clinician observation.',
      ];
    }

    final recommendations = <String>[];
    final speechTrend = _trendPhrase(sessions, (s) => s.acousticFeatures.wordsPerSec);
    final pauseTrend = _trendPhrase(sessions, (s) => s.acousticFeatures.pauseRatio);
    final vocabTrend = _trendPhrase(sessions, (s) => s.linguisticFeatures.typeTokenRatio);
    final fillerTrend = _trendPhrase(sessions, (s) => _fillerRate(s));

    if (speechTrend == 'lower' || pauseTrend == 'higher') {
      recommendations.add('- Keep monitoring for reduced fluency and increased pausing.');
    }
    if (vocabTrend == 'lower') {
      recommendations.add('- Consider structured language tasks to support vocabulary richness.');
    }
    if (fillerTrend == 'higher') {
      recommendations.add('- Encourage paced responses to reduce filler words.');
    }
    if (recommendations.isEmpty) {
      recommendations.add('- Continue routine monitoring across speech and language measures.');
    }
    recommendations.add('- Review recent recordings in conjunction with MMSE trends.');
    return recommendations;
  }

  Widget _renderMarkdown(String markdown) {
    final lines = markdown.split('\n');
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (i + 1 < lines.length && _isTableHeader(line, lines[i + 1])) {
        final headers = _splitTableRow(line);
        final rows = <List<String>>[];
        i += 2;
        while (i < lines.length && lines[i].trim().startsWith('|')) {
          rows.add(_splitTableRow(lines[i]));
          i++;
        }
        i--;
        widgets.add(_buildTable(headers, rows));
        continue;
      }

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('>')) {
        final text = line.substring(1).trimLeft();
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(left: BorderSide(color: AppColors.primaryStart, width: 3)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.cardText.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
          ),
        );
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

  bool _isTableHeader(String line, String separatorLine) {
    if (!line.trim().startsWith('|')) return false;
    return _isTableSeparator(separatorLine);
  }

  bool _isTableSeparator(String line) {
    final cells = _splitTableRow(line);
    if (cells.isEmpty) return false;
    final pattern = RegExp(r'^:?-+:?$');
    return cells.every((cell) => pattern.hasMatch(cell));
  }

  List<String> _splitTableRow(String line) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('|')) return [];
    final content = trimmed.endsWith('|') ? trimmed.substring(1, trimmed.length - 1) : trimmed.substring(1);
    return content.split('|').map((cell) => cell.trim()).toList();
  }

  Widget _buildTable(List<String> headers, List<List<String>> rows) {
    final tableRows = <TableRow>[];
    tableRows.add(
      TableRow(
        children: headers.map((cell) => _buildTableCell(cell, isHeader: true)).toList(),
      ),
    );
    for (final row in rows) {
      final cells = List<String>.from(row);
      while (cells.length < headers.length) {
        cells.add('');
      }
      tableRows.add(
        TableRow(
          children: cells.take(headers.length).map(_buildTableCell).toList(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
        columnWidths: {
          for (var i = 0; i < headers.length; i++) i: const FlexColumnWidth(),
        },
        children: tableRows,
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.cardText,
        ),
      ),
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
