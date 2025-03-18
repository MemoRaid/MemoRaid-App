import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../services/question_service.dart';

class MemoryQuestionsScreen extends StatefulWidget {
  final String memoryId;
  final String photoUrl;
  final String briefDescription;

  const MemoryQuestionsScreen({
    Key? key,
    required this.memoryId,
    required this.photoUrl,
    required this.briefDescription,
  }) : super(key: key);

  @override
  State<MemoryQuestionsScreen> createState() => _MemoryQuestionsScreenState();
}

class _MemoryQuestionsScreenState extends State<MemoryQuestionsScreen> {
  late Future<List<Question>> _questionsFuture;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = QuestionService().getMemoryQuestions(widget.memoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Practice'),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final questions = snapshot.data!;

          return Column(
            children: [
              // Memory Context Section
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.photoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.briefDescription,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              // Question Section
              if (!_showResult) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    questions[_currentQuestionIndex].question,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ...questions[_currentQuestionIndex].options.asMap().entries.map(
                  (entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ElevatedButton(
                        onPressed: () => _handleAnswer(entry.key),
                        child: Text(entry.value),
                      ),
                    );
                  },
                ).toList(),
              ],

              // Progress Indicator
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / questions.length,
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleAnswer(int selectedIndex) async {
    try {
      final questions = await _questionsFuture;
      final currentQuestion = questions[_currentQuestionIndex];
      
      if (selectedIndex == currentQuestion.correctOptionIndex) {
        setState(() {
          _score += currentQuestion.points;
        });
      }

      if (_currentQuestionIndex < questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        setState(() {
          _showResult = true;
        });
        // Show results
        _showResultDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Practice Complete!'),
        content: Text('Your score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}