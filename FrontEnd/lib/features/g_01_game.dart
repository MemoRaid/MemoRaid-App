import 'package:flutter/material.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<String> steps = [
    'Chop vegetables',
    'Heat oil in a pan',
    'Cook the vegetables',
    'Serve the meal',
    'Gather ingredients'
  ];

  List<String> shuffledSteps = [];
  List<String> userOrder = [];

  @override
  void initState() {
    super.initState();
    shuffledSteps = List.from(steps)..shuffle(Random());
  }

  void checkOrder() {
    if (userOrder.length < steps.length) {
      return; // Not enough steps arranged
    }

    if (userOrder.toString() == steps.toString()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Correct!'),
          content: Text('You arranged the steps correctly!'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
            ),
          ],
        ),
      );
    } else {
      // Give feedback
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Try Again!'),
          content: Text('The arrangement is incorrect.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void resetGame() {
    userOrder.clear();
    shuffledSteps = List.from(steps)..shuffle(Random());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game'),
      ),
      body: Column(
        children: [
          Text('Arrange the following steps in order:'),
          Expanded(
            child: ListView.builder(
              itemCount: shuffledSteps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(shuffledSteps[index]),
                  onTap: () {
                    if (!userOrder.contains(shuffledSteps[index])) {
                      userOrder.add(shuffledSteps[index]);
                      checkOrder();
                    }
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: checkOrder,
            child: Text('Check Order'),
          ),
        ],
      ),
    );
  }
}
