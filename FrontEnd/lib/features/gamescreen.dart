import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/homescreen01.dart';
import 'bottomnavbar.dart'; // Import the custom bottom navbar
import 'game.dart';
import 'g_01_home_screen.dart';
import 'spot_difference_game.dart';
import 'g_02_memory_recovery_app.dart';
import 'neuro_snap.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3445),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D3445), Color(0xFF165066)],
            ),
          ),
        ),
        elevation: 0,
        title: const Text(
          "Games",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: 'Epilogue',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D3445),
                  Color(0xFFFFFFFF),
                  Color(0xFF0A2632),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Challenge Your Mind",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Select a game to begin your journey",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: [
                      _buildGameCard(
                        context,
                        title: "Path Quest",
                        subtitle: "Remember the path to win",
                        image: "assets/images/Pathquest.jpeg",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StartScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildGameCard(
                        context,
                        title: "Daily Task Sequencer",
                        subtitle: "Reorder the jumbled tasks",
                        image: "assets/images/Sequence.jpeg",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const g01Screen()),
                          );
                          // Navigate to Puzzle Solver Game
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildGameCard(
                        context,
                        title: "Spot the Difference",
                        subtitle: "Find whats different on the image",
                        image: "assets/images/Spot.jpeg",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SpotDifferenceGame()),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildGameCard(
                        context,
                        title: "Memory Master",
                        subtitle: "Remember the Flipped cards ",
                        image: "assets/images/Emojie.jpeg",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MemoryRecoveryApp()),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildGameCard(
                        context,
                        title: "Neuro Snap",
                        subtitle: "Test your memory skills",
                        image: "assets/images/Neurosnap.jpeg",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WelcomeScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        // Use the custom navigation bar
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/notes');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/chatbot');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  Widget _buildGameCard(BuildContext context,
      {required String title,
      required String image,
      required String subtitle,
      VoidCallback? onTap}) {
    return Hero(
      tag: title,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF0D3445).withOpacity(0.3),
                    BlendMode.overlay,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D3445).withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      const Color(0xFF0D3445).withOpacity(0.2),
                      const Color(0xFF0D3445).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
