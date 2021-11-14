import 'dart:async';
import 'dart:convert';

import 'package:Carrywiz/services/ApiAuthProvider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class Messaging {
  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"
  // static const String myDeviceToken =
  //     'eqeCvJ7wQzqCbJdXPEnnsS:APA91bHJlBwA3BeQl_8wQxOJ1K-3iWHbGVkTP0FyhrjzNNeCBEpvLqtoi0M72G6o2aYJg3YfmI67H1gMJkOPuDCkvxLaPgXDthdzFy-OaTBS994CDnZgQgyV2zt_7rLAHsJr3Bh_0KlH';
  static const String serverToken =
      'AAAAN4kCjJE:APA91bE2bncKJOsNbrWnd07Tm8Czso2UDaigbR7aoo_ToQZG7rfCe5U35NblCxt9OUmNa5hWiyKxJRarY8xLiPSb_0TcOF8zm5F5pLDLAWh4Bt0Zbgth08vBspbOHX9NrmrwKIKSO6vc';
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Messaging() {
    firebaseMessaging.subscribeToTopic('all');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      final notification = message.notification;
      // handleRouting(notification);
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      print("onBackgroundMessage: $message");
      final notification = message.data;
      // handleRouting(notification);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      final notification = message.data;
      // handleRouting(notification);
    });


  } //  static Future<Response> sendToAll({
//    @required String title,
//    @required String body,
//  }) =>
//      sendToTopic(title: title, body: body, topic: 'all');

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

  static void onRefreshToken(int userId) {
    firebaseMessaging.onTokenRefresh.listen(sendTokenToServer(userId));
  }

  static sendTokenToServer(int userId) async {
    ApiAuthProvider apiAuthProvider = ApiAuthProvider();
    String? fcmToken = await firebaseMessaging.getToken();
    apiAuthProvider.updateFirebaseTokenByUserId(userId, fcmToken!);
  }

  static Future<Map<String, dynamic>> sendAndRetrieveMessage({
    required String title,
    required String body,
    String? route,
    required String fcmToken,
  }) async {
    // await firebaseMessaging.requestNotificationPermissions(
    //   const IosNotificationSettings(
    //       sound: true, badge: true, alert: true, provisional: false),
    // );
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
            'route': route,
            'sound': 'default'
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
      print("onMessage: $message");
      final notification = message.notification;
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      print("onBackgroundMessage: $message");
      final notification = message.data;
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      final notification = message.data;
    });
    // firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(
    //         sound: true, badge: true, alert: true, provisional: true));
    // firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });

    return completer.future;
  }
}
