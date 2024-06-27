import 'dart:convert';
import 'package:art_gallery_app/gallery_screen.dart';
import 'package:art_gallery_app/login_screen.dart';
import 'package:art_gallery_app/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(ArtGalleryApp());
}

class ArtGalleryApp extends StatelessWidget {
  

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
