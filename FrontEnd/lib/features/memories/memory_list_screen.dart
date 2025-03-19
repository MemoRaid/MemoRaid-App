// lib/features/memories/memory_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/memory.dart';
import '../../services/memory_service.dart';
import '../questions/memory_questions_screen.dart';
class MemoryListScreen extends StatefulWidget {
  const MemoryListScreen({Key? key}) : super(key: key);

  @override
  State<MemoryListScreen> createState() => _MemoryListScreenState();
}

class _MemoryListScreenState extends State<MemoryListScreen> {
  late Future<List<Memory>> _memoriesFuture;

  @override
  void initState() {
    super.initState();
    _memoriesFuture = MemoryService().getPatientMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Memories'),
      ),
      body: FutureBuilder<List<Memory>>(
        future: _memoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          final memories = snapshot.data!;
          
          if (memories.isEmpty) {
            return const Center(
              child: Text('No memories found'),
            );
          }
          
          return ListView.builder(
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return MemoryCard(memory: memory);
            },
          );
        },
      ),
    );
  }
}

class MemoryCard extends StatelessWidget {
  final Memory memory;
  
  const MemoryCard({Key? key, required this.memory}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              memory.photoUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                memory.briefDescription,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}