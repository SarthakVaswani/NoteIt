import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/ui/splashScreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     // 'This channel is used for important notifications.', // description
//     importance: Importance.high,
//     playSound: true);

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('A bg message just showed up :  ${message.messageId}');
// }
String kAppId = "8aedfc1b-f167-4754-bb9f-69c71e0d673e";
String tokenId;
Future<void> initPlatformState() async {
  OneSignal.shared.setAppId(kAppId);

  var status = await OneSignal.shared.getDeviceState();
  tokenId = status.userId;
  print(tokenId);
  OneSignal.shared.setNotificationOpenedHandler((openedResult) {
    return OSNotificationDisplayType.notification;
  });
}

void main() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    initPlatformState();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //   print("Accepted permission: $accepted");
  // });
  // FirebaseMessaging.instance.getToken().then((value) {
  //   String token = value;
  //   print("test = $token");
  // });
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  runApp(MaterialApp(
    title: "NoteIt",
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
