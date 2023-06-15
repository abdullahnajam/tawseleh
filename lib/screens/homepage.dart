import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawseleh/screens/create_ride.dart';
import 'package:tawseleh/screens/choose_settings.dart';
import 'package:tawseleh/screens/notification_test.dart';
import 'package:tawseleh/screens/ride_list_screen.dart';
import 'package:tawseleh/widgets/profile_image.dart';

import '../api/local_notification_service.dart';
import '../provider/user_provider.dart';
import 'chat/chat_screen.dart';
import 'chat/individual_chat.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.instance.getInitialMessage().then((message) {

      print("FirebaseMessaging.instance.getInitialMessage");
      if (message != null) {
        LocalNotificationService.createAndDisplayNotification(message);
        print("New Notification ${message.data}");
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ChatScreen(message.data['chatHeadId'])
          ),
        );

      }
    },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
          (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createAndDisplayNotification(message);

        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data}");
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChatScreen(message.data['chatHeadId'])
            ),
          );
          if (mounted) {
            print('mounted');
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  ChatScreen(message.data['chatHeadId'])));
          }
          else{
            print('not');
          }

        }
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserDataProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 70,
              padding: const EdgeInsets.all(10),
              child: Stack(

                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => IndividualChat()));
                        //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => NotificationTest()));

                      },
                      child: Icon(Icons.chat_outlined),
                    )
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20,right: 20),
                      child: Text ('Tawseleh'.tr(),style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w800
                      ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: (){

                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChooseSettings()));

                      },
                      child: ProfilePicture(url: provider.userData!.profilePic),
                    ),
                  ),


                ],
              ),
            ),
            SizedBox(height: 20,),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20,right: 20),
                  child: Center(child: Text('Welcome to Tawseleh'.tr(),textAlign: TextAlign.center,style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w500))),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: Text('Take Advantage of Our Services for FREE'.tr(),textAlign: TextAlign.center,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w400))),
                ),
              ],
            ),
            Card(
              margin: EdgeInsets.all(20),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RideListScreen()));

                },
                child: Column(
                  children: [
                    Image.asset('assets/images/booking.png',height: 150,width: MediaQuery.of(context).size.width,fit: BoxFit.fitHeight,),
                    SizedBox(height: 20,),
                    Text('Find a Ride'.tr(),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500)),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(20),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CreateRideScreen()));

                },
                child: Column(
                  children: [
                    Image.asset('assets/images/addride.png',height: 150,width: MediaQuery.of(context).size.width,fit: BoxFit.fitHeight,),
                    SizedBox(height: 20,),
                    Text('Create a Ride'.tr(),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500)),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
