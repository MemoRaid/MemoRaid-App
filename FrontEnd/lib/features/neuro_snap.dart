import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'services/neuro_snap_stable_diffusion_service.dart';
import 'services/neuro_snap_scoring_service.dart';
import 'neuro_snap_leaderboard_screen.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';

// Custom app theme colors
class AppColors {
  static const Color primaryDark = Color(0xFF0D3445);
  static const Color primaryMedium = Color(0xFF164B60);
  static const Color primaryLight = Color(0xFF2D6E8E);
  static const Color accentColor = Color(0xFF64CCC5);
  static const Color backgroundColor = Color(0xFFEEF5FF);
  static const Color textLight = Color(0xFFF8FBFF);
  static const Color textDark = Color(0xFF0A2730);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Memory Associations',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryMedium,
          primary: AppColors.primaryMedium,
          secondary: AppColors.accentColor,
          background: AppColors.backgroundColor,
          surface: AppColors.backgroundColor,
          onPrimary: AppColors.textLight,
          onSecondary: AppColors.textDark,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: AppColors.primaryMedium,
            foregroundColor: AppColors.textLight,
          ),
        ),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textLight,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryMedium,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.psychology,
                    size: 80,
                    color: AppColors.accentColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NeuroSnap',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 46,
                      color: AppColors.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Memory Recall Game for Rehabilitation',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textLight.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  _buildMenuButton(
                    context: context,
                    label: 'Start Game',
                    icon: Icons.play_arrow_rounded,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameModesScreen(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context: context,
                    label: 'Leaderboard',
                    icon: Icons.leaderboard,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaderboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentColor,
            AppColors.accentColor.withOpacity(0.8),
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 60),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryDark),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameModesScreen extends StatelessWidget {
  const GameModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Challenge'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textLight,
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily challenge banner with updated gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentColor.withOpacity(0.8),
                      AppColors.accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Challenge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Complete today\'s challenge to earn bonus points!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const GameScreen(
                                  gameMode: 'daily',
                                  isDaily: true,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.amber.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('PLAY'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'Game Modes',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a mode that matches your skill level',
                style: TextStyle(color: AppColors.textLight.withOpacity(0.8)),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    _buildGameModeCard(
                      context: context,
                      title: 'Beginner Mode',
                      description:
                          'Perfect for new players. More time to memorize images with helpful hints.',
                      icon: Icons.lightbulb_outline,
                      difficulty: 1,
                      rewards: '5-15 points per correct answer',
                      color: Colors.green,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const GameScreen(
                                    gameMode: 'Beginner',
                                    isDaily: false,
                                  ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildGameModeCard(
                      context: context,
                      title: 'Expert Mode',
                      description:
                          'For memory masters. Quick glimpses of images with hints.',
                      icon: Icons.psychology,
                      difficulty: 3,
                      rewards: '15-30 points per correct answer',
                      color: Colors.red,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const GameScreen(
                                    gameMode: 'Expert',
                                    isDaily: false,
                                  ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildGameModeCard(
                      context: context,
                      title: 'Speed Challenge',
                      description:
                          'Race against time! Earn bonus points for faster responses.',
                      icon: Icons.timer,
                      difficulty: 2,
                      rewards: 'Up to 40 points with time bonus',
                      color: Colors.blue,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const GameScreen(
                                    gameMode: 'Speed',
                                    isDaily: false,
                                  ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required int difficulty,
    required String rewards,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.primaryDark.withOpacity(0.4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryMedium.withOpacity(0.7),
              AppColors.primaryDark.withOpacity(0.9),
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.8), color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: AppColors.textLight, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Difficulty indicator
                              Row(
                                children: List.generate(
                                  3,
                                  (index) => Icon(
                                    Icons.circle,
                                    size: 10,
                                    color:
                                        index < difficulty
                                            ? color
                                            : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                difficulty == 1
                                    ? 'Easy'
                                    : difficulty == 2
                                    ? 'Medium'
                                    : 'Hard',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        rewards,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('START'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class GameScreen extends StatefulWidget {
  final String gameMode;
  final bool isDaily;

  const GameScreen({super.key, required this.gameMode, this.isDaily = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  String _lastFeedbackMessage = '';
  DateTime _lastFeedbackTime = DateTime.now();
  late AnimationController _imageAnimationController;
  bool _imageVisible = true;
  int? _selectedOption;
  late Animation<double> _imageAnimation;
  bool _isLoading = true;
  ImagePair? _imagePair;
  final StableDiffusionService _stableDiffusionService =
      StableDiffusionService();
  final ScoringService _scoringService = ScoringService();
  int _score = 0;
  int _round = 0;

  // Concepts to generate image pairs for - expanded list
  final List<String> _concepts = [
    'apple',
    'cat',
    'car',
    'house',
    'chair',
    'tree',
    'book',
    'flower',
    'bird',
    'watch',
    'coffee cup',
    'banana',
    'dog',
    'bicycle',
    'laptop',
    'shoe',
    'camera',
    'guitar',
    'umbrella',
    'sunglasses',
  ];

  // Add a variable to track the last concept used
  String? _lastUsedConcept;

  // Add viewTime parameter based on difficulty
  int get _viewTime {
    switch (widget.gameMode) {
      case 'Beginner':
        return 7; // 7 seconds to view images
      case 'Expert':
        return 3; // Only 3 seconds to view images
      case 'Speed':
        return 2; // 2 seconds for speed challenge
      case 'Daily':
        return 5; // 5 seconds for daily challenge
      default:
        return 5;
    }
  }

  // Adjust points based on game mode
  int _calculatePoints(bool isCorrect) {
    return _scoringService.calculatePoints(
      isCorrect: isCorrect,
      gameMode: widget.gameMode,
      comboCount: _comboCount,
      timeRemaining: _timeRemainingNotifier.value ?? 0,
    );
  }

  // Add time tracking for speed mode
  final ValueNotifier<int?> _timeRemainingNotifier = ValueNotifier<int?>(null);
  Timer? _timer;

  // Get view size based on difficulty
  double get _imageSize {
    switch (_difficultyLevels) {
      case 1:
        return 150.0; // Largest for beginners
      case 2:
        return 130.0; // Medium for intermediate
      case 3:
        return 110.0; // Small for experts
      default:
        return 130.0;
    }
  }

  // Animation controllers for enhanced visual effects
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  // Confetti controller for celebration effects
  late ConfettiController _confettiController;

  // Game enhancement variables
  int _comboCount = 0;
  int _streak = 0;
  int _maxStreak = 0;
  bool _powerUpAvailable = false;
  bool _hintUsed = false;
  bool _isAnswerRevealing = false;
  double _gameProgress = 0.0;

  // For power-ups
  final int _requiredComboForPowerUp = 3;
  bool _isFiftyfiftyUsed = false;

  // For hints
  List<String> _hints = [];
  bool _showHint = false;

  // Game level configuration
  int _level = 1;
  int _attemptsRemaining = 3; // 3 attempts per question
  int _totalCorrectAnswers = 0;

  // Define rounds per level
  int get _maxRounds {
    // Daily challenge has fixed rounds
    if (widget.isDaily) return 5;

    // Regular game modes have level-based rounds
    switch (_level) {
      case 1:
        return 3; // Level 1: 3 rounds
      case 2:
        return 4; // Level 2: 4 rounds
      case 3:
        return 5; // Level 3: 5 rounds
      case 4:
        return 5; // Level 4: 5 rounds
      case 5:
        return 5; // Level 5: 5 rounds
      default:
        return 3;
    }
  }

  // Check if all rounds in current level are complete
  bool get _isLevelComplete => _round >= _maxRounds;

  // Define difficulty based on level rather than just game mode
  int get _difficultyLevels {
    // For daily challenge, keep existing random difficulty
    if (widget.isDaily) {
      return 1 + Random().nextInt(3);
    }

    // For beginner mode, difficulty increases more slowly
    if (widget.gameMode == 'Beginner') {
      return min((_level + 1) ~/ 2, 3); // 1,1,2,2,3
    }

    // For expert mode, always challenging
    if (widget.gameMode == 'Expert') {
      return 3;
    }

    // For speed mode, medium to hard difficulty
    return min(_level, 3);
  }

  // Add a variable to track total attempts used throughout the game
  int _totalAttemptsMade = 0;

  @override
  void initState() {
    super.initState();
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _imageAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _imageAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize pulse animation
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(
            parent: _pulseAnimationController, curve: Curves.easeInOut));

    // Initialize confetti
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Test API connectivity before loading images
    _testApiAndLoadImages();

    // Reset attempts when starting
    _attemptsRemaining = 3;
    _level = 1;
    _round = 0;
  }

 // New method to test API before loading images
  Future<void> _testApiAndLoadImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First test API connectivity
      await _stableDiffusionService.testApiConnection();

      // if (!isConnected) {
      //   throw Exception(
      //       "Cannot connect to image generation API. Check your internet connection and API key.");
      // }

      // If connection is good, proceed with loading images
      _loadImages();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error with more helpful message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Connection Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _testApiAndLoadImages,
            ),
          ),
        );
      }
    }
  }

  // Modify existing loading method to include more error details
  Future<void> _loadImages() async {
    // If level is complete, show level completion screen
    if (_isLevelComplete && !widget.isDaily) {
      _showLevelCompleteDialog();
      return;
    }

    // Reset attempts when loading new question
    _attemptsRemaining = 3;

    _timer?.cancel();

    setState(() {
      _isLoading = true;
      _imageVisible = true;
      _selectedOption = null;
      _imageAnimationController.reset();
    });

    try {
      // Choose a random concept that's different from the last one used
      final random = Random();
      String concept;

      do {
        // Randomly select a concept from the list
        concept = _concepts[random.nextInt(_concepts.length)];
      } while (concept == _lastUsedConcept && _concepts.length > 1);

      // Update the last used concept tracker
      _lastUsedConcept = concept;

      // Increment round counter - only increment if not already at max rounds
      if (_round < _maxRounds) {
        _round++;
      }

      // Pass the difficulty level to the image generation service
      _imagePair = await _stableDiffusionService.generateImagePair(
        concept,
        difficulty: _difficultyLevels,
      );

      // Generate hints based on the concept
      _generateHints(concept);

      // Reset game state for new round
      setState(() {
        _hintUsed = false;
        _showHint = false;
        if (_isFiftyfiftyUsed) _isFiftyfiftyUsed = false;

        // Update game progress based on rounds in current level
        _gameProgress = _round / _maxRounds;
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show both images for 5 seconds, then hide the second one
        Future.delayed(Duration(seconds: _viewTime), () {
          if (mounted) {
            _hideImage();

            // Start timer after images are hidden for speed mode
            if (widget.gameMode == 'Speed') {
              _startTimer();
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Improve error logging
        String errorMessage = e.toString();
        debugPrint('Detailed error loading images: $errorMessage');

        setState(() {
          _isLoading = false;
        });

        // More informative error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error: ${errorMessage.length > 100 ? errorMessage.substring(0, 100) + '...' : errorMessage}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadImages,
            ),
          ),
        );
      }
    }
  }
