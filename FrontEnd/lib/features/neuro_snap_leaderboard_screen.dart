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
          tabs: const [
            Tab(text: 'High Scores'),
            Tab(text: 'Recent Games'),
          ],
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
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentColor),
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
              'value': stats.highScore.toString()
            },
            {
              'label': 'Total Games Played',
              'value': stats.totalGamesPlayed.toString()
            },
            {'label': 'Lifetime Points', 'value': stats.totalScore.toString()},
            {'label': 'Best Streak', 'value': stats.maxStreak.toString()},
          ]),

          const SizedBox(height: 24),

          // Mode-specific high scores
          _buildStatsCard('Mode High Scores', [
            {
              'label': 'Beginner Mode',
              'value': stats.modeHighScores['Beginner']?.toString() ?? '0'
            },
            {
              'label': 'Expert Mode',
              'value': stats.modeHighScores['Expert']?.toString() ?? '0'
            },
            {
              'label': 'Speed Challenge',
              'value': stats.modeHighScores['Speed']?.toString() ?? '0'
            },
            {
              'label': 'Daily Challenge',
              'value': stats.modeHighScores['daily']?.toString() ?? '0'
            },
          ]),
        ],
      ),
    );
  }
