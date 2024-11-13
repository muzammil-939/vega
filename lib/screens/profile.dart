import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _imageFile;
  final _usernameController = TextEditingController();
  String? _username;
  final _auth = FirebaseAuth.instance;
  final _databaseRef = FirebaseDatabase.instance.ref();

  // Method to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Method to handle username submission and update the Realtime Database
  Future<void> _submitUsername() async {
    if (_usernameController.text.isNotEmpty) {
      setState(() {
        _username = _usernameController.text;
      });

      // Get the current user's UID
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final uid = currentUser.uid;

        // Update the Realtime Database with the username
        try {
          await _databaseRef.child('users/$uid').update({
            'username': _usernameController.text,
          });

          // Clear the TextField after updating
          _usernameController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username updated successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update username: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SizedBox(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showImageSourceSelector(context),
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? const Icon(Icons.add_a_photo, size: 30)
                    : null,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.06,
            ),
            // Check if the username is entered
            if (_username == null) ...[
              SizedBox(
                width: screenWidth * 0.6,
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              ElevatedButton(
                onPressed: _submitUsername,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[900]),
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ] else
              // Display the entered username under the profile picture
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  _username!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Stack(
            //   alignment: Alignment.center,
            //   children: [
            //     // Frame as a background
            //     Container(
            //       width: 130,
            //       height: 130,
            //       decoration: BoxDecoration(
            //         border: Border.all(
            //           color: Colors.green,
            //           width: 5,
            //         ),
            //         shape: BoxShape.circle,
            //       ),
            //     ),
            //     // Image inside the frame
            //     CircleAvatar(
            //       radius: 60,
            //       backgroundImage:
            //           _imageFile != null ? FileImage(_imageFile!) : null,
            //       child: _imageFile == null
            //           ? const Icon(Icons.add_a_photo, size: 30)
            //           : null,
            //     ),
            //     // CircleAvatar(
            //     //     radius: 60,
            //     //     backgroundImage:
            //     //         AssetImage('assets/images/man-sample.png')),
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  // Show a dialog to choose the image source
  void _showImageSourceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.of(ctx).pop();
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.of(ctx).pop();
              _pickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }
}
