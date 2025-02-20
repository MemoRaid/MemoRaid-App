import 'package:flutter/material.dart';
import 'bottomnavbar.dart'; // Import the custom bottom navbar

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Games",
          style: TextStyle(
            color: Color(0xFF0D3445),
            fontSize: 24,
            fontFamily: 'Epilogue',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFF0D3445)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _buildGameCard(
                        context,
                        title: "Memory Match",
                        image: "lib/assets/images/memoraid.png",
                        onTap: () {
                          // Navigate to Memory Match Game
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildGameCard(
                        context,
                        title: "Puzzle Solver",
                        image: "lib/assets/images/memoraid.png",
                        onTap: () {
                          // Navigate to Puzzle Solver Game
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildGameCard(
                        context,
                        title: "Reaction Test",
                        image: "lib/assets/images/memoraid.png",
                        onTap: () {
                          // Navigate to Reaction Test Game
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildGameCard(
                        context,
                        title: "Reaction Test",
                        image: "lib/assets/images/memoraid.png",
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
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/chatbot');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/rocket');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/achievements');
              break;
          }
        },
      ),
    );
  }

  Widget _buildGameCard(BuildContext context,
      {required String title, required String image, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
