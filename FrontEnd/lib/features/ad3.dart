import 'package:flutter/material.dart';

class AdScreen3 extends StatelessWidget {
  const AdScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () {
            Navigator.pop(context); // Navigate back to AdScreen2
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFF0D3445),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjusted spacing
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                children: [
                  SizedBox(height: height * 0.03), // Add some space at the top
                  Image.asset("lib/assets/images/receivemoney.png",
                      width: width * 0.6),
                  SizedBox(height: height * 0.03),
                  Text(
                    "Capture Daily Reflections and Milestones for Steady Growth ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0D3445),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                  // Progress Indicator
                  SizedBox(
                    width: width * 0.6,
                    height: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: (width * 0.35 - 2 * 2) / 3,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD0D0D0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Container(
                          width: (width * 0.35 - 2 * 2) / 3,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD0D0D0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Container(
                          width: (width * 0.35 - 2 * 2) / 3,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Color(0xFF0D3445),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Finish Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: GestureDetector(
                onTap: () {
                  // You can modify this to navigate to the next screen
                },
                child: Container(
                  width: width * 0.9,
                  height: height * 0.06,
                  decoration: ShapeDecoration(
                    color: Color(0xFF0D3445),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Finish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.03), // Add space at the bottom
          ],
        ),
      ),
    );
  }
}
