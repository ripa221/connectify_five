import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/image_sender_widget.dart'; // Sheikh Rubel's Section: Base64 image picker widget

class ChatPage extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String recipientImage;

  const ChatPage({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.recipientImage,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //final TextEditingController _messageController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    }
  }

  /// ETU Part: Send a plain text message to Firestore
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    await FirebaseFirestore.instance.collection('chats').add({
      'senderId': currentUserId,
      'receiverId': widget.recipientId,
      'message': message,
      'imageBase64': '',
      'timestamp': FieldValue.serverTimestamp(),
      'participants': [currentUserId, widget.recipientId],
    });

    _messageController.clear();
    _scrollToBottom();
  }

  /// Sheikh Rubel's Section: Handle image selection, convert to base64 and store
  void _handleImageSelected(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      await FirebaseFirestore.instance.collection('chats').add({
        'senderId': currentUserId,
        'receiverId': widget.recipientId,
        'message': '',
        'imageBase64': base64Image,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [currentUserId, widget.recipientId],
      });

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send image: \$e")),
      );
    }
  }

  /// ETU Part: Automatically scroll to latest message
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Sheikh Rubel's Section: Load base64 or placeholder image
            CircleAvatar(
              backgroundImage: widget.recipientImage.isNotEmpty
                  ? MemoryImage(base64Decode(widget.recipientImage))
                  : const AssetImage('assets/images/profile_placeholder.jpg')
              as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(widget.recipientName),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Sheikh Rubel's Section: Chat background
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundchatpage.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No messages yet"));
                    }

                    // ETU Part: Filter messages between current user and selected recipient
                    final messages = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['senderId'] == currentUserId &&
                          data['receiverId'] == widget.recipientId) ||
                          (data['senderId'] == widget.recipientId &&
                              data['receiverId'] == currentUserId);
                    }).toList();

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      itemBuilder: (context, index) {
                        final msg = messages[index].data() as Map<String, dynamic>;
                        final isMe = msg['senderId'] == currentUserId;
                        final hasImage = msg['imageBase64'] != null &&
                            msg['imageBase64'].toString().isNotEmpty;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blueAccent : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: hasImage
                                ? Image.memory(
                              base64Decode(msg['imageBase64']),
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                            )
                                : Text(
                              msg['message'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // ETU Part: Message input field with image sending option
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: Colors.grey.shade100.withOpacity(0.85),
                child: Row(
                  children: [
                    ImageSenderWidget(onImageSelected: _handleImageSelected),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.teal),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}