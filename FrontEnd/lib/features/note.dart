import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final TimeOfDay scheduleTime;
  final bool isCompleted;
  final TaskCategory category;
  final TaskImportance importance;
  final List<bool> repeatDays; // [Mon-Sun]
  final DateTime createdAt;
  final String? photoMemoryPath;
  final String? voiceNotePath;
  final Position? locationReminder;
  final String? verificationPhoto;
  final MoodState? completionMood;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduleTime,
    this.isCompleted = false,
    required this.category,
    this.importance = TaskImportance.normal,
    required this.repeatDays,
    required this.createdAt,
    this.photoMemoryPath,
    this.voiceNotePath,
    this.locationReminder,
    this.verificationPhoto,
    this.completionMood,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'scheduleTimeHour': scheduleTime.hour,
        'scheduleTimeMinute': scheduleTime.minute,
        'isCompleted': isCompleted,
        'category': category.toString(),
        'importance': importance.toString(),
        'repeatDays': repeatDays,
        'createdAt': createdAt.toIso8601String(),
        'photoMemoryPath': photoMemoryPath,
        'voiceNotePath': voiceNotePath,
        'locationReminder': locationReminder != null
            ? {
                'latitude': locationReminder!.latitude,
                'longitude': locationReminder!.longitude
              }
            : null,
        'verificationPhoto': verificationPhoto,
        'completionMood': completionMood?.toString(),
      };

  static Task fromJson(Map<String, dynamic> json) {
    Position? locationReminder;
    if (json['locationReminder'] != null) {
      try {
        locationReminder = Position.fromMap(json['locationReminder']);
      } catch (e) {
        print('Error parsing location: $e');
      }
    }

    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      scheduleTime: TimeOfDay(
        hour: json['scheduleTimeHour'],
        minute: json['scheduleTimeMinute'],
      ),
      isCompleted: json['isCompleted'],
      category: TaskCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => TaskCategory.morningRoutine,
      ),
      importance: TaskImportance.values.firstWhere(
        (e) => e.toString() == json['importance'],
        orElse: () => TaskImportance.normal,
      ),
      repeatDays: List<bool>.from(json['repeatDays']),
      createdAt: DateTime.parse(json['createdAt']),
      photoMemoryPath: json['photoMemoryPath'],
      voiceNotePath: json['voiceNotePath'],
      locationReminder: locationReminder,
      verificationPhoto: json['verificationPhoto'],
      completionMood: json['completionMood'] != null
          ? MoodState.values.firstWhere(
              (e) => e.toString() == json['completionMood'],
              orElse: () => MoodState.neutral,
            )
          : null,
    );
  }
}

enum TaskCategory {
  morningRoutine,
  medication,
  meals,
  appointments,
  activities
}

enum TaskImportance { high, normal, low }

enum MoodState { happy, neutral, confused, distressed }

class TaskService {
  static final List<Task> _tasks = [];
  static const String _storageKey = 'tasks';

  static Future<void> initialize() async {
    await _loadTasks();
  }

  static Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_storageKey) ?? [];
    _tasks.clear();
    _tasks.addAll(tasksJson.map((json) => Task.fromJson(jsonDecode(json))));
  }

  static Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_storageKey, tasksJson);
  }

  static Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
  }

  static Future<void> updateTaskCompletion(String id, bool isCompleted) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == id);
      if (taskIndex == -1) throw Exception('Task not found');

      final task = _tasks[taskIndex];
      _tasks[taskIndex] = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        scheduleTime: task.scheduleTime,
        category: task.category,
        importance: task.importance,
        repeatDays: task.repeatDays,
        createdAt: task.createdAt,
        isCompleted: isCompleted,
        photoMemoryPath: task.photoMemoryPath,
        voiceNotePath: task.voiceNotePath,
        locationReminder: task.locationReminder,
        verificationPhoto: task.verificationPhoto,
        completionMood: task.completionMood,
      );

      await _saveTasks();
    } catch (e) {
      print('Error updating task completion: $e');
      rethrow;
    }
  }

  static Future<void> saveVerificationPhoto(
      String taskId, String photoPath) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      _tasks[taskIndex] = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        scheduleTime: task.scheduleTime,
        category: task.category,
        importance: task.importance,
        repeatDays: task.repeatDays,
        createdAt: task.createdAt,
        isCompleted: task.isCompleted,
        photoMemoryPath: task.photoMemoryPath,
        voiceNotePath: task.voiceNotePath,
        locationReminder: task.locationReminder,
        verificationPhoto: photoPath,
        completionMood: task.completionMood,
      );
      await _saveTasks();
    }
  }

  static Future<void> updateTaskMood(String taskId, MoodState mood) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      _tasks[taskIndex] = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        scheduleTime: task.scheduleTime,
        category: task.category,
        importance: task.importance,
        repeatDays: task.repeatDays,
        createdAt: task.createdAt,
        isCompleted: task.isCompleted,
        photoMemoryPath: task.photoMemoryPath,
        voiceNotePath: task.voiceNotePath,
        locationReminder: task.locationReminder,
        verificationPhoto: task.verificationPhoto,
        completionMood: mood,
      );
      await _saveTasks();
    }
  }
}

