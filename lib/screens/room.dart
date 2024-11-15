import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Room extends StatefulWidget {
  const Room({super.key});

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  Map<int, Widget> tappedButtons = {}; // Store Widgets
  // bool isAvatarFieldShown = false;
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, String>> _messages = [];
  DatabaseReference? _sessionRef;
  String? _sessionId;
  String? _userName;
  Map<String, Widget> _userAvatars =
      {}; // Map to store avatar widgets for each user
  List<Widget> micButtons = [];
  @override
  void initState() {
    super.initState();
    _initializeChatSession();
    _fetchOrCreateUserName();
    _fetchOrCreateUserName().then((_) {
      _initializeAvatars();
    });
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

  Widget _assignAvatarForUser(String userName) {
    if (!_userAvatars.containsKey(userName)) {
      final avatars = [
        avatarfieldsOne(),
        avatarfieldsTwo(),
        avatarfieldsThree()
      ];
      _userAvatars[userName] = avatars[_userAvatars.length % avatars.length];
    }
    return _userAvatars[userName]!;
  }

  /// Initialize avatars for all users in the chat
  void _initializeAvatars() {
    if (_sessionRef == null) return;

    _sessionRef!.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return;

      setState(() {
        for (var entry in data.entries) {
          final senderName = entry.value['sender'] as String;
          _assignAvatarForUser(senderName);
        }
      });
    });
  }

  /// Listen to chat messages for the current session
  void _listenToMessages() {
    if (_sessionRef == null) return;

    _sessionRef!.onChildAdded.listen((event) {
      final messageData = event.snapshot.value as Map<dynamic, dynamic>;
      final senderName = messageData['sender'] as String;

      // Ensure this sender has an avatar assigned
      _assignAvatarForUser(senderName);

      setState(() {
        _messages.add({
          'sender': senderName,
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
        leading: Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: CircleAvatar(child: Image.asset('')),
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
                margin: const EdgeInsets.only(top: 5),
                width: screenWidth * 0.8,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ..._userAvatars.values.map((avatar) => avatar).toList(),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     buildMicButton(4),
                    //     buildMicButton(5),
                    //     buildMicButton(6),
                    //     buildMicButton(7),
                    //   ],
                    //),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.04,
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
                          final userName = message['sender']!;
                          final avatarWidget = _userAvatars[userName];

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isUser)
                                  avatarWidget ??
                                      Container(), // Display avatar if it exists
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Colors.blueAccent
                                        : Colors.grey[700],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${userName}: ${message['text']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
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

  Widget buildMicButton(int index) {
    final screenWidth = MediaQuery.of(context).size.width;

    // If button is tapped, display the avatar
    if (tappedButtons.containsKey(index) && tappedButtons[index] != null) {
      return tappedButtons[index]!;
    }

    // Default mic button
    return GestureDetector(
      onTap: () {
        setState(() {
          // Assign an avatar and store it in the tappedButtons map
          final userName = _userName ?? 'Guest $index'; // Example username
          tappedButtons[index] = _assignAvatarForUser(userName);
        });
      },
      child: Container(
        width: screenWidth * 0.13,
        height: screenWidth * 0.13,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.mic),
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
