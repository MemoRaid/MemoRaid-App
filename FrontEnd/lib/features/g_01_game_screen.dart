import 'package:flutter/material.dart';
import '../features/g_01_scenario.dart';
import '../features/g_01_task_step.dart';
import '../features/g_01_shuffler.dart';
import 'g_01_results_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game variables
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
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _initializeGame();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
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
    // Convert string steps to TaskStep objects
    List<TaskStep> stepObjects = scenarios[currentScenarioIndex]
        .steps
        .asMap()
        .entries
        .map((entry) => TaskStep(
            id: entry.key, text: entry.value, correctPosition: entry.key))
        .toList();

    setState(() {
      jumbledSteps = Shuffler.ShuffleSteps(stepObjects);
      orderedSteps = [];
      isCorrect = false;
      showHint = false;
      feedback = "";
      attempts = 0;

      // Trigger animations
      _slideController.reset();
      _slideController.forward();
    });
  }

  void _selectStep(TaskStep step) {
    if (isCorrect) return;

    setState(() {
      jumbledSteps.removeWhere((s) => s.id == step.id);
      orderedSteps.add(step);

      // Trigger scale animation
      _scaleController.reset();
      _scaleController.forward();
    });
  }

  void _removeStep(TaskStep step) {
    if (isCorrect) return;

    setState(() {
      orderedSteps.removeWhere((s) => s.id == step.id);
      jumbledSteps.add(step);
    });
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
      } else {
        feedback = "Not quite right. Try again or use a hint!";
      }
    });
  }

  void _nextScenario() {
    setState(() {
      if (currentScenarioIndex + 1 < scenarios.length) {
        currentScenarioIndex++;
        _resetScenario();
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
  }

  void _toggleHint() {
    setState(() {
      showHint = !showHint;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary color and its variations
    final Color primaryColor = Color(0xFF0D3445);
    final Color primaryLightColor = Color(0xFF164C64);
    final Color primaryDarkColor = Color(0xFF092736);
    final Color primaryLighterColor = Color(0xFFE6EEF2);
    final Color primarySuperLightColor = Color(0xFFF2F7FA);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Daily Tasks Sequencer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor.withOpacity(0.95),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryLightColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryLighterColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current scenario card
                SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryDarkColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white30,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getScenarioIcon(
                                      scenarios[currentScenarioIndex].title),
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scenarios[currentScenarioIndex].title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      scenarios[currentScenarioIndex]
                                          .description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Scenario ${currentScenarioIndex + 1}/${scenarios.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Ordered steps section
                Text(
                  'Your Sequence:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: orderedSteps.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    size: 40,
                                    color: Color(0xFF5A91A6),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Select steps from below\nto arrange them in order',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: orderedSteps.length,
                              padding: EdgeInsets.all(12),
                              itemBuilder: (context, index) {
                                final step = orderedSteps[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: ScaleTransition(
                                    scale: orderedSteps.last == step
                                        ? _scaleAnimation
                                        : const AlwaysStoppedAnimation(1.0),
                                    child: Material(
                                      color: primaryLighterColor,
                                      borderRadius: BorderRadius.circular(12),
                                      elevation: 1,
                                      child: InkWell(
                                        onTap: () => _removeStep(step),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xFF5A91A6)),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      primaryLightColor,
                                                      primaryColor,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: primaryLightColor
                                                          .withOpacity(0.4),
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  step.text,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: primaryDarkColor,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.remove_circle,
                                                color: Colors.redAccent,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
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
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: jumbledSteps.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 40,
                                  color: Colors.green.shade300,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'All steps have been used',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.all(12),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.8,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: jumbledSteps.length,
                            itemBuilder: (context, index) {
                              final step = jumbledSteps[index];
                              return Material(
                                color: primarySuperLightColor,
                                borderRadius: BorderRadius.circular(12),
                                elevation: 1,
                                child: InkWell(
                                  onTap: () => _selectStep(step),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      step.text,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: primaryDarkColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                SizedBox(height: 16),

                // Feedback section
                if (feedback.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCorrect
                            ? [Colors.green.shade400, Colors.green.shade700]
                            : [Colors.amber.shade400, Colors.amber.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isCorrect
                              ? Colors.green.shade200.withOpacity(0.5)
                              : Colors.amber.shade200.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.info,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feedback,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Hint section
                if (showHint)
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE2EEF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF5A91A6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.amber.shade600,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Hint:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The first step should be: "${scenarios[currentScenarioIndex].steps[0]}"',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        if (orderedSteps.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'After "${orderedSteps.last.text}", you should consider what logically comes next.',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                              ),
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
                    Expanded(
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
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                          shadowColor: primaryLightColor.withOpacity(0.4),
                          disabledBackgroundColor:
                              primaryLightColor.withOpacity(0.4),
                          disabledForegroundColor: Colors.white70,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _toggleHint,
                      icon: Icon(Icons.lightbulb_outline),
                      label: Text(showHint ? 'Hide Hint' : 'Show Hint'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                        shadowColor: Colors.amber.shade200,
                      ),
                    ),
                    SizedBox(width: 12),
                    if (isCorrect)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _nextScenario,
                          icon: Icon(Icons.arrow_forward),
                          label: Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                            shadowColor: Colors.green.shade200,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _resetScenario,
                          icon: Icon(Icons.refresh),
                          label: Text('Reset'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF425A64),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                            shadowColor: Color(0xFF425A64).withOpacity(0.3),
                          ),
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

  // Helper method to get appropriate icon for scenario
  IconData _getScenarioIcon(String title) {
    switch (title.toLowerCase()) {
      case 'morning routine':
        return Icons.wb_sunny;
      case 'making pasta':
        return Icons.restaurant;
      case 'grocery shopping':
        return Icons.shopping_cart;
      default:
        return Icons.list_alt;
    }
  }
}
