import 'package:flutter/material.dart';
import 'start_screen.dart';

void main() {
  runApp(const PathFinderApp());
}

class PathFinderApp extends StatelessWidget {
  const PathFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const StartScreen(),
    );
  }
}

class GameLevel {
  final int levelNumber;
  final int dotCount;
  final int sequenceLength;
  final bool dotsMove;
  final double movementSpeed;
}
