import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class ProfileImagePicker {
  // Main method to show image source options
  static Future<void> showImageSourceBottomSheet({
    required BuildContext context,
    required Function(File?) onImageSelected,
    required Function(Uint8List?) onWebImageSelected,
  }) async {
    if (kIsWeb) {
      // For web, directly pick from gallery since camera access is limited
      _pickImage(
        source: ImageSource.gallery, 
        onImageSelected: onImageSelected,
        onWebImageSelected: onWebImageSelected,
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 220,
          child: Column(
            children: [
              // Bottom sheet handle
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Title
              const Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              // Options row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera option
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      _pickImage(
                        source: ImageSource.camera,
                        onImageSelected: onImageSelected,
                        onWebImageSelected: onWebImageSelected,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  // Gallery option
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      _pickImage(
                        source: ImageSource.gallery,
                        onImageSelected: onImageSelected,
                        onWebImageSelected: onWebImageSelected,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper to build each option button
  static Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF4C4127)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Image picker method
  static Future<void> _pickImage({
    required ImageSource source,
    required Function(File?) onImageSelected,
    required Function(Uint8List?) onWebImageSelected,
  }) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, read as bytes
          final bytes = await pickedFile.readAsBytes();
          onWebImageSelected(bytes);
        } else {
          // For mobile platforms
          onImageSelected(File(pickedFile.path));
        }
      } else {
        // No image selected/captured
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
}

// Example usage in your profile screen:
/*
// In your state class:
File? _profileImage;
Uint8List? _webImage;

// Method to show the picker
void _openImagePicker() {
  ProfileImagePicker.showImageSourceBottomSheet(
    context: context,
    onImageSelected: (File? image) {
      setState(() {
        _profileImage = image;
      });
    },
    onWebImageSelected: (Uint8List? bytes) {
      setState(() {
        _webImage = bytes;
      });
    },
  );
}

// To get the image provider:
ImageProvider _getProfileImage() {
  if (kIsWeb && _webImage != null) {
    return MemoryImage(_webImage!);
  } else if (!kIsWeb && _profileImage != null) {
    return FileImage(_profileImage!);
  } else {
    return const AssetImage('assets/default_profile.png');
  }
}
*/
