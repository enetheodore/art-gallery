import 'dart:convert';
import 'package:art_gallery_app/art_description_screen.dart';
import 'package:art_gallery_app/buildPage.dart';
import 'package:art_gallery_app/gallery_screen.dart';
import 'package:art_gallery_app/selling_art_screen.dart';
import 'package:art_gallery_app/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GalleryScreenAdmin extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreenAdmin> {
  List<Map<String, dynamic>> arts = [];
  List<String> imagePaths = [];
  bool isLoading = false;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchArtsDataFromServer();
  }

  Future<void> fetchArtsDataFromServer() async {
    setState(() {
      isLoading = true;
    });

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
        showSnackBar('Failed to fetch arts data. Please try again later.');
      }
    } catch (error) {
      showSnackBar(
          'Error fetching arts data. Please check your internet connection.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteArt(int index) async {
    try {
      final response = await http.delete(
          Uri.parse('http://localhost:8000/api/delete/${arts[index]['id']}'));

      if (response.statusCode == 200) {
        setState(() {
          arts.removeAt(index);
          imagePaths.removeAt(index);
        });
      } else {
        showSnackBar('Failed to delete item. Please try again later.');
      }
    } catch (error) {
      showSnackBar(
          'Error deleting item. Please check your internet connection.');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        await Future.delayed(Duration(seconds: 1));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UploadScreen()),
        );
        break;
      case 1:
        await Future.delayed(Duration(seconds: 1));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GalleryScreenAdmin()),
        );
        break;
      case 2:
        await Future.delayed(Duration(seconds: 1));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignupScreen()),
        );
        break;
      case 3:
        await Future.delayed(Duration(seconds: 1));
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BottomPage(userId: 1),
            ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Text('Gallery Admin'),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            imageUrl:
                                'http://localhost:8000/${imagePaths[index]}',
                            title: arts[index]['title'] ?? '',
                            artist: arts[index]['artist'] ?? 'Unknown',
                            description: arts[index]['description'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10.0),
                              ),
                              child: Image.network(
                                'http://localhost:8000/${imagePaths[index]}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              arts[index]['description'],
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => deleteArt(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      persistentFooterButtons: [
        Container(
          height: MediaQuery.of(context).size.height * 0.08,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.monetization_on, size: 15),
                  label: 'Sell Art',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 15),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 15),
                  label: 'Sign up',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_outdoor_outlined, size: 15),
                  label: 'Gallery page',
                ),
              ],
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black.withOpacity(0.5),
              backgroundColor: Colors.transparent,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 14,
              unselectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ],
    );
  }
}
