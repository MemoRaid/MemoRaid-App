// lib/features/memories/memory_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/memory.dart';
import '../../services/memory_service.dart';
import '../questions/memory_questions_screen.dart';
import '../../memoraid_features/services/auth_service.dart';

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

    // Authentication check
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    // Only fetch memories if authenticated
    _memoriesFuture = MemoryService().getPatientMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Memories',
          style: TextStyle(
            color: Color(0xFF0D3445),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0D3445)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFF0D3445).withOpacity(0.3)],
          ),
        ),
        child: FutureBuilder<List<Memory>>(
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
      ),
    );
  }
}

class MemoryCard extends StatelessWidget {
  final Memory memory;

  const MemoryCard({Key? key, required this.memory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Material(
          color: Colors.transparent,
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
                Stack(
                  children: [
                    Image.network(
                      memory.photoUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7)
                            ],
                          ),
                        ),
                        child: Text(
                          memory.briefDescription,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Color(0xFF4E6077)),
                      SizedBox(width: 8),
                      Text(
                        '${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year}',
                        style: TextStyle(color: Color(0xFF4E6077)),
                      ),
                      Spacer(),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF0D3445),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.question_answer,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('Quiz', style: TextStyle(color: Colors.white)),
                          ],
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
    );
  }
}
