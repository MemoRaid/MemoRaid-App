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
    final savedUnlockedLevel = prefs.getInt('unlockedLevel') ?? 1;

    setState(() {
      unlockedLevel = savedUnlockedLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showResetConfirmation,
        backgroundColor: Colors.red,
        tooltip: 'Reset All Progress',
        child: const Icon(Icons.refresh),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade100],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a Level:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: gameLevels.length,
                  itemBuilder: (context, index) {
                    final level = gameLevels[index];
                    final isUnlocked = level.levelNumber <= unlockedLevel;

                    return FutureBuilder<int>(
                      future: _getLevelHighScore(level.levelNumber),
                      builder: (context, snapshot) {
                        final highScore = snapshot.data ?? 0;

                        return GestureDetector(
                          onTap:
                              isUnlocked
                                  ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                GameScreen(level: level),
                                      ),
                                    ).then((_) {
                                      // Refresh unlocked levels when returning from game
                                      _loadUnlockedLevel();
                                    });
                                  }
                                  : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isUnlocked
                                      ? Colors.white
                                      : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${level.levelNumber}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isUnlocked
                                                ? Colors.blue
                                                : Colors.grey.shade700,
                                      ),
                                    ),
                                    if (isUnlocked && highScore > 0)
                                      Text(
                                        'Best: $highScore',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                  ],
                                ),
                                if (!isUnlocked)
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.black38,
                                    size: 30,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset All Progress?'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 50),
                SizedBox(height: 10),
                Text(
                  'This will reset all level unlocks and high scores. This action cannot be undone.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _resetAllProgress();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  Future<void> _resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Reset unlocked levels back to 1
    await prefs.setInt('unlockedLevel', 1);

    // Reset overall high score
    await prefs.setInt('highScore', 0);

    // Reset all level high scores
    for (final level in gameLevels) {
      await prefs.remove('highScore_level_${level.levelNumber}');
    }

    // Update UI
    setState(() {
      unlockedLevel = 1;
    });

    // Show confirmation to user
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All progress has been reset'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<int> _getLevelHighScore(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore_level_$level') ?? 0;
  }
}

class GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game constants
  static const int maxLives = 3;
  static const Duration sequenceDisplayDuration = Duration(milliseconds: 800);

  // Game state variables
  late int level;
  late int score;
  late int lives;
  late int dotCount;
  late int sequenceLength;
  late List<Dot> dots;
  late List<int> sequence;
  late int currentIndex;
  late bool showingSequence;
  late bool awaitingInput;
  late bool gameOver;
  late Random random;
  late int startTime;
  bool _isFirstBuild = true;
  int? countdownNumber;
  late bool dotsMove;
  Duration dotMovementDuration = const Duration(milliseconds: 1500);

  // Controllers for animations
  late List<AnimationController> moveControllers;
  late List<Animation<Offset>> moveAnimations;

  @override
  void initState() {
    super.initState();
    random = Random();
    moveControllers = [];
    moveAnimations = [];
    _initializeGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only generate levels after the first build to ensure context is available
    if (!_isFirstBuild) {
      _generateLevel();
    } else {
      _isFirstBuild = false;
      // Schedule level generation after the first frame is drawn
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _generateLevel();
        }
      });
    }
  }
