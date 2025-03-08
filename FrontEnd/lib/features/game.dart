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