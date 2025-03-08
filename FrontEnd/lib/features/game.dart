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