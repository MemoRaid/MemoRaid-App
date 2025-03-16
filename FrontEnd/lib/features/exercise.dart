import 'package:flutter/material.dart';
import 'exercises/hand_coordination.dart';
import 'exercises/brain_boosting_yoga.dart';
import 'exercises/cross_body_movement.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Memory Boosting Exercises",
          style: TextStyle(
            color: Color(0xFF0D3445),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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

                  // Description text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Improve your memory with physical exercises designed to enhance cognitive abilities and brain function.",
                      style: TextStyle(
                        color: Color(0xFF0D3445),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Grid of exercise cards
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
                                description:
                                    'Finger exercises that boost neural connections',
                                rating: 4.8,
                                icon: Icons.pan_tool_outlined,
                                isHighlighted: true,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HandCoordinationExercise()),
                                ),
                              ),
                              _buildExerciseCard(
                                context: context,
                                title: 'Brain-Boosting Yoga',
                                description:
                                    'Yoga poses that enhance memory and focus',
                                rating: 4.6,
                                icon: Icons.self_improvement,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BrainBoostingYogaExercise()),
                                ),
                              ),
                              _buildExerciseCard(
                                context: context,
                                title: 'Cross-Body Movement',
                                description:
                                    'Exercises for hemispheric integration',
                                rating: 4.7,
                                icon: Icons.accessibility_new,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CrossBodyMovementExercise(),
                                  ),
                                ),
                              ),
                              _buildExerciseCard(
                                context: context,
                                title: 'Deep Breathing',
                                description:
                                    'Techniques to oxygenate the brain',
                                rating: 4.5,
                                icon: Icons.air,
                                onTap: () {
                                  // Show coming soon dialog when clicked
                                  _showComingSoonDialog(
                                      context, 'Deep Breathing');
                                },
                              ),
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

  void _showComingSoonDialog(BuildContext context, String exerciseName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Coming Soon'),
          content: Text(
              '$exerciseName exercises will be available in the next update!'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseCard({
    required BuildContext context,
    required String title,
    required String description,
    required double rating,
    required IconData icon,
    required VoidCallback onTap,
    bool isHighlighted = false,
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
            // Exercise image/icon
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF0D3445).withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 60,
                    color: Color(0xFF0D3445),
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
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFF0D3445),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Color(0xFF0D3445).withOpacity(0.7),
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Padding(
                            padding: EdgeInsets.only(right: 2),
                            child: Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 12,
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
