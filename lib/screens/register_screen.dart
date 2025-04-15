import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  // Input controllers for name, email, and password
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Sheikh Rubel's Section: Profile picture selection
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Animations for smooth page load and bounce effect
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Slide animation on enter
    _slideController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    // Bounce animation for logo
    _bounceController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _bounceAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticInOut),
    );

    _slideController.forward();
    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Select profile image
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  /// Convert user-selected file to base64
  Future<String> _convertToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Convert placeholder asset image to base64
  Future<String> _defaultImageToBase64() async {
    final byteData = await DefaultAssetBundle.of(context).load('assets/images/profile_placeholder.jpg');
    return base64Encode(byteData.buffer.asUint8List());
  }

  /// ETU Part: Register user and store info in Firestore
  Future<void> _registerUser() async {
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      // Firebase Authentication
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get base64 string of selected or fallback image
      String profilePic = _imageFile != null
          ? await _convertToBase64(_imageFile!)
          : await _defaultImageToBase64();

      // Save user profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
        'profilePic': profilePic,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/images/backgroundregister.jpg', fit: BoxFit.cover),
          ),

          // Main form layout
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Animated logo
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: Image.asset('assets/images/registerimg.jpg', height: 150),
                  ),

                  const SizedBox(height: 20),

                  // Profile image selection UI
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : const AssetImage('assets/images/profile_placeholder.jpg') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Create Your Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  // Full name input
                  TextField(
                    controller: _fullNameController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Full Name'),
                  ),

                  const SizedBox(height: 20),

                  // Email input
                  TextField(
                    controller: _emailController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Email'),
                  ),

                  const SizedBox(height: 20),

                  // Password input
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Password'),
                  ),

                  const SizedBox(height: 20),

                  // Confirm password input
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Confirm Password'),
                  ),

                  const SizedBox(height: 30),

                  // Register button
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.green,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text("Register"),
                  ),

                  const SizedBox(height: 20),

                  // Already have account? Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.white),
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

  // TextField styling helper
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.black.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }
}
