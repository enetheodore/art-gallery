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
  int _selectedIndex = 1;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return SellingArtScreen();
      case 1:
        return _buildGallery();
      case 2:
        return ProfilePictureWidget(userId: widget.userId);
      default:
        return _buildGallery();
    }
  }

  Widget _buildGallery() {
    return Container(
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
                Text(
                  arts[index]['description'],
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8.0),
                Center(
                  child: ElevatedButton(
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
    );
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
                decoration: BoxDecoration(color: Colors.blueGrey),
                child: profilePictureUrl != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(profilePictureUrl!),
                      )
                    : CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text(
                  'Home',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text(
                  'Sell Art',
                  style: TextStyle(color: Colors.white),
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
                  style: TextStyle(color: Colors.white),
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
                  style: TextStyle(color: Colors.white),
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
      body: _buildPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.blueGrey.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.monetization_on),
                label: 'Sell Art',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            backgroundColor: Colors.transparent,
            onTap: _onItemTapped,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