class TaskSchedulerScreen extends StatefulWidget {
  const TaskSchedulerScreen({Key? key})
      : super(key: key); // Make constructor public and add key

  @override
  _TaskSchedulerScreenState createState() => _TaskSchedulerScreenState();
}

class _TaskSchedulerScreenState extends State<TaskSchedulerScreen>
    with SingleTickerProviderStateMixin {
  List<Task> _tasks = []; // Change to non-final to allow updates
  DateTime _selectedDate = DateTime.now();
  AnimationController? _animationController;
  final SpeechToText _speechToText = SpeechToText();
  final FaceDetector _faceDetector =
      FaceDetector(options: FaceDetectorOptions());
  CameraController? _cameraController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeAndLoadTasks();
    _initializeSpeech();
    _checkPermissions().then((_) {
      _initializeCamera();
    });
    _requestLocationPermission();
  }

  Future<void> _initializeAndLoadTasks() async {
    await TaskService.initialize();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = TaskService._tasks; // Access tasks from service
    });
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speechToText.initialize();
    setState(() => _isListening = available);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await _cameraController?.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e')),
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    await Geolocator.requestPermission();
  }

  Future<void> _verifyTaskWithFace(Task task) async {
    try {
      if (_cameraController == null) return;
      if (!_cameraController!.value.isInitialized) return;

      final image = await _cameraController!.takePicture();
      final faces = await _faceDetector.processImage(
        InputImage.fromFilePath(image.path),
      );

      if (faces.isNotEmpty) {
        await TaskService.updateTaskCompletion(task.id, true);
        await TaskService.saveVerificationPhoto(task.id, image.path);
        _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No face detected. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying task: $e')),
      );
    }
  }

  Future<void> _startVoiceCommand() async {
    if (!_isListening) return;

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          _processVoiceCommand(result.recognizedWords);
        }
      },
    );
  }

  void _processVoiceCommand(String command) {
    if (command.contains('add task')) {
      _showAddTaskSheet(context);
    } else if (command.contains('complete')) {
      final taskTitle = command.replaceAll('complete', '').trim();
      final taskMatch = _tasks
          .where((t) => t.title.toLowerCase().contains(taskTitle.toLowerCase()))
          .toList();

      if (taskMatch.isNotEmpty) {
        TaskService.updateTaskCompletion(taskMatch.first.id, true);
        _loadTasks();
      }
    }
  }

  Future<void> _checkPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.location,
    ];

    for (var permission in permissions) {
      if (await permission.status.isDenied) {
        final status = await permission.request();
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${permission.toString()} permission required')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D3445).withOpacity(0.8), Color(0xFF0D3445)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            _buildTimeSelector(),
            _buildDailyOverview(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildTasksList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddTaskButton(),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          DateFormat('EEEE, MMMM d').format(_selectedDate),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D3445).withOpacity(0.6),
                Color(0xFF0D3445),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 8),
          itemCount: 7,
          itemBuilder: (context, index) {
            final time = DateTime.now().add(Duration(days: index));
            final isToday = index == 0;
            return _buildTimeCard(time, isToday);
          },
        ),
      ),
    );
  }

  Widget _buildTimeCard(DateTime time, bool isToday) {
    final isSelected = DateUtils.isSameDay(time, _selectedDate);
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = time),
      child: Container(
        width: 80,
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday ? 'Today' : DateFormat('EEE').format(time),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isToday ? 14 : 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('d').format(time),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyOverview() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildProgressBars(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBars() {
    return Column(
      children: TaskCategory.values.map((category) {
        final tasksForCategory = _tasks
            .where((t) =>
                t.category == category &&
                t.repeatDays[_selectedDate.weekday - 1])
            .length;

        final completedTasks = _tasks
            .where((t) =>
                t.category == category &&
                t.isCompleted &&
                t.repeatDays[_selectedDate.weekday - 1])
            .length;

        final progress =
            tasksForCategory == 0 ? 0.0 : completedTasks / tasksForCategory;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getCategoryName(category),
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '$completedTasks/$tasksForCategory',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white10,
                  valueColor:
                      AlwaysStoppedAnimation(_getCategoryColor(category)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.morningRoutine:
        return 'Morning Routine';
      case TaskCategory.medication:
        return 'Medications';
      case TaskCategory.meals:
        return 'Meals & Snacks';
      case TaskCategory.appointments:
        return 'Appointments';
      case TaskCategory.activities:
        return 'Daily Activities';
    }
  }

  Widget _buildTasksList() {
    final filteredTasks = _tasks.where((task) {
      return task.repeatDays[_selectedDate.weekday - 1] ||
          (task.createdAt.year == _selectedDate.year &&
              task.createdAt.month == _selectedDate.month &&
              task.createdAt.day == _selectedDate.day);
    }).toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= filteredTasks.length) return null;
          return _buildTaskCard(filteredTasks[index]);
        },
        childCount: filteredTasks.length,
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return AnimatedBuilder(
      animation: _animationController ??
          AnimationController(vsync: this, duration: Duration.zero),
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12), // Reduced margin
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(task.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(task.category),
                    color: _getCategoryColor(task.category),
                  ),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          task.scheduleTime.format(context),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (task.importance == TaskImportance.high) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.priority_high,
                                    color: Colors.red, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'High Priority',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) async {
                      await TaskService.updateTaskCompletion(
                          task.id, value ?? false);
                      _loadTasks(); // Reload tasks after updating
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: Color(0xFF0D3445),
                  ),
                ),
              ),
              if (task.description.isNotEmpty)
                Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  width: double.infinity,
                  child: Text(
                    task.description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              if (task.locationReminder != null) _buildLocationReminder(task),
              if (task.photoMemoryPath != null) _buildPhotoMemory(task),
              _buildMoodTracker(task),
              _buildEmergencyButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationReminder(Task task) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text('Location Reminder'),
      subtitle: Text('Tap to view on map'),
      onTap: () => _showLocationOnMap(task.locationReminder!),
    );
  }

  Widget _buildPhotoMemory(Task task) {
    return Container(
      height: 150,
      child: Image.file(
        File(task.photoMemoryPath!),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildMoodTracker(Task task) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: MoodState.values.map((mood) {
        return IconButton(
          icon: Icon(_getMoodIcon(mood)),
          color: task.completionMood == mood ? Colors.blue : Colors.grey,
          onPressed: () => TaskService.updateTaskMood(task.id, mood),
        );
      }).toList(),
    );
  }

  Widget _buildEmergencyButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.emergency),
      label: Text('Emergency Contact'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: _callEmergencyContact,
    );
  }

  IconData _getMoodIcon(MoodState mood) {
    switch (mood) {
      case MoodState.happy:
        return Icons.sentiment_very_satisfied;
      case MoodState.neutral:
        return Icons.sentiment_neutral;
      case MoodState.confused:
        return Icons.sentiment_dissatisfied;
      case MoodState.distressed:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Future<void> _showLocationOnMap(Position position) async {
    try {
      final Uri url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch map');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening map: $e')),
      );
    }
  }

  Future<void> _callEmergencyContact() async {
    try {
      final Uri phoneUri = Uri.parse('tel:+1234567890');
      if (!await launchUrl(phoneUri)) {
        throw Exception('Could not launch phone call');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making phone call: $e')),
      );
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _speechToText.stop();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: _AddTaskForm(
          onSave: (task) async {
            await TaskService.addTask(task);
            _loadTasks(); // Reload tasks after adding
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.morningRoutine:
        return Colors.yellow;
      case TaskCategory.medication:
        return Colors.red;
      case TaskCategory.meals:
        return Colors.orange;
      case TaskCategory.appointments:
        return Colors.blue;
      case TaskCategory.activities:
        return Colors.green;
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.morningRoutine:
        return Icons.wb_sunny;
      case TaskCategory.medication:
        return Icons.medication;
      case TaskCategory.meals:
        return Icons.restaurant;
      case TaskCategory.appointments:
        return Icons.event;
      case TaskCategory.activities:
        return Icons.directions_run;
    }
  }

  Widget _buildAddTaskButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddTaskSheet(context),
      icon: const Icon(Icons.add_alarm, color: Colors.white),
      label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF0D3445),
    );
  }
}

