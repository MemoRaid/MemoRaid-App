import 'package:flutter/material.dart';
import 'hand_coordination_exercise.dart';
import 'brain_boosting_yoga_exercise.dart';
import 'cross_body_movement_exercise.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Colors.white, Color(0xFF0D3445)],
          ),
        ),
        child: Stack(
          children: [
            // Semi-transparent overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Status bar space
                  SizedBox(height: 12),

                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Heading for exercises
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 16.0, left: 4.0),
                            child: Text(
                              'Brain Training Exercises',
                              style: TextStyle(
                                color: Color(0xFF0D3445),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Grid of exercise cards - now with only 3 exercises
                          GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 155 / 205,
                            children: [
                              _buildExerciseCard(
                                context: context,
                                title: 'Hand Coordination',
                                rating: 4.6,
                                isHighlighted: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HandCoordinationExercise(),
                                    ),
                                  );
                                },
                              ),
                              _buildExerciseCard(
                                context: context,
                                title:
                                    'Cross Body Movement', // Moved to second position
                                rating: 4.4,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CrossBodyMovementExercise(),
                                    ),
                                  );
                                },
                              ),
                              _buildExerciseCard(
                                context: context,
                                title:
                                    'Brain Boosting Yoga', // Moved to third position
                                rating: 4.2,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BrainBoostingYogaExercise(),
                                    ),
                                  );
                                },
                              ),
                              // Fourth "Coming Soon" exercise card removed
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom navigation indicator
                  Container(
                    height: 85,
                    decoration: BoxDecoration(
                      color: Color(0xFF0D3445),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1C000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 133,
                        height: 6,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard({
    required BuildContext context,
    required String title,
    required double rating,
    bool isHighlighted = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isHighlighted ? Color(0xFFFCFFFC) : Color(0xFFF4F7FB),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: Colors.white.withOpacity(isHighlighted ? 1 : 0.5),
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x333B4056),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Exercise image
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/155x120"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Bookmark button
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: ShapeDecoration(
                  color: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Icon(
                  Icons.bookmark_border,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),

            // Title and rating
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFF0D3445),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 0.81,
                        letterSpacing: 0.07,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Padding(
                            padding: EdgeInsets.only(right: 2),
                            child: Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFF0D3445),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            color: Color(0xFF0D3445),
                            fontSize: 12,
                            fontFamily: 'M PLUS 1',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
