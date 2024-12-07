import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/micprovider.dart';

class CustomRoom extends ConsumerStatefulWidget {
  final String? roomId;
  final String roomName;
  final String roomImage;

  const CustomRoom({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.roomImage,
  });

  @override
  ConsumerState<CustomRoom> createState() => _CustomRoomState();
}

class _CustomRoomState extends ConsumerState<CustomRoom> {
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

    final micNotifier = ref.read(micStateProvider.notifier);
    micNotifier.initialize();

    _initializeChatRoom();
    _fetchUsername().then((_) {
      _initializeAvatars();
    });
  }

  Future<void> _fetchUsername() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = FirebaseDatabase.instance.ref('users/$userId');
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists && userSnapshot.child('username').exists) {
      setState(() {
        _username = userSnapshot.child('username').value as String;
      });
    } else {
      setState(() {
        _username = 'unknown user';
      });
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

  Widget _assignAvatar(String username) {
    if (!_userAvatars.containsKey(username)) {
      final avatars = [
        avatarfieldsOne(),
        avatarfieldsTwo(),
        avatarfieldsThree(),
      ]; // Define avatars
      setState(() {
        _userAvatars[username] = avatars[
            _userAvatars.length % avatars.length]; // Cycle through avatars
      });
    }
    return _userAvatars[username]!;
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

  void _clearUserMessages() {
    final senderId = _auth.currentUser?.uid;

    if (senderId != null && _roomRef != null) {
      // Clear messages in Firebase Realtime Database
      _roomRef!.once().then((snapshot) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          for (var entry in data.entries) {
            final message = entry.value as Map<dynamic, dynamic>;
            if (message['senderId'] == senderId) {
              _roomRef!.child(entry.key).remove();
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

  void _assignMic(int index) {
    if (_username == null) return;
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    ref.read(micStateProvider.notifier).assignMic(index, userId, _username!);
  }

  void _releaseMic(int index) {
    ref.read(micStateProvider.notifier).releaseMic(index);
  }

  // void _clearMicAssignment() {
  //   final userId = _auth.currentUser?.uid;
  //
  //   if (userId != null) {
  //     // Iterate through all mic slots to find and remove the user's mic assignment
  //     for (int i = 0; i < 10; i++) {
  //       final micRef = FirebaseDatabase.instance.ref('mic_assignments/mic_$i');
  //       micRef.once().then((snapshot) {
  //         final micData = snapshot.snapshot.value as Map<dynamic, dynamic>?;
  //         if (micData != null && micData['userId'] == userId) {
  //           micRef.remove();
  //         }
  //       });
  //     }
  //   }
  // }
  void _clearMicAssignment() async {
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

    final micStates = ref.watch(micStateProvider);

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
            const SizedBox(width: 10),
            Text(
              widget.roomName,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          final shouldLeave = await _showExitConfirmationDialog();
          if (shouldLeave) {
            _clearUserMessages();
            _clearMicAssignment();
          }
          return shouldLeave;
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/15.jpg'), // Path to your image
              fit: BoxFit
                  .cover, // Ensures the image covers the entire background
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
                      mainAxisSpacing: 10, // Spacing between rows
                      crossAxisSpacing: 10, // Spacing between columns
                      children: List.generate(
                        8, // Total number of mic containers
                        (index) => buildMicContainer(index),
                      ),
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
                              _userAvatars[sender] ?? const SizedBox.shrink(),
                              const SizedBox(width: 8), // Add spacing
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sender,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? Colors.blue
                                          : Colors.grey[700],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${message['text']}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 8), // Add spacing
                              _userAvatars[sender] ?? const SizedBox.shrink(),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
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
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMicContainer(int index) {
    final micStates = ref.watch(micStateProvider);
    final micState = micStates[index];
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if mic is occupied
    if (micState.userId != null) {
      // Get avatar for the user
      final assignedAvatar = _assignAvatar(micState.userName!);
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
        final userName = _username; // Use the username initialized earlier

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
      child: Container(
        width: screenWidth * 0.13,
        height: screenWidth * 0.13,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.mic, color: Colors.white),
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
          margin: const EdgeInsets.symmetric(horizontal: 10),
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
          margin: const EdgeInsets.symmetric(horizontal: 10),
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
          margin: const EdgeInsets.symmetric(horizontal: 10),
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
