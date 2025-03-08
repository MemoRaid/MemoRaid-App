import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_data.dart';

// START SCREEN
// This widget represents the initial screen of the Path Quest game
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller to manage all animations
  late AnimationController _controller;
  // Animation for the logo scaling effect
  late Animation<double> _logoScaleAnimation;
  // Animation for the logo opacity
  late Animation<double> _logoOpacityAnimation;
  // Animation for the button scaling effect
  late Animation<double> _buttonScaleAnimation;
  // Animation for the button opacity
  late Animation<double> _buttonOpacityAnimation;
  // Animation for the score/quote text opacity
  late Animation<double> _scoreOpacityAnimation;

  // List to store wave layers for the animated background
  final List<WaveLayer> _waveLayers = [];
  // Random generator for wave properties
  final Random _random = Random();
  // Notifier to update time-based animations
  final ValueNotifier<double> _timeNotifier = ValueNotifier(0);
  // Timer for continuous animation updates
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with 2.5s duration
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Configure logo scale animation with elastic effect
    // Logo grows from 0 to full size in the first 60% of the animation
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Configure logo opacity animation
    // Logo fades in during the first 30% of the animation
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Configure button scale animation with elastic effect
    // Button grows from 0 to full size during 40%-80% of the animation
    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Configure button opacity animation
    // Button fades in during 40%-60% of the animation
    _buttonOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );

    // Configure score text opacity animation
    // Text fades in during the final 30% of the animation
    _scoreOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Create the wave layers for the animated background
    _generateWaveLayers();

    // Set up a timer to continuously update the time value for wave animations
    // Updates approximately 60 times per second (16ms intervals)
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _timeNotifier.value += 0.016;
    });

    // Start the entrance animations
    _controller.forward();
  }

  // Creates multiple wave layers with randomized properties for the water-like background
  void _generateWaveLayers() {
    // Define base colors for the waves (various shades of blue)
    final List<Color> baseColors = [
      const Color(0xFF0D3445),
      const Color(0xFF0F4155),
      const Color(0xFF125673),
      const Color(0xFF1A789B),
    ];

    // Create 5 wave layers with randomized properties
    for (int i = 0; i < 5; i++) {
      // Select a random base color for this wave
      final baseColor = baseColors[_random.nextInt(baseColors.length)];

      // Add a new wave layer with randomized properties
      _waveLayers.add(
        WaveLayer(
          // Semi-transparent color for layered effect
          color: baseColor.withOpacity(0.12 + _random.nextDouble() * 0.08),
          // Random speed for varied movement
          speed: 0.3 + _random.nextDouble() * 0.7,
          // Random amplitude (height) of the wave
          amplitude: 30 + _random.nextDouble() * 40,
          // Random frequency affects the number of waves
          frequency: 0.005 + _random.nextDouble() * 0.01,
          // Random starting phase so waves don't all sync
          phase: _random.nextDouble() * pi * 2,
          // Position waves at different heights
          heightFactor: 0.55 + (i * 0.1),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Clean up resources when widget is removed
    _controller.dispose();
    _animationTimer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (dark blue to black) for deep sea effect
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D3445),
                  const Color(0xFF0A2A38),
                  const Color(0xFF061A25),
                ],
              ),
            ),
          ),

          // Animated wave background that updates with time
          ValueListenableBuilder(
            valueListenable: _timeNotifier,
            builder: (context, time, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: WaveBackgroundPainter(_waveLayers, time),
              );
            },
          ),

          // Light spots overlay for additional visual effect
          CustomPaint(
            size: Size(size.width, size.height),
            painter: LightSpotsPainter(),
          ),

          // Main content container
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section with animations
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // Logo icon with glowing effect
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return RadialGradient(
                            center: Alignment.center,
                            radius: 0.5,
                            colors: [
                              const Color(0xFF4ECDC4),
                              const Color(0xFF4ECDC4).withOpacity(0.3),
                            ],
                          ).createShader(bounds);
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: CircuitPainter(),
                            child: const Center(
                              child: Icon(
                                Icons.route,
                                size: 60,
                                color: Color(0xFF4ECDC4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Game title with gradient text effect
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'PATH QUEST',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Start game button with animations
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _buttonOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _buttonScaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: GlowingActionButton(
                    onPressed: () {
                      // Provide haptic feedback when button is pressed
                      HapticFeedback.mediumImpact();
                      // Navigate to level selection with fade transition
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 800),
                          pageBuilder: (_, animation, __) {
                            return FadeTransition(
                              opacity: animation,
                              child: const LevelSelectionScreen(),
                            );
                          },
                        ),
                      );
                    },
                    text: 'START GAME',
                  ),
                ),

                const SizedBox(height: 30),

                // Game tagline/quote with animations
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _scoreOpacityAnimation.value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          20 * (1 - _scoreOpacityAnimation.value),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFF4ECDC4).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const ui.Color.fromARGB(255, 25, 66, 64),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Every dot tells a story—remember it well!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: ui.Color.fromARGB(255, 198, 215, 214),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// LEVEL SELECTION SCREEN

