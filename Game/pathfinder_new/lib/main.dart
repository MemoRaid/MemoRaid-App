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

  const GameLevel({
    required this.levelNumber,
    required this.dotCount,
    required this.sequenceLength,
    this.dotsMove = false,
    this.movementSpeed = 1.0,
  });
}

import 'game_level.dart';

final List<GameLevel> gameLevels = [
  const GameLevel(levelNumber: 1, dotCount: 3, sequenceLength: 3),
  const GameLevel(levelNumber: 2, dotCount: 4, sequenceLength: 4),
  const GameLevel(levelNumber: 3, dotCount: 5, sequenceLength: 4, dotsMove: true, movementSpeed: 0.5),
];

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'level_selection_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('PATH FINDER', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LevelSelectionScreen()));
              },
              child: const Text('Start Game'),
            ),
            FutureBuilder<int>(
              future: _getHighScore(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('High Score: ${snapshot.data}');
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_level.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadUnlockedLevel();
  }

  Future<void> _loadUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      unlockedLevel = prefs.getInt('unlockedLevel') ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: gameLevels.length,
        itemBuilder: (context, index) {
          final level = gameLevels[index];
          return GestureDetector(
            onTap: level.levelNumber <= unlockedLevel
                ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen(level: level)))
                : null,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: level.levelNumber <= unlockedLevel ? Colors.white : Colors.grey),
              child: Center(child: Text('${level.levelNumber}')),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:ui';

class Dot {
  final int id;
  final Offset position;
  final double size;
  final bool isActive;
  final bool isHighlighted;

  Dot({
    required this.id,
    required this.position,
    required this.size,
    required this.isActive,
    required this.isHighlighted,
  });

  Dot copyWith({Offset? position, bool? isActive, bool? isHighlighted}) {
    return Dot(
      id: id,
      position: position ?? this.position,
      size: size,
      isActive: isActive ?? this.isActive,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}

import 'package:flutter/material.dart';

class Animations {
  static Widget fadeInWidget(Widget child) {
    return TweenAnimationBuilder(
      duration: const Duration(seconds: 1),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class HighScore {
  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }

  static Future<void> setHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', score);
  }
}
