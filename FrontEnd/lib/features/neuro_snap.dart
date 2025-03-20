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
    }2
  }
 void _generateHints(String concept) {
    // Generate helpful hints based on the concept
    _hints = [
      "Look for unique details that stand out",
      "Pay attention to the shape and color of the $concept",
      "Try to remember the position and orientation",
      "Notice any distinctive features of this particular $concept"
    ];
    _hints.shuffle();
  }

  void _hideImage() {
    _imageAnimationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _imageVisible = false;
        });
      }
    });
  }

  void _handleCorrectAnswer(int points) {
    setState(() {
      _score += points;
      _comboCount++;
      _streak++;
      _maxStreak = max(_streak, _maxStreak);
      _powerUpAvailable = _comboCount >= _requiredComboForPowerUp;
    });

    _showFeedback('Correct! +$points points', true);
    _confettiController.play();
    _revealAnswer(true);
  }

  void _selectOption(int index) {
    // Handle incorrect answer
    void _handleIncorrectAnswer() {
      setState(() {
        _comboCount = 0;
        _streak = 0;
      });
      _showFeedback('Incorrect! Try again.', false);
    }

    // Don't allow selection if already selected, timer is up, or no attempts left
    if (_selectedOption != null ||
        (_timeRemainingNotifier.value != null &&
            _timeRemainingNotifier.value == 0) ||
        _attemptsRemaining <= 0) {
      return;
    }

    setState(() {
      _selectedOption = index;
    });

    // Get the correct hidden image URL
    final String hiddenImageUrl = _imagePair!.hiddenImageIndex == 0
        ? _imagePair!.firstImage
        : _imagePair!.secondImage;

    // Check if the selected option is correct
    final selectedImageUrl = _imagePair!.optionImages[index];
    final isCorrect = selectedImageUrl == hiddenImageUrl;

    // Calculate points based on game mode and combos
    int points = _calculatePoints(isCorrect);

    // Apply combo bonus
    if (isCorrect && _comboCount > 0) {
      points = (points * (1 + _comboCount * 0.1)).toInt();
    }

    // Store current timer value for Speed mode to restore it later if needed
    final currentTimerValue = _timeRemainingNotifier.value;

    // Pause timer temporarily while showing feedback
    if (widget.gameMode == 'Speed' && _timer != null) {
      _timer!.cancel();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (isCorrect) {
        // Handle correct answer - increment total correct answers
        _totalCorrectAnswers++;
        // Always count a correct answer as one attempt
        _totalAttemptsMade++;
        _handleCorrectAnswer(points);
      } else {
        // Decrease attempts remaining
        setState(() {
          _attemptsRemaining--;
          // Increment total attempts counter when an attempt is used
          _totalAttemptsMade++;
        });

        if (_attemptsRemaining <= 0) {
          // Out of attempts - show correct answer and game over
          _showFeedback('No attempts remaining!', false);
          _revealAnswer(
              false); // This will trigger _showGameOverDialog() after revealing answer
        } else {
          // Still have attempts left - allow another try
          _handleIncorrectAnswer();

          // Reset selection so user can select again
          setState(() {
            _selectedOption = null;
          });

          // For Speed mode, resume the timer from where it left off
          if (widget.gameMode == 'Speed' &&
              currentTimerValue != null &&
              currentTimerValue > 0) {
            _resumeTimer(currentTimerValue);
          }
        }
      }
    });
  }
 // Add a new method to build the timer display
  Widget _buildTimerDisplay() {
    return ValueListenableBuilder<int?>(
      valueListenable: _timeRemainingNotifier,
      builder: (context, timeRemaining, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: timeRemaining != null && timeRemaining > 0
                ? Colors.blue.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer,
                color: timeRemaining != null && timeRemaining > 0
                    ? Colors.blue
                    : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                timeRemaining != null && timeRemaining > 0
                    ? '$timeRemaining s'
                    : 'Time\'s up!',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: timeRemaining != null && timeRemaining > 0
                      ? Colors.blue
                      : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Add a new method to resume the timer without resetting
  void _resumeTimer(int timeRemaining) {
    // Set the time remaining to continue from where it was paused
    _timeRemainingNotifier.value = timeRemaining;

    // Create a new timer to continue countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemainingNotifier.value! > 0) {
        // Update only the timer value, don't rebuild everything
        _timeRemainingNotifier.value = _timeRemainingNotifier.value! - 1;
      } else {
        timer.cancel();

        // Show feedback when time's up
        _showFeedback('Time\'s up!', false);

        setState(() {
          _selectedOption = -1; // Use -1 to indicate timeout
          _attemptsRemaining = 0; // Use all attempts when time runs out
        });

        // Immediately show game over for timed mode
        Future.delayed(const Duration(seconds: 1), () {
          _showGameOverDialog();
        });
      }
    });
  }

  void _revealAnswer(bool wasCorrect) {
    // Store current timer value to potentially resume after the reveal
    final currentTimerValue =
        widget.gameMode == 'Speed' ? _timeRemainingNotifier.value : null;

    setState(() {
      _isAnswerRevealing = true;

      // Pause timer display during the reveal but don't reset it
      if (_timer != null) {
        _timer!.cancel();
      }
    });

    // After showing the answer, determine next action
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnswerRevealing = false;
        });

        // Check if attempts are exhausted and it's not a correct answer
        if (!wasCorrect && _attemptsRemaining <= 0) {
          // Show game over dialog if all attempts were used
          _showGameOverDialog();
          return;
        }

        // Check if this was the last round
        bool isLastRound = _round >= _maxRounds;

        // For correct answers, proceed to next question or level complete
        if (wasCorrect) {
          if (isLastRound && !widget.isDaily) {
            // If it's the final round, show level complete
            _showLevelCompleteDialog();
          } else {
            // Otherwise load next image
            _loadImages();
          }
        }
        // For incorrect answers with remaining attempts, resume the timer
        else if (widget.gameMode == 'Speed' &&
            currentTimerValue != null &&
            currentTimerValue > 0) {
          _resumeTimer(currentTimerValue);
        }
      }
    });
  }

  void _startTimer() {
    // First cancel any existing timer
    _timer?.cancel();

    if (widget.gameMode == 'Speed') {
      // Start a new timer (only for new rounds, not for retries)
      _timeRemainingNotifier.value = 15; // 15 seconds to answer

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeRemainingNotifier.value! > 0) {
          // Update only the timer value, don't rebuild everything
          _timeRemainingNotifier.value = _timeRemainingNotifier.value! - 1;
        } else {
          timer.cancel();

          // Show feedback when time's up
          _showFeedback('Time\'s up!', false);

          setState(() {
            _selectedOption = -1; // Use -1 to indicate timeout
            _attemptsRemaining = 0; // Use all attempts when time runs out
          });

          // Immediately show game over for timed mode
          Future.delayed(const Duration(seconds: 1), () {
            _showGameOverDialog();
          });
        }
      });
    }
  }
 // New method to show game over dialog when attempts are exhausted
  void _showGameOverDialog() {
    if (!mounted) return;

    // Calculate the same accuracy metrics as in level complete
    final int totalQuestionsAttempted = _round;
    final int maxPossibleAttempts = totalQuestionsAttempted * 3;
    final int attemptsUsed = _totalAttemptsMade;

    final double questionAccuracy = totalQuestionsAttempted > 0
        ? (_totalCorrectAnswers / totalQuestionsAttempted) * 100
        : 0;
    final double attemptEfficiency =
        attemptsUsed > 0 ? (_totalCorrectAnswers / attemptsUsed) * 100 : 0;
    final double combinedAccuracy = (questionAccuracy + attemptEfficiency) / 2;

    // Cancel any active timers
    _timer?.cancel();

    // Save game result to persistent storage
    _scoringService.saveGameResult(
      mode: widget.gameMode,
      score: _score,
      correctAnswers: _totalCorrectAnswers,
      totalQuestions: _round,
      maxStreak: _maxStreak,
      totalAttempts: _totalAttemptsMade, // Add this parameter
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        // Prevent back button from dismissing the dialog
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: AppColors.primaryDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Game Over!',
            style: TextStyle(color: Colors.red, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game over message
                Text(
                  'You\'ve used all your attempts for this question.',
                  style: TextStyle(color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Results for session
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryMedium.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildResultRow('Final Score', '$_score',
                          isHeader: false, highlight: true),
                      _buildResultRow(
                          'Correct Answers', '$_totalCorrectAnswers/$_round',
                          isHeader: false),
                      _buildResultRow(
                          'Accuracy', '${combinedAccuracy.toStringAsFixed(0)}%',
                          isHeader: false,
                          tooltip: 'Based on questions and attempts'),
                      _buildResultRow('Attempts Used',
                          '$attemptsUsed/${maxPossibleAttempts}',
                          isHeader: false),
                      _buildResultRow('Max Streak', '$_maxStreak',
                          isHeader: false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Encouragement message
                Text(
                  'Keep practicing to improve your memory skills!',
                  style: TextStyle(
                      color: AppColors.textLight, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Return to Menu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: AppColors.primaryDark,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to game modes
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
// Use 50/50 power-up to eliminate half of incorrect options
  void _useFiftyFifty() {
    if (!_powerUpAvailable || _isFiftyfiftyUsed || _selectedOption != null)
      return;

    // Get the correct answer
    final String hiddenImageUrl = _imagePair!.hiddenImageIndex == 0
        ? _imagePair!.firstImage
        : _imagePair!.secondImage;

    // Find index of correct answer
    int correctIndex = _imagePair!.optionImages.indexOf(hiddenImageUrl);

    // Choose which wrong answers to eliminate
    List<int> wrongIndices =
        List.generate(_imagePair!.optionImages.length, (i) => i)
            .where((i) => i != correctIndex)
            .toList();
    wrongIndices.shuffle();

    // Keep only half (rounded up) of wrong answers
    int toRemove = wrongIndices.length ~/ 2;
    List<int> indicesToEliminate = wrongIndices.sublist(0, toRemove);

    setState(() {
      _isFiftyfiftyUsed = true;
      _powerUpAvailable = false;
    });

    // Show elimination animation
    for (int index in indicesToEliminate) {
      _flashOption(index);
    }
  }

  void _flashOption(int index) {
    // Flash the option that's being eliminated
    // This creates a visual effect for the power-up
  }

  void _showHintToUser() {
    if (_hintUsed || _selectedOption != null) return;

    // Get the correct image prompt from the ImagePair object
    String promptHint;
    if (_imagePair != null &&
        _imagePair!.firstImagePrompt != null &&
        _imagePair!.secondImagePrompt != null) {
      // Use the prompt from the hidden image
      promptHint = _imagePair!.hiddenImageIndex == 0
          ? _imagePair!.firstImagePrompt!
          : _imagePair!.secondImagePrompt!;
    } else {
      // Fall back to regular hints if prompts aren't available
      promptHint =
          _hints.isNotEmpty ? _hints.first : "Look closely at the details";
    }

    setState(() {
      _showHint = true;
      _hintUsed = true;
      // Store the prompt to show
      _currentHintText = promptHint;
    });

    // Hide hint after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
    });
  }

  void _showFeedback(String message, bool isCorrect) {
    // Update tracking variables
    _lastFeedbackMessage = message;
    _lastFeedbackTime = DateTime.now();

    // First, clear any existing SnackBars to prevent stacking
    ScaffoldMessenger.of(context).clearSnackBars();

    // Then show the new message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _timeRemainingNotifier.dispose();
    _pulseAnimationController.dispose();
    _confettiController.dispose();
    _imageAnimationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              widget.isDaily ? 'Daily Challenge' : '${widget.gameMode} Mode',
            ),
            if (widget.isDaily) ...[
              const SizedBox(width: 8),
              const Icon(Icons.star, color: AppColors.accentColor, size: 20),
            ],
          ],
        ),
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
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _isLoading
                    ? _buildLoadingState()
                    : _imagePair == null
                        ? _buildErrorState()
                        : _buildGameContent(),
              ),
            ),
            // Confetti overlay for celebrations
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2, // straight down
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                maxBlastForce: 20,
                minBlastForce: 5,
                gravity: 0.2,
              ),
            ),
            // Hint overlay
            if (_showHint) _buildHintOverlay(),

            // Answer reveal overlay
            if (_isAnswerRevealing) _buildAnswerRevealOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Generating images...\nThis may take a moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to generate images',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: AppColors.primaryDark,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    // Replace Column with SingleChildScrollView + Column to make content scrollable
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              48, // account for padding
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top content (status bar, progress)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Game status bar
                _buildEnhancedStatusBar(),

                const SizedBox(height: 16),

                // Progress indicator
                _buildProgressBar(),

                const SizedBox(height: 24),
              ],
            ),

            // Middle content (images and options)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Description text
                Text(
                  _imagePair!.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),

                // Image row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnimatedImageContainer(
                      _imagePair!.firstImage,
                      _imageVisible || _imagePair!.hiddenImageIndex != 0,
                      size: _imageSize,
                    ),
                    _buildAnimatedImageContainer(
                      _imagePair!.secondImage,
                      _imageVisible || _imagePair!.hiddenImageIndex != 1,
                      size: _imageSize,
                    ),
                  ],
                ),

                // Power-up and options section - always show the hint when images are hidden
                if (!_imageVisible && !_isAnswerRevealing) ...[
                  const SizedBox(height: 24),

                  // Always show the power-up bar since it now contains the hint button
                  _buildPowerUpBar(),

                  const SizedBox(height: 16),

                  // Options section
                  const Text(
                    'Select the missing image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedOptionGrid(_imagePair!.optionImages),
                ],
              ],
            ),

            // Bottom content (control buttons)
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: _buildGameControlButtons(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEnhancedStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark.withOpacity(0.7),
            AppColors.primaryMedium.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Score with animation and updated colors
          ScaleTransition(
            scale: _score > 0
                ? _pulseAnimation
                : const AlwaysStoppedAnimation(1.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentColor.withOpacity(0.7),
                    AppColors.accentColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.star,
                      color: Theme.of(context).colorScheme.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_score',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Streak counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _streak > 0
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: _streak > 0 ? Colors.orange : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Streak: $_streak',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _streak > 0 ? Colors.orange : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Timer display - only show for Speed mode
          if (widget.gameMode == 'Speed') _buildTimerDisplay(),

          // Attempts remaining indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _attemptsRemaining > 1
                  ? AppColors.accentColor.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.favorite,
                      size: 14,
                      color: index < _attemptsRemaining
                          ? Colors.red
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Progress:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Round $_round/${_maxRounds}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            if (!widget.isDaily) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level $_level',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _gameProgress,
            backgroundColor: AppColors.primaryDark.withOpacity(0.3),
            color: AppColors.accentColor,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildPowerUpBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark.withOpacity(0.2),
            Colors.indigo.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Power-ups or combo progress
          Row(
            children: [
              // 50/50 Power-up
              if (_powerUpAvailable)
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: GestureDetector(
                    onTap: _useFiftyFifty,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isFiftyfiftyUsed ? Colors.grey : Colors.indigo,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.filter_2,
                          color: Colors.white, size: 20),
                    ),
                  ),
                )
              else if (_comboCount > 0)
                // Combo progress
                Row(
                  children: [
                    const Text(
                      'Combo: ',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    ...List.generate(
                      _requiredComboForPowerUp,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: i < _comboCount
                              ? Colors.indigo
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Placeholder text when no powerups available
                const Text(
                  'Use hints to help remember',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
            ],
          ),

          // Right side: Hint button
          Column(
            children: [
              GestureDetector(
                onTap: _showHintToUser,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _hintUsed ? Colors.grey : Colors.amber.shade600,
                        _hintUsed
                            ? Colors.grey.shade600
                            : Colors.amber.shade800,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _hintUsed ? 'Used' : 'Hint',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
