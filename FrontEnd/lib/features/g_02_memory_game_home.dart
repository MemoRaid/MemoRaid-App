import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../features/g_02_theme.dart' as custom_theme;
import 'package:flutter/material.dart' hide Theme;

class MemoryGameHome extends StatefulWidget {
  final int initialLevel;
  final String initialTheme;
  final int initialTimeSeconds;

  const MemoryGameHome({
    super.key,
    this.initialLevel = 1,
    this.initialTheme = 'Hobbies',
    this.initialTimeSeconds = 90,
  });

  @override
  State<MemoryGameHome> createState() => _MemoryGameHomeState();
}

class _MemoryGameHomeState extends State<MemoryGameHome>
    with TickerProviderStateMixin {
  final Map<String, custom_theme.Theme> _themes = {
    'Family': custom_theme.Theme(
      name: 'Family',
      emojis: [
        '👨‍👩‍👧‍👦',
        '👵',
        '👴',
        '👨‍👩‍👦',
        '👩‍👧',
        '👨‍👧',
        '👩‍👦',
        '👨‍👦',
        '👩‍👧‍👦',
        '👨‍👧‍👦',
        '👩‍👩‍👦',
        '👨‍👨‍👦',
        '👪', // Added more emojis to accommodate 4x5 grid (20 cards = 10 pairs)
        '👶',
        '👧',
      ],
    ),

    'Places': custom_theme.Theme(
      name: 'Places',
      emojis: [
        '🏠',
        '🏢',
        '🏡',
        '🏫',
        '🏥',
        '🏦',
        '🏨',
        '🏩',
        '🏪',
        '🏫',
        '🏬',
        '🏭',
        '🏯', // Added more emojis for 4x5 grid
        '🏰',
        '⛪',
      ],
    ),

    'Hobbies': custom_theme.Theme(
      name: 'Hobbies',
      emojis: [
        '🎨',
        '🎸',
        '🎹',
        '🎤',
        '🎧',
        '🎮',
        '🎲',
        '🎯',
        '🎳',
        '🎽',
        '🎿',
        '🏀',
        '⚽', // Added more emojis for 4x5 grid
        '🏓',
        '🎭',
      ],
    ),
  };

    String _currentTheme = 'Family';
  List<String> _gameImages = [];
  List<bool> _flippedCards = [];
  List<bool> _matchedCards = [];
  int _score = 0;
  int? _firstFlippedIndex;
  bool _canFlip = true;
  Timer? _timer;
  int _timeLeft = 60;
  bool _isGameActive = false;
  int _level = 1;
  int _streak = 0;
  int _moves = 0;
  int _stars = 3;
  bool _showSuccess = false;
  late AnimationController _bounceController;
  late AnimationController _rotationController;

  // Primary color scheme
  final Color _primaryColor = const Color(0xFF0D3445);
  List<Color> _themeColors = [const Color(0xFF0D3445), const Color(0xFF0A2535)];
  double _difficultyFactor = 1.0;

  // Add a flag to track if the timer has started
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize with the passed level
    _level = widget.initialLevel;

    // Initialize with the passed theme
    if (_themes.containsKey(widget.initialTheme)) {
      _currentTheme = widget.initialTheme;
    }

    _updateThemeColors();
    _initializeGame();
    if (_level == 1) {
      _showTutorialIfNeeded();
    }
  }

  void _updateThemeColors() {
    // Update theme colors based on our primary color
    switch (_currentTheme) {
      case 'Family':
        _themeColors = [
          _primaryColor,
          _primaryColor.withBlue((_primaryColor.blue * 0.8).round())
        ];
        break;
      case 'Places':
        _themeColors = [
          _primaryColor.withGreen((_primaryColor.green * 1.1).round()),
          _primaryColor
        ];
        break;
      case 'Hobbies':
        _themeColors = [
          _primaryColor.withRed((_primaryColor.red * 1.2).round()),
          _primaryColor
        ];
        break;
    }
  }

  void _initializeGame() {
    // Need 10 pairs for a 4x5 grid (20 cards total)
    // Get the first 10 emojis from the theme
    List<String> selectedEmojis = _themes[_currentTheme]!.emojis.sublist(0, 10);

    // Create pairs of each emoji
    _gameImages = [...selectedEmojis, ...selectedEmojis];
    _gameImages.shuffle();

    _flippedCards = List.generate(_gameImages.length, (_) => false);
    _matchedCards = List.generate(_gameImages.length, (_) => false);
    _score = 0;
    _firstFlippedIndex = null;
    _canFlip = true;

    // Use specified time or calculate based on level
    _timeLeft = widget.initialTimeSeconds;

    // Set difficulty based on level
    _difficultyFactor = 1.0 + ((_level - 1) * 0.1);

    _isGameActive = true;
    _moves = 0;
    _stars = 3;
    _streak = 0;

    // Reset timer started flag
    _timerStarted = false;

    // Cancel any existing timer
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    if (!_timerStarted) {
      _timerStarted = true;
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (_timeLeft > 0) {
            setState(() {
              _timeLeft--;
            });
          } else {
            _endGame();
          }
        },
      );
    }
  }

  // Show tutorial on first level
  void _showTutorialIfNeeded() {
    if (_level == 1) {
      Future.delayed(Duration(milliseconds: 300), () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text(
              'How to Play',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.touch_app, size: 40, color: Colors.blue),
                SizedBox(height: 10),
                Text(
                  'Tap cards to flip them over and find matching pairs.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Match all cards before the timer runs out!',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Level 1 is easy with extra time to learn the game.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Got it!'),
              ),
            ],
          ),
        );
      });
    }
  }

  void _handleCardTap(int index) {
    if (!_canFlip ||
        _flippedCards[index] ||
        _matchedCards[index] ||
        !_isGameActive) {
      return;
    }

    // Start timer on first card tap
    if (!_timerStarted) {
      _startTimer();
    }

    _rotationController.forward(from: 0.0);

    setState(() {
      _flippedCards[index] = true;

      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else {
        _canFlip = false;
        _moves++;

        if (_moves >= 20 && _stars == 3) {
          _stars = 2;
        } else if (_moves >= 30 && _stars == 2) {
          _stars = 1;
        }

        if (_gameImages[_firstFlippedIndex!] == _gameImages[index]) {
          _matchedCards[_firstFlippedIndex!] = true;
          _matchedCards[index] = true;

          _score += (10 * _level * _difficultyFactor).toInt();
          _streak++;

          if (_streak == 3) {
            _score += (50 * _difficultyFactor).toInt();
            setState(() {
              _showSuccess = true;
            });
            Timer(const Duration(seconds: 2), () {
              setState(() {
                _showSuccess = false;
              });
            });
            _streak = 0;
          }

          _bounceController.forward(from: 0.0);
          _canFlip = true;
          _firstFlippedIndex = null;

          if (_matchedCards.every((matched) => matched)) {
            _levelUp();
          }
        } else {
          _streak = 0;
          Timer(const Duration(seconds: 1), () {
            setState(() {
              _flippedCards[_firstFlippedIndex!] = false;
              _flippedCards[index] = false;
              _canFlip = true;
              _firstFlippedIndex = null;
            });
          });
        }
      }
    });
  }

  void _levelUp() {
    // Store the points earned in this level before moving to the next
    int pointsEarnedThisLevel = _score;

    setState(() {
      _level++;
      Timer(const Duration(milliseconds: 800), () {
        showLevelCompletionDialog(pointsEarnedThisLevel);
      });
    });
  }

  void showLevelCompletionDialog(int pointsEarnedThisLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF185373).withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        title: const Text(
          'Level Complete!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _stars,
                      (index) =>
                          const Icon(Icons.star, color: Colors.amber, size: 30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Points Earned: $pointsEarnedThisLevel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Score: $_score',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you ready for the next challenge?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showLevelUpDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Next Level'),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _level = 1;
                    _initializeGame();
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.8),
                ),
                child: const Text('Restart Game'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showLevelUpDialog() {
    String difficultyText =
        _level == 2 ? 'The challenge begins!' : 'Difficulty increases!';

    int timeForNextLevel = max(30, 90 - ((_level - 1) * 7));
    double multiplierForNextLevel = 1.0 + ((_level - 1) * 0.1);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF0A2836).withOpacity(0.95),
        title: Text(
          'Level $_level',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_level <= 3 ? Icons.arrow_upward : Icons.warning,
                color: _level <= 3 ? Colors.green : Colors.orange, size: 50),
            const SizedBox(height: 10),
            Text(
              'Get ready for Level $_level!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              difficultyText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: _level > 3 ? FontStyle.italic : FontStyle.normal,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer,
                          size: 16,
                          color: _level > 5 ? Colors.red : Colors.lightBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Time: $timeForNextLevel seconds',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        'Score: ${multiplierForNextLevel.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Start Level'),
            ),
          ),
        ],
      ),
    );
  }
