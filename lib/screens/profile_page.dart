import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import '../screens/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  //final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String email = '';
  String profilePicBase64 = '';
  File? _newImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load user info from Firestore
  Future<void> _loadUserProfile() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final data = snapshot.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        email = data['email'] ?? '';
        profilePicBase64 = data['profilePic'] ?? '';
      });
    }
  }

  // Pick new image from gallery
  Future<void> _pickNewImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _newImage = File(picked.path);
        profilePicBase64 = base64Encode(bytes);
      });
    }
  }

  // Save updated name and base64 image to Firestore
  Future<void> _saveChanges() async {
    Map<String, dynamic> updatedData = {
      'name': _nameController.text.trim(),
    };

    if (profilePicBase64.isNotEmpty) {
      updatedData['profilePic'] = profilePicBase64;
    }

    await FirebaseFirestore.instance.collection('users').doc(user?.uid).update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/images/profilebackground.jpg', fit: BoxFit.cover),
          ),

          // Profile form
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 80),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile image with local preview
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundImage: _newImage != null
                            ? FileImage(_newImage!)
                            : (profilePicBase64.isNotEmpty
                            ? MemoryImage(base64Decode(profilePicBase64))
                            : const AssetImage('assets/images/profile_placeholder.jpg'))
                        as ImageProvider,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: _pickNewImage,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Editable name
                  _isEditing
                      ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  )
                      : Text(
                    _nameController.text,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    email,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),

                  const SizedBox(height: 30),

                  // Edit or Save button
                  _isEditing
                      ? ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text("Save"),
                  )
                      : ElevatedButton(
                    onPressed: () => setState(() => _isEditing = true),
                    child: const Text("Edit Profile"),
                  ),

                  const SizedBox(height: 20),

                  // Sign out button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Sign Out"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
