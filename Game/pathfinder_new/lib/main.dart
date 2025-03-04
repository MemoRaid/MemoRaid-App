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
  void _initializeGame() {
    // Initialize based on the passed level
    level = widget.level.levelNumber;
    score = 0;
    lives = maxLives;
    dotCount = widget.level.dotCount;
    sequenceLength = widget.level.sequenceLength;
    dotsMove = widget.level.dotsMove;

    // Adjust movement speed based on level
    dotMovementDuration = Duration(
      milliseconds: (1500 / widget.level.movementSpeed).round(),
    );

    dots = [];
    sequence = [];
    currentIndex = 0;
    showingSequence = false;
    awaitingInput = false;
    gameOver = false;
    startTime = DateTime.now().millisecondsSinceEpoch;
  }

  void _generateLevel() {
    if (!mounted) return;

    // Clear previous level data
    dots.clear();
    sequence.clear();
    currentIndex = 0;

    // Generate dots and their positions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;
    final safeAreaInsets = MediaQuery.of(context).padding;

    // Calculate safe boundaries to keep dots fully on screen
    final dotSize = 60.0;
    final safeWidth = screenWidth - dotSize;
    final safeTop = 100.0 + safeAreaInsets.top; // Top padding + status bar
    final safeBottom = screenHeight - dotSize;

    // Generate dots with random positions within safe bounds
    for (int i = 0; i < dotCount; i++) {
      final xPos = random.nextDouble() * safeWidth;
      final yPos = safeTop + random.nextDouble() * (safeBottom - safeTop);

      dots.add(
        Dot(
          id: i,
          position: Offset(xPos, yPos),
          size: dotSize,
          isActive: false,
          isHighlighted: false,
        ),
      );
    }

    // Generate random sequence only if we have dots
    if (dots.isNotEmpty) {
      // Use only the number of dots we need for the sequence
      List<int> indices = List.generate(dotCount, (index) => index);
      indices.shuffle(random);
      // Take only the required number of dots for the sequence
      sequence = indices.take(sequenceLength).toList();

      // Setup animation controllers for dot movement
      if (dotsMove) {
        _setupMovementAnimations();
      }

      // Start showing the sequence after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showSequence();
        }
      });
    }
  }

  void _setupMovementAnimations() {
    // Don't proceed if no dots
    if (dots.isEmpty) return;

    // Dispose old controllers if any
    for (var controller in moveControllers) {
      controller.dispose();
    }

    moveControllers = [];
    moveAnimations = [];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;
    final safeAreaInsets = MediaQuery.of(context).padding;

    for (int i = 0; i < dots.length; i++) {
      // Create animation controller
      final controller = AnimationController(
        duration: dotMovementDuration,
        vsync: this,
      );

      // Calculate safe boundaries for this dot
      final dotSize = dots[i].size;
      final safeWidth = screenWidth - dotSize;
      final safeTop = 100.0 + safeAreaInsets.top; // Top padding + status bar
      final safeBottom = screenHeight - dotSize;

      // Calculate a new random position within safe bounds
      final newX = random.nextDouble() * safeWidth;
      final newY = safeTop + random.nextDouble() * (safeBottom - safeTop);

      // Create tween animation
      final animation = Tween<Offset>(
        begin: dots[i].position,
        end: Offset(newX, newY),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      // Add listener to update dot position
      animation.addListener(() {
        if (mounted && i < dots.length) {
          // Check if index is valid
          setState(() {
            dots[i] = dots[i].copyWith(position: animation.value);
          });
        }
      });

      moveControllers.add(controller);
      moveAnimations.add(animation);

      // When animation completes, start a new one in a different direction
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && i < dots.length) {
          // Calculate new safe position within screen bounds
          final newX = random.nextDouble() * safeWidth;
          final newY = safeTop + random.nextDouble() * (safeBottom - safeTop);

          // Create a new tween animation with new positions
          final newAnimation = Tween<Offset>(
            begin: dots[i].position,
            end: Offset(newX, newY),
          ).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );

          // Add listener to update dot position
          newAnimation.addListener(() {
            if (mounted && i < dots.length) {
              setState(() {
                dots[i] = dots[i].copyWith(position: newAnimation.value);
              });
            }
          });

          if (i < moveAnimations.length) {
            moveAnimations[i] = newAnimation;
          }

          controller.reset();
          controller.forward();
        }
      });
    }
  }

  void _showSequence() {
    if (sequence.isEmpty) return; // Don't proceed with empty sequence

    setState(() {
      showingSequence = true;
      awaitingInput = false;
    });

    // Show sequence one by one
    Future.forEach(List.generate(sequence.length, (index) => index), (
      index,
    ) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          // Reset all dots
          for (int i = 0; i < dots.length; i++) {
            dots[i] = dots[i].copyWith(isHighlighted: false, isActive: false);
          }

          // Highlight current dot in sequence
          final dotIndex = sequence[index];
          dots[dotIndex] = dots[dotIndex].copyWith(
            isHighlighted: true,
            isActive: true,
          );
        });
      }

      // Blink effect
      for (int i = 0; i < 2; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          setState(() {
            final dotIndex = sequence[index];
            dots[dotIndex] = dots[dotIndex].copyWith(
              isHighlighted: !dots[dotIndex].isHighlighted,
            );
          });
        }
      }

      // Wait for display duration
      await Future.delayed(sequenceDisplayDuration);

      // Turn off highlight
      if (mounted) {
        setState(() {
          final dotIndex = sequence[index];
          dots[dotIndex] = dots[dotIndex].copyWith(
            isHighlighted: false,
            isActive: false,
          );
        });
      }
    }).then((_) {
      if (mounted) {
        // Start countdown
        _startCountdown();
      }
    });
  }

void _startCountdown() {
    setState(() {
      countdownNumber = 3;
    });

    // Countdown 3, 2, 1
    Future.forEach([2, 1, 0], (number) async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          countdownNumber = number;
        });
      }
    }).then((_) {
      if (mounted) {
        setState(() {
          countdownNumber = null;
          showingSequence = false;
          awaitingInput = true;

          // Start dot movement for level 3+
          if (dotsMove) {
            for (var controller in moveControllers) {
              controller.forward();
            }
          }
        });
      }
    });
  }

  void _handleDotTap(int dotId) {
    // Ignore taps if not awaiting input
    if (!awaitingInput || gameOver) return;

    final expectedDotId = sequence[currentIndex];

    if (dotId == expectedDotId) {
      // Correct tap
      setState(() {
        dots[dotId] = dots[dotId].copyWith(isHighlighted: true);
        score += 10;
        currentIndex++;
      });

      // Visual feedback for correct tap
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            dots[dotId] = dots[dotId].copyWith(isHighlighted: false);
          });
        }
      });

      // Check if the sequence is complete
      if (currentIndex >= sequence.length) {
        _handleLevelComplete();
      }
    } else {
      // Incorrect tap
      setState(() {
        lives--;
        score = max(0, score - 5);
      });

      // Visual feedback for wrong tap
      _showErrorAnimation();

      if (lives <= 0) {
        _handleGameOver();
      }
    }
  }
