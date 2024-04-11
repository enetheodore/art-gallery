import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ArtDescriptionScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String artist;
  final String description;

  ArtDescriptionScreen({
    required this.imageUrl,
    required this.title,
    required this.artist,
    required this.description,
  });

  Future<List<String>> fetchImagePathsFromDirectory() async {
    List<String> imagePaths = [];

    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String uploadsPath = '${appDocDirectory.path}/uploads';

    Directory uploadsDirectory = Directory(uploadsPath);
    if (uploadsDirectory.existsSync()) {
      var files = uploadsDirectory.listSync();
      for (var file in files) {
        if (file is File &&
            (file.path.endsWith('.png') || file.path.endsWith('.jpg'))) {
          imagePaths.add(file.path);
        }
      }
    }

    return imagePaths;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            Image.network(
              height: MediaQuery.of(context).size.height*0.6,
              imageUrl,
              fit: BoxFit.scaleDown,
            ),
            SizedBox(height: 16.0),
            Text(
              'Artist: $artist',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Description: $description',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
