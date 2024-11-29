import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class RoomCreation extends StatefulWidget {
  final Function(String name, File? image) onRoomCreated;
  const RoomCreation({super.key, required this.onRoomCreated});

  @override
  State<RoomCreation> createState() => _RoomCreationState();
}

class _RoomCreationState extends State<RoomCreation> {
  bool isRoomCreated = false;
  String roomName = '';
  String roomType = 'Open Chat';
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  final TextEditingController roomNameController = TextEditingController();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref('rooms');
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('room_images')
          .child('$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> _loadRoomData() async {
    final snapshot = await dbRef.child(userId).get();
    if (snapshot.exists) {
      final roomData = snapshot.value as Map;
      setState(() {
        isRoomCreated = true;
        roomName = roomData['roomName'] ?? '';
        imageUrl = roomData['imageUrl'];
        _selectedImage =
            null; // Clear local image since we're displaying from the URL
      });
    }
  }

  Future<void> _saveRoomData() async {
    String? uploadedImageUrl;
    if (_selectedImage != null) {
      final File imageFile = File(_selectedImage!.path);
      uploadedImageUrl = await _uploadImageToFirebase(imageFile);
    }

    final Map<String, dynamic> roomData = {
      'roomName': roomNameController.text,
      'imageUrl': uploadedImageUrl ??
          imageUrl, // Keep the existing image if not updated
    };

    await dbRef.child(userId).set(roomData);
    setState(() {
      isRoomCreated = true;
      roomName = roomNameController.text;
      imageUrl = uploadedImageUrl ?? imageUrl;
      _selectedImage = null;
    });
  }

  // Show bottom sheet for image selection
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedImage =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  setState(() {
                    _selectedImage = pickedImage;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedImage =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedImage != null) {
                  setState(() {
                    _selectedImage = pickedImage;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "ROOM CREATION",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                    if (!isRoomCreated)
                      TextField(
                        controller: roomNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter room name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 20.0,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              roomName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () {
                              setState(() {
                                isRoomCreated =
                                    false; // Allow editing room name
                                roomNameController.text = roomName;
                              });
                            },
                          ),
                        ],
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
                    if (_selectedImage != null)
                      Row(
                        children: [
                          Expanded(
                            child: Image.file(
                              File(_selectedImage!.path),
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: _showImageSourceSheet,
                          ),
                        ],
                      )
                    else if (imageUrl != null)
                      Row(
                        children: [
                          Expanded(
                            child: Image.network(
                              imageUrl!,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: _showImageSourceSheet,
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: const Text(
                          'Upload from mobile',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  onPressed: () async {
                    await _saveRoomData();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(107),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Center(
                    child: Text(
                      'SAVE',
                      style: const TextStyle(
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
