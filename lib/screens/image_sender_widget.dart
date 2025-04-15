import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A reusable widget that allows users to select an image from the gallery
/// and sends the selected image file back to the parent widget using a callback.
class ImageSenderWidget extends StatefulWidget {
  /// Callback function to handle the selected image file
  final void Function(File imageFile) onImageSelected;

  const ImageSenderWidget({
    required this.onImageSelected,
    super.key,
  });

  @override
  State<ImageSenderWidget> createState() => _ImageSenderWidgetState();
}

class _ImageSenderWidgetState extends State<ImageSenderWidget> {
  final ImagePicker _picker = ImagePicker();

  /// Opens the image gallery and allows the user to pick a photo.
  /// When a photo is selected, it passes the image file to the parent.
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      widget.onImageSelected(file); // Pass image to parent callback
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.image, color: Colors.blueAccent),
      onPressed: _pickImage, // Trigger image picker when button is tapped
    );
  }
}
