import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'art_description_screen.dart';
import 'buy_screen.dart';
import 'galleryScreenAdmin.dart';
import 'selling_art_screen.dart';
import 'profilePic.dart'; // Assuming you have this file for profile picture upload functionality

class GalleryScreen extends StatefulWidget {
  final String userEmail;
  GalleryScreen({required this.userEmail});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, dynamic>> arts = [];
  List<String> imagePaths = [];
  String? profilePictureUrl;

  @override
  void initState() {
    super.initState();
    fetchArtsDataFromServer();
    fetchProfilePicFromServer();
  }

  Future<void> fetchProfilePicFromServer() async {
    try {
      final userEmail = widget.userEmail;
      final response = await http.get(
          Uri.parse('http://127.0.0.1:8000/api/profile_picture/$userEmail'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          profilePictureUrl = responseData['profile_picture'];
        });
      } else if (response.statusCode == 404) {
        print('Profile picture not found for user with email: $userEmail');
      } else {
        print(
            'Failed to fetch profile picture. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching profile picture: $error');
    }
  }

  Future<void> fetchArtsDataFromServer() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8000/api/arts'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        final List<String> fetchedImagePaths = [];
        final List<Map<String, dynamic>> fetchedArts = [];

        for (final item in responseData) {
          fetchedImagePaths.add(item['image_path']);
          fetchedArts.add(item);
        }

        setState(() {
          imagePaths = fetchedImagePaths;
          arts = fetchedArts;
        });
      } else {
        print('Failed to fetch arts data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching arts data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Art Gallery'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryScreenAdmin()),
              );
            },
            icon: Icon(Icons.admin_panel_settings),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: profilePictureUrl != null
                  ? Image.network(
                      'http://localhost:8000/$profilePictureUrl',
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.person, size: 100),
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Sell Art'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellingArtScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePictureUploaderWidget(
                      onPictureSelected: (File imageFile) {
                        // Handle the selected profile picture here (e.g., upload to server)
                      },
                    ),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                // Implement logout functionality
              },
            ),
          ],
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: arts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtDescriptionScreen(
                    imageUrl: 'http://localhost:8000/${imagePaths[index]}',
                    title: '',
                    artist: 'me',
                    description: arts[index]['description'],
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    'http://localhost:8000/${imagePaths[index]}',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(arts[index]['description']),
                SizedBox(height: 8.0),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyScreen()),
                      );
                    },
                    child: Text('Buy'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SellingArtScreen()),
          );
        },
        child: Icon(Icons.monetization_on),
      ),
    );
  }
}
