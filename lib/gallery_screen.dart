// import 'dart:convert';
// import 'package:art_gallery_app/buildPage.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'login_screen.dart';
// import 'art_description_screen.dart';
// import 'buy_screen.dart';
// import 'selling_art_screen.dart';
// import 'galleryScreenAdmin.dart';
// import 'profilePic.dart';

// class GalleryScreen extends StatefulWidget {
//   final int userId;
//   final String? profilePictureUrl;

//   GalleryScreen({required this.userId, this.profilePictureUrl});

//   @override
//   _GalleryScreenState createState() => _GalleryScreenState();
// }

// class _GalleryScreenState extends State<GalleryScreen> {
//   List<Map<String, dynamic>> arts = [];
//   List<String> imagePaths = [];
//   String? profilePictureUrl;
//   int _selectedIndex = 1;
//   final TextEditingController _searchController = TextEditingController();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     profilePictureUrl = widget.profilePictureUrl;
//     fetchArtsDataFromServer();
//     fetchProfilePicture();
//   }

//   Future<void> fetchProfilePicture() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:8000/api/profile_picture/${widget.userId}'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           profilePictureUrl = 'http://localhost:8000${data['profile_picture']}';
//         });
//       } else if (response.statusCode == 404) {
//         setState(() {
//           profilePictureUrl = null;
//         });
//         print('Profile picture not found for userId ${widget.userId}');
//       } else {
//         print('Failed to load profile picture: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching profile picture: $error');
//     }
//   }

//   Future<void> fetchArtsDataFromServer() async {
//     try {
//       final response =
//           await http.get(Uri.parse('http://localhost:8000/api/arts'));

//       if (response.statusCode == 200) {
//         final List<dynamic> responseData = json.decode(response.body);

//         final List<String> fetchedImagePaths = [];
//         final List<Map<String, dynamic>> fetchedArts = [];

//         for (final item in responseData) {
//           fetchedImagePaths.add(item['image_path']);
//           fetchedArts.add(item);
//         }

//         setState(() {
//           imagePaths = fetchedImagePaths;
//           arts = fetchedArts;
//         });
//       } else {
//         print('Failed to fetch arts data. Status code: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching arts data: $error');
//     }
//   }

//   void _searchArts(String query) {
//     final filteredArts = arts.where((art) {
//       final descriptionLower = art['description'].toLowerCase();
//       final searchLower = query.toLowerCase();
//       return descriptionLower.contains(searchLower);
//     }).toList();

//     setState(() {
//       arts = filteredArts;
//     });
//   }

