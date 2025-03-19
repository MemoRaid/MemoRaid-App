// lib/features/tests/memory_test_screen.dart
import 'package:flutter/material.dart';
import '../memories/memory_list_screen.dart';

class MemoryTestScreen extends StatelessWidget {
  const MemoryTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Feature Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MemoryListScreen(),
              ),
            );
          },
          child: const Text('Show Patient Memories'),
        ),
      ),
    );
  }
}