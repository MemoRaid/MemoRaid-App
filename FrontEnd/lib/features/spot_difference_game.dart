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

  // List of differences with their coordinates (x, y, radius)
  final List<Map<String, dynamic>> _differences = [
    {'x': 0.3, 'y': 0.4, 'radius': 0.05, 'found': false},
    {'x': 0.7, 'y': 0.2, 'radius': 0.04, 'found': false},
    {'x': 0.5, 'y': 0.6, 'radius': 0.05, 'found': false},
    {'x': 0.8, 'y': 0.7, 'radius': 0.04, 'found': false},
    {'x': 0.2, 'y': 0.8, 'radius': 0.05, 'found': false},
  ];

  // Image pairs - you would replace these with your actual images
  final List<List<String>> _imagePairs = [
    [
      'assets/images/spot_diff/pair1_original.jpg',
      'assets/images/spot_diff/pair1_modified.jpg',
    ],
    [
      'assets/images/spot_diff/pair2_original.jpg',
      'assets/images/spot_diff/pair2_modified.jpg',
    ],
    [
      'assets/images/spot_diff/pair3_original.jpg',
      'assets/images/spot_diff/pair3_modified.jpg',
    ],
  ];

  int _currentLevel = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _startTimer();
    _animationController.forward();
  }

  void _startTimer() {
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: won
                ? [Colors.green.shade700, Colors.green.shade900]
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
                  label: const Text('PLAY AGAIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                        won ? Colors.green.shade800 : Colors.red.shade800,
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
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('MAIN MENU'),
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
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    // Use media query to get screen size
    final size = MediaQuery.of(context).size;
    final imageSize = Size(size.width / 2, size.height * 0.6);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Spot the Difference",
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
            colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Game status bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  "Find all the differences in the right image!",
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
                      child: child,
                    );
                  },
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
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
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    // Use a placeholder until you have actual assets
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
                          Container(
                            width: 2,
                            color: Colors.white,
                          ),
                          // Modified Image with differences
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (details) =>
                                  _handleTap(details, imageSize, 1),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    _imagePairs[_currentLevel][1],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    // Use a placeholder until you have actual assets
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
                                        left: diff['x'] * imageSize.width - 15,
                                        top: diff['y'] * imageSize.height - 15,
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: diff['found']
                                                ? Colors.green.withOpacity(0.5)
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
                  ),
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
                        backgroundColor: Colors.purpleAccent,
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
