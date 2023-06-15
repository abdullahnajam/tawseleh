import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawseleh/api/local_notification_service.dart';
import 'package:tawseleh/provider/audio_provider.dart';
import 'package:tawseleh/provider/chat_provider.dart';
import 'package:tawseleh/provider/create_ride_provider.dart';
import 'package:tawseleh/provider/filter_provider.dart';
import 'package:tawseleh/provider/user_provider.dart';
import 'package:tawseleh/screens/splash_screen.dart';

import 'api/notification_api.dart';
Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
  //LocalNotificationService.createAndDisplayNotification(message);
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  LocalNotificationService.initialize();

  await EasyLocalization.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ar')],
        path: 'assets/json',
        fallbackLocale: Locale('en'),
        child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserDataProvider>(
          create: (_) => UserDataProvider(),
        ),

        ChangeNotifierProvider<FilterProvider>(
          create: (_) => FilterProvider(),
        ),

        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),
        ChangeNotifierProvider<CreateRideProvider>(
          create: (_) => CreateRideProvider(),
        ),
        ChangeNotifierProvider<AudioProvider>(
          create: (_) => AudioProvider(),
        ),

      ],
      child:  MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Tawseleh',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
      )

    );
  }
}

