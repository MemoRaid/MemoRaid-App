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
