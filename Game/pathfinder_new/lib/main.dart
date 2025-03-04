import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// Level data class to define each level's properties
class GameLevel {
  final int levelNumber;
  final int dotCount;
  final int sequenceLength;
  final bool dotsMove;
  final double movementSpeed;

  const GameLevel({
    required this.levelNumber,
    required this.dotCount,
    required this.sequenceLength,
    this.dotsMove = false,
    this.movementSpeed = 1.0,
  });
}

// Define all game levels
final List<GameLevel> gameLevels = [
  const GameLevel(levelNumber: 1, dotCount: 3, sequenceLength: 3),
  const GameLevel(levelNumber: 2, dotCount: 4, sequenceLength: 4),
  const GameLevel(
    levelNumber: 3,
    dotCount: 5,
    sequenceLength: 4,
    dotsMove: true,
    movementSpeed: 0.5,
  ),
  const GameLevel(
    levelNumber: 4,
    dotCount: 5,
    sequenceLength: 5,
    dotsMove: true,
    movementSpeed: 0.7,
  ),
  const GameLevel(
    levelNumber: 5,
    dotCount: 6,
    sequenceLength: 5,
    dotsMove: true,
    movementSpeed: 0.8,
  ),
  const GameLevel(
    levelNumber: 6,
    dotCount: 6,
    sequenceLength: 6,
    dotsMove: true,
    movementSpeed: 0.9,
  ),
  const GameLevel(
    levelNumber: 7,
    dotCount: 7,
    sequenceLength: 6,
    dotsMove: true,
    movementSpeed: 1.0,
  ),
  const GameLevel(
    levelNumber: 8,
    dotCount: 7,
    sequenceLength: 7,
    dotsMove: true,
    movementSpeed: 1.1,
  ),
  const GameLevel(
    levelNumber: 9,
    dotCount: 8,
    sequenceLength: 7,
    dotsMove: true,
    movementSpeed: 1.2,
  ),
  const GameLevel(
    levelNumber: 10,
    dotCount: 8,
    sequenceLength: 8,
    dotsMove: true,
    movementSpeed: 1.3,
  ),
  const GameLevel(
    levelNumber: 11,
    dotCount: 9,
    sequenceLength: 8,
    dotsMove: true,
    movementSpeed: 1.4,
  ),
  const GameLevel(
    levelNumber: 12,
    dotCount: 9,
    sequenceLength: 9,
    dotsMove: true,
    movementSpeed: 1.5,
  ),
  const GameLevel(
    levelNumber: 13,
    dotCount: 10,
    sequenceLength: 9,
    dotsMove: true,
    movementSpeed: 1.6,
  ),
  const GameLevel(
    levelNumber: 14,
    dotCount: 10,
    sequenceLength: 10,
    dotsMove: true,
    movementSpeed: 1.7,
  ),
  const GameLevel(
    levelNumber: 15,
    dotCount: 12,
    sequenceLength: 10,
    dotsMove: true,
    movementSpeed: 1.8,
  ),
];

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade200],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'PATH FINDER',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black38,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LevelSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Start Game',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<int>(
                future: _getHighScore(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'High Score: ${snapshot.data}',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }
}
