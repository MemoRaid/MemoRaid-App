import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

// Class to store individual game results
class GameResult {
  final String mode;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int totalAttempts; // Add this field to track attempts
  final int maxStreak;
  final DateTime timestamp;

  GameResult({
    required this.mode,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.maxStreak,
    required this.totalAttempts, // Make this required
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'totalAttempts': totalAttempts, // Save total attempts
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
      totalAttempts: json['totalAttempts'] ?? 0, // Load total attempts
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

  // Initialize and load stored data
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _loadStats();
      _isInitialized = true;
    }
  }

  // Load stats from SharedPreferences
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? statsJson = prefs.getString('gameStats');

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

  // Save stats to SharedPreferences
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gameStats', jsonEncode(_stats.toJson()));
    } catch (e) {
      print('Error saving game stats: $e');
    }
  }

  // Get current stats
  GameStats get stats {
    if (!_isInitialized) {
      throw Exception(
        'ScoringService not initialized. Call initialize() first.',
      );
    }
    return _stats;
  }

  // Calculate score for a correct answer
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

  // Save result of a game session
  Future<void> saveGameResult({
    required String mode,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int maxStreak,
    required int totalAttempts, // Add this parameter
  }) async {
    if (!_isInitialized) await initialize();

    // Create new result
    final result = GameResult(
      mode: mode,
      score: score,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      totalAttempts: totalAttempts, // Pass the total attempts
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
}
