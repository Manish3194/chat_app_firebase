import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app_demo/model/chat_user.dart';
import 'package:chatting_app_demo/screens/user_profile/view_profile_screen.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //user profile picture
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              imageUrl: user.image,
              errorWidget: (context, url, error) =>
              const CircleAvatar(child: Icon(Icons.person)),
            ),
          ),

          const SizedBox(height: 10),

          //user name
          Text(user.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),

          const SizedBox(height: 10),

          //info button
          ElevatedButton(
            onPressed: () {
              //for hiding image dialog
              Navigator.pop(context);

              //move to view profile screen
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(user: user)));
            },
            child: const Text('View Profile'),
          )
        ],
      ),
    );
  }
}