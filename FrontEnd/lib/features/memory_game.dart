import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({Key? key}) : super(key: key);

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  // Game configuration
  final int _pairCount = 8; // Total pairs of cards
  late List<int> _cards;
  List<bool> _cardFlips = [];
  List<bool> _cardMatched = [];
  int? _firstCardIndex;
  bool _waiting = false;
  int _score = 0;
  int _moves = 0;
  int _matchedPairs = 0;
  Timer? _timer;
  int _secondsElapsed = 0;
  late ConfettiController _confettiController;
  bool _gameCompleted = false;

  // Difficulty levels
  final Map<String, int> _difficultyTimers = {
    'Easy': 120,
    'Medium': 90,
    'Hard': 60,
  };
  String _currentDifficulty = 'Medium';
  late int _maxSeconds;

  @override
  void initState() {
    super.initState();
    _maxSeconds = _difficultyTimers[_currentDifficulty]!;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    // Create pairs of cards
    _cards = List.generate(_pairCount, (index) => index + 1)
      ..addAll(List.generate(_pairCount, (index) => index + 1));

    // Shuffle the cards
    _cards.shuffle(Random());

    // Reset game state
    _cardFlips = List.generate(_cards.length, (index) => false);
    _cardMatched = List.generate(_cards.length, (index) => false);
    _firstCardIndex = null;
    _waiting = false;
    _score = 0;
    _moves = 0;
    _matchedPairs = 0;
    _gameCompleted = false;
    _secondsElapsed = 0;

    // Start the game timer
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsElapsed < _maxSeconds) {
          _secondsElapsed++;
        } else {
          _endGame(false);
          timer.cancel();
        }
      });
    });
  }

  void _flipCard(int index) {
    // Ignore if waiting for cards to be hidden again
    if (_waiting) return;

    // Ignore if this card is already flipped or matched
    if (_cardFlips[index] || _cardMatched[index]) return;

    setState(() {
      _cardFlips[index] = true;

      // First card flipped
      if (_firstCardIndex == null) {
        _firstCardIndex = index;
      }
      // Second card flipped
      else {
        _moves++;

        // Check if the cards match
        if (_cards[_firstCardIndex!] == _cards[index]) {
          // Match found
          _cardMatched[_firstCardIndex!] = true;
          _cardMatched[index] = true;
          _score += 10;
          _matchedPairs++;

          // Check if the game is complete
          if (_matchedPairs == _pairCount) {
            _endGame(true);
          }

          _firstCardIndex = null;
        } else {
          // No match, flip cards back after delay
          _waiting = true;
          Future.delayed(const Duration(milliseconds: 1000), () {
            setState(() {
              _cardFlips[_firstCardIndex!] = false;
              _cardFlips[index] = false;
              _firstCardIndex = null;
              _waiting = false;
            });
          });
        }
      }
    });
  }

  void _endGame(bool victory) {
    _timer?.cancel();
    setState(() {
      _gameCompleted = true;
    });

    if (victory) {
      _confettiController.play();
      // Calculate bonus points based on remaining time and moves
      int timeBonus = ((_maxSeconds - _secondsElapsed) / 10).ceil() * 5;
      int moveEfficiency = (_pairCount * 2 - _moves).clamp(0, 100);
      setState(() {
        _score += timeBonus + moveEfficiency;
      });
    }

    // Show completion dialog
    Future.delayed(Duration(milliseconds: victory ? 500 : 0), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(victory ? 'Congratulations! 🎉' : 'Time\'s Up! ⌛'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(victory
                  ? 'You\'ve completed the memory exercise!\nThis activity helps rebuild visual memory and pattern recognition.'
                  : 'You ran out of time. Memory recovery takes practice. Each attempt strengthens neural pathways!'),
              SizedBox(height: 16),
              Text('Score: $_score',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Pairs Matched: $_matchedPairs of $_pairCount'),
              Text('Moves: $_moves'),
              Text('Time: ${_formatTime(_secondsElapsed)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _initializeGame();
                });
              },
              child: Text('Play Again'),
            ),
          ],
        ),
      );
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildCard(int index) {
    return GestureDetector(
      onTap: _gameCompleted ? null : () => _flipCard(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(_cardFlips[index] ? pi : 0.0),
        transformAlignment: Alignment.center,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _cardMatched[index]
                  ? Colors.lightGreen.withOpacity(0.3)
                  : _cardFlips[index]
                      ? Colors.white
                      : Color(0xFF0D3445),
            ),
            child: _cardFlips[index]
                ? Center(
                    child: Text(
                      '${_cards[index]}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D3445),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.memory,
                      color: Colors.white54,
                      size: 30,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          "Memory Matching Exercise",
          style: TextStyle(
            color: Color(0xFF0D3445),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Color(0xFF0D3445)),
            onSelected: (String difficulty) {
              setState(() {
                _currentDifficulty = difficulty;
                _maxSeconds = _difficultyTimers[difficulty]!;
                _initializeGame();
              });
            },
            itemBuilder: (BuildContext context) {
              return _difficultyTimers.keys.map((String difficulty) {
                return PopupMenuItem<String>(
                  value: difficulty,
                  child: Text(
                      '$difficulty ${_currentDifficulty == difficulty ? "✓" : ""}'),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE1F5FE)],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Game info section
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoCard(
                        'Score',
                        '$_score',
                        Icons.star,
                        Colors.amber,
                      ),
                      _infoCard(
                        'Moves',
                        '$_moves',
                        Icons.touch_app,
                        Colors.blue,
                      ),
                      _infoCard(
                        'Time',
                        '${_formatTime(_secondsElapsed)}',
                        Icons.timer,
                        _secondsElapsed > _maxSeconds * 0.8
                            ? Colors.red
                            : Colors.green,
                      ),
                    ],
                  ),
                ),

                // Educational hint
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rehabilitation Tip:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D3445),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "This exercise stimulates visual memory and pattern recognition, which can help rebuild memory pathways affected by amnesia.",
                            style: TextStyle(
                              color: Color(0xFF0D3445).withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Cards grid
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        return _buildCard(index);
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Confetti effect for victory
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3445),
            ),
          ),
        ],
      ),
    );
  }
}
