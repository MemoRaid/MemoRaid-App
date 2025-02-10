import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/breath.dart';
import 'bottomnavbar.dart'; // Import the custom bottom navbar
import 'gamescreen.dart'; // Import the Game Screen

class HomeScreen2 extends StatelessWidget {
  const HomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFF0D3445)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        context,
                        title: "Games",
                        image: 'lib/assets/images/patient.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: size.height * 0.03),
                      _buildFeatureCard(
                        context,
                        title: "Story",
                        image: 'lib/assets/images/story.png',
                      ),
                      SizedBox(height: size.height * 0.03),
                      _buildFeatureCard(
                        context,
                        title: "Reminder and Diary",
                        image: 'lib/assets/images/reminder.png',
                      ),
                      SizedBox(height: size.height * 0.03),
                      _buildFeatureCard(
                        context,
                        title: "Calm Mind",
                        image: 'lib/assets/images/mind.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BreathExerciseScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  Widget _buildFeatureCard(BuildContext context,
      {required String title, required String image, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap, // Handle navigation when tapped
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Color(0xFF0D3445), // Same color scheme as HomeScreen1 cards
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 40,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 20),
            Image.asset(
              image,
              width: 90,
              height: 80,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
