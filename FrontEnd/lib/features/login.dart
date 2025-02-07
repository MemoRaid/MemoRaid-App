import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/loginorsignup.dart';
import 'signup.dart';
import 'homescreen01.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginSignupScreen(),
              ),
            );
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
              const Color(0xFF0D3445),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.01),

              // Logo
              Image.asset("lib/assets/images/login.png",
                  width: width * 0.6, height: height * 0.25),

              SizedBox(height: height * 0.002),

              // Welcome Text
              Text(
                "Welcome Back!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Log in to continue your journey with MemoRAid.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: height * 0.05),

              // Email Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email, color: Color(0xFF0D3445)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Password Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF0D3445)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xFF0D3445),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Forgot Password
              Padding(
                padding: EdgeInsets.only(right: width * 0.1),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement Forgot Password Logic
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFF0D3445),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),

              // Log In Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Container(
                  width: width * 0.8,
                  height: height * 0.06,
                  decoration: BoxDecoration(
                    color: Color(0xFF0D3445),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),

              // Continue with Social Media Options
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                child: Column(
                  children: [
                    Text(
                      "or continue with",
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    SizedBox(height: 10),

                    // Social Media Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google Button
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement Google Login Logic
                          },
                          child: CircleAvatar(
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            child: Image.asset("lib/assets/images/google.png",
                                width: 25),
                          ),
                        ),
                        SizedBox(width: 15),

                        // Facebook Button
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement Facebook Login Logic
                          },
                          child: CircleAvatar(
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            child: Image.asset("lib/assets/images/facebook.png",
                                width: 25),
                          ),
                        ),
                        SizedBox(width: 15),

                        // Apple Button
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement Apple Login Logic
                          },
                          child: CircleAvatar(
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            child: Image.asset("lib/assets/images/apple.png",
                                width: 25),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),

              // Sign Up Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
