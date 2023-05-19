import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class Api {
  static FirebaseAuth inst = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;
  static User get user => inst.currentUser!;
  static late ChatUser me;
  //****************push notification******************
  static Future<void> getFCM_Token() async {
    await fmessaging.requestPermission();
    await fmessaging.getToken().then((token) {
      if (token != null) {
        me.pushToken = token;
        log('push token : $token');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAA_eymoao:APA91bG9gmFGd6wyhQvHo3jWlOGGFZGP7TVXWBpKuSGvfap5oGMCKN-ZkdeQsMt_bNeo79cD7Y_TC7-giRB5AM3RbAUl85TvURGOtZn_1927MVWaR7SI9I6c4hmBShURfwQ5cTJbgnE0'
              },
              body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('errorr :$e');
    }
  }

  //****************push notification******************

  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_friends')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  static Future<void> getUserInfo() async {
    firestore.collection('users').doc(user.uid).get().then((User) async {
      if (User.exists) {
        me = ChatUser.fromJson(User.data()!);
        await getFCM_Token();
        updateUserOnlineStatus(true);
      } else {
        await createUser().then((value) => getUserInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: 'Hey, I\'m using a We Chat',
        image: user.photoURL.toString(),
        lastActive: time,
        createdAt: time,
        pushToken: '',
        itsOnline: false);
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_friends')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> usersId) {
    return firestore
        .collection('users')
        .where('id', whereIn: usersId)
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> sentFirstMsgto_other_user(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_friends')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Future<void> updateUserProfile() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_Pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('data transfered: ${p0.bytesTransferred / 1000} kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  // **************Chat/msg screen related api***************
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMsgs(ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future sendMessage(ChatUser chatUser, String msg, Type type) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final Message message = Message(
          toid: chatUser.id,
          msg: msg,
          read: '',
          type: type,
          fromid: user.uid,
          sent: time);

      final ref = firestore
          .collection('chats/${getConversationId(chatUser.id)}/messages/');
      await ref.doc(time).set(message.toJson()).then((value) =>
          sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
    } catch (e) {
      print('error........$e');
    }
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromid)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMsg(ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sentChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('data transfered: ${p0.bytesTransferred / 1000} kb');
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> updateUserOnlineStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'its_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserLstSeen(
      ChatUser user) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: user.id)
        .snapshots();
  }

  static Future<void> deleteMsg(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toid)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  // static deleteUser(ChatUser chatuser, Message message) async {
  //   await firestore
  //       .collection('users')
  //       .doc(user.uid)
  //       .collection('my_friends')
  //       .doc(chatuser.id)
  //       .delete()
  //       .then((value) async {
  //     await firestore
  //         .collection('chats/${getConversationId(chatuser.id)}/messages')
  //         .doc(message.sent)
  //         .delete();
  //   });
  // }
}
