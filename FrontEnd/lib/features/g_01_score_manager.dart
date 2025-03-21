import 'package:flutter/material.dart';

class ScoreManager {
  // Singleton pattern implementation
  static final ScoreManager _instance = ScoreManager._internal();

  factory ScoreManager() {
    return _instance;
  }

  ScoreManager._internal();

  // Calculate points for a level based on attempts
  int calculateLevelPoints(int attempts) {
    // 10 points maximum, lose 1 point per attempt, minimum 5 points
    return 10 - (attempts > 5 ? 5 : attempts);
  }

  // Show the level completion dialog
  void showLevelCompletionDialog({
    required BuildContext context,
    required int pointsEarned,
    required int totalScore,
    required int currentLevel,
    required int totalLevels,
    required VoidCallback onNextLevel,
    required VoidCallback onSeeResults,
  }) {
    final bool hasNextLevel = currentLevel < totalLevels - 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D3445),
                  Color(0xFF164C64),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy icon with shining animation
                _buildTrophyIcon(),

                SizedBox(height: 16),
                Text(
                  'Level ${currentLevel + 1} Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 24),
                _buildScoreContainer(
                    'Points Earned:', '+$pointsEarned', Colors.amber),
                SizedBox(height: 12),
                _buildScoreContainer(
                    'Total Score:', '$totalScore', Colors.white),
                SizedBox(height: 24),

                // Guidance text about next level
                if (hasNextLevel)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Level ${currentLevel + 2} is now unlocked!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasNextLevel)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onNextLevel();
                        },
                        icon: Icon(Icons.arrow_forward),
                        label: Text('Next Level'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onSeeResults();
                        },
                        icon: Icon(Icons.flag),
                        label: Text('See Final Results'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Display score badge in app bar
  Widget buildScoreBadge(int score) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF164C64),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            size: 18,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            '$score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for score display
  Widget _buildScoreContainer(String label, String value, Color valueColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Trophy icon with subtle animation
  Widget _buildTrophyIcon() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 60,
          ),
        );
      },
    );
  }
}
