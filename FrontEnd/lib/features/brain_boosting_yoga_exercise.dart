import 'package:flutter/material.dart';
import 'dart:async';

class BrainBoostingYogaExercise extends StatefulWidget {
  const BrainBoostingYogaExercise({super.key});

  @override
  _BrainBoostingYogaExerciseState createState() =>
      _BrainBoostingYogaExerciseState();
}

class _BrainBoostingYogaExerciseState extends State<BrainBoostingYogaExercise> {
  int _currentStep = 0;
  bool _isExercising = false;
  int _timeRemaining = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Padahastasana (Forward Fold)',
      'description':
          'This forward fold increases blood flow to the brain while calming the nervous system.',
      'duration': 60,
      'instructions': [
        'Start by standing straight with your feet together',
        'Inhale deeply, raising your arms above your head',
        'As you exhale, fold forward from your hips',
        'Bring your hands to the floor beside your feet',
        'Hold the position and breathe deeply',
        'Let your head hang freely to enhance blood flow',
        'Hold for 60 seconds, breathing slowly'
      ],
      'benefit':
          'Increases circulation to the brain, which can improve cognitive function, memory, and concentration.'
    },
    {
      'title': 'Halasana (Plow Pose)',
      'description':
          'This inverted pose stimulates the thyroid and pituitary gland, which helps regulate memory function.',
      'duration': 45,
      'instructions': [
        'Lie flat on your back',
        'Place your arms alongside your body, palms down',
        'Lift your legs slowly over your head',
        'Try to touch your toes to the floor behind your head',
        'Keep your back supported and hands flat on the floor',
        'Breathe deeply and hold for 45 seconds',
        'To release, slowly roll your spine back down'
      ],
      'benefit':
          'Stimulates the pituitary and thyroid glands, improving memory, reducing stress, and enhancing neural communication.'
    },
    {
      'title': 'Sarvangasana (Shoulder Stand)',
      'description':
          'An inverted pose that increases blood flow to the brain while stimulating the thyroid gland.',
      'duration': 60,
      'instructions': [
        'Lie on your back with arms alongside your body',
        'Lift your legs and lower back off the floor',
        'Support your back with your hands',
        'Straighten your legs upward',
        'Keep your body straight from shoulders to toes',
        'Breathe deeply, focusing on steady breaths',
        'Hold for 60 seconds if comfortable'
      ],
      'benefit':
          'Improves blood circulation to the brain, enhances memory and concentration, and supports the functioning of the pituitary and pineal glands.'
    },
    {
      'title': 'Paschimottanasana (Seated Forward Bend)',
      'description':
          'A calming forward bend that stimulates the brain while relaxing the nervous system.',
      'duration': 60,
      'instructions': [
        'Sit with your legs extended in front of you',
        'Inhale, elongating your spine',
        'Exhale and hinge at the hips to fold forward',
        'Reach for your feet, ankles, or shins',
        'Keep your back as straight as possible',
        'Relax your head toward your knees',
        'Hold for 60 seconds with deep breathing'
      ],
      'benefit':
          'Calms the mind, reduces stress, enhances focus, and stimulates the liver and kidneys, which helps to clear toxins that can hinder cognitive function.'
    }
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isExercising = true;
      _timeRemaining = _exercises[_currentStep]['duration'];
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer?.cancel();
          _isExercising = false;
          // Show completion dialog
          _showCompletionDialog();
        }
      });
    });
  }

  void _stopExercise() {
    setState(() {
      _timer?.cancel();
      _isExercising = false;
    });
  }

  void _nextExercise() {
    if (_currentStep < _exercises.length - 1) {
      setState(() {
        _currentStep++;
        _isExercising = false;
      });
      _timer?.cancel();
    }
  }

  void _previousExercise() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _isExercising = false;
      });
      _timer?.cancel();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pose Complete!'),
          content: Text(
              'Excellent work holding this pose! Take a moment to breathe normally.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                // If this is not the last exercise, proceed to next
                if (_currentStep < _exercises.length - 1) {
                  _nextExercise();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _exercises[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Brain-Boosting Yoga',
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _exercises.length,
                    (index) => Container(
                      width: 60,
                      height: 5,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? Color(0xFF0D3445)
                            : Color(0xFF0D3445).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              ),

              // Exercise content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise title
                      Text(
                        currentExercise['title'],
                        style: TextStyle(
                          color: Color(0xFF0D3445),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Exercise image placeholder
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF0D3445).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.self_improvement,
                            size: 80,
                            color: Color(0xFF0D3445).withOpacity(0.5),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Description
                      Text(
                        'Description',
                        style: TextStyle(
                          color: Color(0xFF0D3445),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        currentExercise['description'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0D3445),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Step by step instructions
                      Text(
                        'Instructions',
                        style: TextStyle(
                          color: Color(0xFF0D3445),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...List.generate(
                        currentExercise['instructions'].length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ',
                                style: TextStyle(
                                  color: Color(0xFF0D3445),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  currentExercise['instructions'][index],
                                  style: TextStyle(
                                    color: Color(0xFF0D3445),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Benefits
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF0D3445).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Benefits',
                              style: TextStyle(
                                color: Color(0xFF0D3445),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              currentExercise['benefit'],
                              style: TextStyle(
                                color: Color(0xFF0D3445),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Safety note for yoga poses
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber[800],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Safety Note',
                                  style: TextStyle(
                                    color: Colors.amber[800],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Listen to your body and only perform poses within your comfort level. If you experience pain, please stop immediately. These poses may not be suitable for everyone, especially those with certain medical conditions.',
                              style: TextStyle(
                                color: Colors.amber[800],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Timer area
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Timer display
                    if (_isExercising)
                      Column(
                        children: [
                          Text(
                            'Time Remaining',
                            style: TextStyle(
                              color: Color(0xFF0D3445),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$_timeRemaining seconds',
                            style: TextStyle(
                              color: Color(0xFF0D3445),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),

                    // Control buttons
                    Row(
                      children: [
                        // Previous button
                        if (_currentStep > 0)
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed:
                                  _isExercising ? null : _previousExercise,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF0D3445),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Color(0xFF0D3445)),
                                ),
                              ),
                              child: Text('Previous'),
                            ),
                          ),

                        if (_currentStep > 0) SizedBox(width: 8),

                        // Start/Stop button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed:
                                _isExercising ? _stopExercise : _startExercise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isExercising
                                  ? Colors.red
                                  : Color(0xFF0D3445),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(_isExercising ? 'Stop' : 'Start Pose'),
                          ),
                        ),

                        if (_currentStep < _exercises.length - 1)
                          SizedBox(width: 8),

                        // Next button
                        if (_currentStep < _exercises.length - 1)
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: _isExercising ? null : _nextExercise,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF0D3445),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Color(0xFF0D3445)),
                                ),
                              ),
                              child: Text('Next'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
