import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/exam.dart';
import '../widgets/bottom_navigation.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final ApiService _apiService = ApiService();
  List<Exam> _exams = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exams = await _apiService.getExams();
      setState(() {
        _exams = exams;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrance Exams'),
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: const BottomNavigation(currentRoute: '/exams'),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _exams.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load exams',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchExams,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_exams.isEmpty) {
      return const Center(
        child: Text('No exams available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchExams,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _exams.length,
        itemBuilder: (context, index) {
          final exam = _exams[index];
          return _buildExamCard(exam);
        },
      ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showExamDetails(exam),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (exam.fullName != null && exam.fullName != exam.name) ...[
                          const SizedBox(height: 4),
                          Text(
                            exam.fullName!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getExamTypeColor(exam.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      exam.type,
                      style: TextStyle(
                        color: _getExamTypeColor(exam.type),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (exam.conductingBody != null) ...[
                Row(
                  children: [
                    Icon(Icons.business, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exam.conductingBody!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (exam.examDate != null) ...[
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Exam Date: ${_formatDate(exam.examDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (exam.applicationEndDate != null) ...[
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Registration Ends: ${_formatDate(exam.applicationEndDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getExamTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'engineering':
        return Colors.blue;
      case 'medical':
        return Colors.red;
      case 'management':
        return Colors.green;
      case 'law':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showExamDetails(Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _buildExamDetailsModal(exam, scrollController),
      ),
    );
  }

  Widget _buildExamDetailsModal(Exam exam, ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            exam.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (exam.fullName != null && exam.fullName != exam.name) ...[
            const SizedBox(height: 8),
            Text(
              exam.fullName!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                if (exam.conductingBody != null)
                  _buildDetailRow('Conducting Body', exam.conductingBody!),
                if (exam.type != null)
                  _buildDetailRow('Exam Type', exam.type),
                if (exam.frequency != null)
                  _buildDetailRow('Frequency', exam.frequency!),
                if (exam.applicationStartDate != null)
                  _buildDetailRow('Application Start', _formatDate(exam.applicationStartDate!)),
                if (exam.applicationEndDate != null)
                  _buildDetailRow('Application End', _formatDate(exam.applicationEndDate!)),
                if (exam.examDate != null)
                  _buildDetailRow('Exam Date', _formatDate(exam.examDate!)),
                if (exam.resultDate != null)
                  _buildDetailRow('Result Date', _formatDate(exam.resultDate!)),
                if (exam.totalMarks != null)
                  _buildDetailRow('Total Marks', exam.totalMarks.toString()),
                if (exam.duration != null)
                  _buildDetailRow('Duration', exam.duration!),
                if (exam.eligibility != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Eligibility',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(exam.eligibility!),
                ],
                if (exam.examPattern != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Exam Pattern',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(exam.examPattern!),
                ],
                const SizedBox(height: 24),
                if (exam.website != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(exam.website!),
                      icon: const Icon(Icons.web),
                      label: const Text('Visit Official Website'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}