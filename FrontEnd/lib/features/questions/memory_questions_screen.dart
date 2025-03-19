// lib/features/questions/memory_questions_screen.dart
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
  bool _quizComplete = false;
  List<bool> _userAnswers = [];
  int? _selectedAnswerIndex;
  bool _showingFeedback = false;
  
  @override
  void initState() {
    super.initState();
    _questionsFuture = QuestionService().getMemoryQuestions(widget.memoryId);
  }
  
  void _handleAnswer(int selectedIndex, Question question) {
    // Don't allow selecting another answer while showing feedback
    if (_showingFeedback) return;
    
    setState(() {
      _selectedAnswerIndex = selectedIndex;
      _showingFeedback = true;
      
      // Update score if correct
      if (selectedIndex == question.correctOptionIndex) {
        _score += question.points;
        _userAnswers.add(true);
      } else {
        _userAnswers.add(false);
      }
    });
    
    // Delay before moving to next question
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        _questionsFuture.then((questions) {
          setState(() {
            _showingFeedback = false;
            _selectedAnswerIndex = null;
            
            if (_currentQuestionIndex < questions.length - 1) {
              _currentQuestionIndex++;
            } else {
              _quizComplete = true;
            }
          });
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Questions'),
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
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions found for this memory'));
          }
          
          final questions = snapshot.data!;
          
          if (_quizComplete) {
            return _buildResultsView(questions.length);
          }
          
          final currentQuestion = questions[_currentQuestionIndex];
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Memory context
                Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Image.network(
                        widget.photoUrl,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.briefDescription,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                
                // Question
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentQuestion.question,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Options
                ...List.generate(currentQuestion.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: _showingFeedback ? null : () => _handleAnswer(index, currentQuestion),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                        padding: EdgeInsets.all(12),
                        // Visual feedback based on selection
                        backgroundColor: _selectedAnswerIndex == index 
                            ? (index == currentQuestion.correctOptionIndex 
                                ? Colors.green[100]  // Correct answer
                                : Colors.red[100])   // Wrong answer
                            : (_showingFeedback && index == currentQuestion.correctOptionIndex
                                ? Colors.green[50]   // Highlight correct answer
                                : null),
                        foregroundColor: _selectedAnswerIndex == index 
                            ? (index == currentQuestion.correctOptionIndex 
                                ? Colors.green[800]  // Correct answer text
                                : Colors.red[800])   // Wrong answer text
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentQuestion.options[index],
                            style: TextStyle(fontSize: 16),
                          ),
                          if (_showingFeedback && index == currentQuestion.correctOptionIndex)
                            Icon(Icons.check_circle, color: Colors.green[800]),
                          if (_showingFeedback && _selectedAnswerIndex == index && 
                              index != currentQuestion.correctOptionIndex)
                            Icon(Icons.cancel, color: Colors.red[800]),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildResultsView(int totalQuestions) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _score > totalQuestions * 0.7 ? Icons.star : Icons.star_half,
              color: Colors.amber,
              size: 80,
            ),
            SizedBox(height: 24),
            Text(
              'Quiz Complete!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Your Score: $_score',
              style: TextStyle(fontSize: 22),
            ),
            Text(
              'Correct Answers: ${_userAnswers.where((answer) => answer).length} of $totalQuestions',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Back to Memories'),
            ),
          ],
        ),
      ),
    );
  }
}