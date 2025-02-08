import 'package:flutter/material.dart';

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
        title: Text(
          "Advertisement",
          style: TextStyle(
            color: Color(0xFF0D3445),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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

                  // Main Content
                  Text(
                    "Rebuild Memory with Engaging, Science-Backed Exercises",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0D3445),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Image.asset(
                    "lib/assets/images/Trust.png",
                    width: width * 0.8,
                  ),

                  SizedBox(height: height * 0.05),

                  // Centered Progress Bar
                  Center(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translate(0.0, 0.0)
                        ..rotateZ(3.14),
                      child: Container(
                        width: 102,
                        height: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 37,
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
                              width: 37,
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
                              width: 16,
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
                    ),
                  ),
                ],
              ),
            ),

            // Next and Previous Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4E6077),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implement "Previous" button action
                    },
                    child: Text(
                      "Previous",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4E6077),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implement "Next" button action
                    },
                    child: Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    );
  }
}
