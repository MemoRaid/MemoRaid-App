import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class StoryRecallScreen extends StatefulWidget {
  const StoryRecallScreen({super.key});

  @override
  _StoryRecallScreenState createState() => _StoryRecallScreenState();
}

class _StoryRecallScreenState extends State<StoryRecallScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedStoryIndex = -1;
  bool _readingStory = false;
  bool _showQuestions = false;
  int _currentQuestionIndex = 0;
  Timer? _readingTimer;
  int _remainingReadTime = 60; // seconds
  int _score = 0;
  List<bool?> _questionResults = [];

  late AnimationController _animationController;

  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'The Lost Key',
      'author': 'Memory Tales',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '3 min',
      'text':
          'Alex was walking home from school when he noticed his house key was missing. He retraced his steps, checking the sidewalk, the school bus, and his friend\'s house. After searching for hours, he remembered putting it in a different pocket that morning because his usual pocket had a small hole. The key had been with him all along.',
      'questions': [
        {
          'question': 'Why was Alex unable to find his key initially?',
          'options': [
            'He left it at school',
            'It was in a different pocket than usual',
            'His friend took it',
            'It fell on the sidewalk'
          ],
          'correctIndex': 1
        },
        {
          'question': 'Why did Alex put his key in a different pocket?',
          'options': [
            'His usual pocket had a hole',
            'He was in a hurry',
            'His mother told him to',
            'The other pocket was more convenient'
          ],
          'correctIndex': 0
        },
        {
          'question': 'Where did Alex look for his key?',
          'options': [
            'Under his bed',
            'At the school cafeteria',
            'The sidewalk, school bus, and friend\'s house',
            'In his backpack'
          ],
          'correctIndex': 2
        }
      ]
    },
    {
      'title': 'The Birthday Surprise',
      'author': 'Memory Masters',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '4 min',
      'text':
          'Maria was planning a surprise party for her best friend Sara. She invited 15 friends, ordered a chocolate cake with strawberry filling, and bought blue and silver decorations because those were Sara\'s favorite colors. On the day of the party, everyone hid in Sara\'s apartment. When Sara arrived, she was so surprised that she dropped her phone, but luckily it landed on the carpet and didn\'t break.',
      'questions': [
        {
          'question': 'How many friends did Maria invite to the party?',
          'options': ['10', '15', '20', '25'],
          'correctIndex': 1
        },
        {
          'question': 'What kind of cake did Maria order?',
          'options': [
            'Vanilla with chocolate filling',
            'Chocolate with strawberry filling',
            'Strawberry with vanilla filling',
            'Carrot cake'
          ],
          'correctIndex': 1
        },
        {
          'question': 'What colors were the decorations?',
          'options': [
            'Red and gold',
            'Pink and purple',
            'Green and yellow',
            'Blue and silver'
          ],
          'correctIndex': 3
        },
        {
          'question': 'What happened when Sara was surprised?',
          'options': [
            'She screamed',
            'She cried',
            'She dropped her phone',
            'She fainted'
          ],
          'correctIndex': 2
        }
      ]
    },
    {
      'title': 'The Ancient Map',
      'author': 'Recall Chronicles',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '5 min',
      'text':
          'Professor Jenkins discovered an ancient map in a forgotten library vault. The map showed seven landmarks: a tall oak tree, a river fork, a stone circle, a cliff face with a carved eagle, a small cave, a meadow of unique purple flowers, and finally an X marking the treasure spot. The professor memorized the map before it crumbled to dust in his hands. He followed the landmarks one by one, finally discovering a chest filled with ancient scrolls containing lost knowledge from a civilization that disappeared 3,000 years ago.',
      'questions': [
        {
          'question': 'How many landmarks were on the map?',
          'options': ['Five', 'Six', 'Seven', 'Eight'],
          'correctIndex': 2
        },
        {
          'question': 'What was carved on the cliff face?',
          'options': ['A lion', 'An eagle', 'A dragon', 'A snake'],
          'correctIndex': 1
        },
        {
          'question': 'What color were the unique flowers in the meadow?',
          'options': ['Blue', 'Red', 'Yellow', 'Purple'],
          'correctIndex': 3
        },
        {
          'question': 'What did the professor find in the chest?',
          'options': [
            'Gold coins',
            'Ancient scrolls',
            'Precious gems',
            'A magical artifact'
          ],
          'correctIndex': 1
        }
      ]
    },
    {
      'title': 'The Missing Dog',
      'author': 'Memory Lane',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '3 min',
      'text':
          'Emma\'s dog Max went missing on Tuesday afternoon when the gate was accidentally left open by the gardener. Emma posted 32 flyers around the neighborhood, checked the local animal shelter twice, and posted on three social media platforms. On Friday morning, she received a call from Mrs. Peterson who lives 4 blocks away. Max had been playing with her children in their backyard for the past two days. Emma was so happy to reunite with Max that she bought him a new blue collar with a GPS tracker.',
      'questions': [
        {
          'question': 'On what day did Max go missing?',
          'options': ['Monday', 'Tuesday', 'Wednesday', 'Thursday'],
          'correctIndex': 1
        },
        {
          'question': 'How many flyers did Emma post around the neighborhood?',
          'options': ['22', '32', '42', '52'],
          'correctIndex': 1
        },
        {
          'question': 'How far away was Mrs. Peterson\'s house?',
          'options': ['2 blocks', '3 blocks', '4 blocks', '5 blocks'],
          'correctIndex': 2
        },
        {
          'question': 'What color was the new collar Emma bought for Max?',
          'options': ['Red', 'Green', 'Blue', 'Black'],
          'correctIndex': 2
        }
      ]
    },
    {
      'title': 'The Science Experiment',
      'author': 'Recall Masters',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '4 min',
      'text':
          'For his science project, Jason needed 250ml of distilled water, 15 grams of sodium bicarbonate, 3 copper plates, and a 9-volt battery. He had to keep the temperature between 22 and 24 degrees Celsius and record observations every 5 minutes for one hour. His hypothesis was that the copper plates would change color from orange-brown to blue-green within 45 minutes. Instead, they changed to a deep purple color after only 30 minutes, which led him to discover a new chemical reaction that his teacher had never seen before.',
      'questions': [
        {
          'question': 'How much distilled water did Jason need?',
          'options': ['150ml', '200ml', '250ml', '300ml'],
          'correctIndex': 2
        },
        {
          'question': 'How many copper plates were used in the experiment?',
          'options': ['2', '3', '4', '5'],
          'correctIndex': 1
        },
        {
          'question': 'How often did Jason record observations?',
          'options': [
            'Every 3 minutes',
            'Every 5 minutes',
            'Every 7 minutes',
            'Every 10 minutes'
          ],
          'correctIndex': 1
        },
        {
          'question': 'What color did the copper plates actually turn?',
          'options': ['Blue-green', 'Deep purple', 'Bright yellow', 'Black'],
          'correctIndex': 1
        },
        {
          'question': 'How long did it take for the color change to happen?',
          'options': ['15 minutes', '30 minutes', '45 minutes', '60 minutes'],
          'correctIndex': 1
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _questionResults = List.filled(_stories.first['questions'].length, null);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _readingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _selectStory(int index) {
    setState(() {
      _selectedStoryIndex = index;
      _readingStory = true;
      _showQuestions = false;
      _currentQuestionIndex = 0;
      _remainingReadTime = 60; // Reset timer
      _score = 0;
      _questionResults = List.filled(_stories[index]['questions'].length, null);
    });
    _startReadingTimer();
  }

  void _startReadingTimer() {
    _readingTimer?.cancel();
    _readingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingReadTime > 0) {
          _remainingReadTime--;
        } else {
          _readingTimer?.cancel();
          _showQuestions = true;
          _readingStory = false;
        }
      });
    });
  }

  void _checkAnswer(int selectedOptionIndex) {
    final questions = _stories[_selectedStoryIndex]['questions'];
    final correctIndex = questions[_currentQuestionIndex]['correctIndex'];

    setState(() {
      _questionResults[_currentQuestionIndex] =
          selectedOptionIndex == correctIndex;
      if (selectedOptionIndex == correctIndex) {
        _score++;
      }
    });

    // Wait a moment to show feedback before moving to next question
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if (_currentQuestionIndex < questions.length - 1) {
          _currentQuestionIndex++;
        } else {
          // All questions answered
          _tabController.animateTo(1); // Switch to results tab
        }
      });
    });
  }

  void _resetActivity() {
    setState(() {
      _selectedStoryIndex = -1;
      _readingStory = false;
      _showQuestions = false;
      _currentQuestionIndex = 0;
      _readingTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _selectedStoryIndex == -1
              ? "Story Recall"
              : _readingStory
                  ? "Reading Time"
                  : _showQuestions
                      ? "Story Questions"
                      : "Results",
          style: TextStyle(
            color: Color(0xFF0D3445),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () {
            if (_selectedStoryIndex == -1) {
              Navigator.pop(context);
            } else {
              _resetActivity();
            }
          },
        ),
        bottom: _selectedStoryIndex != -1 && !_readingStory && !_showQuestions
            ? TabBar(
                controller: _tabController,
                labelColor: Color(0xFF0D3445),
                tabs: [
                  Tab(text: "Questions"),
                  Tab(text: "Results"),
                ],
              )
            : null,
      ),
      body: _selectedStoryIndex == -1
          ? _buildStoryListView()
          : _readingStory
              ? _buildReadingView()
              : _showQuestions
                  ? _buildQuestionsView()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildQuestionsReviewView(),
                        _buildResultsView(),
                      ],
                    ),
    );
  }

  Widget _buildStoryListView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFF0D3445)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _selectStory(index),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFF0D3445),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Image.asset(
                        story['coverImage'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['title'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            story['author'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                story['duration'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                Icons.question_answer,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "${story['questions'].length} questions",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF4E6077),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadingView() {
    final story = _stories[_selectedStoryIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFF0D3445).withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Timer bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _remainingReadTime / 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF0D3445),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Time remaining: $_remainingReadTime seconds",
                  style: TextStyle(
                    color: Color(0xFF0D3445),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _readingTimer?.cancel();
                    setState(() {
                      _showQuestions = true;
                      _readingStory = false;
                    });
                  },
                  child: Text(
                    "I'm Ready",
                    style: TextStyle(
                      color: Color(0xFF0D3445),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Story content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3445),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "by ${story['author']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0D3445).withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    story['text'],
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: Color(0xFF0D3445),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsView() {
    final story = _stories[_selectedStoryIndex];
    final questions = story['questions'] as List;
    final currentQuestion =
        questions[_currentQuestionIndex] as Map<String, dynamic>;
    final options = currentQuestion['options'] as List;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFF0D3445).withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: List.generate(
              questions.length,
              (index) => Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _currentQuestionIndex >= index
                        ? Color(0xFF0D3445)
                        : Color(0xFF0D3445).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Question number
          Text(
            "QUESTION ${_currentQuestionIndex + 1} OF ${questions.length}",
            style: TextStyle(
              color: Color(0xFF0D3445),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),

          // Question
          Text(
            currentQuestion['question']?.toString() ?? 'Question',
            style: TextStyle(
              color: Color(0xFF0D3445),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          SizedBox(height: 24),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index]?.toString() ?? '';
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: _questionResults[_currentQuestionIndex] == null
                            ? () => _checkAnswer(index)
                            : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: _questionResults[_currentQuestionIndex] ==
                                    null
                                ? Color(0xFF0D3445)
                                : index ==
                                        (currentQuestion['correctIndex'] ?? 0)
                                    ? Colors.green
                                    : _questionResults[_currentQuestionIndex] ==
                                                false &&
                                            index ==
                                                (currentQuestion[
                                                        'correctIndex'] ??
                                                    0)
                                        ? Colors.green
                                        : _questionResults[
                                                        _currentQuestionIndex] ==
                                                    false &&
                                                index !=
                                                    (currentQuestion[
                                                            'correctIndex'] ??
                                                        0)
                                            ? Colors.red
                                            : Color(0xFF0D3445),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsReviewView() {
    final story = _stories[_selectedStoryIndex];
    final questions = story['questions'];

    return Container(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final options = question['options'];
          final correctIndex = question['correctIndex'];
          final isAnsweredCorrectly = _questionResults[index] ?? false;

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isAnsweredCorrectly ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${index + 1}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D3445),
                        ),
                      ),
                      Icon(
                        isAnsweredCorrectly ? Icons.check_circle : Icons.cancel,
                        color: isAnsweredCorrectly ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    question['question'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3445),
                    ),
                  ),
                  SizedBox(height: 12),
                  ...options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isCorrect = index == correctIndex;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrect ? Colors.green : Colors.grey,
                          ),
                        ),
                        child: Row(
                          children: [
                            isCorrect
                                ? Icon(Icons.check_circle,
                                    color: Colors.green, size: 20)
                                : Icon(Icons.circle_outlined,
                                    color: Colors.grey, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color:
                                      isCorrect ? Colors.green : Colors.black,
                                  fontWeight: isCorrect
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsView() {
    final story = _stories[_selectedStoryIndex];
    final questions = story['questions'];
    final percentage = _score / questions.length * 100;

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score display
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0D3445),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${percentage.toInt()}%",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Score",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),

          // Results summary
          Text(
            _score == questions.length
                ? "Perfect Score! Amazing memory!"
                : _score >= questions.length * 0.8
                    ? "Great job! Your memory is impressive!"
                    : _score >= questions.length * 0.6
                        ? "Good effort! Keep practicing!"
                        : "Keep trying to improve your memory!",
            style: TextStyle(
              color: Color(0xFF0D3445),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "You correctly answered $_score out of ${questions.length} questions",
            style: TextStyle(
              color: Color(0xFF0D3445).withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                icon: Icon(Icons.refresh),
                label: Text("Review Questions"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D3445),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _resetActivity,
                icon: Icon(Icons.home),
                label: Text("New Story"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D3445),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
