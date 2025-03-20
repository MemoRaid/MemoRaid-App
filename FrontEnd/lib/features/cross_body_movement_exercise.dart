import 'package:flutter/material.dart';
import 'dart:async';

class CrossBodyMovementExercise extends StatefulWidget {
  const CrossBodyMovementExercise({super.key});

  @override
  _CrossBodyMovementExerciseState createState() =>
      _CrossBodyMovementExerciseState();
}

class _CrossBodyMovementExerciseState extends State<CrossBodyMovementExercise> {
  int _currentStep = 0;
  bool _isExercising = false;
  int _timeRemaining = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Cross Crawl',
      'description':
          'This exercise involves touching your opposite knee to elbow, activating both sides of your brain simultaneously.',
      'duration': 45,
      'instructions': [
        'Stand with your feet shoulder-width apart',
        'Lift your right knee and touch it with your left elbow',
        'Return to standing position',
        'Lift your left knee and touch it with your right elbow',
        'Continue alternating sides in a rhythmic motion',
        'Try to maintain a steady pace',
        'Continue for 45 seconds'
      ],
      'benefit':
          'Enhances coordination between the brain hemispheres, improves neural pathway efficiency, and boosts cognitive function.'
    },
    {
      'title': 'Cross-Body Arm Swings',
      'description':
          'Swinging arms across the midline of your body stimulates both hemispheres of the brain simultaneously.',
      'duration': 60,
      'instructions': [
        'Stand with feet hip-width apart',
        'Extend your arms out to the sides at shoulder height',
        'Swing your right arm across your body to the left side',
        'Return to the starting position',
        'Swing your left arm across your body to the right side',
        'Gradually increase your speed while maintaining control',
        'Continue alternating for 60 seconds'
      ],
      'benefit':
          'Improves neural connections between brain hemispheres, enhances focus, and helps with memory formation and recall.'
    },
    {
      'title': 'Diagonal Reaches',
      'description':
          'Reaching diagonally engages multiple brain regions and strengthens neural connections across hemispheres.',
      'duration': 60,
      'instructions': [
        'Stand with feet slightly wider than hip-width apart',
        'Reach your right hand toward your left foot (or ankle/shin)',
        'Return to standing position',
        'Reach your left hand toward your right foot',
        'Keep your movements controlled and deliberate',
        'Bend your knees as needed to prevent strain',
        'Continue alternating sides for 60 seconds'
      ],
      'benefit':
          'Activates both hemispheres simultaneously, improves spatial awareness, and strengthens neural pathways related to memory processing.'
    },
    {
      'title': 'Figure-8 Exercise',
      'description':
          'Drawing figure-8 patterns with your arms activates both hemispheres and requires coordinated mental processing.',
      'duration': 45,
      'instructions': [
        'Stand with feet shoulder-width apart',
        'Extend both arms forward at shoulder height',
        'Using both arms together, draw large figure-8 patterns in the air',
        'After 15 seconds, reverse the direction of your figure-8',
        'Try to make your movements fluid and symmetrical',
        'Focus on the crossover point in the middle of the figure-8',
        'Continue for 45 seconds, alternating directions'
      ],
      'benefit':
          'Strengthens coordination between left and right brain hemispheres, enhances spatial awareness, and improves memory integration.'
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
          title: Text('Exercise Complete!'),
          content: Text('Great job completing this cross-body exercise!'),
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
          'Cross-Body Movement',
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
                            Icons.accessibility_new,
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
                              'Benefits for Brain Health',
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
                            child:
                                Text(_isExercising ? 'Stop' : 'Start Exercise'),
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
