import 'package:flutter/material.dart';
import '../features/g_01_scenario.dart';
import '../features/g_01_task_step.dart';
import '../features/g_01_shuffler.dart';
import '../features/g_01_score_manager.dart'; // Import the new score manager
import '../features/g_01_level_selector.dart';
import '../features/g_01_scenario_card.dart';
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

  // Track completed scenarios
  late List<bool> completedScenarios;
  late bool scoreVisible = false;

  // Animation controllers
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // Add score manager instance
  final ScoreManager _scoreManager = ScoreManager();

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

      // New scenarios
      Scenario(
        id: 4,
        title: "Car Maintenance",
        description: "Order the steps for basic car maintenance",
        steps: [
          "Check engine oil level",
          "Inspect tire pressure",
          "Refill windshield washer fluid",
          "Check brake fluid",
          "Examine headlights and taillights",
          "Clean air filters",
          "Schedule professional inspection"
        ],
      ),
      Scenario(
        id: 5,
        title: "House Cleaning",
        description: "Arrange the steps for thorough house cleaning",
        steps: [
          "Declutter rooms and surfaces",
          "Dust furniture and shelves",
          "Vacuum carpets and rugs",
          "Mop hard floors",
          "Clean kitchen appliances",
          "Scrub bathroom fixtures",
          "Empty trash and recycling"
        ],
      ),
      Scenario(
        id: 6,
        title: "Job Interview Prep",
        description: "Put these preparation steps in the right order",
        steps: [
          "Research the company",
          "Review your resume and experience",
          "Prepare answers for common questions",
          "Choose professional attire",
          "Practice with mock interviews",
          "Plan your route to the interview",
          "Arrive 15 minutes early"
        ],
      ),
    ];

    currentScenarioIndex = 0;
    score = 0;
    scoreVisible = false;

    // Initialize all scenarios as locked except the first one
    completedScenarios = List.generate(scenarios.length, (index) => false);

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
      jumbledSteps = Shuffler.shuffleSteps(stepObjects);
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
        // Calculate points earned for this level using score manager
        int pointsEarned = _scoreManager.calculateLevelPoints(attempts);

        // Mark current scenario as completed
        completedScenarios[currentScenarioIndex] = true;

        // Update total score
        score += pointsEarned;
        scoreVisible = true;
        feedback = "Great job! You've arranged the steps correctly!";

        // Show level completion dialog
        Future.delayed(Duration(milliseconds: 500), () {
          _showLevelCompletionDialog(pointsEarned);
        });
      } else {
        feedback = "Not quite right. Try again or use a hint!";
      }
    });
  }

  // Method to show level completion dialog
  void _showLevelCompletionDialog(int pointsEarned) {
    _scoreManager.showLevelCompletionDialog(
      context: context,
      pointsEarned: pointsEarned,
      totalScore: score,
      currentLevel: currentScenarioIndex,
      totalLevels: scenarios.length,
      onNextLevel: _nextScenario,
      onSeeResults: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              score: score,
              totalScenarios: scenarios.length,
            ),
          ),
        );
      },
    );
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

  void _navigateToLevel(int levelIndex) {
    setState(() {
      currentScenarioIndex = levelIndex;
      _resetScenario();
    });
  }

  void _toggleHint() {
    setState(() {
      showHint = !showHint;
    });
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
      case 'car maintenance':
        return Icons.directions_car;
      case 'house cleaning':
        return Icons.cleaning_services;
      case 'job interview prep':
        return Icons.work;
      default:
        return Icons.list_alt;
    }
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Explicitly set to white
          ),
        ),
        backgroundColor: primaryColor.withOpacity(0.95),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        // Set the icon theme to ensure back button is white
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          // Only show score if at least one task has been completed
          if (scoreVisible)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                // Use the score manager to create the score badge
                child: _scoreManager.buildScoreBadge(score),
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
          child: Column(
            children: [
              // Level selector
              LevelSelector(
                totalLevels: scenarios.length,
                currentLevel: currentScenarioIndex,
                completedLevels: completedScenarios,
                onLevelSelected: _navigateToLevel,
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current scenario card
                      ScenarioCard(
                        scenario: scenarios[currentScenarioIndex],
                        currentIndex: currentScenarioIndex,
                        totalScenarios: scenarios.length,
                        slideAnimation: _slideAnimation,
                        scenarioIcon: _getScenarioIcon(
                            scenarios[currentScenarioIndex].title),
                      ),

                      SizedBox(height: 12), // Reduced spacing

                      // Ordered steps section
                      Text(
                        'Your Sequence:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Slightly smaller
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 4), // Reduced spacing
                      Expanded(
                        flex: 5, // Give more space to the ordered sequence
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    // Reverse the ListView to show most recent items at the top
                                    reverse: true,
                                    itemCount: orderedSteps.length,
                                    padding: EdgeInsets.all(12),
                                    itemBuilder: (context, index) {
                                      // Adjust the index to work with reversed list
                                      final actualIndex =
                                          orderedSteps.length - 1 - index;
                                      final step = orderedSteps[actualIndex];
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: ScaleTransition(
                                          // Scale animation for the newest item (now at the top)
                                          scale: index == 0
                                              ? _scaleAnimation
                                              : const AlwaysStoppedAnimation(
                                                  1.0),
                                          child: Material(
                                            color: primaryLighterColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            elevation: 1,
                                            child: InkWell(
                                              onTap: () => _removeStep(step),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
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
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            primaryLightColor,
                                                            primaryColor,
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                primaryLightColor
                                                                    .withOpacity(
                                                                        0.4),
                                                            blurRadius: 4,
                                                            offset:
                                                                Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          // Still display the correct step number
                                                          '${actualIndex + 1}',
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
                                                          color:
                                                              primaryDarkColor,
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

                      SizedBox(height: 8), // Reduced spacing

                      // Available steps section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Steps:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Slightly smaller
                              color: primaryColor,
                            ),
                          ),
                          // Optional: Add a count of remaining steps
                          if (jumbledSteps.isNotEmpty)
                            Text(
                              '${jumbledSteps.length} remaining',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4), // Reduced spacing
                      Expanded(
                        flex: 4, // Less space to available steps
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
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Fixed parameters for consistent box sizing
                                    int crossAxisCount =
                                        2; // Always use 2 columns
                                    int maxRows = 3; // Maximum of 3 rows

                                    // Calculate fixed item dimensions
                                    double availableWidth =
                                        constraints.maxWidth -
                                            24; // Account for padding
                                    double availableHeight =
                                        constraints.maxHeight - 24;

                                    double itemWidth =
                                        (availableWidth / crossAxisCount) -
                                            4; // 8px spacing, 4px per side
                                    double itemHeight =
                                        availableHeight / maxRows -
                                            4; // 8px spacing, 4px per side

                                    return GridView.builder(
                                      padding: EdgeInsets.all(12),
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: itemWidth /
                                            itemHeight, // Use fixed dimensions
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: jumbledSteps.length,
                                      itemBuilder: (context, index) {
                                        final step = jumbledSteps[index];
                                        return Material(
                                          color: primarySuperLightColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          elevation: 1,
                                          child: InkWell(
                                            onTap: () => _selectStep(step),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              width: itemWidth,
                                              height: itemHeight,
                                              padding: EdgeInsets.all(8),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  step.text,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: primaryDarkColor,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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

                      SizedBox(height: 8), // Reduced spacing

                      // Feedback section
                      if (feedback.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCorrect
                                  ? [
                                      Colors.green.shade400,
                                      Colors.green.shade700
                                    ]
                                  : [
                                      Colors.amber.shade400,
                                      Colors.amber.shade700
                                    ],
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

                      SizedBox(height: 8), // Reduced spacing

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
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
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
                                  shadowColor:
                                      Color(0xFF425A64).withOpacity(0.3),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