class _AddTaskForm extends StatefulWidget {
  final Function(Task) onSave;

  const _AddTaskForm({required this.onSave});

  @override
  __AddTaskFormState createState() => __AddTaskFormState();
}

class __AddTaskFormState extends State<_AddTaskForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TaskCategory _selectedCategory = TaskCategory.morningRoutine;
  TaskImportance _importance = TaskImportance.normal;
  List<bool> _selectedDays = List.filled(7, true);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Task',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3445),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaskCategory>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: TaskCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() => _selectedTime = time);
                    }
                  },
                  child: Text(_selectedTime.format(context)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeekdaySelector(),
            const SizedBox(height: 16),
            _buildImportanceSelector(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < 7; i++)
          GestureDetector(
            onTap: () {
              setState(() => _selectedDays[i] = !_selectedDays[i]);
            },
            child: CircleAvatar(
              backgroundColor:
                  _selectedDays[i] ? Colors.blue : Colors.grey[200],
              child: Text(
                ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                style: TextStyle(
                  color: _selectedDays[i] ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImportanceSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: TaskImportance.values.map((importance) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ChoiceChip(
            label: Text(importance.toString().split('.').last),
            selected: _importance == importance,
            onSelected: (selected) {
              if (selected) setState(() => _importance = importance);
            },
          ),
        );
      }).toList(),
    );
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) return;

    final task = Task(
      id: const Uuid().v4(),
      title: _titleController.text,
      description: _descController.text,
      scheduleTime: _selectedTime,
      category: _selectedCategory,
      importance: _importance,
      repeatDays: _selectedDays,
      createdAt: DateTime.now(),
    );

    widget.onSave(task);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
