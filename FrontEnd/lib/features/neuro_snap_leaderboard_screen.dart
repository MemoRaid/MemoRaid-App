// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/services/neuro_snap_scoring_service.dart';
import 'neuro_snap.dart';

/// Screen that displays leaderboard information and player statistics
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  // Controller & Data Properties
  late TabController _tabController;
  final ScoringService _scoringService = ScoringService();
  List<Map<String, dynamic>> _leaderboardEntries = [];
  bool _isLoading = true;

  // Lifecycle Methods
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

  // Data Loading & Management Methods

  /// Loads leaderboard data from the scoring service
  Future<void> _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _scoringService.getLeaderboardEntries();
      setState(() {
        _leaderboardEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error if data loading fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading leaderboard data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Shows a confirmation dialog before resetting all data
  Future<void> _showResetConfirmationDialog() async {
    // Show warning dialog asking for confirmation
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Reset Progress',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Warning: This will permanently delete all your game progress and leaderboard data. This action cannot be undone.',
                style: TextStyle(color: AppColors.textLight),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.accentColor),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset All Data'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    // If user confirmed, proceed with reset
    if (confirmed == true) {
      await _resetAllData();
    }
  }

  /// Resets all leaderboard and game data
  Future<void> _resetAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Clear all saved data
      await _scoringService.clearAllData();

      // Reload the (now empty) leaderboard
      await _loadLeaderboardData();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All progress has been reset successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Main Build Method
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
        child: _isLoading
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

  // Tab Content Builders

  /// Builds the high scores tab showing overall and per-mode statistics
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

  /// Builds the recent games tab showing detailed history of gameplay
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

  // Helper UI Components

  /// Builds a row for displaying result information
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

  /// Builds a card for displaying grouped statistics
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
