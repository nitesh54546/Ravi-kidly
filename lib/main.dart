import 'dart:convert';

import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_facebook_sdk/flutter_facebook_sdk.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kidly/constant/ScreenConstant.dart';
import 'package:kidly/screens/DashboardScreen.dart';
import 'package:kidly/screens/DashboardScreen2.dart';
import 'package:kidly/screens/OTPVerificationScreen.dart';
import 'package:kidly/screens/SignUpScreen.dart';
import 'package:kidly/screens/SplashScreen.dart';
import 'package:kidly/screens/login.dart';
import 'package:kidly/utils/provider.dart';
import 'package:kidly/utils/sharepreference.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_tag_manager/google_tag_manager.dart' as gtm;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', //id
    'High Importance Notifications', // name
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  // gtm.pushEvent('button1-click');
  // gtm.pushEvent('button2-click', data: {'value': 1});
  // gtm.push({'variable_name': 'GTM-THM8T4L'});

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseInAppMessaging.instance.setMessagesSuppressed(false);
  FirebaseDatabase.instance.setPersistenceEnabled(false);
  FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  _getInstanceId();
  runApp(const MyApp());

  // to hide status bar
  // SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.immersiveSticky,
  //   // overlays: [SystemUiOverlay.bottom]
  // );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  // to use potrait mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

void _getInstanceId() async {
  await Firebase.initializeApp();
  var token1 = await FirebaseMessaging.instance.getToken();
  print("Instance ID: " + token1!);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final facebookAppEvents = FacebookAppEvents();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void configLocalNotification() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/noti_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteMessage message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? 'com.tabschool.kidly' : 'com.tabschool.kidly',
      'Kidly',
      playSound: true,
      enableVibration: true,
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    print(message.data.toString());
    await flutterLocalNotificationsPlugin.show(
        0,
        message.data['title'].toString(),
        message.data['message'].toString(),
        platformChannelSpecifics,
        payload: json.encode(message));
  }

  getFCMToken() async {
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getAPNSToken();
    FirebaseMessaging.instance.getToken().then((token) async {
      print('fcm-token-----$token');
      setFcmToken(token!);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMsgggggggg: ' + message.data.toString());

      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;
      AppleNotification? appleNotification = message.notification?.apple;
      print("channel......${channel.id}");
      if (androidNotification != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification!.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails('channelHigh', channel.name,
                    color: const Color.fromRGBO(71, 79, 156, 1),
                    playSound: true,
                    largeIcon: const DrawableResourceAndroidBitmap(
                        '@mipmap/noti_launcher'),
                    importance: Importance.max,
                    icon: '@mipmap/noti_launcher')));
      }
      if (appleNotification != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification!.title,
            notification.body,
            const NotificationDetails(
                iOS: IOSNotificationDetails(
              presentSound: true,
              presentAlert: true,
              presentBadge: true,
            )));
      }
    });
  }

  getLoginUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('login') != null) {
      setState(() {
        checkLogin = prefs.getBool('login')!;
        print(checkLogin);
      });
    }
  }

  bool checkLogin = false;
  @override
  void initState() {
    getLoginUser();

    SystemChannels.textInput.invokeMethod('TextInput.hide');
    configLocalNotification();
    getFCMToken();
    facebookAppEvents.setAdvertiserTracking(enabled: true);
    facebookAppEvents.logEvent(
      name: 'Tabschool Kidly',
      parameters: {
        'button_id': 'the_clickme_button',
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: provider,
      child: GetMaterialApp(
        title: 'Kidly',
        supportedLocales: const [
          Locale('en'),
          Locale('el'),
          Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hans'), // Generic Simplified Chinese 'zh_Hans'
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ],
        localizationsDelegates: const [
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        // initialRoute: ScreenConstant.splash,
        routes: {
          ScreenConstant.splash: (context) => const SplashScreen(),
          ScreenConstant.signUp: (context) => SignUpScreen('', '', '', '', ''),
          ScreenConstant.otp: (context) =>
              OTPVerificationScreen('', '', '', ''),
          ScreenConstant.dashboard: (context) => DashboardScreen(),
          ScreenConstant.login: ((context) => const LoginScreen())
        },
        home: checkLogin ? DashboardScreen() : const SplashScreen(),
      ),
    );
  }
}
