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
  int _currentIndex = 0;
  int _score = 0;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    try {
      _questionsFuture = QuestionService().getMemoryQuestions(widget.memoryId);
    } catch (e) {
      print('Error initializing questions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Memory Practice',
          style: TextStyle(
            color: Color(0xFF0D3445),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
              // Memory Context
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
                  style: const TextStyle(
                    color: Color(0xFF0D3445),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Progress Indicator
              LinearProgressIndicator(
                value: (_currentIndex + 1) / questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D3445)),
              ),

              // Questions Section
              Expanded(
                child: _showResults 
                    ? _buildResultView(questions.length)
                    : _buildQuestionView(questions[_currentIndex]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionView(Question question) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              color: Color(0xFF0D3445),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...question.options.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton(
                onPressed: () => _handleAnswer(entry.key, question),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0D3445),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(entry.value),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResultView(int totalQuestions) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Practice Complete!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3445),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Score: $_score / ${totalQuestions * 5}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3445),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                    _score = 0;
                    _showResults = false;
                    _questionsFuture = QuestionService().getMemoryQuestions(widget.memoryId);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3445),
                ),
                child: const Text('Try Again'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAnswer(int selectedIndex, Question question) async {
    try {
      final questions = await _questionsFuture;
      setState(() {
        if (selectedIndex == question.correctOptionIndex) {
          _score += question.points;
        }

        if (_currentIndex < questions.length - 1) {
          _currentIndex++;
        } else {
          _showResults = true;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}