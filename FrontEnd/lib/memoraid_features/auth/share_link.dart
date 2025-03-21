import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../memoraid_features/services/auth_service.dart';
import '../../memoraid_features/services/api_service.dart';

class ShareLinkScreen extends StatefulWidget {
  const ShareLinkScreen({super.key});

  @override
  _ShareLinkScreenState createState() => _ShareLinkScreenState();
}

class _ShareLinkScreenState extends State<ShareLinkScreen> {
  String? _shareLink;
  bool _isLoading = true;
  bool _linkCopied = false;

  @override
  void initState() {
    super.initState();
    _generateShareLink();
  }

  Future<void> _generateShareLink() async {
    try {
      final apiService = ApiService();

      // Add debug prints
      print("Attempting to generate share link...");

      final response = await apiService.post('auth/generate-share-link', {});
      print("Share link response: $response");

      setState(() {
        // Use your ngrok URL here
        _shareLink = '${response['baseUrl']}/share?token=${response['token']}';

        _isLoading = false;
      });
    } catch (e) {
      print("ERROR generating share link: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate share link: $e')),
      );
    }
  }

  void _copyToClipboard() {
    if (_shareLink != null) {
      Clipboard.setData(ClipboardData(text: _shareLink!));
      setState(() {
        _linkCopied = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Link copied to clipboard!')));

      // Reset the "Copied" state after a delay
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _linkCopied = false;
          });
        }
      });
    }
  }

  void shareLink() {
    // For now, just copy to clipboard
    _copyToClipboard();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authService = Provider.of<AuthService>(context);
    final user = authService.userData;

    return Scaffold(
      appBar: AppBar(
        title: Text('MemoRaid'),
        backgroundColor: Color(0xFF0D3445),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),

                    // Welcome message
                    Text(
                      'Welcome ${user?['name'] ?? 'to MemoRaid'}!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Instructions
                    Text(
                      'Share this link with your family and friends to help them contribute to your memory collection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),

                    SizedBox(height: 40),

                    // Link display
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFF0D3445)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _shareLink ?? 'Link not available',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _linkCopied ? Icons.check : Icons.copy,
                              color: Color(0xFF0D3445),
                            ),
                            onPressed: _copyToClipboard,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Share button
                    ElevatedButton.icon(
                      onPressed: shareLink,
                      icon: Icon(Icons.share),
                      label: Text('Share Link'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0D3445),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    ),

                    Spacer(),

                    // View memories button (commented out for now)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF0D3445),
                        side: BorderSide(color: Color(0xFF0D3445)),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }
}