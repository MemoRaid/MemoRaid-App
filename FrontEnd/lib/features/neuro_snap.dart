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
                      color: AppColors.textLight.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  _buildMenuButton(
                    context: context,
                    label: 'Start Game',
                    icon: Icons.play_arrow_rounded,
                    onTap:
                        () => Navigator.push(
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

  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentColor,
            AppColors.accentColor.withOpacity(0.8),
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 60),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryDark),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameModesScreen extends StatelessWidget {
  const GameModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Challenge'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textLight,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark.withOpacity(0.9),
              AppColors.primaryMedium,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily challenge banner with updated gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentColor.withOpacity(0.8),
                      AppColors.accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Challenge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Complete today\'s challenge to earn bonus points!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameScreen(
                              gameMode: 'daily',
                              isDaily: true,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.amber.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('PLAY'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'Game Modes',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a mode that matches your skill level',
                style: TextStyle(color: AppColors.textLight.withOpacity(0.8)),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    _buildGameModeCard(
                      context: context,
                      title: 'Beginner Mode',
                      description:
                          'Perfect for new players. More time to memorize images with helpful hints.',
                      icon: Icons.lightbulb_outline,
                      difficulty: 1,
                      rewards: '5-15 points per correct answer',
                      color: Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(
                            gameMode: 'Beginner',
                            isDaily: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGameModeCard(
                      context: context,
                      title: 'Expert Mode',
                      description:
                          'For memory masters. Quick glimpses of images with hints.',
                      icon: Icons.psychology,
                      difficulty: 3,
                      rewards: '15-30 points per correct answer',
                      color: Colors.red,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(
                            gameMode: 'Expert',
                            isDaily: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGameModeCard(
                      context: context,
                      title: 'Speed Challenge',
                      description:
                          'Race against time! Earn bonus points for faster responses.',
                      icon: Icons.timer,
                      difficulty: 2,
                      rewards: 'Up to 40 points with time bonus',
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(
                            gameMode: 'Speed',
                            isDaily: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
