import 'dart:convert';
import 'package:art_gallery_app/art_description_screen.dart';
import 'package:art_gallery_app/buy_screen.dart';
import 'package:art_gallery_app/selling_art_screen.dart';
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
      final response = await http.get(Uri.parse('http://localhost:8000/api/arts'));

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
        // Handle error gracefully (e.g., show a Snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch arts data. Please try again later.'),
          ),
        );
      }
    } catch (error) {
      print('Error fetching arts data: $error');
      // Handle network or server errors gracefully (e.g., show a Snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching arts data. Please check your internet connection.'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteArt(int index) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8000/api/delete/${arts[index]['id']}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          arts.removeAt(index);
          imagePaths.removeAt(index);
        });
      } else {
        print('Failed to delete item. Status code: ${response.statusCode}');
        // Handle error deleting item (e.g., show a Snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete item. Please try again later.'),
          ),
        );
      }
    } catch (error) {
      print('Error deleting item: $error');
      // Handle network or server errors (e.g., show a Snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting item. Please check your internet connection.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Art Gallery Admin'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
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
                          onPressed: () => deleteArt(index),
                          child: Text('Delete'),
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
