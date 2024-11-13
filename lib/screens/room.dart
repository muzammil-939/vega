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
  String? _userName; // Store unique username for each user

  @override
  void initState() {
    super.initState();
    _initializeChatSession();
    _fetchOrCreateUserName();
  }

  /// Fetch or create a unique username for the user
  Future<void> _fetchOrCreateUserName() async {
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) return;

    // Reference to the unique username path for this user
    final userRef = FirebaseDatabase.instance.ref('users/$senderId');
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists && userSnapshot.child('username').exists) {
      // If user already has a username, retrieve it
      _userName = userSnapshot.child('username').value as String;
    } else {
      // Generate a unique username based on the current user count
      final userCountRef = FirebaseDatabase.instance.ref('user_count');
      final userCountSnapshot = await userCountRef.get();
      int userNumber =
          userCountSnapshot.exists ? userCountSnapshot.value as int : 0;
      userNumber++;

      // Set username as "user" + userNumber (e.g., "user1")
      _userName = 'user$userNumber';

      // Save this username for the user and update user count
      await userRef.set({'username': _userName});
      await userCountRef.set(userNumber); // Increment global user count
    }
  }

  /// Initialize the chat session
  void _initializeChatSession() {
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) return;

    _sessionId = 'global_chat_room';
    _sessionRef =
        FirebaseDatabase.instance.ref('chat/sessions/$_sessionId/messages');
    _listenToMessages();
  }

  /// Listen to chat messages for the current session
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
    if (_controller.text.isEmpty || _sessionId == null || _userName == null)
      return;

    final userMessage = _controller.text;
    final senderId = _auth.currentUser?.uid;

    if (senderId == null) return;

    // Store user's message in Firebase Realtime Database
    final messageData = {
      'message': userMessage,
      'sender': _userName!,
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
      resizeToAvoidBottomInset: true,
      // This helps to resize when the keyboard appears
      body: SafeArea(
        child: Column(
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
                          4,
                          (index) => Container(
                                width: screenWidth * 0.13,
                                height: screenWidth * 0.13,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(Icons.mic),
                              )),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                          4,
                          (index) => Container(
                                width: screenWidth * 0.13,
                                height: screenWidth * 0.13,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(Icons.mic),
                              )),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.025,
            ),

            // Chat UI
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  reverse: true, // Makes the scroll view start from the bottom
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUser =
                              message['senderId'] == _auth.currentUser?.uid;
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blueAccent
                                    : Colors.grey[700],
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
                    ],
                  ),
                ),
              ),
            ),

            // Message Input
            SafeArea(
              child: Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}
