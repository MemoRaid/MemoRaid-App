import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Class to store individual game results
class GameResult {
  final String mode;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int totalAttempts;
  final int maxStreak;
  final DateTime timestamp;

  GameResult({
    required this.mode,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.maxStreak,
    required this.totalAttempts,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'totalAttempts': totalAttempts,
      'maxStreak': maxStreak,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Create from JSON for retrieval
  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      mode: json['mode'] ?? 'unknown',
      score: json['score'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      totalAttempts: json['totalAttempts'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }

  // Calculate combined accuracy that matches the game screen calculation
  double get accuracy {
    if (totalQuestions == 0) return 0;

    // Calculate question accuracy (% of questions answered correctly)
    double questionAccuracy = (correctAnswers / totalQuestions) * 100;

    // Calculate attempt efficiency (% of correct answers out of total attempts)
    double attemptEfficiency =
        totalAttempts > 0 ? (correctAnswers / totalAttempts) * 100 : 0;

    // Return the combined accuracy as used in the game
    return (questionAccuracy + attemptEfficiency) / 2;
  }
}

/// Class to store overall game statistics
class GameStats {
  int highScore;
  int totalGamesPlayed;
  int totalScore;
  int maxStreak;
  Map<String, int> modeHighScores; // Stores high scores for each game mode
  List<GameResult> recentResults;

  GameStats({
    this.highScore = 0,
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.maxStreak = 0,
    Map<String, int>? modeHighScores,
    List<GameResult>? recentResults,
  }) : modeHighScores =
           modeHighScores ??
           {'Beginner': 0, 'Expert': 0, 'Speed': 0, 'daily': 0},
       recentResults = recentResults ?? [];

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'highScore': highScore,
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'maxStreak': maxStreak,
      'modeHighScores': modeHighScores,
      'recentResults': recentResults.map((result) => result.toJson()).toList(),
    };
  }

  // Create from JSON for retrieval
  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      highScore: json['highScore'] ?? 0,
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      modeHighScores: Map<String, int>.from(json['modeHighScores'] ?? {}),
      recentResults:
          json['recentResults'] != null
              ? (json['recentResults'] as List)
                  .map((result) => GameResult.fromJson(result))
                  .toList()
              : [],
    );
  }
}

/// Service class for handling game scoring, statistics, and leaderboard
class ScoringService {
  // Singleton pattern
  static final ScoringService _instance = ScoringService._internal();
  factory ScoringService() => _instance;
  ScoringService._internal();

  // Game stats
  late GameStats _stats;
  bool _isInitialized = false;

  // Stream controller for score updates
  final _statsController = StreamController<GameStats>.broadcast();
  Stream<GameStats> get statsStream => _statsController.stream;

  // Key for storing leaderboard data in SharedPreferences
  static const String _leaderboardKey = 'neurosnap_leaderboard';
  static const String _statsKey = 'gameStats';

  // Initialization methods

