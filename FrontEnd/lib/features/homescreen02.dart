import 'package:flutter/material.dart';

class HomeScreen2 extends StatelessWidget {
  const HomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          // Hexagonal Pattern Overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundhex.png', // Add your hexagonal pattern image to the assets folder.
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        context,
                        title: "Games",
                        image:
                            'assets/images/patient.png', // Replace with actual image path
                      ),
                      SizedBox(height: size.height * 0.02),
                      _buildFeatureCard(
                        context,
                        title: "Story",
                        image:
                            'assets/images/story.png', // Replace with actual image path
                      ),
                      SizedBox(height: size.height * 0.02),
                      _buildFeatureCard(
                        context,
                        title: "Reminder and Diary",
                        image:
                            'assets/images/reminder.png', // Replace with actual image path
                      ),
                      SizedBox(height: size.height * 0.02),
                      _buildFeatureCard(
                        context,
                        title: "Calm Mind",
                        image:
                            'assets/images/mind.png', // Replace with actual image path
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 8, 41, 55),
        selectedItemColor: const Color.fromARGB(255, 18, 33, 18),
        unselectedItemColor: Colors.grey[400],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title, required String image}) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFF4E6077),
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
          SizedBox(width: 16),
          Image.asset(
            image,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
