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
  String? _uid;
  bool _isEditing = false; // Controls if the username is being edited
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;
  final _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final uid = currentUser.uid;

      try {
        setState(() {
          _isLoading = true;
        });

        // Fetch username
        final usernameSnapshot =
            await _databaseRef.child('users/$uid/username').get();
        if (usernameSnapshot.exists) {
          setState(() {
            _username = usernameSnapshot.value as String?;
          });
        }

        // Fetch UID from 'users/$uid/uid'
        final uidSnapshot = await _databaseRef.child('users/$uid/uid').get();
        if (uidSnapshot.exists) {
          setState(() {
            _uid = uidSnapshot.value as String?;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch user data: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final uid = currentUser.uid;

      try {
        setState(() {
          _isLoading = true;
        });

        await _databaseRef.child('users/$uid').update({
          'username': _usernameController.text.trim(),
        });

        setState(() {
          _username = _usernameController.text.trim();
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update username: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
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
                  SizedBox(height: screenHeight * 0.03),
                  // Display username and allow editing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isEditing)
                        SizedBox(
                          width: screenWidth * 0.6,
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Edit Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                            ),
                          ),
                        )
                      else
                        Text(
                          _username ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      IconButton(
                        icon: Icon(_isEditing ? Icons.check : Icons.edit),
                        onPressed: () {
                          if (_isEditing) {
                            _updateUsername();
                          } else {
                            setState(() {
                              _isEditing = true;
                              _usernameController.text = _username ?? '';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (_uid != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'UID: $_uid',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
