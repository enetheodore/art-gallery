import 'dart:convert';
import 'package:art_gallery_app/art_description_screen.dart';
import 'package:art_gallery_app/buy_screen.dart';
import 'package:art_gallery_app/selling_art_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class GalleryScreenAdmin extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreenAdmin> {
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
        print('imagePaths length: ${imagePaths.length}');
        print('arts length: ${arts.length}');
      }
    } catch (error) {
      print('Error fetching arts data: $error');
      print('imagePaths length: ${imagePaths.length}');
      print('arts length: ${arts.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Art Gallery Admin'),
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
                        description: arts[index]['description']),
                  ));
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
                    onPressed: () async {
                      try {
                        // Send a DELETE request to the server to delete the item
                        final response = await http.delete(
                          Uri.parse(
                              'http://localhost:8000/api/delete/${arts[index]['id']}'),
                        );

                        if (response.statusCode == 200) {
                          // If deletion is successful, update the local lists
                          setState(() {
                            arts.removeAt(index);
                            imagePaths.removeAt(index);
                          });
                        } else {
                          // Handle error response from the server
                          print(
                              'Failed to delete item. Status code: ${response.statusCode}');
                        }
                      } catch (error) {
                        // Handle network or server errors
                        print('Error deleting item: $error');
                      }
                    },
                    child: Center(child: Text('Delete')),
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