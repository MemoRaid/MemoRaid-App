import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": _controller.text});

      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          messages
              .add({"sender": "ai", "text": _getAIResponse(_controller.text)});
        });
      });
    });

    _controller.clear();
  }

  String _getAIResponse(String userMessage) {
    return "Vanakamda mapilai!.. Nan than Mr.MemoRaid 😎";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Chat with Mr. MemoRaid",
          style: TextStyle(color: Color(0xFF0D3445)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFF0D3445)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isUser = message["sender"] == "user";
                    return Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          // AI Profile Pic
                          FadeInLeft(
                            duration: Duration(milliseconds: 500),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage("lib/assets/images/memoraid.png"),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                        Flexible(
                          child: FadeInUp(
                            duration: Duration(milliseconds: 300),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(14),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Color(0xFF0D3445)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                message["text"]!,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isUser) ...[
                          SizedBox(width: 8),
                          // User Profile Pic (Default Avatar)
                          FadeInRight(
                            duration: Duration(milliseconds: 500),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage("lib/assets/images/user.png"),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              // Input Field
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type your feelings...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: sendMessage,
                      backgroundColor: Color(0xFF0D3445),
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
