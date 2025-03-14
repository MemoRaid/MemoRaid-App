import 'package:flutter/material.dart';

import 'package:confetti/confetti.dart';

class ResultsScreen extends StatefulWidget {
  final int score;
  final int totalScenarios;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.totalScenarios,
  });

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 5));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
}
