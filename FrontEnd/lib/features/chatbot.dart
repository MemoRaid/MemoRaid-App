import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro', // Changed from 'gemini-1.0-pro' to 'gemini-pro'
      apiKey: APIConfig.geminiApiKey,
    );
    _chat = _model.startChat(history: [
      Content.text(
          'You are Mr. MemoRaid, a friendly and knowledgeable memory training assistant. '
          'Your purpose is to help users improve their memory through techniques, '
          'exercises, and encouragement. Keep responses focused on memory improvement '
          'and cognitive enhancement. Be friendly and concise.'),
    ]);

    messages.add({
      "sender": "ai",
      "text":
          "Hello! I'm Mr. MemoRaid, your memory training assistant. How can I help you improve your memory today?",
      "time": DateTime.now().toString(),
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;
    _controller.clear();

    setState(() {
      messages.add({
        "sender": "user",
        "text": userMessage,
        "time": DateTime.now().toString(),
      });
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(userMessage));
      final aiResponse = response.text ??
          'I apologize, I cannot provide a response at this moment.';

      setState(() {
        messages.add({
          "sender": "ai",
          "text": aiResponse,
          "time": DateTime.now().toString(),
        });
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error: $e');
      setState(() {
        messages.add({
          "sender": "ai",
          "text":
              "I apologize, but I'm having trouble connecting. Please check your internet connection and try again.",
          "time": DateTime.now().toString(),
        });
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("lib/assets/images/memoraid.png"),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mr. MemoRaid",
                  style: TextStyle(
                    color: Color(0xFF0D3445),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "AI Memory Assistant",
                  style: TextStyle(
                    color: Color(0xFF0D3445).withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF0D3445)),
            onPressed: () {
              setState(() => messages.clear());
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFF0D3445)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final bool isUser = message["sender"] == "user";
                  return FadeIn(
                    duration: Duration(milliseconds: 300),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser)
                            _buildAvatar("lib/assets/images/memoraid.png"),
                          SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    isUser ? Color(0xFF0D3445) : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                                  bottomRight: Radius.circular(isUser ? 0 : 20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message["text"]!,
                                    style: TextStyle(
                                      color: isUser
                                          ? Colors.white
                                          : Color(0xFF0D3445),
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatTime(message["time"]!),
                                    style: TextStyle(
                                      color: isUser
                                          ? Colors.white.withOpacity(0.7)
                                          : Color(0xFF0D3445).withOpacity(0.7),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (isUser)
                            _buildAvatar("lib/assets/images/kushen.png"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isTyping)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildAvatar("lib/assets/images/memoraid.png"),
                    SizedBox(width: 8),
                    SpinKitThreeBounce(
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String imagePath) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: AssetImage(imagePath),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Color(0xFF0D3445).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: Color(0xFF0D3445)),
                    onPressed: () {
                      // Implement voice input
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF0D3445),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF0D3445).withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.send_rounded, color: Colors.white),
              padding: EdgeInsets.all(12),
              constraints: BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
