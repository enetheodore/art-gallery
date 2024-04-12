import 'dart:convert';
import 'package:art_gallery_app/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signUp(BuildContext context) async {
    final String baseUrl =
        'http://127.0.0.1:8000/api/register'; // Replace with your Laravel backend URL

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'name': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        // Successful signup
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        // Handle errors
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
      // Handle network errors
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
            
            Text('Signup'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Stack(
            children: [
              Image.asset(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                'assets/images/bmw.png',
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
                      children: [
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
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => signUp(context),
                          child: Text('Sign Up'),
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

class ImageDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Details'),
      ),
      body: Center(
        child: Text('Image Details Screen'),
      ),
    );
  }
}
