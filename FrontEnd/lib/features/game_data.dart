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

/// Predefined levels with progressive difficulty
/// Early levels are simpler with static dots and shorter sequences
/// Later levels introduce movement and longer sequences
final List<GameLevel> gameLevels = [
  // Static dot levels (1-3)
  const GameLevel(levelNumber: 1, dotCount: 3, sequenceLength: 3),
  const GameLevel(levelNumber: 2, dotCount: 4, sequenceLength: 3),
  const GameLevel(levelNumber: 3, dotCount: 6, sequenceLength: 4),
  // Shuffle and stop levels (4-9)
  // Dots move, then stop before player must repeat sequence
  const GameLevel(
    levelNumber: 4,
    dotCount: 4,
    sequenceLength: 4,
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.4,
  ),
  const GameLevel(
    levelNumber: 5,
    dotCount: 5,
    sequenceLength: 4,
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.5,
  ),
  const GameLevel(
    levelNumber: 6,
    dotCount: 6,
    sequenceLength: 4,
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.6,
  ),
  const GameLevel(
    levelNumber: 7,
    dotCount: 6,
    sequenceLength: 5,
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.7,
  ),
  const GameLevel(
    levelNumber: 8,
    dotCount: 7,
    sequenceLength: 5,
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.8,
  ),
  const GameLevel(
    levelNumber: 9,
    dotCount: 7,
    sequenceLength: 6,
    dotsMove: true,
    shuffleAndStop: true,
    movementSpeed: 0.9,
  ),
];

/// Represents a single interactive dot in the game
/// Dots can be tapped, highlighted, and moved
class Dot {
  final int id; // Unique identifier for the dot
  final Offset position; // Position on screen
  final double size; // Diameter of the dot
  final bool isActive; // Whether dot is interactable
  final bool isHighlighted; // Whether dot is currently highlighted in sequence

  Dot({
    required this.id,
    required this.position,
    required this.size,
    required this.isActive,
    required this.isHighlighted,
  });

  /// Creates a new Dot with updated properties
  /// Useful for updating position or state without recreating the entire object
  Dot copyWith({
    int? id,
    Offset? position,
    double? size,
    bool? isActive,
    bool? isHighlighted,
  }) {
    return Dot(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      isActive: isActive ?? this.isActive,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}
