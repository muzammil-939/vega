import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Room extends StatefulWidget {
  const Room({super.key});

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, String>> _messages = [];
  DatabaseReference? _sessionRef;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _initializeChatSession();
  }

  /// Function to initialize the chat session
  void _initializeChatSession() {
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) return;

    // Set up a global chat session path (e.g., for a public room)
    _sessionId = 'global_chat_room';

    // Reference to the session in Firebase Realtime Database
    _sessionRef =
        FirebaseDatabase.instance.ref('chat/sessions/$_sessionId/messages');

    // Listen to this specific chat session messages
    _listenToMessages();
  }

  /// Listening to the chat messages for the current session
  void _listenToMessages() {
    if (_sessionRef == null) return;

    _sessionRef!.onChildAdded.listen((event) {
      final messageData = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _messages.add({
          'sender': messageData['sender'],
          'text': messageData['message'],
        });
      });
    });
  }

  /// Sending a chat message
  void _sendMessage() async {
    if (_controller.text.isEmpty || _sessionId == null) return;

    final userMessage = _controller.text;
    final senderId = _auth.currentUser?.uid;
    final userName = _auth.currentUser?.displayName ?? 'User';

    if (senderId == null) return;

    // Store user's message in Firebase Realtime Database
    final messageData = {
      'message': userMessage,
      'sender': userName,
      'senderId': senderId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _sessionRef?.push().set(messageData);

    // Clear input field
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Global Chat Room',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Host UI
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Host',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 2,
                        style: BorderStyle.solid,
                        color: const Color(0x33ffffff),
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Microphone UI
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              width: screenWidth * 0.8,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                        4, (index) => Image.asset('assets/images/Mic.png')),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                        4, (index) => Image.asset('assets/images/Mic.png')),
                  ),
                ],
              ),
            ),
          ),

          // Chat UI
          Expanded(
            child: Container(
              height: screenHeight * 0.3,
              padding: const EdgeInsets.all(8.0),
              color: Colors.white.withOpacity(0.1),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['senderId'] == _auth.currentUser?.uid;
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blueAccent : Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${message['sender']}: ${message['text']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Message Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
