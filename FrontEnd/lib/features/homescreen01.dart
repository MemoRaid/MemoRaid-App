import 'package:flutter/material.dart';
import 'bottomnavbar.dart';
import 'homescreen02.dart'; // Import the bottom navigation bar file

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          "Activity",
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.03),

              // Activity Info Card
              Container(
                width: width * 0.9,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Complete a full training session or assessment to view your cognitive scores.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Image.asset(
                      "lib/assets/images/graph.png",
                      width: width * 0.8,
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.04),

              // General Memory Assessment Card
              buildActivityCard(
                title: "General Memory Assessment",
                buttonText: "Test your memory now",
                image: null, // No image provided for this card
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen2()),
                  );
                },
              ),

              SizedBox(height: height * 0.02),

              // Personalized Training Card
              buildActivityCard(
                title: "Personalized Memory Training",
                buttonText: "Start Training",
                image: "lib/assets/images/brainperson.png",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen2()),
                  );
                },
              ),

              SizedBox(height: height * 0.03),

              // Footer Message
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Text(
                  "Complete a full training session to see your full cognitive scores",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),

              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        // Use the custom navigation bar
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/chatbot');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/rocket');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/achievements');
              break;
          }
        },
      ),
    );
  }

  Widget buildActivityCard({
    required String title,
    required String buttonText,
    String? image, // Image is now optional
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFF0D3445),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (image != null) ...[
            SizedBox(height: 10),
            Image.asset(
              image,
              width: 150,
            ),
          ],
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4E6077),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onTap,
            child: Text(buttonText, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
