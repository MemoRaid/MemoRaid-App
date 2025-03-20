import 'package:flutter/material.dart';
import 'hand_coordination_exercise.dart';
import 'brain_boosting_yoga_exercise.dart';
import 'cross_body_movement_exercise.dart';
import 'homescreen02.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modify AppBar to move back button lower
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80, // Increase toolbar height
        leading: Padding(
          padding: EdgeInsets.only(
              top: 16.0, left: 8.0), // Add top padding to move down
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
            onPressed: () {
              // Navigate to homescreen2 instead of just popping
              Navigator.pushReplacementNamed(context, '/homescreen2');
            },
          ),
        ),
      ),
      extendBodyBehindAppBar: true, // Allow content to flow behind AppBar
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
                  // Status bar space - reduced since we now have an AppBar
                  SizedBox(height: 0),

                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Heading for exercises - now centered
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Center(
                              child: Text(
                                'Brain Training Exercises',
                                style: TextStyle(
                                  color: Color(0xFF0D3445),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          // Grid of exercise cards - updated size parameters
                          GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing:
                                15, // Reduced for more space for cards
                            crossAxisSpacing:
                                15, // Reduced for more space for cards
                            childAspectRatio: 150 /
                                220, // Modified to make cards larger/taller
                            children: [
                              _buildExerciseCard(
                                context: context,
                                title: 'Hand Coordination',
                                rating: 4.6,
                                isHighlighted: true,
                                imagePath:
                                    'lib/assets/images/hand.webp', // Add hand image
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
                                title: 'Cross Body Movement',
                                rating: 4.4,
                                imagePath:
                                    'lib/assets/images/CrossBody.webp', // Add specific image
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
                                title: 'Brain Boosting Yoga',
                                rating: 4.2,
                                imagePath:
                                    'lib/assets/images/yoga.jpeg', // Add yoga image
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
                              _buildLockedExerciseCard(
                                context: context,
                                title: 'Coming Soon',
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
    );
  }

  Widget _buildExerciseCard({
    required BuildContext context,
    required String title,
    required double rating,
    bool isHighlighted = false,
    required VoidCallback onTap,
    String? imagePath,
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
            // Exercise image - increased height
            Container(
              height: 180, // Increased from 120 to make images larger
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imagePath != null
                      ? AssetImage(imagePath)
                      : NetworkImage("https://placehold.co/155x120")
                          as ImageProvider,
                  fit: BoxFit
                      .cover, // Changed back to cover with proper dimensions
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

            // Title only - no category text
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method for locked exercise card
  Widget _buildLockedExerciseCard({
    required BuildContext context,
    required String title,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Color(0xFFF4F7FB).withOpacity(0.7),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withOpacity(0.3),
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
          // Exercise image with darker overlay - fixed coverage
          Container(
            height: 140, // Increased from 120 to match other cards
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://placehold.co/155x120"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.lock_outline,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),

          // Title and lock icon
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
                  // Keep just the lock icon and text
                  Row(
                    children: [
                      Icon(
                        Icons.lock_clock,
                        size: 14,
                        color: Color(0xFF0D3445).withOpacity(0.7),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Unlock Soon",
                        style: TextStyle(
                          color: Color(0xFF0D3445).withOpacity(0.7),
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
    );
  }
}
