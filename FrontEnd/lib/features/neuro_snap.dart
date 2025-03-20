import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'services/neuro_snap_stable_diffusion_service.dart';
import 'services/neuro_snap_scoring_service.dart';
import 'neuro_snap_leaderboard_screen.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';

// Custom app theme colors
class AppColors {
  static const Color primaryDark = Color(0xFF0D3445);
  static const Color primaryMedium = Color(0xFF164B60);
  static const Color primaryLight = Color(0xFF2D6E8E);
  static const Color accentColor = Color(0xFF64CCC5);
  static const Color backgroundColor = Color(0xFFEEF5FF);
  static const Color textLight = Color(0xFFF8FBFF);
  static const Color textDark = Color(0xFF0A2730);
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Memory Associations',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryMedium,
          primary: AppColors.primaryMedium,
          secondary: AppColors.accentColor,
          background: AppColors.backgroundColor,
          surface: AppColors.backgroundColor,
          onPrimary: AppColors.textLight,
          onSecondary: AppColors.textDark,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: AppColors.primaryMedium,
            foregroundColor: AppColors.textLight,
          ),
        ),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textLight,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryMedium,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.psychology,
                    size: 80,
                    color: AppColors.accentColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NeuroSnap',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 46,
                          color: AppColors.textLight,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Memory Recall Game for Rehabilitation',
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textLight.withOpacity(0.8)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  _buildMenuButton(
                    context: context,
                    label: 'Start Game',
                    icon: Icons.play_arrow_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameModesScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context: context,
                    label: 'Leaderboard',
                    icon: Icons.leaderboard,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaderboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
