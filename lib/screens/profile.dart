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

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Load the username from the database when the widget initializes.
  }

  Future<void> _loadUsername() async {
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final uid = currentUser.uid;

      try {
        // Fetch the username from Firebase
        final snapshot = await _databaseRef.child('users/$uid/username').get();
        if (snapshot.exists) {
          setState(() {
            _username = snapshot.value as String?;
          });
        }
      } catch (e) {
        print("Failed to fetch username: $e");
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitUsername() async {
    if (_usernameController.text.isNotEmpty) {
      setState(() {
        _username = _usernameController.text;
      });

      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final uid = currentUser.uid;

        try {
          await _databaseRef.child('users/$uid').update({
            'username': _usernameController.text,
          });

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
          ],
        ),
      ),
    );
  }

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
