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
