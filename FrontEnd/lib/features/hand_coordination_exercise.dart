import 'package:flutter/material.dart';
import 'dart:async';
import '../../components/exercise_video_player.dart';

class HandCoordinationExercise extends StatefulWidget {
  const HandCoordinationExercise({super.key});

  @override
  _HandCoordinationExerciseState createState() =>
      _HandCoordinationExerciseState();
}

class _HandCoordinationExerciseState extends State<HandCoordinationExercise> {
  int _currentStep = 0;
  bool _isExercising = false;
  int _timeRemaining = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Finger Tapping',
      'description':
          'Tap each finger against your thumb in sequence, then reverse. This builds fine motor control and activates multiple brain regions.',
      'videoUrl':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', // Example video URL
      'duration': 30,
      'instructions': [
        'Sit comfortably with your hand raised, palm facing you',
        'Start with your index finger and tap it to your thumb',
        'Continue with your middle finger to thumb',
        'Then ring finger to thumb',
        'Finally pinky finger to thumb',
        'Reverse the sequence (pinky to index)',
        'Repeat continuously for 30 seconds'
      ],
      'benefit':
          'Improves neural connections between brain hemispheres, enhancing memory recall and processing speed.'
    },
    {
      'title': 'Finger Isolation',
      'description':
          'Place your palm flat on a surface, then lift and lower each finger independently while keeping others down.',
      'videoUrl':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // Example video URL
      'duration': 45,
      'instructions': [
        'Place your hand flat on a table, palm down',
        'Keep all fingers touching the surface',
        'Slowly lift only your index finger, then lower it',
        'Lift only your middle finger, then lower it',
        'Continue with ring finger, then pinky',
        'Try to maintain complete isolation (other fingers stay down)',
        'Perform with both hands for 45 seconds'
      ],
      'benefit':
          'Enhances fine motor control and activates precise regions of your motor cortex, which is linked to better cognitive processing.'
    },
    {
      'title': 'Thumb Opposition',
      'description':
          'Create complex patterns by touching thumb to specific fingers in varying sequences, challenging your brain.',
      'videoUrl':
          'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4', // Example video URL
      'duration': 60,
      'instructions': [
        'Create this pattern: thumb→index→middle→ring→pinky',
        'Then try: thumb→middle→index→pinky→ring',
        'Finally: thumb→pinky→ring→middle→index',
        'Increase speed as you become more comfortable',
        'Add challenge by doing different patterns with each hand simultaneously',
        'Continue for 60 seconds'
      ],
      'benefit':
          'Creates new neural pathways in the brain, improving overall cognitive function and memory formation.'
    },
    {
      'title': 'Finger Counting',
      'description':
          'Count using your fingers but in creative patterns - skip numbers, use different bases, or count backward.',
      'videoUrl':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', // Example video URL
      'duration': 45,
      'instructions': [
        'Hold both hands up, palms facing you',
        'Start counting using a non-standard pattern',
        'Try counting by 3s (3, 6, 9...) using finger movements',
        'Count backward from 10 to 1',
        'Try binary counting (each finger is a binary digit)',
        'Proceed slowly at first, then increase speed',
        'Continue for 45 seconds'
      ],
      'benefit':
          'Combines numerical processing with motor skills, strengthening connections that enhance working memory.'
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
          content: Text('Great job completing this exercise!'),
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
          'Hand Coordination Exercises',
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

                      // Video player instead of static icon
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: ExerciseVideoPlayer(
                          videoUrl: currentExercise['videoUrl'],
                          autoplay: false,
                          looping: true,
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
