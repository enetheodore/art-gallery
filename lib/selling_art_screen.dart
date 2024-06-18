import 'dart:io';
import 'package:art_gallery_app/gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(SellingArtScreen());
}

class SellingArtScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Art Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UploadScreen(),
    );
  }
}

class UploadScreen extends StatefulWidget {
  
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  
  File? _image;
  final picker = ImagePicker();
  TextEditingController _descriptionController = TextEditingController();
  
    late final int userId;


  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImage() async {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/api/upload'),
    );
    request.fields['description'] = _descriptionController.text;
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();

    if (response.statusCode == 201) {
      print('Image uploaded successfully');
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GalleryScreen(userId: userId)),
    );
    } else {
      print('Failed to upload image');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Art'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _image != null
                ? Image.file(
                    _image!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                : Placeholder(
                    fallbackHeight: 200,
                    fallbackWidth: 200,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _image != null ? uploadImage : null,
              child: Text('Upload Art'),
            ),
          ],
        ),
      ),
    );
  }
}
