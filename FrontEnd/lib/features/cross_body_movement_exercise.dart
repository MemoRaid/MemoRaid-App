import 'package:flutter/material.dart';

class CrossBodyMovementExercise extends StatelessWidget {
  const CrossBodyMovementExercise({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cross Body Movement'),
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
                  'Cross Body Movement Exercise',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3445),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Cross-lateral movements help connect both hemispheres of the brain, improving cognitive function and memory formation.',
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
                _buildStep(1, 'Stand with your feet shoulder-width apart'),
                _buildStep(2, 'Touch your right hand to your left knee'),
                _buildStep(3, 'Return to standing position'),
                _buildStep(4, 'Touch your left hand to your right knee'),
                _buildStep(
                    5, 'Repeat for 2-3 minutes, increasing speed gradually'),

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
