import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../models/task_step.dart';
import '../utils/shuffler.dart';
import 'results_screen.dart';
import 'dart:math' as math;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late List<Scenario> scenarios;
  late int currentScenarioIndex;
  late List<TaskStep> jumbledSteps;
  late List<TaskStep> orderedSteps;
  late bool isCorrect;
  late bool showHint;
  late String feedback;
  late int attempts;
  late int score;

  // Animation controllers
  late AnimationController _fadeInController;
  late AnimationController _buttonController;
  late AnimationController _checkAnswerController;
  late AnimationController _scenarioTransitionController;
  late AnimationController _shakeController;

  // Animations
  late Animation<double> _fadeInAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _checkAnswerRotationAnimation;
  late Animation<Offset> _scenarioSlideAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize variables before using them
    orderedSteps = [];
    jumbledSteps = [];
    isCorrect = false;
    showHint = false;
    feedback = "";
    attempts = 0;
    score = 0;

    // Initialize animation controllers
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _checkAnswerController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _scenarioTransitionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Setup animations
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeIn,
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _checkAnswerRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _checkAnswerController,
      curve: Curves.elasticOut,
    ));

    _scenarioSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _scenarioTransitionController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _initializeGame();

    // Start initial animations
    _fadeInController.forward();
    _scenarioTransitionController.forward();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _buttonController.dispose();
    _checkAnswerController.dispose();
    _scenarioTransitionController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    scenarios = [
      Scenario(
        id: 1,
        title: "Morning Routine",
        description: "Arrange the steps for getting ready in the morning",
        steps: [
          "Wake up and get out of bed",
          "Brush teeth and wash face",
          "Take a shower",
          "Get dressed",
          "Eat breakfast",
          "Pack bag for the day",
          "Leave the house"
        ],
      ),
      Scenario(
        id: 2,
        title: "Making Pasta",
        description: "Put these steps in order to make pasta",
        steps: [
          "Fill pot with water",
          "Bring water to a boil",
          "Add salt to water",
          "Add pasta to boiling water",
          "Cook pasta until al dente",
          "Drain pasta",
          "Add sauce and serve"
        ],
      ),
      Scenario(
        id: 3,
        title: "Grocery Shopping",
        description: "Arrange the steps for a successful grocery trip",
        steps: [
          "Make a shopping list",
          "Grab reusable bags",
          "Drive to the store",
          "Select items and put in cart",
          "Wait in checkout line",
          "Pay for groceries",
          "Load groceries in car and drive home"
        ],
      ),
    ];

    currentScenarioIndex = 0;
    score = 0;
    _resetScenario();
  }

  void _resetScenario() {
    // Save previous items length if any
    final int oldLength = orderedSteps.length;

    // Convert string steps to TaskStep objects
    List<TaskStep> stepObjects = scenarios[currentScenarioIndex]
        .steps
        .asMap()
        .entries
        .map((entry) => TaskStep(
            id: entry.key, text: entry.value, correctPosition: entry.key))
        .toList();

    jumbledSteps = Shuffler.shuffleSteps(stepObjects);

    // Clear list with animations
    if (oldLength > 0 && _listKey.currentState != null) {
      for (int i = oldLength - 1; i >= 0; i--) {
        final item = orderedSteps[i];
        _listKey.currentState!.removeItem(
          i,
          (context, animation) => _buildRemovedItem(item, context, animation),
          duration: const Duration(milliseconds: 200),
        );
      }
    }

    orderedSteps = [];
    isCorrect = false;
    showHint = false;
    feedback = "";
    attempts = 0;
  }

  void _selectStep(TaskStep step) {
    if (isCorrect) return;

    setState(() {
      jumbledSteps.removeWhere((s) => s.id == step.id);
      orderedSteps.add(step);
    });

    // Add button press animation effect
    _buttonController.reset();
    _buttonController.forward().then((_) => _buttonController.reverse());

    _listKey.currentState?.insertItem(orderedSteps.length - 1);
  }

  void _removeStep(TaskStep step) {
    if (isCorrect) return;

    final int index = orderedSteps.indexWhere((s) => s.id == step.id);
    if (index < 0) return;

    final removedItem = orderedSteps[index];

    // First notify AnimatedList about the removal
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildRemovedItem(removedItem, context, animation),
      duration: const Duration(milliseconds: 300),
    );

    setState(() {
      orderedSteps.removeWhere((s) => s.id == step.id);
      jumbledSteps.add(step);
    });

    // Add button press animation effect
    _buttonController.reset();
    _buttonController.forward().then((_) => _buttonController.reverse());
  }

  void _checkAnswer() {
    setState(() {
      attempts++;

      // Check if steps are in correct order
      bool correct = true;
      for (int i = 0; i < orderedSteps.length; i++) {
        if (orderedSteps[i].correctPosition != i) {
          correct = false;
          break;
        }
      }

      isCorrect = correct;

      if (correct) {
        score += 10 - (attempts > 5 ? 5 : attempts);
        feedback = "Great job! You've arranged the steps correctly!";
        // Success animation
        _checkAnswerController.reset();
        _checkAnswerController.forward();
      } else {
        feedback = "Not quite right. Try again or use a hint!";
        // Error animation
        _shakeController.reset();
        _shakeController.forward();
      }
    });
  }

  void _nextScenario() {
    // Animate out current scenario
    _scenarioTransitionController.reverse().then((_) {
      setState(() {
        if (currentScenarioIndex + 1 < scenarios.length) {
          currentScenarioIndex++;
          _resetScenario();
          // Animate in new scenario
          _scenarioTransitionController.forward();
        } else {
          // All scenarios completed, navigate to ResultsScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                score: score,
                totalScenarios: scenarios.length,
              ),
            ),
          );
        }
      });
    });
  }

  void _toggleHint() {
    setState(() {
      showHint = !showHint;
    });

    // Animate button press
    _buttonController.reset();
    _buttonController.forward().then((_) => _buttonController.reverse());
  }

  Widget _buildRemovedItem(
      TaskStep item, BuildContext context, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(child: Text(item.text)),
              Icon(Icons.remove_circle_outline, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Tasks Sequencer'),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: SlideTransition(
          position: _scenarioSlideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score display
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Score: $score',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16),

                // Current scenario info
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenarios[currentScenarioIndex].title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        scenarios[currentScenarioIndex].description,
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Ordered steps section
                Text(
                  'Your Sequence:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: !isCorrect && _shakeController.isAnimating
                            ? Offset(
                                math.sin(_shakeAnimation.value * math.pi * 8) *
                                    10,
                                0)
                            : Offset.zero,
                        child: child!,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: orderedSteps.isEmpty
                          ? Center(
                              child: Text(
                                'Select steps from below to arrange them in order',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : AnimatedList(
                              key: _listKey,
                              initialItemCount: orderedSteps.length,
                              itemBuilder: (context, index, animation) {
                                final step = orderedSteps[index];
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    // Change from sliding in from right to sliding up from bottom
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.indigo.shade100),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.indigo.shade600,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(child: Text(step.text)),
                                          ScaleTransition(
                                            scale: _buttonScaleAnimation,
                                            child: IconButton(
                                              icon: Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _removeStep(step),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Available steps section
                Text(
                  'Available Steps:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: jumbledSteps.isEmpty
                        ? Center(
                            child: Text(
                              'All steps have been used',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: jumbledSteps.length,
                            itemBuilder: (context, index) {
                              final step = jumbledSteps[index];
                              return TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.8, end: 1.0),
                                duration: Duration(milliseconds: 300),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Opacity(
                                      opacity: value,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        child: InkWell(
                                          onTap: () => _selectStep(step),
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 2,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(step.text),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),

                SizedBox(height: 16),

                // Feedback section
                if (feedback.isNotEmpty)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.shade100
                                : Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            feedback,
                            style: TextStyle(
                              color: isCorrect
                                  ? Colors.green.shade800
                                  : Colors.amber.shade800,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Hint section
                if (showHint)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hint:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'The first step should be: "${scenarios[currentScenarioIndex].steps[0]}"',
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                        if (orderedSteps.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'After "${orderedSteps.last.text}", you should consider what logically comes next.',
                              style: TextStyle(color: Colors.blue.shade800),
                            ),
                          ),
                      ],
                    ),
                  ),

                SizedBox(height: 16),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RotationTransition(
                      turns: _checkAnswerRotationAnimation,
                      child: ElevatedButton.icon(
                        onPressed: orderedSteps.length ==
                                    scenarios[currentScenarioIndex]
                                        .steps
                                        .length &&
                                !isCorrect
                            ? _checkAnswer
                            : null,
                        icon: Icon(Icons.check_circle),
                        label: Text('Check Answer'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: ElevatedButton.icon(
                        onPressed: _toggleHint,
                        icon: Icon(Icons.lightbulb_outline),
                        label: Text(showHint ? 'Hide Hint' : 'Show Hint'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    if (isCorrect)
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: ElevatedButton.icon(
                              onPressed: _nextScenario,
                              icon: Icon(Icons.arrow_forward),
                              label: Text('Next'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    if (!isCorrect)
                      ElevatedButton.icon(
                        onPressed: _resetScenario,
                        icon: Icon(Icons.refresh),
                        label: Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
