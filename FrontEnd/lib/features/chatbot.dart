import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';
import 'homescreen01.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  GenerativeModel? _model;
  ChatSession? _chat;
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isInitializing = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = '';
    });

    try {
      // Use the recommended model from APIConfig
      final modelName = APIConfig.getPreferredModelName();
      print('Initializing chatbot with model: $modelName');

      _model = GenerativeModel(
        model: modelName,
        apiKey: APIConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 800,
        ),
      );

      _chat = _model!.startChat(history: [
        Content.text(
            'You are MemoRaid Assistant, a specialized AI designed to help people with amnesia and memory loss. '
            'Your purpose is to provide support, information, and techniques specifically for amnesia rehabilitation and memory recovery. '
            'Focus on topics like: cognitive rehabilitation exercises, memory recovery techniques, coping strategies for amnesia, '
            'helping patients reconnect with their past, supporting caregivers of amnesia patients, and explaining the science of memory loss and recovery. '
            'Be compassionate, patient, and encouraging. Use clear, simple language and occasionally add emoji for warmth. '
            'Avoid general memory improvement advice that isn\'t specific to amnesia rehabilitation. '
            'If asked about topics unrelated to amnesia rehabilitation or memory recovery, gently redirect to how you can help with memory rehabilitation.'),
      ]);

      setState(() {
        messages.add({
          "sender": "ai",
          "text":
              "Hello! 👋 I'm MemoRaid Assistant, here to help with amnesia rehabilitation and memory recovery. Whether you're recovering from memory loss yourself or supporting someone who is, I can suggest rehabilitation techniques, memory exercises, and coping strategies. How can I assist you today?",
          "time": DateTime.now().toString(),
        });
        _isInitializing = false;
      });
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() {
        _errorMessage = 'Could not initialize chatbot: $e';
        _isInitializing = false;
      });

      // Try alternative models if the first one fails
      _tryAlternativeModels();
    }
  }

  Future<void> _tryAlternativeModels() async {
    // Alternative models to try
    final alternativeModels = [
      'models/gemini-1.5-pro-002',
      'models/gemini-1.5-pro-001',
      'models/gemini-1.5-flash',
      'models/gemini-1.5-flash-002',
      'models/gemini-2.0-flash'
    ];

    for (final modelName in alternativeModels) {
      try {
        print('Trying alternative model: $modelName');

        _model = GenerativeModel(
          model: modelName,
          apiKey: APIConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 800,
          ),
        );

        _chat = _model!.startChat(history: [
          Content.text(
              'You are MemoRaid Assistant, specialized in amnesia rehabilitation and memory recovery. '
              'Keep focused on helping people recover lost memories and cope with amnesia.'),
        ]);

        // Test the model with a simple greeting
        final response =
            await _chat!.sendMessage(Content.text('Quick test message'));

        if (response.text != null) {
          print('Successfully connected with model: $modelName');
          setState(() {
            messages.add({
              "sender": "ai",
              "text":
                  "Hello! 👋 I'm MemoRaid Assistant, here to help with amnesia rehabilitation and memory recovery. How can I assist you today?",
              "time": DateTime.now().toString(),
            });
            _isInitializing = false;
            _errorMessage = '';
          });
          return;
        }
      } catch (e) {
        print('Error with model $modelName: $e');
      }
    }

    // If we get here, all models failed
    setState(() {
      _errorMessage =
          'Could not connect to any available AI model. Please try again later.';
      _isInitializing = false;
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
    if (_controller.text.trim().isEmpty || _chat == null) return;

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
      final response = await _chat!.sendMessage(Content.text(userMessage));
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
              backgroundImage: AssetImage("assets/images/memoraid.png"),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MemoRaid Assistant",
                  style: TextStyle(
                    color: Color(0xFF0D3445),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isInitializing
                      ? "Connecting..."
                      : "Amnesia Rehabilitation Support",
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
          onPressed: () {
            // Navigate to HomeScreen01 instead of just popping
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF0D3445)),
            onPressed: () {
              if (_errorMessage.isNotEmpty) {
                _initializeChat();
              } else {
                setState(() => messages.clear());
                if (_chat != null) {
                  setState(() {
                    messages.add({
                      "sender": "ai",
                      "text":
                          "Hello! 👋 I'm MemoRaid Assistant, here to help with amnesia rehabilitation and memory recovery. How can I assist you today?",
                      "time": DateTime.now().toString(),
                    });
                  });
                }
              }
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
        child: _isInitializing
            ? _buildLoadingView()
            : (_errorMessage.isNotEmpty ? _buildErrorView() : _buildChatView()),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitDoubleBounce(
            color: Colors.white,
            size: 60,
          ),
          SizedBox(height: 24),
          Text(
            "Connecting to MemoRaid Assistant...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Your amnesia rehabilitation companion",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 70,
            ),
            SizedBox(height: 24),
            Text(
              "Connection Error",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text("Try Again"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF0D3445),
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _initializeChat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
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
                        _buildAvatar("assets/images/memoraid.png"),
                      SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser ? Color(0xFF0D3445) : Colors.white,
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
                                  color:
                                      isUser ? Colors.white : Color(0xFF0D3445),
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
                      if (isUser) _buildAvatar("assets/images/no.png"),
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
                _buildAvatar("assets/images/memoraid.png"),
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
                        hintText: "Ask about amnesia rehabilitation...",
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
