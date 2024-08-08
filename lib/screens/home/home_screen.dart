import 'dart:developer';

import 'package:chatting_app_demo/api/api.dart';
import 'package:chatting_app_demo/helper/dialouge.dart';
import 'package:chatting_app_demo/model/chat_user.dart';
import 'package:chatting_app_demo/screens/profile/profile_screen.dart';
import 'package:chatting_app_demo/widget/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Home screen -- where all available contacts are shown
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // For storing all users
  List<ChatUser> _list = [];

  // For storing searched items
  final List<ChatUser> _searchList = [];

  // For storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();

    // For updating user active status according to lifecycle events
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  // Initialize user data and fetch user info
  Future<void> _initializeUserData() async {
    await APIs.getSelfInfo();
    setState(() {}); // Refresh the state after fetching self info
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: WillPopScope(
        onWillPop: () async {
          if (_isSearching) {
            setState(() => _isSearching = !_isSearching);
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Name, Email, ...'),
              autofocus: true,
              style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
              onChanged: (val) {
                _updateSearchList(val);
              },
            )
                : const Text('We Chat'),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  },
                  icon: const Icon(Icons.more_vert))
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
                onPressed: () {
                  _addChatUserDialog();
                },
                child: const Icon(Icons.add_comment_rounded)),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.done) {
                final userIds = snapshot.data?.docs.map((e) => e.id).toList() ?? [];
                log('Fetched user IDs: $userIds');

                return StreamBuilder(
                  stream: APIs.getAllUsers(userIds),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.done) {
                      final data = snapshot.data?.docs;
                      log('Fetched users data: ${data?.map((e) => e.data()).toList()}');
                      _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount: _isSearching ? _searchList.length : _list.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                  user: _isSearching ? _searchList[index] : _list[index]);
                            });
                      } else {
                        return const Center(
                          child: Text('No Connections Found!', style: TextStyle(fontSize: 20)),
                        );
                      }
                    } else {
                      return const Center(child: Text('Error loading users'));
                    }
                  },
                );
              } else {
                return const Center(child: Text('Error loading data'));
              }
            },
          ),
        ),
      ),
    );
  }

  // Update the search list based on the search query
  void _updateSearchList(String query) {
    setState(() {
      _searchList.clear();
      for (var user in _list) {
        if (user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase())) {
          _searchList.add(user);
        }
      }
    });
  }

  // Dialog for adding a new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(
                Icons.person_add,
                color: Colors.blue,
                size: 28,
              ),
              Text('  Add User')
            ],
          ),
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
                hintText: 'Email Id',
                prefixIcon: const Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          actions: [
            MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 16))),
            MaterialButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (email.isNotEmpty) {
                    final success = await APIs.addChatUser(email);
                    if (!success) {
                      Dialogs.showSnackbar(context, 'User does not Exist!');
                    }
                  }
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ))
          ],
        ));
  }
}
