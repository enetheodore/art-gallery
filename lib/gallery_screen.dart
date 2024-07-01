import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'art_description_screen.dart';
import 'buy_screen.dart';
import 'selling_art_screen.dart';
import 'galleryScreenAdmin.dart';
import 'profilePic.dart';

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
  final TextEditingController _searchController = TextEditingController();

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

  void _searchArts(String query) {
    final filteredArts = arts.where((art) {
      final descriptionLower = art['description'].toLowerCase();
      final searchLower = query.toLowerCase();
      return descriptionLower.contains(searchLower);
    }).toList();

    setState(() {
      arts = filteredArts;
    });
  }

  Widget _buildGallery() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.8,
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
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      'http://localhost:8000/${imagePaths[index]}',
                      height: MediaQuery.of(context).size.height * 0.14,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      arts[index]['description'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Buy'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
          title: Text(
            'Art Gallery',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
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
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blueGrey.withOpacity(0.7),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueGrey, Colors.blueGrey.withOpacity(0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
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
              _buildDrawerItem(Icons.home, 'Home', () {
                Navigator.pop(context);
              }),
              _buildDrawerItem(Icons.monetization_on, 'Sell Art', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellingArtScreen()),
                );
              }),
              _buildDrawerItem(Icons.person, 'Profile', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePictureWidget(userId: widget.userId),
                  ),
                );
              }),
              _buildDrawerItem(Icons.exit_to_app, 'Logout', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchArts,
              decoration: InputDecoration(
                hintText: 'Search art...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryButton('Home', Icons.home, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GalleryScreen(userId: 1),
                    ),
                  );
                }),
                _buildCategoryButton('Car', Icons.directions_car,() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GalleryScreenAdmin(),
                    ),
                  );
                }),
                _buildCategoryButton('Chair', Icons.chair,() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GalleryScreen(userId: 1),
                    ),
                  );
                }),
                _buildCategoryButton('Art', Icons.palette,() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GalleryScreen(userId: 1),
                    ),
                  );
                }),
                _buildCategoryButton('Music', Icons.music_note,() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GalleryScreen(userId: 1),
                    ),
                  );
                }),
                // Add more categories as needed
              ],
            ),
          ),
          Expanded(child: _buildGallery()),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GalleryScreen(userId: 1),
  ));
}
