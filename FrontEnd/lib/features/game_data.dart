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

/// Tracks achievements upon completing a level
/// Used to display appropriate feedback and rewards to the player
class LevelAchievement {
  final bool isNewHighScore; // Whether player beat their previous score
  final bool isNewLevelUnlocked; // Whether this unlocked a new level
  final int previousHighScore; // Previous best score for comparison

  LevelAchievement({
    required this.isNewHighScore,
    required this.isNewLevelUnlocked,
    required this.previousHighScore,
  });

  /// Helper to determine if any special achievement was earned
  bool get isSpecialAchievement => isNewHighScore || isNewLevelUnlocked;
}

/// Defines a layer for creating wave animations in the background
/// Multiple layers with different parameters create complex wave effects
class WaveLayer {
  final Color color; // Color of this wave layer
  final double speed; // How fast the wave moves
  final double amplitude; // Height of the wave
  final double frequency; // How compressed/spread out the wave is
  final double phase; // Starting position of the wave
  final double heightFactor; // Vertical positioning factor

  WaveLayer({
    required this.color,
    required this.speed,
    required this.amplitude,
    required this.frequency,
    required this.phase,
    required this.heightFactor,
  });
}

/// Represents a single node in the particle background effect
/// Used to create flowing background animations
class ParticleNode {
  Offset position; // Current position
  final double size; // Size of the particle
  final double speed; // Movement speed
  double angle; // Direction of movement
  final double opacity; // Transparency value

  ParticleNode({
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
    required this.opacity,
  });

  /// Updates the particle position based on time and ensures it wraps around screen
  void update(double time, Size screenSize) {
    // Move particle based on angle and speed
    position = Offset(
      position.dx + cos(angle) * speed,
      position.dy + sin(angle) * speed,
    );

    // Wrap particles around screen edges to create infinite effect
    if (position.dx < -50)
      position = Offset(screenSize.width + 50, position.dy);
    if (position.dx > screenSize.width + 50)
      position = Offset(-50, position.dy);
    if (position.dy < -50)
      position = Offset(position.dx, screenSize.height + 50);
    if (position.dy > screenSize.height + 50)
      position = Offset(position.dx, -50);

    // Slightly vary angle over time for more organic movement
    angle += (sin(time * 0.5) * 0.03);
  }
}

/// Defines a connection between particle nodes
/// Used to create web-like effects in the background
class Connection {
  final int startNodeIndex; // Index of first connected node
  final int endNodeIndex; // Index of second connected node
  final double maxDistance; // Maximum distance before connection disappears
  final double thickness; // Line thickness

  Connection({
    required this.startNodeIndex,
    required this.endNodeIndex,
    required this.maxDistance,
    required this.thickness,
  });
}

/// Similar to ParticleNode but specifically for dot-shaped particles
/// Used for specialized visual effects
class ParticleDot {
  Offset position; // Current position
  final double size; // Size of the dot
  final double opacity; // Transparency
  final double speed; // Movement speed
  double angle; // Direction of movement

  ParticleDot({
    required this.position,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.angle,
  });

  /// Updates particle position and ensures screen wrapping
  void update(double time, Size screenSize) {
    // Move particle based on angle and speed
    position = Offset(
      position.dx + cos(angle) * speed,
      position.dy + sin(angle) * speed,
    );

    // Wrap around screen edges
    if (position.dx < -50)
      position = Offset(screenSize.width + 50, position.dy);
    if (position.dx > screenSize.width + 50)
      position = Offset(-50, position.dy);
    if (position.dy < -50)
      position = Offset(position.dx, screenSize.height + 50);
    if (position.dy > screenSize.height + 50)
      position = Offset(position.dx, -50);

    // Slightly change angle over time for organic movement
    angle += sin(time * 0.3) * 0.02;
  }
}

/// Manages persistent game data including scores and level progression
/// Uses SharedPreferences to save data between game sessions
class GameDataManager {
  /// Retrieves the overall highest score across all levels
  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }

  /// Gets the highest level unlocked by the player
  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unlockedLevel') ?? 1; // Default to level 1
  }

  /// Saves newly unlocked level progress
  static Future<void> saveUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlockedLevel', level);
  }

  /// Gets the high score for a specific level
  static Future<int> getLevelHighScore(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore_level_$level') ?? 0;
  }

  /// Saves a high score for a specific level (only if better than previous)
  static Future<void> saveLevelHighScore(int level, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentLevelHigh = prefs.getInt('highScore_level_$level') ?? 0;

    if (score > currentLevelHigh) {
      await prefs.setInt('highScore_level_$level', score);
    }
  }

  /// Checks if the player achieved anything noteworthy in the level
  /// Returns details about high scores and level unlocking
  static Future<LevelAchievement> checkLevelAchievement(
    int level,
    int score,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if this is a new level high score
    final currentLevelHigh = prefs.getInt('highScore_level_$level') ?? 0;
    final isNewHighScore = score > currentLevelHigh;

    if (isNewHighScore) {
      await prefs.setInt('highScore_level_$level', score);
    }

    // Check if this is a new overall high score
    final currentHigh = prefs.getInt('highScore') ?? 0;
    if (score > currentHigh) {
      await prefs.setInt('highScore', score);
    }

    // Check if this unlocks a new level
    final currentUnlockedLevel = prefs.getInt('unlockedLevel') ?? 1;
    bool isNewLevelUnlocked = false;

    if (level >= currentUnlockedLevel && level < gameLevels.length) {
      isNewLevelUnlocked = true;
      await prefs.setInt('unlockedLevel', level + 1);
    }

    return LevelAchievement(
      isNewHighScore: isNewHighScore,
      isNewLevelUnlocked: isNewLevelUnlocked,
      previousHighScore: currentLevelHigh,
    );
  }

  /// Resets all game progress
  /// Used for testing or when player wants to start fresh
  static Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Reset unlocked level back to 1
    await prefs.setInt('unlockedLevel', 1);

    // Reset overall high score
    await prefs.setInt('highScore', 0);

    // Reset individual level high scores
    for (final level in gameLevels) {
      await prefs.remove('highScore_level_${level.levelNumber}');
    }
  }
}
