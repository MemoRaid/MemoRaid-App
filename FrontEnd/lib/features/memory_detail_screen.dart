import 'package:flutter/material.dart';
import '../models/memory.dart';
import '../services/auth_service.dart';
import './questions/memory_questions_screen.dart';

class MemoryDetailScreen extends StatelessWidget {
  final Memory memory;  // Add this
  final AuthService authService;  // Add this

  const MemoryDetailScreen({
    Key? key,
    required this.memory,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current user from auth service
    final currentUser = authService.currentUser;

    // Check if user is authenticated
    if (currentUser == null) {
      return const Center(child: Text('Please log in'));
    }

    return Scaffold(
      // ...existing scaffold code...
      body: Column(
        children: [
          // ...existing memory display widgets...
          
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoryQuestionsScreen(
                    memoryId: memory.id,
                    photoUrl: memory.photoUrl,
                    briefDescription: memory.briefDescription,
                    patientId: currentUser.id,
                    authToken: currentUser.token,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3445),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Practice Memory',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Inside your button onPressed or navigation method
void navigateToMemoryDetail(BuildContext context, Memory memory) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MemoryDetailScreen(
        memory: memory,
        authService: AuthService(),
      ),
    ),
  );
}