import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePictureWidget extends StatefulWidget {
  final String userId;
  final double size;

  const ProfilePictureWidget({
    Key? key,
    required this.userId,
    this.size = 100.0,
  }) : super(key: key);

  @override
  _ProfilePictureWidgetState createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  String? profilePictureUrl;

  @override
  void initState() {
    super.initState();
    fetchProfilePicture();
  }

  Future<void> fetchProfilePicture() async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:8000/uploads/profile_pictures/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        profilePictureUrl = data['profile_picture'];
      });
    } else if (response.statusCode == 404) {
      // Handle case where profile picture is not found
      setState(() {
        profilePictureUrl = null; // Reset profilePictureUrl if not found
      });
      print('Profile picture not found for userId ${widget.userId}');
    } else {
      print('Failed to load profile picture: ${response.statusCode}');
      // Handle other HTTP status codes if needed
    }
  } catch (error) {
    print('Error fetching profile picture: $error');
    // Handle other errors if needed
  }
}



  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
          ? Image.network(
              profilePictureUrl!,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
            )
          : Container(
              width: widget.size,
              height: widget.size,
              color: Colors.grey,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: widget.size * 0.6,
              ),
            ),
    );
  }
}
