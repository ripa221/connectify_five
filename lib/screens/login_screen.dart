import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // Animation controllers for visual transitions
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Text controllers for user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Toggle for showing/hiding password
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // Slide animation for form
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Bounce animation for logo
    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticInOut,
      ),
    );

    _slideController.forward();
    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ETU Part: Save FCM token in Firestore after successful login
  Future<void> _saveFcmTokenToFirestore(String userId) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  /// ETU Part: Firebase Authentication login function
  Future<void> _loginUser() async {
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save FCM token after successful login
      await _saveFcmTokenToFirestore(result.user!.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful")),
      );

      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
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
            child: Image.asset(
              'assets/images/backgroundloginpage.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Login form UI
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
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
                      child: Image.asset(
                        'assets/images/loginbannerpage.jpg',
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      "Welcome to Connectify",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Email input
                    TextField(
                      controller: _emailController,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Email'),
                    ),

                    const SizedBox(height: 20),

                    // Password input with toggle visibility
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: _loginUser,
                      child: const Text("Login"),
                    ),

                    const SizedBox(height: 20),

                    // Navigation to register screen
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Don’t have an account? Register",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for consistent text input design
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
