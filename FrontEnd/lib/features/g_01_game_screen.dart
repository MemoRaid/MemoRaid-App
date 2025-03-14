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

class _GameScreenState extends State<GameScreen> {
  late List<Scenario> scenarios;
  late int currentScenarioIndex;
  late List<TaskStep> jumbledSteps;
  late List<TaskStep> orderedSteps;
  late bool isCorrect;
  late bool showHint;
  late String feedback;
  late int attempts;
  late int score;

  @override
  void initState() {
    super.initState();
    _initializeGame();
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

    jumbledSteps = Shuffler.shuffleSteps(stepObjects);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Tasks Sequencer'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score display
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

            SizedBox(height: 16),

            // Current scenario info
            Container(
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
                    : ListView.separated(
                        itemCount: orderedSteps.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final step = orderedSteps[index];
                          return Container(
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
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline,
                                      color: Colors.red),
                                  onPressed: () => _removeStep(step),
                                ),
                              ],
                            ),
                          );
                        },
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
                    : ListView.separated(
                        itemCount: jumbledSteps.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final step = jumbledSteps[index];
                          return GestureDetector(
                            onTap: () => _selectStep(step),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(step.text),
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
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isCorrect ? Colors.green.shade100 : Colors.amber.shade100,
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

            // Hint section
            if (showHint)
              Container(
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
                ElevatedButton.icon(
                  onPressed: orderedSteps.length ==
                              scenarios[currentScenarioIndex].steps.length &&
                          !isCorrect
                      ? _checkAnswer
                      : null,
                  icon: Icon(Icons.check_circle),
                  label: Text('Check Answer'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleHint,
                  icon: Icon(Icons.lightbulb_outline),
                  label: Text(showHint ? 'Hide Hint' : 'Show Hint'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                if (isCorrect)
                  ElevatedButton.icon(
                    onPressed: _nextScenario,
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                if (!isCorrect)
                  ElevatedButton.icon(
                    onPressed: _resetScenario,
                    icon: Icon(Icons.refresh),
                    label: Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
