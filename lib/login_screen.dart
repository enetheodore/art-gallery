import 'dart:convert';
import 'package:art_gallery_app/galleryScreenAdmin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'gallery_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';
  String? selectedRole;

  Future<void> login(BuildContext context) async {
    final String baseUrl = 'http://127.0.0.1:8000/api/login1';
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final int statusCode = response.statusCode;
      print("Response details: ${response.toString()}");
      print("statusCode: ${response.statusCode}");
      print("headers: ${response.headers}");

      if (statusCode >= 400) {
        String errorResponse = response.body;
        print("Error response: $errorResponse");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int? userId = responseData['user']['id'];
        final String? profilePicture = responseData['user']['profile_picture'];
        final String? role = responseData['user']['role'];

        if (userId != null && role != null) {
          if (role == 'seller') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GalleryScreenAdmin(),
              ),
            );
          } else if (role == 'buyer') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GalleryScreen(
                  userId: userId,
                  profilePictureUrl: profilePicture,
                ),
              ),
            );
          } else {
            setState(() {
              message = 'Unknown user role.';
            });
          }
        } else {
          setState(() {
            message = 'Error retrieving user information.';
          });
        }
      } else {
        setState(() {
          message = 'Failed to login. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        message = 'Network error. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Center(
          child: Stack(
            children: [
              Image.asset(
                'assets/images/bmw.png',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.white.withOpacity(0.7),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => login(context),
                            child: Text('Login'),
                          ),
                          SizedBox(height: 10),
                          if (message.isNotEmpty)
                            Text(
                              message,
                              style: TextStyle(color: Colors.red),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Do not have an account?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignupScreen(),
                                    ),
                                  );
                                },
                                child: Text('Signup'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
