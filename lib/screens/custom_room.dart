import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CustomRoom extends StatefulWidget {
  final String? roomId; // Room ID passed from the previous screen
  final String roomName;
  final String roomImage;

  const CustomRoom({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.roomImage,
  });

  @override
  State<CustomRoom> createState() => _CustomRoomState();
}

class _CustomRoomState extends State<CustomRoom> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final Map<String, Widget> _userAvatars = {};
  late DatabaseReference _roomRef;
  String? _username;
  Map<int, Widget> tappedButtons = {}; // Store Widgets for mic buttons
  List<Widget> micButtons = [];

  @override
  void initState() {
    super.initState();
    _initializeChatRoom();
    _fetchOrCreateUsername().then((_) {
      _initializeAvatars();
    });
  }

  Future<void> _fetchOrCreateUsername() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = FirebaseDatabase.instance.ref('users/$userId');
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists && userSnapshot.child('username').exists) {
      _username = userSnapshot.child('username').value as String;
    } else {
      final userCountRef = FirebaseDatabase.instance.ref('user_count');
      final userCountSnapshot = await userCountRef.get();
      int userNumber =
          userCountSnapshot.exists ? userCountSnapshot.value as int : 0;
      userNumber++;

      _username = 'user$userNumber';
      await userRef.set({'username': _username});
      await userCountRef.set(userNumber);
    }
  }

  void _initializeChatRoom() {
    _roomRef =
        FirebaseDatabase.instance.ref('chat/rooms/${widget.roomId}/messages');

    // Add the current user to the room's /users node
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      // Save user details in the `/users/{userId}` node
      FirebaseDatabase.instance
          .ref('chat/rooms/${widget.roomId}/users/$userId')
          .set({
        'username': _username,
      });
    }

    // Now listen for the users in the room (for avatars)
    _initializeAvatars();
    _listenToMessages();
  }

  void _listenToMessages() {
    _roomRef.onChildAdded.listen((event) {
      final messageData = event.snapshot.value as Map<dynamic, dynamic>;
      final senderName = messageData['sender'] as String;
      final messageText = messageData['message'] as String;

      _assignAvatar(senderName);

      setState(() {
        _messages.add({
          'sender': senderName,
          'text': messageText,
        });
      });
    });
  }

  void _initializeAvatars() {
    final usersRef =
        FirebaseDatabase.instance.ref('chat/rooms/${widget.roomId}/users');

    usersRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return;

      setState(() {
        // assign an avatar
        for (var entry in data.entries) {
          final username = entry.value['username'] as String;
          _assignAvatar(username);
        }
      });
    });
  }

  void _assignAvatar(String username) {
    // Only assign an avatar if it hasn't been assigned yet
    if (!_userAvatars.containsKey(username)) {
      final avatars = [
        avatarfieldsOne(),
        avatarfieldsTwo(),
        avatarfieldsThree()
      ]; // Define avatars
      setState(() {
        _userAvatars[username] = avatars[
            _userAvatars.length % avatars.length]; // Cycle through avatars
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty || _username == null) return;

    final message = {
      'sender': _username!,
      'message': _messageController.text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await _roomRef.push().set(message);

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.roomImage.startsWith('http') ||
                      widget.roomImage.startsWith('https')
                  ? NetworkImage(widget.roomImage) as ImageProvider
                  : FileImage(File(widget.roomImage)),
            ),
            SizedBox(width: 10),
            Text(
              widget.roomName,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Host UI
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
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
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Microphone UI
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 5),
                width: screenWidth * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _userAvatars.values.map((avatar) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: avatar,
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.05),
            // Chat UI
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final sender = message['sender']!;
                    final isCurrentUser = sender == _username;

                    return Row(
                      mainAxisAlignment: isCurrentUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isCurrentUser) ...[
                          _userAvatars[sender] ?? SizedBox.shrink(),
                          SizedBox(width: 8), // Add spacing
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                sender,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.blue
                                      : Colors.grey[700],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${message['text']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrentUser) ...[
                          SizedBox(width: 8), // Add spacing
                          _userAvatars[sender] ?? SizedBox.shrink(),
                        ],
                      ],
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
                      controller: _messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget avatarfieldsOne() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/man-sample-1.png',
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Image.asset(
            'assets/images/gold-frame.png',
            width: screenWidth * 0.17,
            height: screenWidth * 0.17,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget avatarfieldsTwo() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/man-sample-2.png',
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Image.asset(
            'assets/images/decorative-round.png',
            width: screenWidth * 0.175,
            height: screenWidth * 0.175,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget avatarfieldsThree() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/man-sample-3.jpg',
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Image.asset(
            'assets/images/gold-frame.png',
            width: screenWidth * 0.17,
            height: screenWidth * 0.17,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
