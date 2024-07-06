import 'dart:convert';
import 'package:art_gallery_app/buildPage.dart';
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
  int index = 0;

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
                builder: (context) => GalleryScreen(userId: ''),
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey, Colors.blueGrey],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Log in to continue',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 50),
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
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.blueGrey),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blueGrey),
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
                                  borderSide: BorderSide(color: Colors.blueGrey),
                                ),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => login(context),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blueGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(fontSize: 18),
                              ),
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
                                  child: Text(
                                    'Signup',
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

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}
