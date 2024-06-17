import 'dart:convert';
import 'dart:io';
import 'package:art_gallery_app/profilePic.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'art_description_screen.dart';
import 'buy_screen.dart';
import 'galleryScreenAdmin.dart';
import 'selling_art_screen.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, dynamic>> arts = [];
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    // Fetch arts data from the server
    fetchArtsDataFromServer();
  }

  Future<void> fetchArtsDataFromServer() async {
    try {
      // Make a GET request to fetch the arts data from the server
      final response =
          await http.get(Uri.parse('http://localhost:8000/api/arts'));

      if (response.statusCode == 200) {
        // Parse the response body
        final List<dynamic> responseData = json.decode(response.body);

        // Extract the image paths and descriptions from the response data
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
                MaterialPageRoute(
                  builder: (context) => GalleryScreenAdmin(),
                ),
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
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Sell Art'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SellingArtScreen(),
                  ),
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
                        // For demonstration, you can set a placeholder image in the UI
                        // or use the selected image for further processing.
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
                    'http://localhost:8000/${imagePaths[index]}', // Adjust the base URL as needed
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(arts[index]['description']), // Display description
                SizedBox(height: 8.0),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyScreen(),
                        ),
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
            MaterialPageRoute(
              builder: (context) => SellingArtScreen(),
            ),
          );
        },
        child: Icon(Icons.monetization_on),
      ),
    );
  }
}
