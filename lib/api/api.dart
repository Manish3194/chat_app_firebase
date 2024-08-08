import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatting_app_demo/api/notification_access_token.dart';
import 'package:chatting_app_demo/model/chat_user.dart';
import 'package:chatting_app_demo/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class APIs {
  // Firebase instances
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // Store self information
  static ChatUser me = ChatUser(
    id: auth.currentUser?.uid ?? '',
    name: auth.currentUser?.displayName ?? '',
    email: auth.currentUser?.email ?? '',
    about: "Hey, I'm using We Chat!",
    image: auth.currentUser?.photoURL ?? '',
    createdAt: '',
    isOnline: false,
    lastActive: '',
    pushToken: '',
  );

  // Get current user
  static User? get user => auth.currentUser;

  // Get Firebase Messaging Token
  static Future<void> getFirebaseMessagingToken() async {
    try {
      await fMessaging.requestPermission();
      final token = await fMessaging.getToken();
      if (token != null) {
        me.pushToken = token;
        log('Push Token: $token');
      } else {
        log('Failed to get push token.');
      }
    } catch (e) {
      log('Error getting Firebase Messaging token: $e');
    }
  }

  // Send push notification
  static Future<void> sendPushNotification(ChatUser chatUser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name,
            "body": msg,
          },
          "android": {
            "notification": {
              "priority": "high",
              "sound": "default",
            }
          },
          "apns": {
            "payload": {
              "aps": {
                "sound": "default",
              }
            }
          }
        }
      };

      const projectID = 'chatting-app-78c46';
      final bearerToken = await NotificationAccessToken.getToken;

      if (bearerToken == null) {
        log('Bearer token is null');
        return;
      }

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken',
        },
        body: jsonEncode(body),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log('Error sending push notification: $e');
    }
  }

  // Check if user exists
  static Future<bool> userExists() async {
    try {
      final doc = await firestore.collection('users').doc(user?.uid).get();
      return doc.exists;
    } catch (e) {
      log('Error checking user existence: $e');
      return false;
    }
  }

  // Add chat user
  static Future<bool> addChatUser(String email) async {
    try {
      final data = await firestore.collection('users').where('email', isEqualTo: email).get();

      if (data.docs.isNotEmpty && data.docs.first.id != user?.uid) {
        await firestore.collection('users').doc(user!.uid).collection('my_users').doc(data.docs.first.id).set({});
        return true;
      }
      return false;
    } catch (e) {
      log('Error adding chat user: $e');
      return false;
    }
  }

  // Get current user info
  static Future<void> getSelfInfo() async {
    try {
      final userDoc = await firestore.collection('users').doc(user?.uid).get();
      if (userDoc.exists) {
        me = ChatUser.fromJson(userDoc.data()!);
        await getFirebaseMessagingToken();
        await updateActiveStatus(true);
        log('My Data: ${userDoc.data()}');
      } else {
        log('User document does not exist. Creating new user.');
        await createUser();
        await getSelfInfo(); // Recursive call to fetch updated info
      }
    } catch (e) {
      log('Error getting self info: $e');
    }
  }

  // Create new user
  static Future<void> createUser() async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final chatUser = ChatUser(
        id: user?.uid ?? '',
        name: user?.displayName ?? '',
        email: user?.email ?? '',
        about: "Hey, I'm using We Chat!",
        image: user?.photoURL ?? '',
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '',
      );
      await firestore.collection('users').doc(user?.uid).set(chatUser.toJson());
    } catch (e) {
      log('Error creating user: $e');
    }
  }

  // Get user IDs
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore.collection('users').doc(user?.uid).collection('my_users').snapshots();
  }

  // Get all users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {
    return firestore.collection('users').where('id', whereIn: userIds.isEmpty ? [''] : userIds).snapshots();
  }

  // Send first message
  static Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {
    try {
      await firestore.collection('users').doc(chatUser.id).collection('my_users').doc(user!.uid).set({});
      await sendMessage(chatUser, msg, type);
    } catch (e) {
      log('Error sending first message: $e');
    }
  }

  // Update user info
  static Future<void> updateUserInfo() async {
    try {
      await firestore.collection('users').doc(user!.uid).update({
        'name': me.name,
        'about': me.about,
      });
    } catch (e) {
      log('Error updating user info: $e');
    }
  }

  // Update profile picture
  static Future<void> updateProfilePicture(File file) async {
    try {
      final ext = file.path.split('.').last;
      final ref = storage.ref().child('profile_pictures/${user!.uid}.$ext');
      await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
      me.image = await ref.getDownloadURL();
      await firestore.collection('users').doc(user!.uid).update({'image': me.image});
    } catch (e) {
      log('Error updating profile picture: $e');
    }
  }

  // Get specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
    return firestore.collection('users').where('id', isEqualTo: chatUser.id).snapshots();
  }

  // Update active status
  static Future<void> updateActiveStatus(bool isOnline) async {
    try {
      await firestore.collection('users').doc(user!.uid).update({
        'is_online': isOnline,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
        'push_token': me.pushToken,
      });
    } catch (e) {
      log('Error updating active status: $e');
    }
  }

  // Get conversation ID
  static String getConversationID(String id) => user!.uid.hashCode <= id.hashCode ? '${user!.uid}_$id' : '${id}_${user!.uid}';

  // Get all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore.collection('chats/${getConversationID(user.id)}/messages/').orderBy('sent', descending: true).snapshots();
  }

  // Send message
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final message = Message(toId: chatUser.id, msg: msg, read: '', type: type, fromId: user!.uid, sent: time);
      final ref = firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
      await ref.add(message.toJson());
      await sendPushNotification(chatUser, msg); // Send notification after message is sent
    } catch (e) {
      log('Error sending message: $e');
    }
  }

  // Get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // Send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File image) async {
    try {
      final ext = image.path.split('.').last;
      final ref = storage.ref().child('chat_images/${DateTime.now().millisecondsSinceEpoch}.$ext');
      await ref.putFile(image, SettableMetadata(contentType: 'image/$ext'));
      final imageUrl = await ref.getDownloadURL();
      await sendMessage(chatUser, imageUrl, Type.image);
    } catch (e) {
      log('Error sending chat image: $e');
    }
  }
}
