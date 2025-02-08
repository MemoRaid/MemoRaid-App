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
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                children: [
                  SizedBox(height: height * 0.03),

                  // Main Image
                  Image.asset(
                    "lib/assets/images/Trust.png",
                    width: width * 0.8,
                  ),

                  SizedBox(height: height * 0.03),

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

                  SizedBox(height: height * 0.05),

                  // Centered Progress Bar
                  Center(
                    child: Container(
                      width: width *
                          0.6, // Control the total width of progress bars
                      height: 8,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center the bars
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Progress Bar
                          Container(
                            width: (width * 0.35 - 2 * 2) /
                                3, // Further minimized width
                            height: 8,
                            decoration: ShapeDecoration(
                              color: Color(0xFF0D3445),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19),
                              ),
                            ),
                          ),
                          SizedBox(width: 2), // Space between bars
                          // Second Progress Bar
                          Container(
                            width: (width * 0.35 - 2 * 2) /
                                3, // Further minimized width
                            height: 8,
                            decoration: ShapeDecoration(
                              color: Color(0xFFD0D0D0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19),
                              ),
                            ),
                          ),
                          SizedBox(width: 2), // Space between bars
                          // Third Progress Bar
                          Container(
                            width: (width * 0.35 - 2 * 2) /
                                3, // Further minimized width
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

            // Next Button Centered
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Positioned(
                left: width * 0.05,
                top: height * 0.7,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdScreen2()),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    );
  }
}
