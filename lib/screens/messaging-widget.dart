import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:Carrywiz/screens/my-home-page.dart';
import 'package:Carrywiz/models/NotificationMessage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MessagingWidget());
}

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final TextEditingController titleController =
      TextEditingController(text: 'Title');
  final TextEditingController bodyController =
      TextEditingController(text: 'Body123');
  final List<NotificationMessage> messages = [];
  var token;

  static const String serverToken =
      'AAAAN4kCjJE:APA91bE2bncKJOsNbrWnd07Tm8Czso2UDaigbR7aoo_ToQZG7rfCe5U35NblCxt9OUmNa5hWiyKxJRarY8xLiPSb_0TcOF8zm5F5pLDLAWh4Bt0Zbgth08vBspbOHX9NrmrwKIKSO6vc';

  @override
  void initState() {
    super.initState();
    // Messaging.onRefreshToken(sendTokenToServer);
    token = firebaseMessaging.getToken();

    firebaseMessaging.subscribeToTopic('all');
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      final notification = message.notification;
      handleRouting(notification);
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      print("onBackgroundMessage: $message");
      final notification = message.data;
      handleRouting(notification);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      final notification = message.data;
      handleRouting(notification);
    });


  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          TextFormField(
            textDirection: TextDirection.ltr,
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            textDirection: TextDirection.ltr,
            controller: bodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
          RaisedButton(
            onPressed: () => sendAndRetrieveMessage(
                title: 'hello',
                body: 'hi',
                fcmToken:
                    'd6LJiFnSRlKG19laJAtrpN:APA91bF96ISkRZ5uxj_yqjG71nxihoRWuCH2uxxd5H2KAy-717XIbG1Fu2Xf_wF-tD9NBSQOjcadDTAynvQJJaKNTQ5GlsUVqENOXQHytkcM6uwfjRVjg3BJIyY4St41u_uo3RJorVsd'),
            child: Text('Send notification to all'),
          ),
        ]..addAll(messages.map(buildMessage).toList()),
      );

  Widget buildMessage(NotificationMessage message) => ListTile(
        title: Text(message.title),
        subtitle: Text(message.body),
      );

  void handleRouting(dynamic notification) {
    switch (notification['route']) {
      case 'home':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => MyHomePage(0)));
        break;
      case 'inbox':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => MyHomePage(3)));
        break;
    }
  }

  static Future<Map<String, dynamic>> sendAndRetrieveMessage({
    required String title,
    required String body,
    String? route,
    required String fcmToken,
  }) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
            'sound': 'default'
            // 'route': route,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': fcmToken,
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      completer.complete(message.data);
    });

    return completer.future;
  }

// void sendTokenToServer(String fcmToken) {
//   print("before token has beed refreshed");
//   print("token has beed refreshed");
//   // send key to your server to allow server to use
//   // this token to send push notifications
// }
}
