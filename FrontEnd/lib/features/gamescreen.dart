import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/homescreen01.dart';
import 'bottomnavbar.dart'; // Import the custom bottom navbar
import 'game.dart';
import 'g_01_home_screen.dart';
import 'spot_difference_game.dart';
import 'dart:math' as math;

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Brain Games",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: 'Epilogue',
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D3445), Color(0xFF051824)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutQuint,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Train your brain with these ",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              TextSpan(
                                text: "games",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Game cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    _buildAnimatedGameCard(
                      context,
                      index: 0,
                      title: "Memory Match",
                      description:
                          "Train your memory with this card matching game",
                      iconData: Icons.grid_view_rounded,
                      gradient: const [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, animation, __) {
                              return FadeTransition(
                                opacity: animation,
                                child: const StartScreen(),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    _buildAnimatedGameCard(
                      context,
                      index: 1,
                      title: "Puzzle Solver",
                      description: "Challenge your brain with spatial puzzles",
                      iconData: Icons.extension,
                      gradient: const [Color(0xFF43A047), Color(0xFF2E7D32)],
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, animation, __) {
                              return FadeTransition(
                                opacity: animation,
                                child: const HomeScreen03(),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    _buildAnimatedGameCard(
                      context,
                      index: 2,
                      title: "Spot the Difference",
                      description: "Sharpen your attention to detail",
                      iconData: Icons.visibility,
                      gradient: const [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, animation, __) {
                              return FadeTransition(
                                opacity: animation,
                                child: const SpotDifferenceGame(),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    _buildAnimatedGameCard(
                      context,
                      index: 3,
                      title: "Reaction Test",
                      description: "Test your speed and reflexes",
                      iconData: Icons.flash_on,
                      gradient: const [Color(0xFFFF9800), Color(0xFFEF6C00)],
                      onTap: () {
                        // Navigate to Reaction Test Game
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomBottomNavigationBar(
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              // ...existing navigation code...
            }
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedGameCard(
    BuildContext context, {
    required int index,
    required String title,
    required String description,
    required IconData iconData,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(100 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.6),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  iconData,
                  size: 150,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

              // Animated circles for visual interest
              ...List.generate(5, (i) {
                final random = math.Random(i * index + 1);
                return Positioned(
                  left: random.nextDouble() * 250,
                  top: random.nextDouble() * 150,
                  child: Container(
                    width: 30 + random.nextDouble() * 50,
                    height: 30 + random.nextDouble() * 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                          .withOpacity(0.05 + random.nextDouble() * 0.05),
                    ),
                  ),
                );
              }),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title section with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            iconData,
                            size: 24,
                            color: gradient.first,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Play button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'PLAY NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
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
}
