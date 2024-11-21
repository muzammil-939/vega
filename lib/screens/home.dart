import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vega/screens/profile.dart';
import 'package:vega/screens/room.dart';
import 'package:vega/screens/room_creation.dart';

import 'custom_room.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> rooms = [];
  final _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadRooms(); // Load rooms from Firebase
  }

  Future<void> _loadRooms() async {
    try {
      final roomsSnapshot = await _databaseRef.child('rooms').get();
      if (roomsSnapshot.exists) {
        final roomsData = Map<String, dynamic>.from(roomsSnapshot.value as Map);
        setState(() {
          rooms = roomsData.entries.map((entry) {
            return {
              'name': entry.value['name'],
              'image': entry.value['image'],
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  Future<void> _addRoomToDatabase(String name, dynamic image) async {
    final roomRef = _databaseRef.child('rooms').push();
    await roomRef.set({
      'name': name,
      'image': image is File ? image.path : image,
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Home
        break;
      case 1:
        // Room Creation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomCreation(
              onRoomCreated: (String name, File? image) async {
                await _addRoomToDatabase(name, image);
                setState(() {
                  rooms.add({'name': name, 'image': image});
                });
              },
            ),
          ),
        );
        break;
      case 2:
        // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        break;
      case 3:
        //Settings
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => SettingsPage()),
        // );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top gradient container with an image
          Container(
            height: screenHeight * 0.46,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffffffff),
                  Color(0xffBDE2E4),
                ],
                stops: [0.8, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Image.asset(
                  'assets/images/most_popular_title.png',
                ),
              ),
            ),
          ),

          // Horizontal scrolling list of popular games
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: _mostPopularGames(context),
                  ),
                ),
              ),
            ),
          ),

          // Bottom section with horizontal ListView of rooms
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.5,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xffffffff),
                    Color(0xffBDE2E4),
                  ],
                  stops: [0.8, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 20),
                      child: Text(
                        "Global Room's",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30, left: 25),
                      width: screenWidth * 0.45,
                      height: screenHeight * 0.24,
                      decoration: BoxDecoration(
                        color: const Color(0x33d5c994),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Container(
                                height: screenHeight * 0.123,
                                width: screenWidth * 0.35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Image.asset(
                                    'assets/images/Rectangle_2.png')),
                          ),
                          SizedBox(
                            width: screenWidth * 0.33,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Global"),
                                const Text(
                                  "#1234",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: screenWidth * 0.35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.person),
                                    Text(
                                        "1/4"), // Update participant count dynamically
                                  ],
                                ),
                                Container(
                                  height: screenHeight * 0.035,
                                  width: screenWidth * 0.19,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromRGBO(37, 152, 158, 100),
                                        Color.fromRGBO(201, 233, 236, 50),
                                        Color.fromRGBO(122, 194, 199, 100),
                                        Color.fromRGBO(37, 152, 158, 100),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(107),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Room()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(107),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text("join"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 20),
                      child: Text(
                        "Custom Room's",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // Horizontal ListView of rooms with height restricted
                          SizedBox(
                            height: screenHeight * 0.28,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: rooms.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 20),
                              itemBuilder: (context, index) {
                                final room = rooms[index];
                                return _buildRoomCard(
                                  context,
                                  room['name'],
                                  room['image'],
                                  screenWidth,
                                  screenHeight,
                                  index, // Pass index here
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xff025253), // Selected icon color
        unselectedItemColor: Colors.grey.shade400, // Unselected icon color
        backgroundColor: const Color(0xffBDE2E4), // Background color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add), // Use cross-swords icon if available
            label: 'Battle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

Widget _mostPopularGames(context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  return SizedBox(
    height: 300,
    child: Stack(
      children: [
        Center(
          child: Container(
            height: screenHeight * 0.23,
            width: screenWidth * 0.4,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFCCE7E8), // Gradient color (Light Blue)
                  Color(0xffffffff), // Gradient color (White)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Game Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '4.5/5',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videogame_asset,
                        color: Colors.black54,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '12.7k',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 40,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(
              Icons.image,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 30,
          child: Container(
            height: screenHeight * 0.035,
            width: screenWidth * 0.23,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(37, 152, 158, 100),
                  Color.fromRGBO(201, 233, 236, 50),
                  Color.fromRGBO(122, 194, 199, 100),
                  Color.fromRGBO(37, 152, 158, 100),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(107),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Perform some action
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Room()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(107),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Center(
                child: Text(
                  'Play',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff025253),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildRoomCard(BuildContext context, String name, dynamic image,
    double screenWidth, double screenHeight, int index) {
  bool isRoomFull =
      false; // Replace this with your actual logic to determine if the room is full

  return Container(
    width: screenWidth * 0.45,
    height: screenHeight * 0.24,
    decoration: BoxDecoration(
      color: const Color(0x33d5c994),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: image is String
              ? Image.asset(
                  image,
                  width: screenWidth * 0.42,
                  height: screenWidth * 0.3,
                )
              : Container(
                  height: screenHeight * 0.123,
                  width: screenWidth * 0.35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.file(
                    image as File,
                    width: screenWidth * 0.42,
                    height: screenWidth * 0.3,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        SizedBox(
          width: screenWidth * 0.33,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name),
              const Text(
                "#1234",
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: screenWidth * 0.35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.person),
                  Text("1/4"), // Update participant count dynamically
                ],
              ),
              Container(
                height: screenHeight * 0.035,
                width: screenWidth * 0.19,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(37, 152, 158, 100),
                      Color.fromRGBO(201, 233, 236, 50),
                      Color.fromRGBO(122, 194, 199, 100),
                      Color.fromRGBO(37, 152, 158, 100),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(107),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (!isRoomFull) {
                      final database = FirebaseDatabase.instance;

                      try {
                        // Check if a room with the same name already exists
                        final roomsRef = database.ref('rooms');
                        final snapshot = await roomsRef
                            .orderByChild('name')
                            .equalTo(name)
                            .get();

                        String? roomId;

                        if (snapshot.exists) {
                          // Use the existing room ID
                          roomId = snapshot.children.first.key;
                          print('Room exists. Using existing roomId: $roomId');
                        } else {
                          // Generate a new room ID and create a new room entry
                          roomId = roomsRef.push().key;
                          if (roomId != null) {
                            print('Creating a new room with roomId: $roomId');
                            await roomsRef.child(roomId).set({
                              'name': name,
                              'image': image is File ? image.path : image,
                              'participants': {}, // Start with no participants
                            });
                          } else {
                            print('Failed to generate a roomId.');
                            return;
                          }
                        }

                        if (roomId != null) {
                          // Navigate to the custom room
                          print(
                              'Navigating to CustomRoom with roomId: $roomId');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomRoom(
                                roomId: roomId,
                                roomName: name,
                                roomImage: image is File ? image.path : image,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error in room creation/joining: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to join/create room: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      // Show an error message if the room is full
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Room $name is currently full.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(107),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(!isRoomFull ? "Join" : "Full"),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
