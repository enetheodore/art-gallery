import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadImageScreen extends StatefulWidget {
  final Function(String) onDescriptionUploaded;
  final String filePath;
  final String fileName;

  UploadImageScreen({
    required this.onDescriptionUploaded,
    required this.filePath,
    required this.fileName,
  });

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  bool _uploading = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    // Cancel any ongoing asynchronous operations
    super.dispose();
  }

  void _uploadArt() async {
    if (!_uploading) {
      setState(() {
        _uploading = true;
      });

      try {
        // Perform the upload operation
        // Simulating an asynchronous operation using Future.delayed
        await Future.delayed(Duration(seconds: 2));

        if (mounted) {
          // Check if the widget is still mounted before accessing the context
          String uploadedDescription = _descriptionController.text;
          widget.onDescriptionUploaded(uploadedDescription);

          Navigator.pop(context); // Go back to the gallery screen after upload
        }
      } catch (error) {
        // Handle any errors that occur during the upload
        print('Upload failed: $error');
      } finally {
        if (mounted) {
          // Check if the widget is still mounted before performing state changes
          setState(() {
            _uploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell Art'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upload Art:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : Text('Choose Image'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadArt,
              child: _uploading ? CircularProgressIndicator() : Text('Upload'),
            ),
            Divider(),
            Text(
              'Description:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter description',
              ),
            ),
          ],
        ),
      ),
    );
  }
}