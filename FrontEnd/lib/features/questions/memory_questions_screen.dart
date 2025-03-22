// lib/features/questions/memory_questions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/question.dart';
import '../../services/question_service.dart';
import '../../memoraid_features/services/auth_service.dart';

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
  // Add these new state variables
  List<String> _shuffledOptions = [];
  int _shuffledCorrectIndex = 0;
  int previousQuestionIndex = -1;

  // Existing variables...
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

    // Use custom AuthService for auth check
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isAuthenticated) {
      // Redirect to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to view questions')));
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    // Continue with loading questions if authenticated
    _questionsFuture = QuestionService().getMemoryQuestions(widget.memoryId);

    _questionsFuture.then((questions) {
      if (questions.isNotEmpty) {
        // Use post-frame callback to safely update state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _shuffleOptions(questions[_currentQuestionIndex]);
          setState(() {}); // Update UI after shuffling
        });
      }
    }).catchError((error) {
      // Better error handling
      if (error.toString().contains('authenticated')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session expired. Please login again.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    });
  }

  // Update this method - REMOVE setState() call
  void _shuffleOptions(Question question) {
    // Create a list of option indices
    final indices = List<int>.generate(question.options.length, (i) => i);

    // Shuffle the indices
    indices.shuffle();

    // Create newly ordered options list
    _shuffledOptions = indices.map((i) => question.options[i]).toList();

    // Find where the correct answer ended up
    _shuffledCorrectIndex = indices.indexOf(question.correctOptionIndex);
  }

  void _handleAnswer(int selectedIndex, Question question) {
    // Print added to debug
    print(
        "Handling answer: selected=$selectedIndex, correct=${_shuffledCorrectIndex}, showing=$_showingFeedback");

    // Don't allow selecting another answer while showing feedback
    if (_showingFeedback) return;

    setState(() {
      _selectedAnswerIndex = selectedIndex;
      _showingFeedback = true;

      // Check against shuffled index instead of original
      if (selectedIndex == _shuffledCorrectIndex) {
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

  void _moveToNextQuestion() {
    _questionsFuture.then((questions) {
      if (_currentQuestionIndex < questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _shuffleOptions(questions[_currentQuestionIndex]);
        });
      } else {
        setState(() {
          _quizComplete = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Memory Questions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0D3445).withOpacity(0.7),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D3445), Colors.white],
          ),
        ),
        child: FutureBuilder<List<Question>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No questions found for this memory'));
            }

            final questions = snapshot.data!;

            if (_quizComplete) {
              return _buildResultsView(questions.length);
            }

            final currentQuestion = questions[_currentQuestionIndex];

            if (_shuffledOptions.isEmpty ||
                _currentQuestionIndex != previousQuestionIndex) {
              _shuffleOptions(currentQuestion);
              previousQuestionIndex = _currentQuestionIndex;
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Memory context
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: Image.network(
                            widget.photoUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            widget.briefDescription,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0D3445),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Progress indicator with custom styling
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF4E6077),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Score: $_score',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value:
                                (_currentQuestionIndex + 1) / questions.length,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Question card with styled design
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      currentQuestion.question,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D3445),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Restyled answer options
                  ...List.generate(_shuffledOptions.length, (index) {
                    bool isSelected = _selectedAnswerIndex == index;
                    bool isCorrect = index == _shuffledCorrectIndex;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: MaterialButton(
                        onPressed: _showingFeedback
                            ? () {}
                            : () => _handleAnswer(index, currentQuestion),
                        elevation: isSelected ? 5 : 2,
                        color: _showingFeedback
                            ? (isCorrect
                                ? Colors.green[400]
                                : (isSelected ? Colors.red[400] : Colors.white))
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: _showingFeedback && (isCorrect || isSelected)
                              ? BorderSide(
                                  color: isCorrect
                                      ? Colors.green[800]!
                                      : Colors.red[800]!,
                                  width: 2.0,
                                )
                              : BorderSide.none,
                        ),
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _showingFeedback
                                      ? (isCorrect || isSelected
                                          ? Colors.white
                                          : Color(0xFF4E6077))
                                      : Color(0xFF4E6077),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(
                                        65 + index), // A, B, C, D
                                    style: TextStyle(
                                      color: _showingFeedback &&
                                              (isCorrect || isSelected)
                                          ? Color(0xFF0D3445)
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _shuffledOptions[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _showingFeedback &&
                                            (isCorrect || isSelected)
                                        ? Colors.white
                                        : Color(0xFF0D3445),
                                  ),
                                ),
                              ),
                              if (_showingFeedback && isCorrect)
                                Icon(Icons.check_circle, color: Colors.white),
                              if (_showingFeedback && isSelected && !isCorrect)
                                Icon(Icons.cancel, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsView(int totalQuestions) {
    // Call this first to save results
    QuestionService().saveQuizResults(
      memoryId: widget.memoryId,
      score: _score,
      correctAnswers: _userAnswers.where((answer) => answer).length,
      totalQuestions: totalQuestions,
    );

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
