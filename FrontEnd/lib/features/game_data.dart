import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:ui';

/// Defines a game level with its specific configuration
/// Each level can have different difficulty parameters
class GameLevel {
  final int levelNumber;
  final int dotCount; // Number of dots displayed on screen
  final int sequenceLength; // Length of sequence player must memorize
  final bool dotsMove; // Whether dots move around the screen
  final double movementSpeed; // Speed at which dots move (if enabled)
  final bool shuffleAndStop; // Whether dots shuffle position then stop

  const GameLevel({
    required this.levelNumber,
    required this.dotCount,
    required this.sequenceLength,
    this.dotsMove = false, // Default: static dots
    this.movementSpeed = 1.0, // Default: standard speed
    this.shuffleAndStop = false, // Default: continuous movement if moving
  });
}
