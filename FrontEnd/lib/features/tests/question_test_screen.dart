// Create in lib/features/tests/question_test_screen.dart
import 'package:flutter/material.dart';
import '../questions/memory_questions_screen.dart';

class QuestionTestScreen extends StatelessWidget {
  const QuestionTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Feature Test'),
        backgroundColor: const Color(0xFF0D3445),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryQuestionsScreen(
                      memoryId: "test-memory-id", // Make sure this is provided
                      photoUrl: "https://picsum.photos/400/300",
                      briefDescription: "Test memory for question feature",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3445),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Test Memory Questions'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/test-questions');
              },
              child: const Text('Test Questions Feature'),
            ),
          ],
        ),
      ),
    );
  }
}