import 'package:flutter/material.dart';

class BrainBoostingYogaExercise extends StatelessWidget {
  const BrainBoostingYogaExercise({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brain Boosting Yoga'),
        backgroundColor: Color(0xFF0D3445),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Color(0xFF0D3445)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/400x200"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Exercise description
                Text(
                  'Brain Boosting Yoga Exercise',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3445),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'This yoga routine is designed to increase blood flow to the brain, reduce stress, and improve cognitive function and memory.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0D3445),
                  ),
                ),
                SizedBox(height: 20),

                // Exercise steps
                Text(
                  'Instructions:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3445),
                  ),
                ),
                SizedBox(height: 10),
                _buildStep(1, 'Start with 2 minutes of deep breathing'),
                _buildStep(2, 'Perform the downward dog pose for 30 seconds'),
                _buildStep(3, 'Transition to child\'s pose for 30 seconds'),
                _buildStep(4, 'Hold the tree pose for 30 seconds on each leg'),
                _buildStep(5, 'Finish with 2 minutes of meditation'),

                Spacer(),

                // Start exercise button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Start exercise logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0D3445),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Start Exercise',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Color(0xFF0D3445),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF0D3445),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
