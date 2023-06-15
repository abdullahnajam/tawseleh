import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:tawseleh/screens/choose_settings.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'pushnotificationapp', // id
  'Pushnotificationapp', // title
  importance: Importance.max,
);
const serverToken="AAAA_xlb5L8:APA91bEiQNSrT8AI8jFvGNbVOhMLOkULZQGhNHD3YP_YA1hp5BEsFrEfnNXkCsOGXRdfS-iovh-lEMYpSAMfYQrSPkDfyMl4Ywb9DNu6MWxvQdlAtohQE06i1TRZRzQQgs5-bRpqVcGX";

class NotificationApi {

  Future<void> setupInteractedMessage(BuildContext context) async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChooseSettings()));
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('message data ${message.data}');
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChooseSettings()));

    });
  }



  static Future init(BuildContext context) async {
    print("started");
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/icon');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS
    );
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse id)async{
          print('on did recieve ${id.payload}');
        },
        onDidReceiveBackgroundNotificationResponse: (NotificationResponse id)async{
          print('on did recieve ${id.payload}');
        }
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then((message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('message data ${message.data}');
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChooseSettings()));

    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("message recieved ${message.data}");
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,

              ),
            ));
      }
      //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChooseSettings()));
    });
  }
  void onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    print("notification recieved");
  }



  static Future sendNotification(String userToken,title,body,userId,chatHeadId) async{
    String url='https://fcm.googleapis.com/fcm/send';
    Uri myUri = Uri.parse(url);
    print('r token $userToken');
    await post(
      myUri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title
          },

          'data': <String, dynamic>{
            'chatHeadId': chatHeadId,
            'status': 'done',
          },
          'to': "$userToken",
          "android": {
            "priority": "high",
            "notification": {
              "channelId": "pushnotificationapp"
            }
          }
        },
      ),
    ).whenComplete(()  {
      FirebaseFirestore.instance.collection("notifications").add({
        'timestamp':DateTime.now().millisecondsSinceEpoch,
        'body':body,
        'title':title,
        'userId':userId,
        'senderId':FirebaseAuth.instance.currentUser!.uid,
        'isRead':false,
      });

    });
  }
}

