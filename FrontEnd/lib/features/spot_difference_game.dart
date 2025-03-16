import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SpotDifferenceGame extends StatefulWidget {
  const SpotDifferenceGame({Key? key}) : super(key: key);

  @override
  _SpotDifferenceGameState createState() => _SpotDifferenceGameState();
}

class _SpotDifferenceGameState extends State<SpotDifferenceGame>
    with TickerProviderStateMixin {
  // Game state variables
  int score = 0;
  int currentLevel = 1;
  int foundDifferences = 0;
  int totalDifferences = 5;
  List<bool> differencesFound = List.generate(5, (_) => false);
  Timer? _timer;
  int _timeRemaining = 120; // 2 minutes per level

  // Animation controllers
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  // Marker positions for found differences
  List<Map<String, dynamic>> markers = [];

  final Color baseColor = const Color(0xFF0D3445);
  final Color accentColor = const Color(0xFF2196F3);

  // Sample image pairs
  final List<Map<String, dynamic>> levels = [
    {
      'originalImage': 'lib/assets/images/spot1.jpeg',
      'modifiedImage': 'lib/assets/images/spot2.jpeg',
      'hotspots': [
        {'x': 100, 'y': 150, 'radius': 20},
        {'x': 250, 'y': 200, 'radius': 20},
        {'x': 300, 'y': 300, 'radius': 20},
        {'x': 150, 'y': 350, 'radius': 20},
        {'x': 400, 'y': 250, 'radius': 20},
      ],
    },
    // More levels would be added here
  ];

  // Add these new variables
  bool showingHintAnimation = false;
  Map<String, dynamic>? hintHotspot;
  Timer? _hintTimer;
  bool firstTimePlaying = true;

  @override
  void initState() {
    super.initState();

    // Initialize timer
    _startTimer();

    // Initialize animations
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
            parent: _pulseAnimationController, curve: Curves.easeInOut));

    // Show tutorial on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (firstTimePlaying) {
        _showTutorial();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseAnimationController.dispose();
    _hintTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeRemaining = 120; // Reset timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer?.cancel();
          _showTimeUpDialog();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentLevelData = levels[currentLevel - 1];

    return Scaffold(
      backgroundColor: baseColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: baseColor.withOpacity(0.8),
        elevation: 0,
        title: Text(
          'Spot the Difference',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events,
                    color: Colors.amberAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              baseColor,
              baseColor
                  .withBlue(baseColor.blue + 15)
                  .withGreen(baseColor.green + 10),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Game info bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Level progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $currentLevel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 150,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: foundDifferences / totalDifferences,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.lightBlueAccent,
                                    Colors.blueAccent
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$foundDifferences/$totalDifferences differences found',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    // Timer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _timeRemaining < 30
                            ? Colors.redAccent.withOpacity(0.3)
                            : Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedBuilder(
                        animation: _pulseAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _timeRemaining < 30
                                ? _pulseAnimation.value
                                : 1.0,
                            child: Text(
                              _formatTime(_timeRemaining),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _timeRemaining < 30
                                    ? Colors.redAccent
                                    : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Game images - Modified to stack vertically for landscape images
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
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
                      child: Column(
                        // Changed from Row to Column
                        children: [
                          // Original image
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                GestureDetector(
                                  onTapDown: (details) =>
                                      _checkDifference(details, true),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 1),
                                    ),
                                    child: Image.asset(
                                      currentLevelData['originalImage'],
                                      fit: BoxFit.contain, // Changed to contain
                                      errorBuilder: (ctx, obj, trace) =>
                                          Container(
                                        color: baseColor.withOpacity(0.5),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                color: Colors.white70,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Original Image',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Draw markers for this image
                                ...markers.map((marker) {
                                  return Positioned(
                                    left: marker['x'] - 15,
                                    top: marker['y'] - 15,
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor:
                                          Colors.greenAccent.withOpacity(0.7),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                }).toList(),

                                // Add hint animation circle
                                if (showingHintAnimation && hintHotspot != null)
                                  Positioned(
                                    left: hintHotspot!['x'] - 25,
                                    top: hintHotspot!['y'] - 25,
                                    child: AnimatedBuilder(
                                      animation: _pulseAnimationController,
                                      builder: (context, child) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.yellowAccent
                                                  .withOpacity(
                                                0.6 +
                                                    (_pulseAnimation.value -
                                                            1.0) *
                                                        0.4,
                                              ),
                                              width: 3,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Divider - horizontal now
                          Container(
                            height: 4,
                            color: accentColor.withOpacity(0.6),
                          ),

                          // Modified image
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                GestureDetector(
                                  onTapDown: (details) =>
                                      _checkDifference(details, false),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 1),
                                    ),
                                    child: Image.asset(
                                      currentLevelData['modifiedImage'],
                                      fit: BoxFit.contain, // Changed to contain
                                      errorBuilder: (ctx, obj, trace) =>
                                          Container(
                                        color: baseColor.withOpacity(0.5),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                color: Colors.white70,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Modified Image',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Draw markers for this image
                                ...markers.map((marker) {
                                  return Positioned(
                                    left: marker['x'] - 15,
                                    top: marker['y'] - 15,
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor:
                                          Colors.greenAccent.withOpacity(0.7),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                }).toList(),

                                // Add hint animation circle for this image too
                                if (showingHintAnimation && hintHotspot != null)
                                  Positioned(
                                    left: hintHotspot!['x'] - 25,
                                    top: hintHotspot!['y'] - 25,
                                    child: AnimatedBuilder(
                                      animation: _pulseAnimationController,
                                      builder: (context, child) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.yellowAccent
                                                  .withOpacity(
                                                0.6 +
                                                    (_pulseAnimation.value -
                                                            1.0) *
                                                        0.4,
                                              ),
                                              width: 3,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Game controls
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.lightbulb_outline,
                      label: 'Hint',
                      onPressed: _showHint,
                      color: Colors.amber,
                    ),
                    _buildActionButton(
                      icon: Icons.exit_to_app,
                      label: 'Exit Game',
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.redAccent,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.5), width: 1),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _checkDifference(TapDownDetails details, bool isOriginal) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    final hotspots = levels[currentLevel - 1]['hotspots'];

    for (int i = 0; i < hotspots.length; i++) {
      if (differencesFound[i]) continue;

      final hotspot = hotspots[i];
      final dx = localPosition.dx - hotspot['x'];
      final dy = localPosition.dy - hotspot['y'];
      final distance = sqrt(dx * dx + dy * dy);

      if (distance <= hotspot['radius']) {
        setState(() {
          differencesFound[i] = true;
          foundDifferences++;
          score += 10 + (_timeRemaining ~/ 10); // Bonus points for speed

          // Add marker for the found difference
          markers.add({
            'x': hotspot['x'],
            'y': hotspot['y'],
          });

          // Show animation and check level completion
          if (foundDifferences >= totalDifferences) {
            _timer?.cancel();
            _showLevelCompleteDialog();
          } else {
            _showFoundDifferenceAnimation();
          }
        });
        break;
      }
    }
  }

  void _showFoundDifferenceAnimation() {
    // Show a more visually appealing animation
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent),
            const SizedBox(width: 10),
            const Text(
              'Difference found!',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '+${10 + (_timeRemaining ~/ 10)} pts',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: baseColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: baseColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Time\'s Up!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_off, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              'You found $foundDifferences of $totalDifferences differences.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Your score: $score points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('Exit Game'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                foundDifferences = 0;
                differencesFound =
                    List.generate(totalDifferences, (_) => false);
                markers.clear();
                _startTimer();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showLevelCompleteDialog() {
    // Calculate completion bonus
    int timeBonus = _timeRemaining * 2;
    int totalScore = score + timeBonus;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: baseColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 28),
            const SizedBox(width: 10),
            const Text('Level Complete!',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              'You found all $totalDifferences differences!',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Base Score:',
                    style: TextStyle(color: Colors.white70)),
                Text(
                  '$score pts',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time Bonus:',
                    style: TextStyle(color: Colors.white70)),
                Text(
                  '$timeBonus pts',
                  style: const TextStyle(
                      color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(color: Colors.white30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Score:',
                    style: TextStyle(color: Colors.white)),
                Text(
                  '$totalScore pts',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to home
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
            ),
            child: const Text('Exit Game'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _goToNextLevel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  void _goToNextLevel() {
    if (currentLevel < levels.length) {
      setState(() {
        currentLevel++;
        foundDifferences = 0;
        differencesFound = List.generate(totalDifferences, (_) => false);
        markers.clear();
        _startTimer();
      });
    } else {
      // Game complete
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: baseColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amberAccent, size: 28),
              SizedBox(width: 10),
              Text('Congratulations!', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                'You completed all levels!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: accentColor.withOpacity(0.2),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: accentColor.withOpacity(0.5),
                      child: Text(
                        score.toString(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'You\'ve earned a spot on the leaderboard!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              child: const Text('Exit Game'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to home
                // In a real app, you'd navigate to the leaderboard here
                // Navigator.of(context).pushNamed('/achievements');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              child: const Text('View Leaderboard'),
            ),
          ],
        ),
      );
    }
  }

  void _showHint() {
    // Find the first unfound difference
    int hintIndex = differencesFound.indexWhere((found) => !found);
    if (hintIndex >= 0) {
      final hotspot = levels[currentLevel - 1]['hotspots'][hintIndex];

      // Reduce score when using hint
      setState(() {
        score -= 5;
        if (score < 0) score = 0;

        // Save hotspot for animation
        hintHotspot = hotspot;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: baseColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amberAccent, size: 24),
              SizedBox(width: 10),
              Text('Hint', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Look carefully at both images - there\'s a difference in one area!',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.touch_app,
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '-5 points for using hint',
                  style: TextStyle(
                    color: Colors.redAccent.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Show hint animation for 3 seconds
                setState(() {
                  showingHintAnimation = true;
                });

                _hintTimer?.cancel();
                _hintTimer = Timer(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      showingHintAnimation = false;
                      hintHotspot = null;
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show Hint'),
            ),
          ],
        ),
      );
    }
  }

  void _showTutorial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: baseColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.lightBlueAccent, size: 28),
            const SizedBox(width: 10),
            const Text('How to Play', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Find $totalDifferences differences between the two images',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '2. Tap on any spot where you notice a difference',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '3. Be quick! You earn more points for finding differences faster',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '4. Use hints if you\'re stuck, but you\'ll lose 5 points',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timelapse, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      'You have ${_formatTime(_timeRemaining)} to finish each level',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              firstTimePlaying = false;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Playing'),
          ),
        ],
      ),
    );
  }
}
