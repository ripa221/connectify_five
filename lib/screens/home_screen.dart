import 'package:flutter/material.dart';
import 'contacts_page.dart';
import 'profile_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundhomepage.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground content: Centered button column
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contacts Button
                  _buildHomeButton(
                    label: "Contacts",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ContactsPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // Profile Button
                  _buildHomeButton(
                    label: "Profile",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Creates a styled button with a common look
  Widget _buildHomeButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity, // Button stretches across available width
      child: ElevatedButton(
        //onPressed: onPressed,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.85), // Button background
          foregroundColor: Colors.black, // Text color
          padding: const EdgeInsets.symmetric(vertical: 20), // Height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
