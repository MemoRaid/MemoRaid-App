import 'package:flutter/material.dart';
import '../models/memory.dart';
import './questions/memory_questions_screen.dart';

class MemoryDetailScreen extends StatelessWidget {
  final Memory memory;

  const MemoryDetailScreen({
    Key? key,
    required this.memory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Details'),
        backgroundColor: const Color(0xFF0D3445),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Memory Image
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(memory.photoUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Memory Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.briefDescription,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3445),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    memory.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Practice Button - Positioned after memory details
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemoryQuestionsScreen(
                              memoryId: memory.id,
                              photoUrl: memory.photoUrl,
                              briefDescription: memory.briefDescription,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3445),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Practice Memory',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}