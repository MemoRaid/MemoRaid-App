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
      'description': 'Find differences between these two images',
      'hotspots': [
        // These values should be updated to match the actual differences in your images
        {'x': 150, 'y': 170, 'radius': 30, 'hint': 'Look at the top left area'},
        {'x': 320, 'y': 220, 'radius': 30, 'hint': 'Check the middle section'},
        {
          'x': 200,
          'y': 300,
          'radius': 30,
          'hint': 'Notice anything different in the bottom half?'
        },
        {
          'x': 380,
          'y': 180,
          'radius': 30,
          'hint': 'Look for color or object changes'
        },
        {
          'x': 100,
          'y': 250,
          'radius': 30,
          'hint': 'Something is missing or added here'
        },
      ],
    },
    // More levels would be added here
  ];

  // Add these new variables
  bool showingHintAnimation = false;
  Map<String, dynamic>? hintHotspot;
  Timer? _hintTimer;
  bool firstTimePlaying = true;
  bool showOverlay = false;
  double overlayOpacity = 0.5;

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

              // Instructions card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amberAccent.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amberAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        levels[currentLevel - 1]['description'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        showOverlay ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          showOverlay = !showOverlay;
                        });
                      },
                      tooltip: showOverlay ? 'Hide Overlay' : 'Show Overlay',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

                                // Show debug overlay if enabled
                                if (showOverlay)
                                  ...levels[currentLevel - 1]['hotspots']
                                      .map<Widget>((hotspot) {
                                    final index = levels[currentLevel - 1]
                                            ['hotspots']
                                        .indexOf(hotspot);
                                    final found = differencesFound[index];

                                    return Positioned(
                                      left: hotspot['x'] - 30,
                                      top: hotspot['y'] - 30,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: found
                                                ? Colors.greenAccent
                                                    .withOpacity(overlayOpacity)
                                                : Colors.redAccent.withOpacity(
                                                    overlayOpacity),
                                            width: 2,
                                          ),
                                          color: found
                                              ? Colors.greenAccent.withOpacity(
                                                  overlayOpacity * 0.3)
                                              : Colors.redAccent.withOpacity(
                                                  overlayOpacity * 0.2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                  overlayOpacity + 0.2),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
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

                                // Show debug overlay if enabled (for second image too)
                                if (showOverlay)
                                  ...levels[currentLevel - 1]['hotspots']
                                      .map<Widget>((hotspot) {
                                    final index = levels[currentLevel - 1]
                                            ['hotspots']
                                        .indexOf(hotspot);
                                    final found = differencesFound[index];

                                    return Positioned(
                                      left: hotspot['x'] - 30,
                                      top: hotspot['y'] - 30,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: found
                                                ? Colors.greenAccent
                                                    .withOpacity(overlayOpacity)
                                                : Colors.redAccent.withOpacity(
                                                    overlayOpacity),
                                            width: 2,
                                          ),
                                          color: found
                                              ? Colors.greenAccent.withOpacity(
                                                  overlayOpacity * 0.3)
                                              : Colors.redAccent.withOpacity(
                                                  overlayOpacity * 0.2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                  overlayOpacity + 0.2),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
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
                      icon: Icons.refresh,
                      label: 'Restart',
                      onPressed: _restartLevel,
                      color: Colors.blueAccent,
                    ),
                    _buildActionButton(
                      icon: Icons.exit_to_app,
                      label: 'Exit',
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
              Text(
                hotspot['hint'] ??
                    'Look carefully at both images - there\'s a difference in one area!',
                style: const TextStyle(color: Colors.white70),
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

  void _restartLevel() {
    setState(() {
      foundDifferences = 0;
      differencesFound = List.generate(totalDifferences, (_) => false);
      markers.clear();
      score = score > 10 ? score - 10 : 0; // Small penalty for restarting
      _startTimer();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Level restarted'),
        backgroundColor: baseColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTutorial() {
    // Use PageView for a swipeable tutorial
    PageController pageController = PageController();
    int currentPage = 0;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Tutorial',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Animated background gradient
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          baseColor.withOpacity(0.95),
                          baseColor
                              .withBlue(baseColor.blue + 30)
                              .withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),

                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(seconds: 1),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                        colors: [
                                          Colors.lightBlueAccent,
                                          Colors.purpleAccent
                                        ],
                                      ).createShader(bounds),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1200),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(20 * (1 - value), 0),
                                      child: const Text(
                                        'How To Play',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Tutorial PageView
                        Expanded(
                          child: PageView(
                            controller: pageController,
                            onPageChanged: (page) {
                              setState(() {
                                currentPage = page;
                              });
                            },
                            children: [
                              _buildTutorialPage(
                                icon: Icons.visibility,
                                title: 'Find The Differences',
                                description:
                                    'Your mission is to find $totalDifferences hidden differences between the two images.',
                                animation: 'lib/assets/animations/find.json',
                              ),
                              _buildTutorialPage(
                                icon: Icons.touch_app,
                                title: 'Tap To Select',
                                description:
                                    'When you spot a difference, tap directly on it to mark it.',
                                animation: 'lib/assets/animations/tap.json',
                              ),
                              _buildTutorialPage(
                                icon: Icons.timer,
                                title: 'Beat The Clock',
                                description:
                                    'Be quick! You have ${_formatTime(_timeRemaining)} to find all differences and you earn more points for speed.',
                                animation: 'lib/assets/animations/timer.json',
                              ),
                              _buildTutorialPage(
                                icon: Icons.lightbulb_outline,
                                title: 'Use Hints Wisely',
                                description:
                                    'Stuck? Use hints, but remember each hint will cost you 5 points.',
                                animation: 'lib/assets/animations/hint.json',
                                isLast: true,
                              ),
                            ],
                          ),
                        ),

                        // Page indicator dots
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                height: 10,
                                width: currentPage == index ? 24 : 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: currentPage == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                  boxShadow: currentPage == index
                                      ? [
                                          BoxShadow(
                                            color: accentColor.withOpacity(0.5),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : [],
                                ),
                              );
                            }),
                          ),
                        ),

                        // Navigation buttons
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24.0, right: 24.0, bottom: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              if (currentPage > 0)
                                _buildTutorialButton(
                                  icon: Icons.arrow_back,
                                  label: 'Back',
                                  onPressed: () {
                                    pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  isOutlined: true,
                                )
                              else
                                const SizedBox(width: 100),

                              // Next or Start button
                              _buildTutorialButton(
                                icon: currentPage < 3
                                    ? Icons.arrow_forward
                                    : Icons.play_arrow,
                                label:
                                    currentPage < 3 ? 'Next' : 'Start Playing',
                                onPressed: () {
                                  if (currentPage < 3) {
                                    pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                    firstTimePlaying = false;
                                    _showConfettiEffect();
                                  }
                                },
                                hasPulseAnimation: currentPage == 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildTutorialPage({
    required IconData icon,
    required String title,
    required String description,
    required String animation,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon with gradient
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              // In a real app, you would use Lottie animation here
              // Lottie.asset(animation, width: 100, height: 100)
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.lightBlueAccent, Colors.purpleAccent],
                ).createShader(bounds),
                child: Icon(
                  icon,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Title with animated effect
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 700),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Description text
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Extra emphasis for last page
          if (isLast)
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purpleAccent.withOpacity(0.2),
                      Colors.blueAccent.withOpacity(0.2)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.amberAccent),
                    SizedBox(width: 8),
                    Text(
                      'You\'re Ready! Let\'s Play!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTutorialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isOutlined = false,
    bool hasPulseAnimation = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: hasPulseAnimation
          ? AnimatedBuilder(
              animation: _pulseAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value * 0.95 + 0.05,
                  child: _buildButtonContent(icon, label, isOutlined),
                );
              },
            )
          : _buildButtonContent(icon, label, isOutlined),
    );
  }

  Widget _buildButtonContent(IconData icon, String label, bool isOutlined) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: isOutlined
            ? null
            : LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(30),
        border: isOutlined
            ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
            : null,
        boxShadow: isOutlined
            ? null
            : [
                BoxShadow(
                  color: accentColor.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: isOutlined ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfettiEffect() {
    // Add confetti effect when the game starts
    // In a real implementation, you would use a confetti package
    // This is just a placeholder for the concept
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, color: Colors.amberAccent),
            SizedBox(width: 10),
            Text(
              'Let\'s Spot the Differences!',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        backgroundColor: accentColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
    );

    // In a complete implementation, you would add real confetti effect here
    // using a package like confetti or particle_field
  }
}
