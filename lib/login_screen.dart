import 'dart:convert';
import 'package:art_gallery_app/gallery_screen.dart';
import 'package:art_gallery_app/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';

  Future<void> login(BuildContext context) async {
    final String baseUrl = 'http://127.0.0.1:8000/api/login';
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
        // Successful login, navigate to the gallery screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GalleryScreen()),
        );
      } else {
        // Handle login failure
        setState(() {
          message = 'Failed to login. Please try again.';
        });
      }
    } catch (error) {
      // Handle network errors
      setState(() {
        message = 'Network error. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          width: 390,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 51, 102).withOpacity(0.5), // Dark blue
                Colors.transparent,
                Colors.transparent,
                Color.fromARGB(255, 0, 51, 102).withOpacity(0.5), // Dark blue
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue
                    .withOpacity(0.2), // Adjust the shadow color here
                blurRadius: 5.0,
                spreadRadius: 1.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            Text('Login'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.white.withOpacity(0.7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                      ));
                                },
                                child: Text('Signup')),
                          ],
                        ),
                      ],
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
