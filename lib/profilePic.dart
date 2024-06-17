import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureUploaderWidget extends StatefulWidget {
  final Function(File) onPictureSelected;

  const ProfilePictureUploaderWidget(
      {Key? key, required this.onPictureSelected})
      : super(key: key);

  @override
  _ProfilePictureUploaderWidgetState createState() =>
      _ProfilePictureUploaderWidgetState();
}

class _ProfilePictureUploaderWidgetState
    extends State<ProfilePictureUploaderWidget> {
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: source); 

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        widget.onPictureSelected(_imageFile!);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_imageFile != null)
          Image.file(
            _imageFile!,
            width: 100.0,
            height: 100.0,
            fit: BoxFit.cover,
          )
        else
          Placeholder(
            fallbackWidth: 100.0,
            fallbackHeight: 100.0,
          ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfilePictureWidget extends StatelessWidget {
  final String imageUrl;
  final double size;

  const ProfilePictureWidget({
    Key? key,
    required this.imageUrl,
    this.size = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : Container(
              width: size,
              height: size,
              color: Colors.grey,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: size * 0.6,
              ),
            ),
    );
  }
}
