import 'package:flutter/material.dart';
import 'bottomnavbar.dart'; // Import the custom bottom navbar

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
                        image:
                            'lib/assets/images/patient.png', // Replace with actual image path
                      ),
                      SizedBox(height: size.height * 0.03),
                      _buildFeatureCard(
                        context,
                        title: "Story",
                        image:
                            'lib/assets/images/story.png', // Replace with actual image path
                      ),
                      SizedBox(height: size.height * 0.03),
                      _buildFeatureCard(
                        context,
                        title: "Reminder and Diary",
                        image:
                            'lib/assets/images/reminder.png', // Replace with actual image path
                      ),
                      SizedBox(height: size.height * 0.03),
                      _buildFeatureCard(
                        context,
                        title: "Calm Mind",
                        image:
                            'lib/assets/images/mind.png', // Replace with actual image path
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
          // Implement the navigation for each tab here
        },
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title, required String image}) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Color(0xFF0D3445), // Same color scheme as HomeScreen1 cards
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 20),
          Image.asset(
            image,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
