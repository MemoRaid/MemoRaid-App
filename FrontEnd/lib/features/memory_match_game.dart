import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({Key? key}) : super(key: key);

  @override
  _MemoryMatchGameState createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame>
    with SingleTickerProviderStateMixin {
  // Game configuration
  final int _gridSize = 4;
  final List<IconData> _allIcons = [
    Icons.home,
    Icons.star,
    Icons.favorite,
    Icons.music_note,
    Icons.pets,
    Icons.flight,
    Icons.cake,
    Icons.camera,
    Icons.car_rental,
    Icons.beach_access,
    Icons.emoji_food_beverage,
    Icons.sports_basketball,
    Icons.lightbulb,
    Icons.smartphone,
    Icons.umbrella,
    Icons.local_florist,
  ];

  // Game state
  late List<CardData> _cards;
  late int _score;
  late int _moves;
  late bool _isGameOver;
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _timeElapsed = "00:00";

  // Card selection tracking
  CardData? _firstCard;
  CardData? _secondCard;
  bool _isChecking = false;

  // Animation controller
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeGame();
  }

  void _initializeGame() {
    // Create pairs of cards
    final cardIcons = _allIcons.take((_gridSize * _gridSize) ~/ 2).toList();
    final iconsList = [...cardIcons, ...cardIcons];

    // Shuffle the icons
    iconsList.shuffle(Random());

    // Create card data objects
    _cards = List.generate(
      _gridSize * _gridSize,
      (index) => CardData(
        id: index,
        icon: iconsList[index],
        isFlipped: false,
        isMatched: false,
      ),
    );

    // Initialize game stats
    _score = 0;
    _moves = 0;
    _isGameOver = false;
    _firstCard = null;
    _secondCard = null;
    _isChecking = false;

    // Setup timer
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final minutes = (_stopwatch.elapsedMilliseconds ~/ 60000)
            .toString()
            .padLeft(2, '0');
        final seconds = ((_stopwatch.elapsedMilliseconds % 60000) ~/ 1000)
            .toString()
            .padLeft(2, '0');
        _timeElapsed = "$minutes:$seconds";
      });
    });
  }

  void _checkForMatch() {
    if (_firstCard == null || _secondCard == null) return;

    _isChecking = true;
    _moves++;

    // Check if the cards match
    if (_firstCard!.icon == _secondCard!.icon) {
      setState(() {
        _cards[_firstCard!.id] =
            _cards[_firstCard!.id].copyWith(isMatched: true);
        _cards[_secondCard!.id] =
            _cards[_secondCard!.id].copyWith(isMatched: true);
        _score += 10;
      });

      // Check if game is over
      if (_cards.every((card) => card.isMatched)) {
        _gameOver();
      }
    } else {
      // Cards don't match - flip them back after a delay
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _cards[_firstCard!.id] =
              _cards[_firstCard!.id].copyWith(isFlipped: false);
          _cards[_secondCard!.id] =
              _cards[_secondCard!.id].copyWith(isFlipped: false);
        });
      });
    }

    // Reset selection
    Future.delayed(const Duration(milliseconds: 800), () {
      _firstCard = null;
      _secondCard = null;
      _isChecking = false;
    });
  }

  void _gameOver() {
    _stopwatch.stop();
    _timer.cancel();
    _isGameOver = true;

    // Show congratulations dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D3445).withOpacity(0.8), Color(0xFF0D3445)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 Congratulations! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'You completed the game in $_timeElapsed',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Score: $_score | Moves: $_moves',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _initializeGame();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Play Again',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Exit Game',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _handleCardTap(CardData card) {
    if (_isChecking || card.isFlipped || card.isMatched) return;

    setState(() {
      // Update flipped state
      _cards[card.id] = _cards[card.id].copyWith(isFlipped: true);

      // Track selected cards
      if (_firstCard == null) {
        _firstCard = _cards[card.id];
      } else if (_secondCard == null) {
        _secondCard = _cards[card.id];
        _checkForMatch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFF0D3445)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildGameBoard()),
              _buildGameControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Memory Match',
                style: TextStyle(
                  color: Color(0xFF0D3445),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Find matching pairs',
                style: TextStyle(
                  color: Color(0xFF0D3445).withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildStatBadge(Icons.timer, _timeElapsed),
              const SizedBox(width: 12),
              _buildStatBadge(Icons.score, '$_score'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF0D3445),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridSize,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return _buildCard(_cards[index]);
        },
      ),
    );
  }

  Widget _buildCard(CardData card) {
    return GestureDetector(
      onTap: () => _handleCardTap(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(card.isFlipped ? pi : 0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: card.isMatched
              ? Colors.green.withOpacity(0.3)
              : card.isFlipped
                  ? Colors.white
                  : Color(0xFF0D3445),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: card.isMatched
                ? Colors.green
                : card.isFlipped
                    ? Color(0xFF0D3445)
                    : Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: Icon(
                    card.icon,
                    size: 40,
                    color: card.isMatched ? Colors.green : Color(0xFF0D3445),
                  ),
                )
              : const Icon(
                  Icons.question_mark,
                  size: 40,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  Widget _buildGameControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _initializeGame();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Restart'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Exit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }
}

class CardData {
  final int id;
  final IconData icon;
  final bool isFlipped;
  final bool isMatched;

  const CardData({
    required this.id,
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });

  CardData copyWith({
    int? id,
    IconData? icon,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return CardData(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
