import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/micprovider.dart';

class Room extends ConsumerStatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  ConsumerState<Room> createState() => _RoomState();
}

class _RoomState extends ConsumerState<Room> {
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

    // Access the provider via `ref.read`
    final micNotifier = ref.read(micStateProvider.notifier);
    micNotifier.initialize();

    _initializeChatSession();

    _fetchOrCreateUserName().then((_) {
      _initializeAvatars();
    });
    _cleanupMicsOnExit();
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

  /// Clear user messages
  void _clearUserMessages() {
    final senderId = _auth.currentUser?.uid;

    if (senderId != null && _sessionRef != null) {
      // Clear messages in Firebase Realtime Database
      _sessionRef!.once().then((snapshot) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          for (var entry in data.entries) {
            final message = entry.value as Map<dynamic, dynamic>;
            if (message['senderId'] == senderId) {
              _sessionRef!.child(entry.key).remove();
            }
          }
        }
      });

      // Clear messages locally
      setState(() {
        _messages.removeWhere((message) => message['senderId'] == senderId);
      });
    }
  }

  /// Clean up mic assignments when exiting the screen
  void _cleanupMicsOnExit() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final micNotifier = ref.read(micStateProvider.notifier);

      for (int i = 0; i < 10; i++) {
        // Iterate over all mics
        final micRef = FirebaseDatabase.instance.ref('mic_assignments/mic_$i');

        final snapshot = await micRef.get();
        final data = snapshot.value as Map<dynamic, dynamic>?;

        if (data != null && data['userId'] == userId) {
          await micRef.remove(); // Remove the mic assignment in the database

          // Reset the mic state locally
          micNotifier.releaseMic(i); // Notify the provider
        }
      }
    }
  }

  /// Show a confirmation dialog
  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Exit Chat'),
              content: const Text(
                  'Are you sure you want to exit and clear your chat history?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
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
          child: CircleAvatar(child: Icon(Icons.image)),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
        onWillPop: () async {
          final shouldLeave = await _showExitConfirmationDialog();
          if (shouldLeave) {
            _clearUserMessages();
            _cleanupMicsOnExit();
          }
          return shouldLeave;
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/15.jpg'), // Path to your image
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
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
                            borderRadius: BorderRadius.circular(50),
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
                const SizedBox(height: 15),

                // Microphone UI
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    child: GridView.count(
                      shrinkWrap:
                          true, // Ensures GridView takes only as much space as needed
                      crossAxisCount: 4, // Number of columns in the grid

                      children: List.generate(
                        8, // Total number of mic containers
                        (index) => buildMicContainer(index),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Chat UI
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      reverse:
                          true, // Makes the scroll view start from the bottom
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
                                        style: const TextStyle(
                                            color: Colors.white),
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
                          icon:
                              const Icon(Icons.send, color: Colors.blueAccent),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build mic container or avatar if tapped
  Widget buildMicContainer(int index) {
    final micStates = ref.watch(micStateProvider);
    final micState = micStates[index];
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if mic is occupied
    if (micState.userId != null) {
      // Get avatar for the user
      final assignedAvatar = _assignAvatarForUser(micState.userName!);
      return Stack(
        alignment: Alignment.center,
        children: [
          assignedAvatar, // Use the avatar assigned to the user
          Positioned(
            bottom: 4,
            child: Text(
              micState.userName!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      );
    }

    // Default mic container
    return GestureDetector(
      onTap: () async {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        final userName = _userName; // Use the username initialized earlier

        if (userId != null && userName != null) {
          final micNotifier = ref.read(micStateProvider.notifier);

          // Step 1: Find and release the mic currently occupied by this user
          for (int i = 0; i < ref.watch(micStateProvider).length; i++) {
            final mic = ref.watch(micStateProvider)[i];
            if (mic.userId == userId) {
              await micNotifier.releaseMic(i); // Release the current mic
              break; // Exit the loop once the mic is released
            }
          }

          // Step 2: Assign the new mic
          await micNotifier.assignMic(index, userId, userName);

          // Step 3: Trigger a UI rebuild
          setState(() {});
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: screenWidth * 0.13,
          height: screenWidth * 0.13,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(Icons.mic, color: Colors.white),
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
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Image.asset(
            'assets/images/gold-frame.png',
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
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
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Image.asset(
            'assets/images/decorative-round.png',
            width: screenWidth * 0.155,
            height: screenWidth * 0.155,
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
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Image.asset(
            'assets/images/gold-frame.png',
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
