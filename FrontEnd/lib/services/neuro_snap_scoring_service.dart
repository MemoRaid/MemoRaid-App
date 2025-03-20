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
