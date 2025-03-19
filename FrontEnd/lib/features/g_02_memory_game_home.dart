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