import 'dart:convert';
import 'dart:io';
import 'package:art_gallery_app/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  File? _profileImage;
  final picker = ImagePicker();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole;

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

  Future<void> signUp(BuildContext context) async {
    final String baseUrl = 'http://127.0.0.1:8000/api/register1';

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'name': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'role': selectedRole ?? 'buyer',
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        final userId = jsonDecode(response.body)['user']['id'];
        if (_profileImage != null) {
          await uploadProfilePicture(userId);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        print('Failed to sign up. Response body: ${response.body}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to sign up. Please try again.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Sign up error: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Network error. Please check your connection.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> uploadProfilePicture(int userId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/upload_profile_picture'),
      );
      request.fields['userId'] = userId.toString();
      request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', _profileImage!.path));

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: pickProfileImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : AssetImage('assets/images/placeholder.png')
                              as ImageProvider,
                      child: _profileImage == null
                          ? Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: 'seller',
                        groupValue: selectedRole,
                        onChanged: (String? value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                      Text('seller'),
                      Radio<String>(
                        value: 'buyer',
                        groupValue: selectedRole,
                        onChanged: (String? value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                      Text('buyer'),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => signUp(context),
                    child: Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
