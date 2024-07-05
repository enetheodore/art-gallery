// import 'dart:io';
// import 'package:art_gallery_app/buildPage.dart';
// import 'package:art_gallery_app/gallery_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class SellingArtScreen extends StatelessWidget {
//   const SellingArtScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Art Upload',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         textTheme: const TextTheme(
//           headlineLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//           //headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//           bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
//         ),
//       ),
//       home: const UploadScreen(),
//     );
//   }
// }

// class UploadScreen extends StatefulWidget {
//   const UploadScreen({Key? key}) : super(key: key);

//   @override
//   _UploadScreenState createState() => _UploadScreenState();
// }

// class _UploadScreenState extends State<UploadScreen> {
//   File? _image;
//   final picker = ImagePicker();
//   final TextEditingController _descriptionController = TextEditingController();
  

//   Future<void> getImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   Future<void> uploadImage() async {
//     if (_image == null) {
//       print('No image selected.');
//       return;
//     }

//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('http://localhost:8000/api/upload'),
//     );
//     request.fields['description'] = _descriptionController.text;
//     request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

//     var response = await request.send();

//     if (response.statusCode == 201) {
//       print('Image uploaded successfully');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => GalleryScreen(userId: 0)),
//       );
//     } else {
//       print('Failed to upload image');
//       // Handle error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         shadowColor: Colors.black,
//         backgroundColor: Colors.blueGrey,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         title: const Text('Upload Art'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _image != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: Image.file(
//                       _image!,
//                       height: 200,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   )
//                 : Container(
//                     height: 200,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     child: Icon(
//                       Icons.image,
//                       color: Colors.grey[800],
//                       size: 100,
//                     ),
//                   ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: getImage,
//               icon: const Icon(Icons.photo_library),
//               label: const Text('Select Image'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueGrey,
//                 foregroundColor: Colors.white,
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 12.0),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: TextField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 4,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _image != null ? uploadImage : null,
//               child: const Text('Upload Art'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent,
//                 foregroundColor: Colors.white,
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 12.0),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:art_gallery_app/buildPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'gallery_screen.dart'; // Adjust this import based on your project structure

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> getImage() async {
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
        MaterialPageRoute(builder: (context) => BottomPage(userId: 1)),
      );
    } else {
      print('Failed to upload image');
      // Handle error
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle if user is not authenticated
      print('User not authenticated');
      return;
    }

    try {
      final String imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child('images/$imageName');
      await storageRef.putFile(_image!);

      final String imageUrl = await storageRef.getDownloadURL();

      // Now you can save the image URL and description to Firestore or Realtime Database
      // Example: Saving to Firestore
      await FirebaseFirestore.instance.collection('arts').add({
        'imageUrl': imageUrl,
        'description': _descriptionController.text,
        'userId': currentUser.uid, // Include user ID for ownership
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Image uploaded successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GalleryScreen(userId: currentUser.uid)),
      );
    } catch (error) {
      print('Failed to upload image: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Art'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.file(
                      _image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 100,
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: getImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Select Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _image != null ? uploadImage : null,
              child: const Text('Upload Art'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

