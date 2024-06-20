import 'dart:convert';
import 'package:art_gallery_app/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'art_description_screen.dart';
import 'buy_screen.dart';
import 'selling_art_screen.dart';
import 'galleryScreenAdmin.dart'; // Import your admin screen if needed
import 'profilePic.dart'; // Import your profile picture widget if needed

class GalleryScreen extends StatefulWidget {
  final int userId;
  final String? profilePictureUrl;

  GalleryScreen({required this.userId, this.profilePictureUrl});

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
    profilePictureUrl = widget.profilePictureUrl;
    fetchArtsDataFromServer();
    fetchProfilePicture();
  }

  Future<void> fetchProfilePicture() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/profile_picture/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profilePictureUrl = 'http://localhost:8000${data['profile_picture']}';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          profilePictureUrl = null;
        });
        print('Profile picture not found for userId ${widget.userId}');
      } else {
        print('Failed to load profile picture: ${response.statusCode}');
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
        centerTitle: true,
        shadowColor: Colors.black,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
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
        child: Container(
          decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.7)),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: profilePictureUrl != null
                    ? Image.network(
                        profilePictureUrl!, // Display profile picture if available
                        fit: BoxFit.cover,
                      )
                    : Placeholder(),
              ),
              ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text(
                  'Sell Art',
                  selectionColor: Colors.white,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellingArtScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  'Profile',
                  selectionColor: Colors.white,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePictureWidget(userId: widget.userId),
                    ),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text(
                  'Logout',
                  selectionColor: Colors.white,
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.7)),
        child: GridView.builder(
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
