import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart'; // Import your chat page

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    //final currentUser = FirebaseAuth.instance.currentUser;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Contacts")),
      body: Stack(
        children: [
          // Background image for the contacts screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundcontactspage.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground: list of other users fetched from Firestore
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No contacts found"));
              }

              // All users in Firestore
              final allUsers = snapshot.data!.docs;

              // Exclude the currently logged-in user
              final filteredUsers = allUsers.where((doc) => doc.id != currentUser?.uid).toList();

              return ListView.separated(
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index].data() as Map<String, dynamic>;
                  final name = user['name'] ?? 'Unknown';
                  final email = user['email'] ?? 'No Email';
                  final profilePicBase64 = user['profilePic'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: profilePicBase64.isNotEmpty
                          ? MemoryImage(base64Decode(profilePicBase64))
                          : const AssetImage('assets/images/profile_placeholder.jpg')
                      as ImageProvider,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      email,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      // Navigate to the ChatPage with the selected user's info
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            recipientId: filteredUsers[index].id,
                            recipientName: name,
                            recipientImage: profilePicBase64,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