//   Widget _buildGallery() {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         color: Colors.grey.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.9),
//             blurRadius: 10,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 8.0,
//           mainAxisSpacing: 8.0,
//           childAspectRatio: 0.8,
//         ),
//         itemCount: arts.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ArtDescriptionScreen(
//                     imageUrl: 'http://localhost:8000/${imagePaths[index]}',
//                     title: '',
//                     artist: 'me',
//                     description: arts[index]['description'],
//                   ),
//                 ),
//               );
//             },
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 5,
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: Column(
//                   children: [
//                     ClipRRect(
//                       borderRadius:
//                           BorderRadius.vertical(top: Radius.circular(15)),
//                       child: Image.network(
//                         'http://localhost:8000/${imagePaths[index]}',
//                         height: MediaQuery.of(context).size.height * 0.14,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         arts[index]['description'],
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => BuyScreen()),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.blueGrey,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: Text('Buy'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           title: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   height: 30,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blueGrey.withOpacity(0.2),
//                         blurRadius: 10,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.menu,
//                       color: Colors.black,
//                       size: 15,
//                     ),
//                     onPressed: () {
//                       _scaffoldKey.currentState?.openDrawer();
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.03,
//                 ),
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blueGrey.withOpacity(0.2),
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     height: MediaQuery.of(context).size.height * 0.05,
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: _searchArts,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(
//                           Icons.search,
//                           size: 15,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         fillColor: Colors.white,
//                         filled: true,
//                         contentPadding: EdgeInsets.symmetric(vertical: 10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.03,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       drawer: Drawer(
//         child: Container(
//           color: Colors.grey.withOpacity(0.3),
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               DrawerHeader(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.grey, Colors.blueGrey],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: profilePictureUrl != null
//                     ? CircleAvatar(
//                         radius: 50,
//                         backgroundImage: NetworkImage(profilePictureUrl!),
//                       )
//                     : CircleAvatar(
//                         radius: 50,
//                         child: Icon(Icons.person, size: 50),
//                       ),
//               ),
//               _buildDrawerItem(Icons.home, 'Home', () {
//                 Navigator.pop(context);
//               }),
//               _buildDrawerItem(Icons.monetization_on, 'Sell Art', () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SellingArtScreen()),
//                 );
//               }),
//               _buildDrawerItem(Icons.person, 'Profile', () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         ProfilePictureWidget(userId: widget.userId),
//                   ),
//                 );
//               }),
//               _buildDrawerItem(Icons.exit_to_app, 'Logout', () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => LoginScreen()));
//               }),
//             ],
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 3),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.grey.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blueGrey.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 SizedBox(height: 10),
//                 Container(
//                   height: MediaQuery.of(context).size.height * 0.2,
//                   child: CarouselSlider(
//                     options: CarouselOptions(
//                       height: 200.0,
//                       autoPlay: true,
//                       enlargeCenterPage: true,
//                     ),
//                     items: imagePaths.map((imagePath) {
//                       return Builder(
//                         builder: (BuildContext context) {
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => BuyScreen(),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               width: MediaQuery.of(context).size.width,
//                               margin: EdgeInsets.symmetric(horizontal: 5.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(15),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.blueGrey.withOpacity(0.2),
//                                     blurRadius: 10,
//                                     offset: Offset(0, 5),
//                                   ),
//                                 ],
//                               ),
//                               child: Stack(
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(15),
//                                     child: Image.network(
//                                       'http://localhost:8000/$imagePath',
//                                       width: double.infinity,
//                                       height: double.infinity,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(15),
//                                       gradient: LinearGradient(
//                                         colors: [
//                                           Colors.transparent,
//                                           Colors.black.withOpacity(0.6)
//                                         ],
//                                         begin: Alignment.topCenter,
//                                         end: Alignment.bottomCenter,
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     bottom: 10,
//                                     left: 10,
//                                     child: Text(
//                                       arts[imagePaths.indexOf(imagePath)]
//                                           ['description'],
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         shadows: [
//                                           Shadow(
//                                             color:
//                                                 Colors.black.withOpacity(0.7),
//                                             blurRadius: 10,
//                                             offset: Offset(0, 5),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Container(
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           height: 3,
//                         ),
//                         _buildCategoryButton('Home', Icons.home, () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => BottomPage(userId: 1),
//                             ),
//                           );
//                         }),

//                         _buildCategoryButton('Car', Icons.directions_car, () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => GalleryScreenAdmin(),
//                             ),
//                           );
//                         }),

//                         _buildCategoryButton('Chair', Icons.chair, () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => GalleryScreen(userId: 1),
//                             ),
//                           );
//                         }),

//                         _buildCategoryButton('Art', Icons.palette, () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => GalleryScreen(userId: 1),
//                             ),
//                           );
//                         }),

//                         _buildCategoryButton('Music', Icons.music_note, () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => GalleryScreen(userId: 1),
//                             ),
//                           );
//                         }),

//                         // Add more categories as needed
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//               ],
//             ),
//           ),
//           SizedBox(height: 3),
//           Expanded(child: _buildGallery()),
//           SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryButton(
//       String label, IconData icon, VoidCallback onPressed) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: ElevatedButton.icon(
//         onPressed: onPressed,
//         icon: Icon(
//           icon,
//           size: 15,
//         ),
//         label: Text(label),
//         style: ElevatedButton.styleFrom(
//           foregroundColor: Colors.blueGrey,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.black),
//       title: Text(
//         title,
//         style: TextStyle(color: Colors.black),
//       ),
//       onTap: onTap,
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: GalleryScreen(userId: 1),
//   ));
// }
// import 'dart:convert';
import 'dart:convert';

import 'package:art_gallery_app/buildPage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'art_description_screen.dart';
import 'buy_screen.dart';
import 'selling_art_screen.dart';
import 'galleryScreenAdmin.dart';
import 'profilePic.dart';

class GalleryScreen extends StatefulWidget {
  final String userId;

  GalleryScreen({required this.userId});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, dynamic>> arts = [];
  String? profilePictureUrl;
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
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
    return GridView.builder(
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
                  imageUrl: arts[index]['imageUrl'],
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
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.black,
                      size: 15,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.03,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchArts,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          size: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey.withOpacity(0.3),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey, Colors.blueGrey],
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
              _buildDrawerItem(Icons.admin_panel_settings, 'Admin', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GalleryScreenAdmin()),
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
          SizedBox(height: 3),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: imagePaths.map((imagePath) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuyScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      'http://localhost:8000/$imagePath',
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.6)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Text(
                                      arts[imagePaths.indexOf(imagePath)]
                                          ['description'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            blurRadius: 10,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    child: Row(
                      children: [
                        SizedBox(
                          height: 3,
                        ),
                        _buildCategoryButton('Home', Icons.home, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomPage(userId: 1),
                            ),
                          );
                        }),

                        _buildCategoryButton('Car', Icons.directions_car, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GalleryScreenAdmin(),
                            ),
                          );
                        }),

                        _buildCategoryButton('Chair', Icons.chair, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GalleryScreen(userId: ''),
                            ),
                          );
                        }),

                        _buildCategoryButton('Art', Icons.palette, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GalleryScreen(userId: ''),
                            ),
                          );
                        }),

                        _buildCategoryButton('Music', Icons.music_note, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GalleryScreen(userId: ''),
                            ),
                          );
                        }),

                        // Add more categories as needed
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          SizedBox(height: 3),
          Expanded(child: _buildGallery()),
          SizedBox(height: 10),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => UploadScreen()),
      //     );
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }

  Widget _buildCategoryButton(
      String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 15,
        ),
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
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FirebaseAuth.instance.currentUser != null
        ? GalleryScreen(userId: FirebaseAuth.instance.currentUser!.uid)
        : LoginScreen(),
  ));
}
