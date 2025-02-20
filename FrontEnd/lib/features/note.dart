// notebook_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// note_model.dart
class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime? reminderTime;
  final String? audioPath;
  final NoteType type;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.reminderTime,
    this.audioPath,
    required this.type,
  });
}

enum NoteType { text, voice, reminder }

// note_service.dart
class NoteService {
  static final List<Note> _notes = [];

  static List<Note> getNotesByCategory(String category) {
    return _notes.where((note) => note.category == category).toList();
  }

  static void addNote(Note note) {
    _notes.add(note);
  }

  static void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
  }
}

class NotebookScreen extends StatelessWidget {
  const NotebookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3445),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3445),
        title: const Text('My Memory Notebook',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCategoryCard(
            context,
            'Text Notes',
            Icons.note,
            const Color(0xFF1E88E5),
            NoteType.text,
          ),
          _buildCategoryCard(
            context,
            'Voice Notes',
            Icons.mic,
            const Color(0xFF43A047),
            NoteType.voice,
          ),
          _buildCategoryCard(
            context,
            'Reminders',
            Icons.alarm,
            const Color(0xFFE53935),
            NoteType.reminder,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon,
      Color color, NoteType type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NotesListScreen(category: title, noteType: type),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view your ${title.toLowerCase()}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// notes_list_screen.dart
class NotesListScreen extends StatelessWidget {
  final String category;
  final NoteType noteType;

  const NotesListScreen(
      {super.key, required this.category, required this.noteType});

  @override
  Widget build(BuildContext context) {
    final notes = NoteService.getNotesByCategory(category);

    return Scaffold(
      backgroundColor: const Color(0xFF0D3445),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3445),
        title: Text(category, style: const TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(noteType == NoteType.voice ? Icons.mic : Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(
                category: category,
                noteType: noteType,
              ),
            ),
          );
        },
      ),
      body: notes.isEmpty
          ? Center(
              child: Text(
                'No ${category.toLowerCase()} yet',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return _buildNoteCard(context, notes[index]);
              },
            ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      NoteService.deleteNote(note.id);
                      // Rebuild screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotesListScreen(
                            category: category,
                            noteType: noteType,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (note.type == NoteType.voice)
              _buildAudioPlayer(note.audioPath!)
            else
              Text(
                note.content,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  note.createdAt.toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (note.reminderTime != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.alarm, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    note.reminderTime.toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(String audioPath) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            // Implement audio playback
          },
        ),
        Expanded(
          child: Slider(
            value: 0,
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}

// add_note_screen.dart
class AddNoteScreen extends StatefulWidget {
  final String category;
  final NoteType noteType;

  const AddNoteScreen({
    super.key,
    required this.category,
    required this.noteType,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _reminderTime;
  String? _audioPath;
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3445),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3445),
        title: Text('Add New ${widget.category}',
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.noteType == NoteType.voice)
                      _buildVoiceRecorder()
                    else
                      TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          hintText: 'Write your note here...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.noteType == NoteType.reminder ||
                widget.noteType == NoteType.text)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notification_add),
                  title: const Text('Set Reminder'),
                  subtitle: Text(_reminderTime != null
                      ? _reminderTime.toString()
                      : 'No reminder set'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _reminderTime = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceRecorder() {
    return Column(
      children: [
        Text(_audioPath ?? 'No recording yet'),
        const SizedBox(height: 16),
        IconButton(
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          onPressed: () {
            setState(() {
              _isRecording = !_isRecording;
              if (!_isRecording) {
                // Simulate saving audio file
                _audioPath =
                    'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
              }
            });
          },
        ),
      ],
    );
  }

  void _saveNote() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final note = Note(
      id: const Uuid().v4(),
      title: _titleController.text,
      content: _contentController.text,
      category: widget.category,
      createdAt: DateTime.now(),
      reminderTime: _reminderTime,
      audioPath: _audioPath,
      type: widget.noteType,
    );

    NoteService.addNote(note);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
