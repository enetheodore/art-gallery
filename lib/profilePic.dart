import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfilePictureUploaderWidget extends StatefulWidget {
  final Function(File) onPictureSelected;

  const ProfilePictureUploaderWidget({
    Key? key,
    required this.onPictureSelected,
  }) : super(key: key);

  @override
  _ProfilePictureUploaderWidgetState createState() =>
      _ProfilePictureUploaderWidgetState();
}

class _ProfilePictureUploaderWidgetState
    extends State<ProfilePictureUploaderWidget> {
  File? _imageFile;
  File? _profileImage;
  final picker = ImagePicker();

  Future<void> pickProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadProfilePicture() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/upload_profile_picture'),
      );
      request.fields['userId'] = toString();
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        _profileImage!.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Profile picture uploaded successfully');
      } else {
        print('Failed to upload profile picture: ${response.reasonPhrase}');
        response.stream.transform(utf8.decoder).listen((value) {
          print('Server response: $value');
        });
      }
    } catch (error) {
      print('Upload error: $error');
    }
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
              onPressed: () => uploadProfilePicture(),
            ),
            IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: () => pickProfileImage(),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfilePictureWidget extends StatefulWidget {
  final String imageUrl;
  final double size;

  const ProfilePictureWidget({
    Key? key,
    required this.imageUrl,
    this.size = 100.0,
  }) : super(key: key);

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  List<Map<String, dynamic>> arts = [];
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    fetchArtsDataFromServer();
  }

  Future<void> fetchArtsDataFromServer() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8000/api/arts'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        final List<String> fetchedImagePaths = [];
        final List<Map<String, dynamic>> fetchedArts = [];

        for (final item in responseData) {
          fetchedImagePaths.add(item['image_path']);
          fetchedArts.add(item);
        }

        setState(() {
          imagePaths = fetchedImagePaths;
          arts = fetchedArts;
        });
      } else {
        print('Failed to fetch arts data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching arts data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: widget.imageUrl.isNotEmpty
          ? Image.network(
              widget.imageUrl,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
            )
          : Container(
              width: widget.size,
              height: widget.size,
              color: Colors.grey,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: widget.size * 0.6,
              ),
            ),
    );
  }
}
