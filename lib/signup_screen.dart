import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'login_screen.dart';

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

//   
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
        final userId = jsonDecode(response.body)['user']['email'];
        if (_profileImage != null) {
          await uploadProfilePicture(userId);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        print('Failed to sign up. Response body: ${response.body}');
        showErrorDialog(context, 'Failed to sign up. Please try again.');
      }
    } catch (error) {
      print('Sign up error: $error');
      showErrorDialog(context, 'Network error. Please check your connection.');
    }
  }

Future<void> uploadProfilePicture(String userId) async {
  if (_profileImage == null) {
    print('No profile picture selected, skipping upload.');
    return;
  }

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/api/upload_profile_picture'),
    );
    request.fields['userId'] = userId;
    request.files.add(await http.MultipartFile.fromPath(
        'profile_picture', _profileImage!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> parsedResponse = jsonDecode(responseBody);

      if (parsedResponse.containsKey('profilePictureUrl')) {
        String profilePictureUrl = parsedResponse['profilePictureUrl'];
        print('Profile picture uploaded successfully. URL: $profilePictureUrl');
      } else {
        print('Profile picture uploaded, but no URL received');
      }
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

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Center(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey, Colors.blueGrey],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: pickProfileImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.withOpacity(0.5),
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
                        child: _profileImage == null
                            ? Icon(Icons.camera_alt,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(height: 30),
                    Card(
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blueGrey),
                                ),
                              ),
                            ),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blueGrey),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blueGrey),
                                ),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: 10),
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
                                Text('Seller'),
                                Radio<String>(
                                  value: 'buyer',
                                  groupValue: selectedRole,
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedRole = value;
                                    });
                                  },
                                ),
                                Text('Buyer'),
                              ],
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => signUp(context),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blueGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account?'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
