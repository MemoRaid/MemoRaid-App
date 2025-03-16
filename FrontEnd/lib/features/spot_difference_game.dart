import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class SpotDifferenceGame extends StatefulWidget {
  const SpotDifferenceGame({super.key});

  @override
  _SpotDifferenceGameState createState() => _SpotDifferenceGameState();
}

class _SpotDifferenceGameState extends State<SpotDifferenceGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _totalDifferences = 5;
  int _foundDifferences = 0;
  int _timeRemaining = 120; // 2 minutes in seconds
  Timer? _timer;
  bool _gameOver = false;
  bool _gameWon = false;
  bool _showHint = false;
  int _currentLevel = 0;
  int _maxLevels = 10; // Changed from 3 to 10
  bool _showLevelSelection = true;

  // List of differences per level
  final List<List<Map<String, dynamic>>> _levelDifferences = [
    // Level 1
    [
      {'x': -0.326, 'y': 1.882, 'radius': 0.04, 'found': false},
      {'x': -0.413, 'y': 1.671, 'radius': 0.04, 'found': false},
      {'x': 0.665, 'y': 1.326, 'radius': 0.04, 'found': false},
      {'x': -0.263, 'y': 1.752, 'radius': 0.04, 'found': false},
      {'x': 0.2, 'y': 0.8, 'radius': 0.05, 'found': false},
    ],
    // Level 2
    [
      {'x': 0.25, 'y': 0.35, 'radius': 0.04, 'found': false},
      {'x': 0.65, 'y': 0.15, 'radius': 0.05, 'found': false},
      {'x': 0.45, 'y': 0.55, 'radius': 0.04, 'found': false},
      {'x': 0.75, 'y': 0.65, 'radius': 0.05, 'found': false},
      {'x': 0.15, 'y': 0.75, 'radius': 0.04, 'found': false},
      {'x': 0.55, 'y': 0.85, 'radius': 0.05, 'found': false},
    ],
    // Level 3
    [
      {'x': 0.2, 'y': 0.3, 'radius': 0.04, 'found': false},
      {'x': 0.6, 'y': 0.1, 'radius': 0.04, 'found': false},
      {'x': 0.4, 'y': 0.5, 'radius': 0.04, 'found': false},
      {'x': 0.7, 'y': 0.6, 'radius': 0.04, 'found': false},
      {'x': 0.1, 'y': 0.7, 'radius': 0.04, 'found': false},
      {'x': 0.5, 'y': 0.8, 'radius': 0.04, 'found': false},
      {'x': 0.9, 'y': 0.4, 'radius': 0.04, 'found': false},
    ],
    // Level 4
    [
      {'x': 0.15, 'y': 0.25, 'radius': 0.04, 'found': false},
      {'x': 0.45, 'y': 0.35, 'radius': 0.04, 'found': false},
      {'x': 0.75, 'y': 0.45, 'radius': 0.04, 'found': false},
      {'x': 0.25, 'y': 0.65, 'radius': 0.04, 'found': false},
      {'x': 0.55, 'y': 0.75, 'radius': 0.04, 'found': false},
      {'x': 0.85, 'y': 0.85, 'radius': 0.04, 'found': false},
      {'x': 0.35, 'y': 0.15, 'radius': 0.04, 'found': false},
      {'x': 0.65, 'y': 0.55, 'radius': 0.04, 'found': false},
    ],
    // Level 5
    [
      {'x': 0.2, 'y': 0.3, 'radius': 0.04, 'found': false},
      {'x': 0.5, 'y': 0.2, 'radius': 0.04, 'found': false},
      {'x': 0.8, 'y': 0.4, 'radius': 0.04, 'found': false},
      {'x': 0.3, 'y': 0.6, 'radius': 0.04, 'found': false},
      {'x': 0.6, 'y': 0.7, 'radius': 0.04, 'found': false},
      {'x': 0.9, 'y': 0.8, 'radius': 0.04, 'found': false},
      {'x': 0.4, 'y': 0.1, 'radius': 0.04, 'found': false},
      {'x': 0.7, 'y': 0.5, 'radius': 0.04, 'found': false},
      {'x': 0.1, 'y': 0.9, 'radius': 0.04, 'found': false},
    ],
    // Level 6
    [
      // Add 10 differences with unique positions
      {'x': 0.15, 'y': 0.15, 'radius': 0.03, 'found': false},
      {'x': 0.35, 'y': 0.25, 'radius': 0.03, 'found': false},
      {'x': 0.55, 'y': 0.35, 'radius': 0.03, 'found': false},
      {'x': 0.75, 'y': 0.45, 'radius': 0.03, 'found': false},
      {'x': 0.95, 'y': 0.55, 'radius': 0.03, 'found': false},
      {'x': 0.25, 'y': 0.65, 'radius': 0.03, 'found': false},
      {'x': 0.45, 'y': 0.75, 'radius': 0.03, 'found': false},
      {'x': 0.65, 'y': 0.85, 'radius': 0.03, 'found': false},
      {'x': 0.85, 'y': 0.95, 'radius': 0.03, 'found': false},
      {'x': 0.05, 'y': 0.05, 'radius': 0.03, 'found': false},
    ],
    // Level 7
    [
      // Add 11 differences
      {'x': 0.1, 'y': 0.1, 'radius': 0.03, 'found': false},
      {'x': 0.3, 'y': 0.2, 'radius': 0.03, 'found': false},
      {'x': 0.5, 'y': 0.3, 'radius': 0.03, 'found': false},
      {'x': 0.7, 'y': 0.4, 'radius': 0.03, 'found': false},
      {'x': 0.9, 'y': 0.5, 'radius': 0.03, 'found': false},
      {'x': 0.2, 'y': 0.6, 'radius': 0.03, 'found': false},
      {'x': 0.4, 'y': 0.7, 'radius': 0.03, 'found': false},
      {'x': 0.6, 'y': 0.8, 'radius': 0.03, 'found': false},
      {'x': 0.8, 'y': 0.9, 'radius': 0.03, 'found': false},
      {'x': 0.1, 'y': 0.5, 'radius': 0.03, 'found': false},
      {'x': 0.9, 'y': 0.1, 'radius': 0.03, 'found': false},
    ],
    // Level 8
    [
      // Add 12 differences
      {'x': 0.05, 'y': 0.15, 'radius': 0.03, 'found': false},
      {'x': 0.25, 'y': 0.25, 'radius': 0.03, 'found': false},
      {'x': 0.45, 'y': 0.35, 'radius': 0.03, 'found': false},
      {'x': 0.65, 'y': 0.45, 'radius': 0.03, 'found': false},
      {'x': 0.85, 'y': 0.55, 'radius': 0.03, 'found': false},
      {'x': 0.15, 'y': 0.65, 'radius': 0.03, 'found': false},
      {'x': 0.35, 'y': 0.75, 'radius': 0.03, 'found': false},
      {'x': 0.55, 'y': 0.85, 'radius': 0.03, 'found': false},
      {'x': 0.75, 'y': 0.95, 'radius': 0.03, 'found': false},
      {'x': 0.95, 'y': 0.05, 'radius': 0.03, 'found': false},
      {'x': 0.15, 'y': 0.45, 'radius': 0.03, 'found': false},
      {'x': 0.85, 'y': 0.15, 'radius': 0.03, 'found': false},
    ],
    // Level 9
    [
      // Add 13 differences
      {'x': 0.1, 'y': 0.1, 'radius': 0.025, 'found': false},
      {'x': 0.3, 'y': 0.2, 'radius': 0.025, 'found': false},
      {'x': 0.5, 'y': 0.3, 'radius': 0.025, 'found': false},
      {'x': 0.7, 'y': 0.4, 'radius': 0.025, 'found': false},
      {'x': 0.9, 'y': 0.5, 'radius': 0.025, 'found': false},
      {'x': 0.2, 'y': 0.6, 'radius': 0.025, 'found': false},
      {'x': 0.4, 'y': 0.7, 'radius': 0.025, 'found': false},
      {'x': 0.6, 'y': 0.8, 'radius': 0.025, 'found': false},
      {'x': 0.8, 'y': 0.9, 'radius': 0.025, 'found': false},
      {'x': 0.1, 'y': 0.5, 'radius': 0.025, 'found': false},
      {'x': 0.9, 'y': 0.1, 'radius': 0.025, 'found': false},
      {'x': 0.5, 'y': 0.5, 'radius': 0.025, 'found': false},
      {'x': 0.3, 'y': 0.8, 'radius': 0.025, 'found': false},
    ],
    // Level 10
    [
      // Add 15 differences
      {'x': 0.05, 'y': 0.05, 'radius': 0.025, 'found': false},
      {'x': 0.25, 'y': 0.15, 'radius': 0.025, 'found': false},
      {'x': 0.45, 'y': 0.25, 'radius': 0.025, 'found': false},
      {'x': 0.65, 'y': 0.35, 'radius': 0.025, 'found': false},
      {'x': 0.85, 'y': 0.45, 'radius': 0.025, 'found': false},
      {'x': 0.15, 'y': 0.55, 'radius': 0.025, 'found': false},
      {'x': 0.35, 'y': 0.65, 'radius': 0.025, 'found': false},
      {'x': 0.55, 'y': 0.75, 'radius': 0.025, 'found': false},
      {'x': 0.75, 'y': 0.85, 'radius': 0.025, 'found': false},
      {'x': 0.95, 'y': 0.95, 'radius': 0.025, 'found': false},
      {'x': 0.15, 'y': 0.35, 'radius': 0.025, 'found': false},
      {'x': 0.85, 'y': 0.15, 'radius': 0.025, 'found': false},
      {'x': 0.45, 'y': 0.55, 'radius': 0.025, 'found': false},
      {'x': 0.65, 'y': 0.75, 'radius': 0.025, 'found': false},
      {'x': 0.35, 'y': 0.95, 'radius': 0.025, 'found': false},
    ],
  ];

  // Current differences for the level
  late List<Map<String, dynamic>> _differences;

  // Image pairs - you would replace these with your actual images
  final List<List<String>> _imagePairs = [
    [
      'lib/assets/images/crow1.jpeg',
      'lib/assets/images/crow2.jpeg',
    ],
    [
      'assets/images/spot_diff/pair2_original.jpg',
      'assets/images/spot_diff/pair2_modified.jpg'
    ],
    [
      'assets/images/spot_diff/pair3_original.jpg',
      'assets/images/spot_diff/pair3_modified.jpg'
    ],
    [
      'assets/images/spot_diff/pair4_original.jpg',
      'assets/images/spot_diff/pair4_modified.jpg'
    ],
    [
      'assets/images/spot_diff/pair5_original.jpg',
      'assets/images/spot_diff/pair5_modified.jpg'
    ],
    [
      'assets/images/spot_diff/pair6_original.jpg',
      'assets/images/spot_diff/pair6_modified.jpg'
    ],
    [
      'assets/images/spot_diff/pair7_original.jpg',
      'assets/images/spot_diff/pair7_modified.jpg'
    ],
    [
      'assets/images/spot_diff/pair8_original.jpg',
      'assets/images/spot_diff/pair8_modified.jpg'
    ],
    [
      'assets/images/spot_diff/pair9_original.jpg',
      'assets/images/spot_diff/pair9_modified.jpg'
    ],
    [
      'assets/images/spot_diff/pair10_original.jpg',
      'assets/images/spot_diff/pair10_modified.jpg'
    ],
  ];

  // Level names and descriptions
  final List<Map<String, String>> _levelInfo = [
    {'name': 'Level 1', 'description': 'Beginner: Find 5 differences'},
    {'name': 'Level 2', 'description': 'Beginner: Find 6 differences'},
    {'name': 'Level 3', 'description': 'Easy: Find 7 differences'},
    {'name': 'Level 4', 'description': 'Easy: Find 8 differences'},
    {'name': 'Level 5', 'description': 'Medium: Find 9 differences'},
    {'name': 'Level 6', 'description': 'Medium: Find 10 differences'},
    {'name': 'Level 7', 'description': 'Hard: Find 11 differences'},
    {'name': 'Level 8', 'description': 'Hard: Find 12 differences'},
    {'name': 'Level 9', 'description': 'Expert: Find 13 differences'},
    {'name': 'Level 10', 'description': 'Master: Find 15 differences'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _differences = _levelDifferences[_currentLevel];
    _totalDifferences = _differences.length;
    _animationController.forward();
  }

  void _startGame() {
    setState(() {
      _showLevelSelection = false;
      _gameOver = false;
      _gameWon = false;
      _foundDifferences = 0;
      _timeRemaining = 120;
      _differences = _levelDifferences[_currentLevel];
      _totalDifferences = _differences.length;

      // Reset all differences to not found
      for (var i = 0; i < _differences.length; i++) {
        _differences[i]['found'] = false;
      }
    });

    _startTimer();
    _animationController.reset();
    _animationController.forward();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _endGame(false);
      }
    });
  }

  void _handleTap(TapDownDetails details, Size imageSize, int imageIndex) {
    if (_gameOver || _gameWon) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);

    // Calculate relative position based on the image container size
    final double relativeX =
        (localPosition.dx - (imageIndex == 0 ? 0 : imageSize.width)) /
            imageSize.width;
    final double relativeY = localPosition.dy / imageSize.height;

    // Debug print for coordinate mapping
    print(
        'Tap Coordinates - X: ${relativeX.toStringAsFixed(3)}, Y: ${relativeY.toStringAsFixed(3)}');
    print('Suggested format for difference map:');
    print(
        "{'x': ${relativeX.toStringAsFixed(3)}, 'y': ${relativeY.toStringAsFixed(3)}, 'radius': 0.04, 'found': false},");

    // Only process taps on the modified image (index 1)
    if (imageIndex == 1) {
      _checkForDifference(relativeX, relativeY);
    }
  }

  void _checkForDifference(double tapX, double tapY) {
    bool foundNew = false;

    for (var i = 0; i < _differences.length; i++) {
      final difference = _differences[i];
      if (difference['found'] == false) {
        final dx = tapX - difference['x'];
        final dy = tapY - difference['y'];
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < difference['radius']) {
          setState(() {
            _differences[i]['found'] = true;
            _foundDifferences++;
            foundNew = true;
          });

          // Visual feedback for correct tap
          _showSuccessFeedback();

          break;
        }
      }
    }

    if (!foundNew) {
      // Visual feedback for incorrect tap
      _showErrorFeedback();
    }

    // Check win condition
    if (_foundDifferences >= _totalDifferences) {
      _endGame(true);
    }
  }

  void _showSuccessFeedback() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Good job! You found a difference!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorFeedback() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Try again! That\'s not a difference.'),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _endGame(bool won) {
    _timer?.cancel();
    setState(() {
      _gameOver = true;
      _gameWon = won;
    });

    // Show game result dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildResultDialog(won),
      );
    });
  }

  Widget _buildResultDialog(bool won) {
    bool isLastLevel = _currentLevel == _maxLevels - 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: won
                ? [const Color(0xFF0D3445), const Color(0xFF051824)]
                : [Colors.red.shade700, Colors.red.shade900],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              size: 80,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 16),
            Text(
              won ? 'CONGRATULATIONS!' : 'TIME\'S UP!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              won
                  ? 'You found all $_totalDifferences differences!'
                  : 'You found $_foundDifferences out of $_totalDifferences differences.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('RETRY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                        won ? const Color(0xFF0D3445) : Colors.red.shade800,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetGame();
                  },
                ),
                if (won && !isLastLevel)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('NEXT LEVEL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF42A5F5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _nextLevel();
                    },
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('LEVELS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showLevels();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _nextLevel() {
    if (_currentLevel < _maxLevels - 1) {
      setState(() {
        _currentLevel++;
      });
      _startGame();
    }
  }

  void _showLevels() {
    setState(() {
      _showLevelSelection = true;
    });
    _timer?.cancel();
  }

  void _resetGame() {
    setState(() {
      _foundDifferences = 0;
      _timeRemaining = 120;
      _gameOver = false;
      _gameWon = false;
      _showHint = false;

      // Reset all differences to not found
      for (var i = 0; i < _differences.length; i++) {
        _differences[i]['found'] = false;
      }
    });

    _startTimer();
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showLevelSelection) {
      return _buildLevelSelectionScreen();
    }

    return _buildGameScreen();
  }

  Widget _buildLevelSelectionScreen() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Select Level",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D3445), Color(0xFF051824)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Spot the Difference",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Challenge your observation skills! Find all the differences between two similar images.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _maxLevels,
                  itemBuilder: (context, index) {
                    return _buildLevelCard(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(int level) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentLevel = level;
        });
        _startGame();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2196F3).withOpacity(0.8),
              const Color(0xFF0D47A1).withOpacity(0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.search,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "${level + 1}",
                        style: TextStyle(
                          color: const Color(0xFF0D3445),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _levelInfo[level]['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _levelInfo[level]['description']!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    // Use media query to get screen size
    final size = MediaQuery.of(context).size;
    final imageSize =
        Size(size.width, size.height * 0.35); // Modified for landscape

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Level ${_currentLevel + 1}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _timer?.cancel();
              _showLevels();
            },
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(_showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: Colors.white),
              onPressed: _toggleHint,
              tooltip: 'Show hint',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D3445), Color(0xFF051824)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Game status bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_timeRemaining),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Found differences counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_foundDifferences/$_totalDifferences',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Game instruction
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  "Find all the differences in the bottom image!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Images container
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeIn,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Original Image
                            Expanded(
                              child: GestureDetector(
                                onTapDown: (details) =>
                                    _handleTap(details, imageSize, 0),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      _imagePairs[_currentLevel][0],
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Text("Image 1"),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 30,
                                      color: Colors.black.withOpacity(0.5),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "ORIGINAL",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Divider(height: 2, color: Colors.white24),

                            // Modified Image with differences
                            Expanded(
                              child: GestureDetector(
                                onTapDown: (details) =>
                                    _handleTap(details, imageSize, 1),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      _imagePairs[_currentLevel][1],
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Text("Image 2"),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 30,
                                      color: Colors.black.withOpacity(0.5),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "FIND DIFFERENCES",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    // Render found differences markers
                                    ..._differences.map((diff) {
                                      if (diff['found'] || _showHint) {
                                        return Positioned(
                                          left:
                                              diff['x'] * imageSize.width - 15,
                                          top:
                                              diff['y'] * imageSize.height - 15,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: diff['found']
                                                  ? Colors.green
                                                      .withOpacity(0.5)
                                                  : Colors.orange
                                                      .withOpacity(0.5),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: diff['found']
                                                    ? Colors.green
                                                    : Colors.orange,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              diff['found']
                                                  ? Icons.check
                                                  : Icons.search,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('RESTART'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _resetGame,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3445),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'GIVE UP',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _endGame(false),
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
}
