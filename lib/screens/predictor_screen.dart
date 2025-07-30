import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/college_provider.dart';
import '../models/college.dart';
import '../widgets/college_card.dart';
import '../widgets/bottom_navigation.dart';

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  String? _selectedExam;
  List<College> _predictedColleges = [];
  bool _isLoading = false;

  final List<String> _exams = [
    'JEE Main',
    'JEE Advanced',
    'NEET',
    'CAT',
    'GATE',
    'BITSAT',
    'COMEDK',
    'KCET',
    'MHT CET',
    'WBJEE',
    'Other',
  ];

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Predictor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predict Your College',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your exam score to get personalized college recommendations',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Exam dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedExam,
                            decoration: const InputDecoration(
                              labelText: 'Select Exam',
                              border: OutlineInputBorder(),
                            ),
                            items: _exams.map((exam) {
                              return DropdownMenuItem(
                                value: exam,
                                child: Text(exam),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedExam = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an exam';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Score input
                          TextFormField(
                            controller: _scoreController,
                            decoration: const InputDecoration(
                              labelText: 'Your Score',
                              border: OutlineInputBorder(),
                              hintText: 'Enter your exam score',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your score';
                              }
                              final score = int.tryParse(value);
                              if (score == null || score < 0) {
                                return 'Please enter a valid score';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          // Predict button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _predictColleges,
                              child: _isLoading
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Predicting...'),
                                      ],
                                    )
                                  : const Text('Predict Colleges'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Results section
            if (_predictedColleges.isNotEmpty) ...[
              Text(
                'Recommended Colleges',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _predictedColleges.length,
                itemBuilder: (context, index) {
                  final college = _predictedColleges[index];
                  return Consumer<CollegeProvider>(
                    builder: (context, provider, child) {
                      return CollegeCard(
                        college: college,
                        isFavorite: provider.isFavorite(college),
                        onTap: () => context.go('/college/${college.id}'),
                        onFavoriteToggle: () => provider.toggleFavorite(college),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentRoute: '/predictor'),
    );
  }

  Future<void> _predictColleges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final score = int.parse(_scoreController.text);
      final colleges = await context.read<CollegeProvider>().predictColleges(
            score: score,
            exam: _selectedExam!,
          );

      setState(() {
        _predictedColleges = colleges;
      });

      if (colleges.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No matching colleges found for your score. Try adjusting your search criteria.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to predict colleges: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}