import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_data.dart';

//------------------------------------------------------------------------------
// GAME SCREENS
//------------------------------------------------------------------------------

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
                                  onTap: isUnlocked
                                      ? () {
                                          // Haptic feedback for better UX
                                          HapticFeedback.mediumImpact();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => GameScreen(
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
                                      gradient: isUnlocked
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
                                          color: isUnlocked
                                              ? const Color(
                                                  0xFF4ECDC4,
                                                ).withOpacity(0.3)
                                              : Colors.black38,
                                          blurRadius: isHovered ? 12 : 5,
                                          spreadRadius: isHovered ? 2 : 0,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: isUnlocked
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
                                              width: isHovered && isUnlocked
                                                  ? 60
                                                  : 55,
                                              height: isHovered && isUnlocked
                                                  ? 60
                                                  : 55,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isUnlocked
                                                    ? const Color(
                                                        0xFF4ECDC4,
                                                      ).withOpacity(0.2)
                                                    : Colors.grey.shade700
                                                        .withOpacity(0.2),
                                                border: Border.all(
                                                  color: isUnlocked
                                                      ? const Color(
                                                          0xFF4ECDC4,
                                                        )
                                                      : Colors.grey.shade600,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${level.levelNumber}',
                                                  style: TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color: isUnlocked
                                                        ? const Color(
                                                            0xFF4ECDC4,
                                                          )
                                                        : Colors.grey.shade400,
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
      builder: (context) => AlertDialog(
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

  // Timer related variables
  Timer? _gameTimer;
  late int _timeLimit; // Time limit in seconds
  late int _remainingTime; // Time remaining in seconds
  bool _timeExpired = false;

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

    // Set time limit based on level difficulty
    // Base time + additional time for each dot in the sequence
    _timeLimit = 10 + (sequenceLength * 2);
    _remainingTime = _timeLimit;
    _timeExpired = false;

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

          // Start the game timer when player's turn begins
          _startGameTimer();

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

  /// Start the game timer that counts down
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timeExpired = true;
            _gameTimer?.cancel();
            // Only end the game if awaiting input (not during sequence display)
            if (awaitingInput && !gameOver) {
              _handleGameOver();
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
          pageBuilder: (_, __, ___) => GameResultsScreen(
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

    // Cancel the game timer
    _gameTimer?.cancel();

    // Save high score
    _saveLevelHighScore(score);

    // Show game over screen
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => GameOverScreen(
          score: score,
          timeExpired: _timeExpired, // Pass the reason for game over
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
      builder: (context) => Positioned.fill(
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
                  color: showingSequence
                      ? const Color(0xFF4ECDC4)
                      : (awaitingInput ? Colors.green : Colors.grey.shade700),
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
                                  color: dot.isHighlighted
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

                    // Timer positioned in top right corner below status area
                    if (awaitingInput && !gameOver)
                      Positioned(
                        top: 10, // Positioned below the status box
                        right: 16, // Right aligned
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _remainingTime < 6
                                  ? Colors.red
                                  : const Color(
                                      0xFF4ECDC4,
                                    ).withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color: _remainingTime < 6
                                    ? Colors.red
                                    : const Color(0xFF4ECDC4),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_remainingTime s',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _remainingTime < 6
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Countdown overlay that appears before the game starts
                    if (countdownNumber != null)
                      Positioned.fill(
                        child: BackdropFilter(
                          // Apply a subtle blur effect to the background
                          filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.5),
                            // Ensure proper centering with Alignment
                            alignment: Alignment.center,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 600),
                              scale: 1.0,
                              curve: Curves.elasticOut,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: countdownNumber == 0
                                      ? Colors.green.withOpacity(0.7)
                                      : const Color.fromARGB(
                                          255,
                                          0,
                                          87,
                                          193,
                                        ).withOpacity(0.7),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                // Added alignment for inner content
                                alignment: Alignment.center,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    countdownNumber == 0
                                        ? "GO!"
                                        : countdownNumber.toString(),
                                    key: ValueKey(countdownNumber),
                                    style: TextStyle(
                                      fontSize: countdownNumber == 0 ? 50 : 60,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              onEnd: () {
                                if (mounted && countdownNumber != null) {
                                  HapticFeedback.mediumImpact();
                                }
                              },
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
    _gameTimer?.cancel();

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
                color: const Color(
                  0xFF4ECDC4,
                ).withOpacity(0.3), // Teal glow effect
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
                  border: Border.all(color: const Color(0xFF4ECDC4), width: 2),
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
              const SizedBox(height: 16),
              // Main title - changes based on achievement type
              Text(
                achievement.isSpecialAchievement
                    ? 'Congratulations!'
                    : 'Level Complete',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              // Level number display
              Text(
                'Level $level Completed',
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF4ECDC4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Score breakdown section
              // Base score (without bonuses)
              _buildScoreRow('Base Score', score - timeBonus - perfectBonus),
              // Time bonus points
              _buildScoreRow('Time Bonus', timeBonus),
              // Only show perfect bonus if it exists
              if (perfectBonus > 0)
                _buildScoreRow('Perfect Clear Bonus', perfectBonus),

              // Divider before total score
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: 2,
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
              ),

              // Total/final score with enhanced styling
              _buildScoreRow('Final Score', score, isTotal: true),
              const SizedBox(height: 24),

              // Conditional achievement displays
              // New high score achievement
              if (achievement.isNewHighScore)
                _buildAchievementRow(
                  'New High Score!',
                  'Previous: ${achievement.previousHighScore}',
                  Icons.star,
                  const Color(0xFFFFD700), // Gold color
                ),
              // New level unlocked achievement
              if (achievement.isNewLevelUnlocked)
                _buildAchievementRow(
                  'New Level Unlocked!',
                  'Keep going for more challenges',
                  Icons.lock_open,
                  const Color(0xFF4ECDC4), // Teal color
                ),
              const SizedBox(height: 32),

              // Continue button to return to menu
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4), // Teal button
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 6, // Button shadow for depth
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build score row with label and value
  // isTotal parameter controls if row has enhanced styling for total score
  Widget _buildScoreRow(String label, int value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score label (left side)
          Text(
            label,
            style: TextStyle(
              // Larger font and bold for total score
              fontSize: isTotal ? 20 : 18,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          // Score value (right side)
          Text(
            '+$value',
            style: TextStyle(
              // Larger font, bold, and teal color for total score
              fontSize: isTotal ? 24 : 18,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF4ECDC4) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build achievement notification rows
  // Used for displaying high score and level unlock achievements
  Widget _buildAchievementRow(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      // Container with color matching the achievement type
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // Semi-transparent background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Icon with circular background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          // Achievement text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Achievement title (e.g., "New High Score!")
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                // Achievement subtitle with additional info
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
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

// This widget displays the game over screen when a player loses
// It shows the final score and provides options to retry or return to menu
class GameOverScreen extends StatelessWidget {
  // Player's final score to display
  final int score;
  // Whether the game ended due to timer expiring
  final bool timeExpired;
  // Callback function for when player chooses to retry
  final VoidCallback onRetry;
  // Callback function for when player chooses to exit to menu
  final VoidCallback onExit;

  // Constructor requiring score and callback functions
  const GameOverScreen({
    Key? key,
    required this.score,
    this.timeExpired = false,
    required this.onRetry,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Semi-transparent black background
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          // Modal takes up 85% of screen width
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          // Styling for the modal container
          decoration: BoxDecoration(
            // Dark blue background
            color: const Color(0xFF0D3445),
            // Rounded corners
            borderRadius: BorderRadius.circular(20),
            // Red glow effect
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
            // Red border
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
          ),
          child: Column(
            // Only take up needed vertical space
            mainAxisSize: MainAxisSize.min,
            children: [
              // X icon in a circular container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Icon(
                  timeExpired ? Icons.timer_off : Icons.close_rounded,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16), // Vertical spacing
              // Game Over title text
              const Text(
                'Game Over',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 16), // Vertical spacing
              // Reason for game over
              Text(
                timeExpired ? 'Time\'s Up!' : 'Wrong Pattern!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24), // Vertical spacing
              // Final Score label
              const Text(
                'Final Score',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 8), // Vertical spacing
              // Score value display
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16), // Vertical spacing
              // Encouraging message for the player
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  timeExpired
                      ? 'Try to complete the pattern faster next time!'
                      : 'Keep trying! You\'ll get better with practice.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 24), // Vertical spacing
              // Button row with Menu and Try Again options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Menu button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onExit, // Exit callback
                      icon: const Icon(Icons.menu),
                      label: const Text('Menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ), // Horizontal spacing between buttons
                  // Try Again button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRetry, // Retry callback
                      icon: const Icon(Icons.replay),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        // Teal-colored button
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
// CUSTOM PAINTERS (VISUAL EFFECTS)
//------------------------------------------------------------------------------

/// Creates animated wave background with multiple layers of waves
/// Each wave has configurable height, color, speed and amplitude
class WaveBackgroundPainter extends CustomPainter {
  final List<WaveLayer> layers;
  final double time;
  static const double fixedWaveHeight = 350.0;

  WaveBackgroundPainter(this.layers, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      final path = Path();

      path.moveTo(0, size.height);

      final waveHeight = fixedWaveHeight * layer.heightFactor;
      final baseY = size.height - waveHeight;

      for (double x = 0; x <= size.width; x += 5) {
        final y = baseY +
            sin(x * layer.frequency + layer.phase + time * layer.speed) *
                layer.amplitude;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            layer.color.withOpacity(0.6),
            layer.color.withOpacity(0.3),
            layer.color.withOpacity(0.1),
          ],
        ).createShader(Rect.fromLTWH(0, baseY, size.width, waveHeight))
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveBackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

/// Creates decorative glowing light spots that pulse at different rates
/// Creates an ethereal, magical atmosphere with randomly positioned spots
class LightSpotsPainter extends CustomPainter {
  static const int spotCount = 50;
  final List<Offset> _positions = [];
  final List<double> _sizes = [];
  final List<double> _opacities = [];

  LightSpotsPainter() {
    final random = Random();
    for (int i = 0; i < spotCount; i++) {
      _positions.add(
        Offset(random.nextDouble() * 1000, random.nextDouble() * 1000),
      );
      _sizes.add(1 + random.nextDouble() * 4);
      _opacities.add(0.1 + random.nextDouble() * 0.5);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000;

    for (int i = 0; i < spotCount; i++) {
      final pulseRate = 0.5 + (_positions[i].dx * 0.001);
      final dynamicOpacity = _opacities[i] * (0.7 + sin(now * pulseRate) * 0.3);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(dynamicOpacity),
            const Color(0xFF4ECDC4).withOpacity(0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(
              _positions[i].dx % size.width,
              _positions[i].dy % size.height,
            ),
            radius: _sizes[i] * 4,
          ),
        );

      canvas.drawCircle(
        Offset(_positions[i].dx % size.width, _positions[i].dy % size.height),
        _sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Creates a circuit-like pattern with nodes and connections
/// Used for the app logo background with glowing effect
class CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) / 2;
    final random = Random(12345);

    for (int i = 0; i < 24; i++) {
      final angle1 = random.nextDouble() * pi * 2;
      final angle2 = random.nextDouble() * pi * 2;

      final x1 = centerX + cos(angle1) * radius * 0.7;
      final y1 = centerY + sin(angle1) * radius * 0.7;
      final x2 = centerX + cos(angle2) * radius * 0.9;
      final y2 = centerY + sin(angle2) * radius * 0.9;

      final paint = Paint()
        ..color = const Color(
          0xFF4ECDC4,
        ).withOpacity(0.4 + random.nextDouble() * 0.3)
        ..strokeWidth = 1 + random.nextDouble() * 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      final pulseRate = 0.5 + i * 0.1;
      final opacity = 0.3 + sin(now * pulseRate) * 0.2;

      final path = Path();
      path.moveTo(x1, y1);

      final midX = (x1 + x2) / 2;
      final midY = (y1 + y2) / 2;
      final ctrlX = midX + (random.nextDouble() - 0.5) * radius * 0.3;
      final ctrlY = midY + (random.nextDouble() - 0.5) * radius * 0.3;

      path.quadraticBezierTo(ctrlX, ctrlY, x2, y2);

      canvas.drawPath(path, paint);

      final nodePaint = Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x1, y1), 1.5, nodePaint);
      canvas.drawCircle(Offset(x2, y2), 2.0, nodePaint);
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4ECDC4).withOpacity(0.8),
          const Color(0xFF4ECDC4).withOpacity(0),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      );

    canvas.drawCircle(Offset(centerX, centerY), radius * 0.85, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Creates an interconnected network of nodes with dynamic connections
/// Nodes move and connections appear/disappear based on proximity
class NetworkBackgroundPainter extends CustomPainter {
  final List<ParticleNode> nodes;
  final List<Connection> connections;
  final double time;
  final Size size;

  NetworkBackgroundPainter({
    required this.nodes,
    required this.connections,
    required this.time,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final node in nodes) {
      node.update(time, size);
    }

    for (final connection in connections) {
      final startNode = nodes[connection.startNodeIndex];
      final endNode = nodes[connection.endNodeIndex];

      final distance = (startNode.position - endNode.position).distance;

      if (distance <= connection.maxDistance) {
        final opacity = 1.0 - (distance / connection.maxDistance);

        final paint = Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF4ECDC4).withOpacity(opacity * 0.5),
              const Color(0xFF0D3445).withOpacity(opacity * 0.3),
            ],
          ).createShader(
            Rect.fromPoints(startNode.position, endNode.position),
          )
          ..strokeWidth = connection.thickness * opacity
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(startNode.position, endNode.position, paint);
      }
    }

    for (final node in nodes) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(node.opacity),
            const Color(0xFF4ECDC4).withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(center: node.position, radius: node.size * 4),
        );

      canvas.drawCircle(node.position, node.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant NetworkBackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

/// Creates light rays emanating from a point above the screen
/// Generates a dramatic lighting effect with angular rays
class LightRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final origin = Offset(width * 0.5, height * -0.2);

    for (int i = 0; i < 8; i++) {
      final angle = (pi * i / 8) + (pi / 16);
      final rayLength = height * 1.5;

      final endX = origin.dx + cos(angle) * rayLength;
      final endY = origin.dy + sin(angle) * rayLength;

      final rayPath = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(endX, endY)
        ..lineTo(endX + width * 0.15, endY)
        ..lineTo(origin.dx, origin.dy)
        ..close();

      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF135777).withOpacity(0.3),
            const Color(0xFF135777).withOpacity(0),
          ],
        ).createShader(Rect.fromPoints(origin, Offset(endX, endY)));

      canvas.drawPath(rayPath, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Creates subtle animated wave effects that move across the screen
/// Multiple layers with different speeds, amplitudes and colors
class SubtleWavesPainter extends CustomPainter {
  final double time;

  SubtleWavesPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    _drawWave(
      canvas: canvas,
      width: width,
      height: height,
      amplitude: 20,
      frequency: 0.015,
      phase: time * 0.2,
      yPosition: height * 0.75,
      color: const Color(0xFF4ECDC4).withOpacity(0.1),
    );

    _drawWave(
      canvas: canvas,
      width: width,
      height: height,
      amplitude: 15,
      frequency: 0.02,
      phase: time * -0.15,
      yPosition: height * 0.6,
      color: const Color(0xFF135777).withOpacity(0.07),
    );

    _drawWave(
      canvas: canvas,
      width: width,
      height: height,
      amplitude: 30,
      frequency: 0.01,
      phase: time * 0.1,
      yPosition: height * 0.9,
      color: const Color(0xFF0D3445).withOpacity(0.05),
    );
  }

  void _drawWave({
    required Canvas canvas,
    required double width,
    required double height,
    required double amplitude,
    required double frequency,
    required double phase,
    required double yPosition,
    required Color color,
  }) {
    final path = Path();

    path.moveTo(0, height);

    for (double x = 0; x <= width; x += 5) {
      final y = yPosition + sin(x * frequency + phase) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, yPosition - amplitude, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SubtleWavesPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

/// Creates a hexagonal grid pattern with connecting lines
/// Includes pulsing glow effects and random connectivity
class HexagonalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) / 2;
    final random = Random(12345);

    for (int ring = 0; ring < 2; ring++) {
      final ringRadius = radius * (0.65 + ring * 0.3);
      final hexCount = 6 + ring * 2;

      for (int i = 0; i < hexCount; i++) {
        final angle = (2 * pi * i / hexCount);
        final x = centerX + cos(angle) * ringRadius;
        final y = centerY + sin(angle) * ringRadius;

        _drawHexagon(
          canvas,
          x,
          y,
          5 + random.nextDouble() * 5,
          const Color(0xFF4ECDC4).withOpacity(0.2 + random.nextDouble() * 0.2),
        );
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final paint = Paint()
      ..color = const Color(0xFF4ECDC4).withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle1 = (2 * pi * i / 12);
      final angle2 = angle1 + pi / 6 + random.nextDouble() * (pi / 3);

      final r1 = radius * 0.7;
      final r2 = radius * 0.9;

      final x1 = centerX + cos(angle1) * r1;
      final y1 = centerY + sin(angle1) * r1;

      final x2 = centerX + cos(angle2) * r2;
      final y2 = centerY + sin(angle2) * r2;

      final glow = (sin(now + i) + 1) / 2;
      paint.color = const Color(0xFF4ECDC4).withOpacity(0.3 + glow * 0.3);

      final path = Path();
      path.moveTo(x1, y1);

      final ctrlX = (x1 + x2) / 2 + (random.nextDouble() - 0.5) * 20;
      final ctrlY = (y1 + y2) / 2 + (random.nextDouble() - 0.5) * 20;

      path.quadraticBezierTo(ctrlX, ctrlY, x2, y2);
      canvas.drawPath(path, paint);

      final nodePaint = Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(0.5 + glow * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x1, y1), 2, nodePaint);
      canvas.drawCircle(Offset(x2, y2), 2, nodePaint);
    }
  }

  void _drawHexagon(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color color,
  ) {
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i;
      final xPoint = x + cos(angle) * size;
      final yPoint = y + sin(angle) * size;

      if (i == 0) {
        path.moveTo(xPoint, yPoint);
      } else {
        path.lineTo(xPoint, yPoint);
      }
    }

    path.close();

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Creates the background for the level selection screen
/// Combines flowing lines, waves, and glowing particles
class LevelSelectBackgroundPainter extends CustomPainter {
  final double time;
  final Random _random = Random(42);

  LevelSelectBackgroundPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    _drawFlowingLines(canvas, size);
    _drawGlowingParticles(canvas, size);
  }

  void _drawFlowingLines(Canvas canvas, Size size) {
    final lineCount = 10;
    final lineWidth = 1.0;

    for (int i = 0; i < lineCount; i++) {
      final y = (size.height / (lineCount + 1)) * (i + 1);
      final path = Path();

      path.moveTo(0, y);

      final amplitude = 20.0 + _random.nextDouble() * 20;
      final frequency = 0.01 + _random.nextDouble() * 0.01;
      final phase = time * (0.1 + _random.nextDouble() * 0.2) + i;

      for (double x = 0; x <= size.width; x += 5) {
        path.lineTo(x, y + sin(x * frequency + phase) * amplitude);
      }

      final paint = Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(0.07 + (i % 3) * 0.02)
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth;

      canvas.drawPath(path, paint);
    }
  }

  void _drawGlowingParticles(Canvas canvas, Size size) {
    const particleCount = 30;

    for (int i = 0; i < particleCount; i++) {
      final x = ((time * (0.1 + i * 0.01)) % 2) * size.width;
      final y = ((i * 37) % size.height) + sin(time + i) * 20;

      final radius = 1.5 + sin(time * 0.8 + i) * 1.0;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(0.6),
            const Color(0xFF4ECDC4).withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(x, y), radius: radius * 4),
        );

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LevelSelectBackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

/// Creates a circuit pattern with branching paths and nodes
/// Used as decorative elements for UI components
class CircuitPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(12345);
    final lineCount = 6;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF4ECDC4).withOpacity(0.2);

    for (int i = 0; i < lineCount; i++) {
      final path = Path();

      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;

      path.moveTo(startX, startY);

      for (int j = 0; j < 2; j++) {
        final endX = random.nextDouble() * size.width;
        final endY = random.nextDouble() * size.height;

        final controlX1 = startX + (endX - startX) * random.nextDouble();
        final controlY1 = startY + (endY - startY) * random.nextDouble();

        path.quadraticBezierTo(controlX1, controlY1, endX, endY);

        canvas.drawCircle(
          Offset(endX, endY),
          1.5,
          Paint()..color = const Color(0xFF4ECDC4).withOpacity(0.3),
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Creates the game screen background with grid, particles and glow effects
/// Particles connect when they're in proximity to each other
class GameBackgroundPainter extends CustomPainter {
  final double time;
  final List<ParticleDot> particles;

  GameBackgroundPainter({required this.time, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(time, size);
    }

    _drawGrid(canvas, size);
    _drawParticles(canvas, size);
    _drawBottomGlow(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final lineCount = 10;
    final horizontalSpacing = size.width / lineCount;
    final verticalSpacing = size.height / lineCount;

    final paint = Paint()
      ..color = const Color(0xFF4ECDC4).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 1; i < lineCount; i++) {
      final x = horizontalSpacing * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 1; i < lineCount; i++) {
      final y = verticalSpacing * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (final particle in particles) {
      final pulsingOpacity = particle.opacity *
          (0.7 + sin(time + particle.position.dx * 0.01) * 0.3);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(pulsingOpacity),
            const Color(0xFF4ECDC4).withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: particle.position,
            radius: particle.size * 6,
          ),
        );

      canvas.drawCircle(particle.position, particle.size, paint);
    }

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final distance =
            (particles[i].position - particles[j].position).distance;
        if (distance < 100) {
          final opacity = (1 - distance / 100) * 0.1;

          final paint = Paint()
            ..color = const Color(0xFF4ECDC4).withOpacity(opacity)
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke;

          canvas.drawLine(particles[i].position, particles[j].position, paint);
        }
      }
    }
  }

  void _drawBottomGlow(Canvas canvas, Size size) {
    final centerY = size.height * 0.9;
    final glowRadius = size.width * 0.8;
    final glowOpacity = 0.05 + sin(time * 0.5) * 0.02;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4ECDC4).withOpacity(glowOpacity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, centerY),
          radius: glowRadius,
        ),
      );

    canvas.drawCircle(Offset(size.width / 2, centerY), glowRadius, paint);
  }

  @override
  bool shouldRepaint(covariant GameBackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

//------------------------------------------------------------------------------
// UI COMPONENTS
//------------------------------------------------------------------------------

/// An animated button with visual effects used for primary actions in the game
class GlowingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const GlowingActionButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  State<GlowingActionButton> createState() => _GlowingActionButtonState();
}

class _GlowingActionButtonState extends State<GlowingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(_pulseController);

    _pulseController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.only(
                top: 2,
                left: 32,
                right: 32,
                bottom: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4ECDC4),
                    const Color(0xFF4ECDC4).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: _pulseAnimation.value * 15,
                    spreadRadius: _pulseAnimation.value * 4,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  color: _isPressed ? Colors.white70 : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(widget.text),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
