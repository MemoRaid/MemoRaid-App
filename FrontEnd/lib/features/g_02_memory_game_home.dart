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