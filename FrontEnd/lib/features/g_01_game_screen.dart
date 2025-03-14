import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../models/task_step.dart';
import '../utils/shuffler.dart';
import 'results_screen.dart';

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
}
