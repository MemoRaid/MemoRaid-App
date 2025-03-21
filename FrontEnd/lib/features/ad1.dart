import 'package:flutter/material.dart';
import 'ad2.dart'; // Import Ad2 screen to navigate

class AdScreen extends StatelessWidget {
  const AdScreen({super.key});

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
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ad Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: Column(
                children: [
                  SizedBox(height: height * 0.01),

                  // Main Image
                  Image.asset(
                    "assets/images/Trust.png",
                    width: width * 0.6,
                  ),

                  SizedBox(height: height * 0.01),

                  // Text Content
                  Text(
                    "Rebuild Memory with Engaging, Science-Backed Exercises",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0D3445),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: height * 0.04),

                  // Centered Progress Bar
                  Center(
                    child: SizedBox(
                      width: width * 0.6,
                      height: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          SizedBox(width: 2), // Space between bars
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
                          SizedBox(width: 2), // Space between bars
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Next Button Centered with Matching Spacing
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdScreen2()),
                  );
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
                      'Next',
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

            // Matching bottom space
            SizedBox(height: height * 0.06),
          ],
        ),
      ),
    );
  }
}
