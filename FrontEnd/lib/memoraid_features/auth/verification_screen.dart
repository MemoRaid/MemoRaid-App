import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../memoraid_features/services/auth_service.dart';
import 'share_link.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
        backgroundColor: Color(0xFF0D3445),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Verification Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Please enter the verification code sent to ${widget.email}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator(color: Color(0xFF0D3445))
                : ElevatedButton(
                    onPressed: () async {
                      if (_codeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter verification code'),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      bool success = await authService.verifyEmailCode(
                        widget.email,
                        _codeController.text,
                      );

                      setState(() {
                        _isLoading = false;
                      });

                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShareLinkScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Invalid verification code. Please try again.',
                            ),
                          ),
                        );
                      }
                    },
                    child: Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0D3445),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Request new verification code
                authService.requestEmailVerification(widget.email);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('New verification code sent')),
                );
              },
              child: Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}