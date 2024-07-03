import 'package:art_gallery_app/galleryScreenAdmin.dart';
import 'package:art_gallery_app/gallery_screen.dart';
import 'package:art_gallery_app/login_screen.dart';
import 'package:art_gallery_app/selling_art_screen.dart';
import 'package:art_gallery_app/signup_screen.dart';
import 'package:flutter/material.dart';

class BottomPage extends StatefulWidget {
  final int userId;

  BottomPage({required this.userId});

  @override
  BottomPageState createState() => BottomPageState();
}

class BottomPageState extends State<BottomPage> {
  int _selectedIndex = 1;
  final List<Widget> _pages = [
    SellingArtScreen(),
    GalleryScreen(userId: 51),
    SignupScreen(),
    LoginScreen(),
  ];

  final List<bool> _showBottomNavBar = [
    true,
    true,
    false,
    false,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPage() {
    return _pages[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(),
      bottomNavigationBar: _showBottomNavBar[_selectedIndex]
          ? Container(
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  //bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  //bottomRight: Radius.circular(20),
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
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.monetization_on,
                        size: 15,
                      ),
                      label: 'Sell Art',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                        size: 15,
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.person,
                        size: 15,
                      ),
                      label: 'Sign up',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.black.withOpacity(0.5),
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
            )
          : null,
    );
  }
}
