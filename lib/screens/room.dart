import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';

class Room extends StatefulWidget {
  const Room({super.key});

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref('chat/messages');
  final List<Map<String, String>> _messages = []; // For local display purpose

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  // Listen to Firebase Realtime Database for new messages
  void _listenToMessages() {
    _messagesRef.onChildAdded.listen((event) {
      final messageData = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _messages.add({
          'sender': messageData['sender'],
          'text': messageData['message'],
        });
      });
    });
  }

  // Method to send the message and get bot response
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;

      // Debug: Print the message to verify
      print("User message: $userMessage");

      // Store user's message in Firebase Realtime Database
      await _storeMessageInDatabase(userMessage, 'user');

      // Show loading indicator while waiting for the response
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Typing...'});
      });

      // Get bot response
      final response = await _getBotResponse(userMessage);

      // Remove 'Typing...' and add actual bot response
      setState(() {
        _messages.removeLast();
        _messages.add({'sender': 'bot', 'text': response});
      });

      // Store bot's response in Firebase Realtime Database
      await _storeMessageInDatabase(response, 'bot');

      // Clear the input field
      _controller.clear();
    }
  }

  // Store message in Firebase Realtime Database
  Future<void> _storeMessageInDatabase(String message, String sender) async {
    final messageData = {
      'message': message,
      'sender': sender,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _messagesRef.push().set(messageData);
  }

  // Method to call Firebase Function for bot response with error handling
  Future<String> _getBotResponse(String message) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('chatBotResponse');
      print("Sending message to Firebase: $message");
      final response = await callable.call({'message': message});
      return response.data['text'] ?? "Error: No response from bot.";
    } catch (e) {
      print("Error: $e");
      return "Error: Could not get response from the bot.";
    }
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
          'Default Room',
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
                  final isUser = message['sender'] == 'user';
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
                        message['text']!,
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
