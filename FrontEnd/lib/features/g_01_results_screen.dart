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