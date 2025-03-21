import 'package:flutter/material.dart';
import 'g_01_game_screen.dart';

class g01Screen extends StatelessWidget {
  const g01Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the primary color and its variations to match game screen
    final Color primaryColor = Color(0xFF0D3445);
    final Color primaryLightColor = Color(0xFF164C64);

    return Scaffold(
      // Add app bar with back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Handle back navigation - typically exit the app
            Navigator.maybePop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true, // Let the gradient extend behind app bar
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              primaryLightColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon with subtle shadow
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ]),
                  child: Icon(
                    Icons.psychology,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),

                // App title
                Text(
                  'Daily Tasks Sequencer',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),

                // App subtitle
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Train your memory with everyday tasks',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 60),

                // Start game button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black38,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start Game',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor, // Explicitly set text color
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.play_arrow_rounded,
                        color: primaryColor, // Explicitly set icon color
                      ),
                    ],
                  ),
                ),

                // Version text
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    'Version 1.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
