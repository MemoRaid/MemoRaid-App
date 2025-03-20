import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'share_link.dart'; // They're in the same folder now
import 'login.dart'; // No change needed
import 'verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isAgreed = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFF0D3445)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.03),

                // Title
                Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Join MemoRaid and reconnect with your cherished memories!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: height * 0.07),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextField("Full Name", nameController, false),
                      SizedBox(height: 15),
                      buildTextField("Email", emailController, false),
                      SizedBox(height: 15),
                      buildPasswordField("Password", passwordController, true),
                      SizedBox(height: 15),
                      buildPasswordField(
                        "Confirm Password",
                        confirmPasswordController,
                        false,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                // Terms and Conditions Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isAgreed,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        "I've read and agree with the Terms and Conditions and the Privacy Policy.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Sign Up Button
                _isLoading
                    ? CircularProgressIndicator(color: Color(0xFF0D3445))
                    : GestureDetector(
                        // In the SignUpScreen class, in the signup button's onPressed method:
                        // Update the onTap handler in your signup button
                        onTap: _isAgreed &&
                                _formKey.currentState?.validate() == true
                            ? () async {
                                if (passwordController.text !=
                                    confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Passwords do not match"),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                // Call the registerWithVerification method instead
                                final result =
                                    await authService.registerWithVerification(
                                  nameController.text,
                                  emailController.text,
                                  passwordController.text,
                                );

                                setState(() {
                                  _isLoading = false;
                                });

                                if (result['status'] ==
                                    'verification_required') {
                                  // Navigate to verification screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VerificationScreen(
                                        email: emailController.text,
                                      ),
                                    ),
                                  );
                                } else if (result['status'] == 'success') {
                                  // Navigate to first ad screen
                                  Navigator.pushReplacementNamed(
                                      context, '/ad1');
                                } else {
                                  // Show error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result['message'] ??
                                            "Registration failed")),
                                  );
                                }
                              }
                            : null,
                        child: Container(
                          width: width * 0.9,
                          height: height * 0.06,
                          decoration: ShapeDecoration(
                            color: _isAgreed ? Color(0xFF0D3445) : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                SizedBox(height: 15),

                // Google Sign Up
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isLoading = true;
                    });

                    bool success = await authService.signInWithGoogle();

                    setState(() {
                      _isLoading = false;
                    });

                    if (success) {
                      // Navigate to home screen
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => HomeScreen()),
                      // );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Google sign-in failed")),
                      );
                    }
                  },
                  child: Container(
                    width: width * 0.9,
                    height: height * 0.06,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "lib/assets/images/google.png",
                          height: 24,
                          width: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Sign up with Google',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 15),

                // Back to Login
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Already have an account? Log In",
                    style: TextStyle(
                      color: Color(0xFF0D3445),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Text Field Widget
  Widget buildTextField(
    String label,
    TextEditingController controller,
    bool isPassword,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF0D3445)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  // Password Field with Show/Hide Feature
  Widget buildPasswordField(
    String label,
    TextEditingController controller,
    bool isMainPassword,
  ) {
    return TextFormField(
      controller: controller,
      obscureText:
          isMainPassword ? !_isPasswordVisible : !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF0D3445)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isMainPassword
                ? (_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                : (_isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
          ),
          onPressed: () {
            setState(() {
              if (isMainPassword) {
                _isPasswordVisible = !_isPasswordVisible;
              } else {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (isMainPassword && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (!isMainPassword && value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
