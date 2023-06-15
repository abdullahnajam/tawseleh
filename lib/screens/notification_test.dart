import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawseleh/api/notification_api.dart';
import 'package:tawseleh/provider/user_provider.dart';

import '../utils/constants.dart';

class NotificationTest extends StatefulWidget {
  const NotificationTest({Key? key}) : super(key: key);

  @override
  State<NotificationTest> createState() => _NotificationTestState();
}

class _NotificationTestState extends State<NotificationTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: ()async{
                  String? token=await FirebaseMessaging.instance.getToken();
                  print('token $token');
                  NotificationApi.sendNotification(token!, 'test notification', 'timestamp ${DateTime.now()}', FirebaseAuth.instance.currentUser!.uid,'');
                },
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: Text('Send',style: TextStyle(fontSize:16,color: Colors.white),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
