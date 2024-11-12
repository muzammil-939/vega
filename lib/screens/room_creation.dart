import 'package:flutter/material.dart';

class RoomCreation extends StatefulWidget {
  const RoomCreation({super.key});

  @override
  State<RoomCreation> createState() => _RoomCreationState();
}

class _RoomCreationState extends State<RoomCreation> {
  bool isPasswordVisible = false;
  String roomType = 'Open Chat'; // Default selected room type

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CREATE A GAME ROOM',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'ROOM NAME',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter room name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0, // Increased height
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ICON/BANNER',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Handle image upload here
                print('Upload from mobile tapped');
              },
              child: const Text(
                'Upload from mobile',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Or',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0, // Increased height
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'PASSWORD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Enter password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0, // Increased height
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ROOM TYPE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Open Chat'),
                    leading: Radio<String>(
                      value: 'Open Chat',
                      groupValue: roomType,
                      onChanged: (value) {
                        setState(() {
                          roomType = value!;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Game Room'),
                    leading: Radio<String>(
                      value: 'Game Room',
                      groupValue: roomType,
                      onChanged: (value) {
                        setState(() {
                          roomType = value!;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenHeight * 0.06,
                width: screenWidth * 0.7,
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
                      'CREATE A ROOM',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff025253),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