// This is the Level Selection Screen widget where users can choose which level to play
class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  // Tracks the highest level unlocked by the player
  int unlockedLevel = 1;

  // Used for animating background elements based on time
  final ValueNotifier<double> _timeNotifier = ValueNotifier(0);
  Timer? _animationTimer;

  // Tracks which level is currently being hovered by the user
  int? _hoveredLevel;

  // Animation controllers for entrance animations
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Load the player's progress from persistent storage
    _loadUnlockedLevel();

    // Initialize animation controller for fade-in animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create fade-in animation with easing
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Set up a timer to continuously update the background animation
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _timeNotifier.value += 0.016; // Approximately 60 FPS
    });

    // Start the entrance animation
    _controller.forward();
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks
    _controller.dispose();
    _animationTimer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  // Loads the player's unlocked level from persistent storage
  Future<void> _loadUnlockedLevel() async {
    final savedUnlockedLevel = await GameDataManager.getUnlockedLevel();

    setState(() {
      unlockedLevel = savedUnlockedLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Allow the background to extend behind the app bar
      extendBodyBehindAppBar: true,

      // Transparent app bar to maintain the themed background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Select Level',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Reset progress button with fade-in animation
      floatingActionButton: FadeTransition(
        opacity: _fadeAnimation,
        child: FloatingActionButton(
          onPressed: _showResetConfirmation,
          backgroundColor: const Color(0xFFE63946),
          foregroundColor: Colors.white,
          elevation: 6,
          tooltip: 'Reset All Progress',
          child: const Icon(Icons.refresh),
        ),
      ),

      body: Stack(
        children: [
          // Dark blue gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D3445),
                  Color(0xFF042f46),
                  Color(0xFF021e2b),
                ],
              ),
            ),
          ),

          // Animated background with custom painter
          // This likely draws particle effects or patterns that animate over time
          ValueListenableBuilder(
            valueListenable: _timeNotifier,
            builder: (context, time, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: LevelSelectBackgroundPainter(time),
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game instructions with entrance animation (fade + slide)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.2),
                        end: Offset.zero,
                      ).animate(_controller),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4ECDC4).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF4ECDC4),
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                "Watch the sequence, remember the order, and tap the dots in the right order. Stay sharp!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid of level selection buttons with fade-in animation
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 levels per row
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: gameLevels.length,
                        itemBuilder: (context, index) {
                          final level = gameLevels[index];
                          final isUnlocked = level.levelNumber <= unlockedLevel;
                          final isHovered = _hoveredLevel == level.levelNumber;

                          // Fetch and display the high score for this level
                          return FutureBuilder<int>(
                            future: _getLevelHighScore(level.levelNumber),
                            builder: (context, snapshot) {
                              final highScore = snapshot.data ?? 0;

                              // Animated scale effect when hovering over a level
                              return AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: isHovered ? 1.05 : 1.0,
                                child: GestureDetector(
                                  // Only allow playing unlocked levels
                                  onTap:
                                      isUnlocked
                                          ? () {
                                            // Haptic feedback for better UX
                                            HapticFeedback.mediumImpact();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => GameScreen(
                                                      level: level,
                                                    ),
                                              ),
                                            ).then((_) {
                                              // Refresh unlocked level data when returning
                                              _loadUnlockedLevel();
                                            });
                                          }
                                          : null,
                                  // Track hover state for visual feedback
                                  onTapDown: (_) {
                                    setState(() {
                                      _hoveredLevel = level.levelNumber;
                                    });
                                  },
                                  onTapUp: (_) {
                                    setState(() {
                                      _hoveredLevel = null;
                                    });
                                  },
                                  onTapCancel: () {
                                    setState(() {
                                      _hoveredLevel = null;
                                    });
                                  },
                                  // Level selection tile with different styling based on unlock status
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // Different gradients for unlocked vs locked levels
                                      gradient:
                                          isUnlocked
                                              ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  const Color(0xFF125673),
                                                  const Color(0xFF0D3445),
                                                ],
                                              )
                                              : LinearGradient(
                                                colors: [
                                                  Colors.grey.shade800,
                                                  Colors.grey.shade900,
                                                ],
                                              ),
                                      borderRadius: BorderRadius.circular(15),
                                      // Enhanced shadow effect when hovering
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              isUnlocked
                                                  ? const Color(
                                                    0xFF4ECDC4,
                                                  ).withOpacity(0.3)
                                                  : Colors.black38,
                                          blurRadius: isHovered ? 12 : 5,
                                          spreadRadius: isHovered ? 2 : 0,
                                        ),
                                      ],
                                      border: Border.all(
                                        color:
                                            isUnlocked
                                                ? const Color(
                                                  0xFF4ECDC4,
                                                ).withOpacity(0.5)
                                                : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Circuit pattern background for unlocked levels
                                        if (isUnlocked)
                                          CustomPaint(
                                            painter: CircuitPatternPainter(),
                                            size: Size.infinite,
                                          ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Level number in a circle
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              // Slightly larger when hovered
                                              width:
                                                  isHovered && isUnlocked
                                                      ? 60
                                                      : 55,
                                              height:
                                                  isHovered && isUnlocked
                                                      ? 60
                                                      : 55,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    isUnlocked
                                                        ? const Color(
                                                          0xFF4ECDC4,
                                                        ).withOpacity(0.2)
                                                        : Colors.grey.shade700
                                                            .withOpacity(0.2),
                                                border: Border.all(
                                                  color:
                                                      isUnlocked
                                                          ? const Color(
                                                            0xFF4ECDC4,
                                                          )
                                                          : Colors
                                                              .grey
                                                              .shade600,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${level.levelNumber}',
                                                  style: TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        isUnlocked
                                                            ? const Color(
                                                              0xFF4ECDC4,
                                                            )
                                                            : Colors
                                                                .grey
                                                                .shade400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Display level type (moving vs static dots)
                                            if (isUnlocked)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    level.dotsMove
                                                        ? Icons.moving
                                                        : Icons.grid_on,
                                                    color: const Color(
                                                      0xFF4ECDC4,
                                                    ).withOpacity(0.7),
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    level.dotsMove
                                                        ? "Moving"
                                                        : "Static",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            // Show high score if available
                                            if (isUnlocked && highScore > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.emoji_events,
                                                      color: Color(0xFFFFD700),
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '$highScore',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        // Lock overlay for locked levels
                                        if (!isUnlocked)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.lock,
                                                color: Colors.white70,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                      ],
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shows a confirmation dialog before resetting all game progress
  void _showResetConfirmation() {
    // Provide haptic feedback for better UX
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF0D3445),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color(0xFF4ECDC4).withOpacity(0.5),
                width: 2,
              ),
            ),
            title: const Text(
              'Reset All Progress?',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.orange,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'This will reset all level unlocks and high scores. This action cannot be undone.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              // Cancel button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: const Text('Cancel'),
              ),
              // Confirm reset button
              ElevatedButton(
                onPressed: () {
                  _resetAllProgress();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE63946),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  // Resets all game progress (unlocked levels and high scores)
  Future<void> _resetAllProgress() async {
    await GameDataManager.resetAllProgress();

    setState(() {
      unlockedLevel = 1; // Reset to only first level unlocked
    });

    // Safety check to avoid showing SnackBar if widget is disposed
    if (!mounted) return;

    // Provide feedback that the reset was successful
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All progress has been reset'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Retrieves the high score for a specific level from persistent storage
  Future<int> _getLevelHighScore(int level) async {
    return GameDataManager.getLevelHighScore(level);
  }
}

// GAME SCREEN
class GameScreen extends StatefulWidget {
  final GameLevel level;

  const GameScreen({super.key, required this.level});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game configuration constants
  static const int maxLives = 3;
  static const Duration sequenceDisplayDuration = Duration(milliseconds: 1000);
  static const Duration shuffleDuration = Duration(seconds: 5);

  // Game state variables
  late int level;
  late int score;
  late int lives;
  late int dotCount; // Number of dots in the level
  late int sequenceLength; // Length of the sequence to memorize
  late List<Dot> dots; // List of all dots in the game
  late List<int> sequence; // The sequence of dots to memorize
  late int currentIndex; // Current position in the sequence during player input
  late bool showingSequence; // Whether the sequence is being displayed
  late bool awaitingInput; // Whether player input is expected
  late bool gameOver; // Whether the game is over
  late Random random; // Random number generator
  late int startTime; // When the level started (for time bonus calculation)
  bool _isFirstBuild = true;
  int? countdownNumber; // Countdown number before player input
  late bool dotsMove; // Whether dots move around
  late bool shuffleAndStop; // Whether dots shuffle and then stop
  Duration dotMovementDuration = const Duration(milliseconds: 1500);
  String gameStatusText = 'Get ready...';

  // Animation controllers and animations for dot movement
  late List<AnimationController> moveControllers;
  late List<Animation<Offset>> moveAnimations;

  // Background animation elements
  final ValueNotifier<double> _backgroundTimeNotifier = ValueNotifier(0);
  Timer? _backgroundAnimationTimer;
  late List<ParticleDot> _backgroundParticles;

  // Tracks target positions for all dots
  List<Offset> targetPositions = [];

  @override
  void initState() {
    super.initState();
    random = Random();
    moveControllers = [];
    moveAnimations = [];
    _initializeGame();

    _setupBackground();

    // Setup timer for background animation
    _backgroundAnimationTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) {
        _backgroundTimeNotifier.value += 0.016;
      },
    );
  }

  /// Sets up background particle effects
  void _setupBackground() {
    _backgroundParticles = List.generate(30, (index) {
      return ParticleDot(
        position: Offset(
          random.nextDouble() * 1000,
          random.nextDouble() * 2000,
        ),
        size: 1.0 + random.nextDouble() * 2.0,
        opacity: 0.1 + random.nextDouble() * 0.2,
        speed: 0.1 + random.nextDouble() * 0.2,
        angle: random.nextDouble() * pi * 2,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Wait for first build to get screen dimensions
    if (!_isFirstBuild) {
      _generateLevel();
    } else {
      _isFirstBuild = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _generateLevel();
        }
      });
    }
  }

  /// Initialize game state with level parameters
  void _initializeGame() {
    level = widget.level.levelNumber;
    score = 0;
    lives = maxLives;
    dotCount = widget.level.dotCount;
    sequenceLength = widget.level.sequenceLength;
    dotsMove = widget.level.dotsMove;
    shuffleAndStop = widget.level.shuffleAndStop;

    // Adjust movement speed based on level configuration
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

  /// Generate level layout with randomly positioned dots
  void _generateLevel() {
    if (!mounted) return;

    dots.clear();
    sequence.clear();
    currentIndex = 0;

    // Get screen dimensions for dot placement
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;
    final safeAreaInsets = MediaQuery.of(context).padding;

    final dotSize = 60.0;
    final safeWidth = screenWidth - dotSize;
    final safeTop = 100.0 + safeAreaInsets.top;
    final safeBottom = screenHeight - dotSize;

    final maxAttempts = 100;

    // Create dots with non-overlapping positions
    for (int i = 0; i < dotCount; i++) {
      bool validPosition = false;
      int attempts = 0;
      double xPos = 0;
      double yPos = 0;

      // Try to find non-overlapping position
      while (!validPosition && attempts < maxAttempts) {
        attempts++;
        xPos = random.nextDouble() * safeWidth;
        yPos = safeTop + random.nextDouble() * (safeBottom - safeTop);

        validPosition = true;

        // Check if this position overlaps with existing dots
        for (var existingDot in dots) {
          final distance = (Offset(xPos, yPos) - existingDot.position).distance;
          final minDistance = dotSize * 1.2;

          if (distance < minDistance) {
            validPosition = false;
            break;
          }
        }
      }

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

    // Generate random sequence if dots were successfully created
    if (dots.isNotEmpty) {
      List<int> indices = List.generate(dotCount, (index) => index);
      indices.shuffle(random);
      sequence = indices.take(sequenceLength).toList();

      // Set up animations if dots should move
      if (dotsMove) {
        _setupMovementAnimations();
      }

      // Show sequence after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showSequence();
        }
      });
    }
  }

  /// Setup animations for dot movement
  void _setupMovementAnimations() {
    if (dots.isEmpty) return;

    // Dispose existing controllers
    for (var controller in moveControllers) {
      controller.dispose();
    }

    moveControllers = [];
    moveAnimations = [];
    targetPositions = List.filled(dots.length, Offset.zero);

    // Get screen dimensions for dot placement
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;
    final safeAreaInsets = MediaQuery.of(context).padding;

    // Create animation controller for each dot
    for (int i = 0; i < dots.length; i++) {
      final controller = AnimationController(
        duration: dotMovementDuration,
        vsync: this,
      );

      final dotSize = dots[i].size;
      final safeWidth = screenWidth - dotSize;
      final safeTop = 100.0 + safeAreaInsets.top;
      final safeBottom = screenHeight - dotSize;

      // Find a new position that doesn't overlap with other dots
      final newPosition = _findNonOverlappingPosition(
        i,
        safeWidth,
        safeTop,
        safeBottom,
        dotSize,
      );

      targetPositions[i] = newPosition;

      // Create animation from current to new position
      final animation = Tween<Offset>(
        begin: dots[i].position,
        end: newPosition,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      // Update dot position during animation
      animation.addListener(() {
        if (mounted && i < dots.length) {
          setState(() {
            dots[i] = dots[i].copyWith(position: animation.value);
          });
        }
      });

      moveControllers.add(controller);
      moveAnimations.add(animation);

      // When animation completes, generate a new target position
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && i < dots.length) {
          final newPosition = _findNonOverlappingPosition(
            i,
            safeWidth,
            safeTop,
            safeBottom,
            dotSize,
          );

          targetPositions[i] = newPosition;

          final newAnimation = Tween<Offset>(
            begin: dots[i].position,
            end: newPosition,
          ).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );

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

  /// Find a position for a dot that doesn't overlap with other dots
  /// Uses collision detection to prevent dots from overlapping
  Offset _findNonOverlappingPosition(
    int dotIndex,
    double safeWidth,
    double safeTop,
    double safeBottom,
    double dotSize,
  ) {
    const maxAttempts = 50;
    int attempts = 0;

    // Try to find non-overlapping position
    while (attempts < maxAttempts) {
      final xPos = random.nextDouble() * safeWidth;
      final yPos = safeTop + random.nextDouble() * (safeBottom - safeTop);
      final testPosition = Offset(xPos, yPos);

      bool overlaps = false;

      // Check if position overlaps with existing dots
      for (int i = 0; i < dots.length; i++) {
        if (i == dotIndex) continue;

        final currentDistance = (testPosition - dots[i].position).distance;
        final minDistance = dotSize * 1.5; // Minimum distance between dots

        // Also check against target positions to avoid future collisions
        final targetDistance =
            targetPositions.isNotEmpty && i < targetPositions.length
                ? (testPosition - targetPositions[i]).distance
                : double.infinity;

        if (currentDistance < minDistance || targetDistance < minDistance) {
          overlaps = true;
          break;
        }
      }

      // Check if movement paths intersect to avoid crossing paths
      if (!overlaps) {
        for (int i = 0; i < dots.length; i++) {
          if (i == dotIndex || i >= targetPositions.length) continue;

          if (_pathsIntersect(
            dots[dotIndex].position,
            testPosition,
            dots[i].position,
            targetPositions[i],
          )) {
            overlaps = true;
            break;
          }
        }
      }

      if (!overlaps) {
        return testPosition;
      }

      attempts++;
    }

    // If no non-overlapping position found, find the best possible position
    double maxMinDistance = 0;
    Offset bestPosition = Offset(
      random.nextDouble() * safeWidth,
      safeTop + random.nextDouble() * (safeBottom - safeTop),
    );

    // Try a few more times to find the best possible position
    for (int attempt = 0; attempt < 20; attempt++) {
      final testX = random.nextDouble() * safeWidth;
      final testY = safeTop + random.nextDouble() * (safeBottom - safeTop);
      final testPos = Offset(testX, testY);

      double minDistanceToOtherDot = double.infinity;
      for (int i = 0; i < dots.length; i++) {
        if (i == dotIndex) continue;
        final dist = (testPos - dots[i].position).distance;
        minDistanceToOtherDot = min(minDistanceToOtherDot, dist);
      }

      if (minDistanceToOtherDot > maxMinDistance) {
        maxMinDistance = minDistanceToOtherDot;
        bestPosition = testPos;
      }
    }

    return bestPosition;
  }

  /// Check if two line segments (paths) intersect
  /// Used to prevent dot movement paths from crossing
  bool _pathsIntersect(Offset a, Offset b, Offset c, Offset d) {
    // Quick bounding box check to avoid expensive calculations
    if (max(a.dx, b.dx) < min(c.dx, d.dx) ||
        max(c.dx, d.dx) < min(a.dx, b.dx) ||
        max(a.dy, b.dy) < min(c.dy, d.dy) ||
        max(c.dy, d.dy) < min(a.dy, b.dy)) {
      return false;
    }

    // Calculate vectors for segment intersection check
    final abX = b.dx - a.dx;
    final abY = b.dy - a.dy;
    final acX = c.dx - a.dx;
    final acY = c.dy - a.dy;
    final adX = d.dx - a.dx;
    final adY = d.dy - a.dy;

    // Check if point c and d are on different sides of line ab
    final cross1 = abX * acY - abY * acX;
    final cross2 = abX * adY - abY * adX;

    if (cross1 * cross2 > 0) return false;

    // Check if point a and b are on different sides of line cd
    final cdX = d.dx - c.dx;
    final cdY = d.dy - c.dy;
    final caX = a.dx - c.dx;
    final caY = a.dy - c.dy;
    final cbX = b.dx - c.dx;
    final cbY = b.dy - c.dy;

    final cross3 = cdX * caY - cdY * caX;
    final cross4 = cdX * cbY - cdY * cbX;

    return cross3 * cross4 <= 0;
  }

  /// Display the sequence for the player to memorize
  void _showSequence() {
    if (sequence.isEmpty) return;

    setState(() {
      showingSequence = true;
      awaitingInput = false;
      gameStatusText = 'Watch carefully...';
    });

    // Show each dot in the sequence one by one
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

          // Highlight the current dot in the sequence
          final dotIndex = sequence[index];
          dots[dotIndex] = dots[dotIndex].copyWith(
            isHighlighted: true,
            isActive: true,
          );
        });
      }

      // Blink the dot twice
      for (int i = 0; i < 2; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            final dotIndex = sequence[index];
            dots[dotIndex] = dots[dotIndex].copyWith(
              isHighlighted: !dots[dotIndex].isHighlighted,
            );
          });
        }
      }

      await Future.delayed(sequenceDisplayDuration);

      // Reset dot highlight
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
        // If dots should shuffle and stop, start shuffle phase
        if (shuffleAndStop && dotsMove) {
          _startShufflePhase();
        } else {
          _startCountdown();
        }
      }
    });
  }

  /// Start shuffling dots before player input
  void _startShufflePhase() {
    setState(() {
      gameStatusText = 'Dots are shuffling...';
    });

    // Start all movement animations
    for (var controller in moveControllers) {
      controller.forward();
    }

    // Stop movements after shuffle duration
    Future.delayed(shuffleDuration, () {
      if (mounted) {
        for (var controller in moveControllers) {
          controller.stop();
        }

        _startCountdown();
      }
    });
  }

  /// Start countdown before player input
  void _startCountdown() {
    setState(() {
      countdownNumber = 3;
      gameStatusText = 'Get ready...';
    });

    // Countdown from 3 to 0
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
          gameStatusText = 'Your turn!';

          // Start dot movement if enabled and not shuffle-and-stop mode
          if (dotsMove && !shuffleAndStop) {
            for (var controller in moveControllers) {
              controller.forward();
            }
          }
        });
      }
    });
  }

  /// Handle player tapping a dot
  void _handleDotTap(int dotId) {
    if (!awaitingInput || gameOver) return;

    final expectedDotId = sequence[currentIndex];

    // Check if tapped the correct dot
    if (dotId == expectedDotId) {
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

      // Check if level complete
      if (currentIndex >= sequence.length) {
        _handleLevelComplete();
      }
    } else {
      // Wrong dot tapped
      setState(() {
        lives--;
        score = max(0, score - 5);
      });

      _showErrorAnimation();

      // Check if game over
      if (lives <= 0) {
        _handleGameOver();
      }
    }
  }

  /// Handle level completion
  void _handleLevelComplete() {
    // Stop dot movement
    if (dotsMove) {
      for (var controller in moveControllers) {
        controller.stop();
      }
    }

    // Calculate time bonus
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final timeElapsed = (endTime - startTime) / 1000;
    int timeBonus = max(0, 100 - (timeElapsed.toInt() * 2));

    // Perfect play bonus
    final perfectBonus = lives >= maxLives ? 50 : 0;

    setState(() {
      score += timeBonus;
      score += perfectBonus;
      awaitingInput = false;
    });

    // Check for level achievement and show results screen
    _checkLevelAchievement().then((achievement) {
      if (!mounted) return;

      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder:
              (_, __, ___) => GameResultsScreen(
                level: level,
                score: score,
                timeBonus: timeBonus,
                perfectBonus: perfectBonus,
                achievement: achievement,
                onContinue: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
        ),
      );
    });
  }

  /// Check if player earned any achievements for this level
  Future<LevelAchievement> _checkLevelAchievement() async {
    return GameDataManager.checkLevelAchievement(level, score);
  }

  /// Handle game over
  void _handleGameOver() {
    setState(() {
      gameOver = true;
      awaitingInput = false;
    });

    // Save high score
    _saveLevelHighScore(score);

    // Show game over screen
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (_, __, ___) => GameOverScreen(
              score: score,
              onRetry: () {
                Navigator.of(context).pop();
                setState(() {
                  _initializeGame();
                  _generateLevel();
                });
              },
              onExit: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
      ),
    );
  }

  /// Save high score for level
  Future<void> _saveLevelHighScore(int score) async {
    GameDataManager.saveLevelHighScore(level, score);
  }

  /// Show red flash animation for error
  void _showErrorAnimation() {
    OverlayEntry entry = OverlayEntry(
      builder:
          (context) => Positioned.fill(
            child: Container(color: Colors.red.withAlpha(76)),
          ),
    );

    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(milliseconds: 200), () {
      entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Allow the background to extend behind the app bar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Level $level',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Score display container in the app bar
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3445).withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background container
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D3445),
                  Color(0xFF042538),
                  Color(0xFF021824),
                ],
              ),
            ),
          ),

          // Animated background particles using CustomPaint
          ValueListenableBuilder(
            valueListenable: _backgroundTimeNotifier,
            builder: (context, time, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: GameBackgroundPainter(
                  time: time,
                  particles: _backgroundParticles,
                ),
              );
            },
          ),

          Column(
            children: [
              // Space for the AppBar and status area
              SizedBox(height: MediaQuery.of(context).padding.top + 70),

              // Lives/Hearts display container
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  // Generate hearts based on the number of lives
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      maxLives,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: index < lives ? 1.0 : 0.3,
                          child: Icon(
                            Icons.favorite,
                            color: index < lives ? Colors.red : Colors.grey,
                            size: 28,
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Game status text container - changes appearance based on game state
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  // Color changes depending on game state
                  color:
                      showingSequence
                          ? const Color(0xFF4ECDC4)
                          : (awaitingInput
                              ? Colors.green
                              : Colors.grey.shade700),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                width: double.infinity,
                child: Text(
                  gameStatusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // Main game area with dots
              Expanded(
                child: Stack(
                  children: [
                    // Dynamic positioning of game dots
                    for (final dot in dots)
                      Positioned(
                        left: dot.position.dx,
                        top: dot.position.dy,
                        child: GestureDetector(
                          // Handle tap events on dots
                          onTap: () => _handleDotTap(dot.id),
                          child: AnimatedContainer(
                            // Animation for highlighting the dots
                            duration: const Duration(milliseconds: 150),
                            width:
                                dot.isHighlighted ? dot.size * 1.3 : dot.size,
                            height:
                                dot.isHighlighted ? dot.size * 1.3 : dot.size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Gradient effect for the dots
                              gradient: RadialGradient(
                                colors: [
                                  dot.isHighlighted
                                      ? Colors.orange
                                      : const Color(0xFF4ECDC4),
                                  dot.isHighlighted
                                      ? Colors.orange.shade700
                                      : Colors.blue.shade700,
                                ],
                                center: const Alignment(-0.3, -0.3),
                                focal: const Alignment(-0.5, -0.5),
                                focalRadius: 0.2,
                              ),
                              // Glow effect for the dots
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      dot.isHighlighted
                                          ? Colors.orange.withOpacity(0.8)
                                          : const Color(
                                            0xFF4ECDC4,
                                          ).withOpacity(0.4),
                                  blurRadius: dot.isHighlighted ? 20 : 10,
                                  spreadRadius: dot.isHighlighted ? 5 : 1,
                                ),
                              ],
                            ),
                            // Dot number display
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 150),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: dot.isHighlighted ? 24 : 16,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text('${dot.id + 1}'),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Countdown overlay that appears before the game starts
                    if (countdownNumber != null)
                      Positioned.fill(
                        child: BackdropFilter(
                          // Apply blur effect to the background
                          filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: AnimatedScale(
                                // Animation for the countdown number
                                scale: countdownNumber == 0 ? 1.5 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    // Different colors for GO! vs numbers
                                    color:
                                        countdownNumber == 0
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.blue.withOpacity(0.3),
                                    border: Border.all(
                                      color:
                                          countdownNumber == 0
                                              ? Colors.green
                                              : Colors.blue,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (countdownNumber == 0
                                                ? Colors.green
                                                : Colors.blue)
                                            .withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  // Display GO! when countdown reaches zero
                                  child: Text(
                                    countdownNumber == 0
                                        ? "GO!"
                                        : countdownNumber.toString(),
                                    style: TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(2, 2),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources when the widget is removed
    _backgroundAnimationTimer?.cancel();
    _backgroundTimeNotifier.dispose();

    // Dispose all animation controllers to prevent memory leaks
    for (var controller in moveControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
// GAME RESULTS SCREEN
class GameResultsScreen extends StatelessWidget {
  // Properties to display game results
  final int level; // Current level number
  final int score; // Total score achieved
  final int timeBonus; // Bonus points from completing level quickly
  final int perfectBonus; // Bonus points from perfect level completion
  final LevelAchievement
      achievement; // Contains achievement data like high scores
  final VoidCallback
      onContinue; // Function to call when "Menu" button is pressed

  const GameResultsScreen({
    Key? key,
    required this.level,
    required this.score,
    required this.timeBonus,
    required this.perfectBonus,
    required this.achievement,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Main scaffold with semi-transparent background
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          // Responsive width based on screen size
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          // Styled container with cyberpunk/tech theme colors
          decoration: BoxDecoration(
            color: const Color(0xFF0D3445), // Dark blue background
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4)
                    .withOpacity(0.3), // Teal glow effect
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: const Color(0xFF4ECDC4).withOpacity(0.5), // Teal border
              width: 2,
            ),
          ),
          // Main content column
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top icon that changes based on achievement type
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(
                    color: const Color(0xFF4ECDC4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  // Trophy icon for special achievements, check mark for regular completion
                  achievement.isSpecialAchievement
                      ? Icons.emoji_events
                      : Icons.check_circle,
                  size: 40,
                  // Gold color for special achievements, teal for regular
                  color: achievement.isSpecialAchievement
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF4ECDC4),
                ),
              ),