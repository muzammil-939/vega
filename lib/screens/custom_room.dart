import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CustomRoom extends StatefulWidget {
  final String roomName;
  final XFile? roomImage;

  const CustomRoom({
    Key? key,
    required this.roomName,
    this.roomImage,
  }) : super(key: key);

  @override
  _CustomRoomState createState() => _CustomRoomState();
}

class _CustomRoomState extends State<CustomRoom> {
  late ValueNotifier<String> _currentRoomName;
  late ValueNotifier<XFile?> _currentRoomImage;

  @override
  void initState() {
    super.initState();
    // Initialize the notifiers with the passed values
    _currentRoomName = ValueNotifier<String>(widget.roomName);
    _currentRoomImage = ValueNotifier<XFile?>(widget.roomImage);
  }

  @override
  void dispose() {
    _currentRoomName.dispose();
    _currentRoomImage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: ValueListenableBuilder<String>(
          valueListenable: _currentRoomName,
          builder: (context, roomName, child) {
            return Text(
              roomName, // Dynamically update room name
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        leading: ValueListenableBuilder<XFile?>(
          valueListenable: _currentRoomImage,
          builder: (context, roomImage, child) {
            return roomImage != null
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: CircleAvatar(
                      backgroundImage: FileImage(
                          File(roomImage.path)), // Dynamically update avatar
                    ),
                  )
                : const CircleAvatar(
                    child: Icon(Icons.image, color: Colors.white),
                  );
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: [
              // Remaining UI
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
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.025),
                width: screenWidth * 0.8,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildMicButton(),
                        buildMicButton(),
                        buildMicButton(),
                        buildMicButton(),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.27),
              Container(
                height: screenHeight * 0.25,
                width: screenWidth * 0.95,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 14.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
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
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMicButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.13,
      height: screenWidth * 0.13,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Icon(Icons.mic),
    );
  }
}