  /// Initialize and load stored data
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _loadStats();
      _isInitialized = true;
    }
  }

  /// Load stats from SharedPreferences
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        _stats = GameStats.fromJson(jsonDecode(statsJson));
      } else {
        _stats = GameStats();
      }

      _statsController.add(_stats);
    } catch (e) {
      print('Error loading game stats: $e');
      _stats = GameStats();
    }
  }

  /// Save stats to SharedPreferences
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, jsonEncode(_stats.toJson()));
    } catch (e) {
      print('Error saving game stats: $e');
    }
  }

  // Scoring and calculation methods

  /// Calculate score for an answer
  int calculatePoints({
    required bool isCorrect,
    required String gameMode,
    int comboCount = 0,
    int timeRemaining = 0,
  }) {
    if (!isCorrect) return 0;

    int basePoints;
    switch (gameMode.toLowerCase()) {
      case 'beginner':
        basePoints = 5;
        break;
      case 'expert':
        basePoints = 15;
        break;
      case 'speed':
        // For speed mode, add time bonus
        basePoints = 10 + (timeRemaining * 2);
        break;
      case 'daily':
        basePoints = 20; // Daily challenges give more points
        break;
      default:
        basePoints = 10;
    }

    // Apply combo bonus
    if (comboCount > 0) {
      basePoints = (basePoints * (1 + comboCount * 0.1)).toInt();
    }

    return basePoints;
  }

  /// Get performance feedback based on accuracy
  String getPerformanceFeedback(double accuracy) {
    if (accuracy >= 90) {
      return 'Excellent work! Your memory is exceptional!';
    } else if (accuracy >= 70) {
      return 'Great job! Your memory skills are strong.';
    } else if (accuracy >= 50) {
      return 'Good effort! Keep practicing to improve further.';
    } else {
      return 'Keep trying! Memory skills improve with practice.';
    }
  }

  // Game result and stats methods

  /// Save result of a game session
  Future<void> saveGameResult({
    required String mode,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int maxStreak,
    required int totalAttempts,
  }) async {
    if (!_isInitialized) await initialize();

    // Create new result
    final result = GameResult(
      mode: mode,
      score: score,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      totalAttempts: totalAttempts,
      maxStreak: maxStreak,
    );

    // Update stats
    _stats.totalGamesPlayed++;
    _stats.totalScore += score;

    // Update high score if needed
    if (score > _stats.highScore) {
      _stats.highScore = score;
    }

    // Update mode-specific high score
    if (!_stats.modeHighScores.containsKey(mode)) {
      _stats.modeHighScores[mode] = 0;
    }
    if (score > _stats.modeHighScores[mode]!) {
      _stats.modeHighScores[mode] = score;
    }

    // Update max streak if needed
    if (maxStreak > _stats.maxStreak) {
      _stats.maxStreak = maxStreak;
    }

    // Add to recent results (keep only 10 most recent)
    _stats.recentResults.insert(0, result);
    if (_stats.recentResults.length > 10) {
      _stats.recentResults = _stats.recentResults.sublist(0, 10);
    }

    // Save changes
    await _saveStats();
    _statsController.add(_stats);
  }

  /// Get current stats
  GameStats get stats {
    if (!_isInitialized) {
      throw Exception(
        'ScoringService not initialized. Call initialize() first.',
      );
    }
    return _stats;
  }

  // Leaderboard methods

  /// Get leaderboard entries
  Future<List<Map<String, dynamic>>> getLeaderboardEntries() async {
    if (!_isInitialized) await initialize();

    // Convert stats into a format suitable for the leaderboard
    List<Map<String, dynamic>> entries = [];

    // Add an entry for overall stats
    entries.add({
      'type': 'stats',
      'highScore': _stats.highScore,
      'totalGamesPlayed': _stats.totalGamesPlayed,
      'totalScore': _stats.totalScore,
      'maxStreak': _stats.maxStreak,
      'modeHighScores': _stats.modeHighScores,
    });

    // Add entries for recent games
    for (final result in _stats.recentResults) {
      entries.add({
        'type': 'game',
        'mode': result.mode,
        'score': result.score,
        'correctAnswers': result.correctAnswers,
        'totalQuestions': result.totalQuestions,
        'accuracy': result.accuracy,
        'maxStreak': result.maxStreak,
        'timestamp': result.timestamp,
      });
    }

    return entries;
  }

  /// Get high score for a specific game mode
  int getHighScore(String mode) {
    if (!_isInitialized) {
      throw Exception(
        'ScoringService not initialized. Call initialize() first.',
      );
    }
    return _stats.modeHighScores[mode] ?? 0;
  }

  // Data management methods

  /// Reset all stats (for testing/reset)
  Future<void> resetStats() async {
    _stats = GameStats();
    await _saveStats();
    _statsController.add(_stats);
  }

  /// Clear all saved data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear leaderboard data
      await prefs.remove(_leaderboardKey);

      // Clear game stats data
      await prefs.remove(_statsKey);

      // Reset the in-memory stats object
      _stats = GameStats();
      _statsController.add(_stats);

      // Optional: Add a small delay to ensure data is cleared
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      // Handle any errors during the clearing process
      throw Exception('Failed to clear game data: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _statsController.close();
  }
}
