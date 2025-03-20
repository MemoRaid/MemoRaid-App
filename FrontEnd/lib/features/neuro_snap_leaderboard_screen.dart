import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/neuro_snap_scoring_service.dart';
import 'neuro_snap.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScoringService _scoringService = ScoringService();
  List<Map<String, dynamic>> _leaderboardEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textLight,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'High Scores'), Tab(text: 'Recent Games')],
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.6),
          indicatorColor: AppColors.accentColor,
        ),
        actions: [
          // Add reset button to the app bar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset All Progress',
            onPressed: _showResetConfirmationDialog,
          ),
        ],
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
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accentColor,
                    ),
                  ),
                )
                : TabBarView(
                  controller: _tabController,
                  children: [
                    // High Scores Tab
                    _buildHighScoresTab(),

                    // Recent Games Tab
                    _buildRecentGamesTab(),
                  ],
                ),
      ),
    );
  }

  Widget _buildHighScoresTab() {
    // Get stats
    final stats = _scoringService.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall stats card
          _buildStatsCard('Overall Stats', [
            {
              'label': 'All-Time High Score',
              'value': stats.highScore.toString(),
            },
            {
              'label': 'Total Games Played',
              'value': stats.totalGamesPlayed.toString(),
            },
            {'label': 'Lifetime Points', 'value': stats.totalScore.toString()},
            {'label': 'Best Streak', 'value': stats.maxStreak.toString()},
          ]),

          const SizedBox(height: 24),

          // Mode-specific high scores
          _buildStatsCard('Mode High Scores', [
            {
              'label': 'Beginner Mode',
              'value': stats.modeHighScores['Beginner']?.toString() ?? '0',
            },
            {
              'label': 'Expert Mode',
              'value': stats.modeHighScores['Expert']?.toString() ?? '0',
            },
            {
              'label': 'Speed Challenge',
              'value': stats.modeHighScores['Speed']?.toString() ?? '0',
            },
            {
              'label': 'Daily Challenge',
              'value': stats.modeHighScores['daily']?.toString() ?? '0',
            },
          ]),
        ],
      ),
    );
  }

  Widget _buildRecentGamesTab() {
    // Get recent games
    final recentGames = _scoringService.stats.recentResults;

    if (recentGames.isEmpty) {
      return Center(
        child: Text(
          'No recent games to display',
          style: TextStyle(color: AppColors.textLight, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: recentGames.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final game = recentGames[index];
        final date = DateFormat('MMM d, yyyy • h:mm a').format(game.timestamp);

        // Use the game's accuracy directly - don't recalculate
        // Just format it consistently with the game results display
        final String formattedAccuracy = '${game.accuracy.toStringAsFixed(0)}%';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: AppColors.primaryMedium.withOpacity(0.7),
          shadowColor: Colors.black.withOpacity(0.3),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game mode title and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${game.mode} Mode',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppColors.textLight.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.accentColor, height: 24),

                // Detailed stats in a format identical to game results screen
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow(
                        'Score',
                        '${game.score} points',
                        isHeader: false,
                        highlight: true,
                      ),
                      _buildResultRow(
                        'Correct Answers',
                        '${game.correctAnswers}/${game.totalQuestions}',
                        isHeader: false,
                      ),
                      _buildResultRow(
                        'Accuracy',
                        formattedAccuracy,
                        isHeader: false,
                      ),
                      _buildResultRow(
                        'Max Streak',
                        '${game.maxStreak}',
                        isHeader: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build a result row - matches the style in game results
  Widget _buildResultRow(
    String label,
    String value, {
    bool isHeader = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? AppColors.accentColor : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, List<Map<String, String>> items) {
    return Card(
      color: AppColors.primaryMedium.withOpacity(0.7),
      shadowColor: Colors.black.withOpacity(0.3),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label']!,
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    Text(
                      item['value']!,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
