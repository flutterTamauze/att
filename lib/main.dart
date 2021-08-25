import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/db/SqlfliteDB.dart';
import 'package:qr_users/Screens/SplashScreen.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:sqflite/sqflite.dart';
import 'FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/connectivity_service.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FirebaseCloudMessaging/NotificationMessage.dart';
import 'enums/connectivity_status.dart';

List<CameraDescription> cameras;
const MethodChannel _channel = MethodChannel('tdsChilango.com/channel_test');
Map<String, String> channelMap = {
  "id": "ChilangoNotifications",
  "name": "tdsChilango.com/channel_test",
  "description": "notifications",
};
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  cameras = await availableCameras();
  if (Platform.isAndroid) {
    await _channel.invokeMethod('createNotificationChannel', channelMap);
  }

  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    print("Handling a background message: ${message.notification}");
    print("going to save this data ${message.data["category"]}");
    final prefs = await SharedPreferences.getInstance();
    print("current shared pref status :");
    print(prefs.getString("notifiCategory"));
    prefs.setStringList("bgNotifyList", []);

    if (prefs.getString('notifCategory') == "" ||
        prefs.getString('notifCategory') == null) {
      print("setting please wait ..");
      prefs.setString("notifCategory", message.data["category"]);
    }
    await prefs.setStringList("bgNotifyList", [
      message.data["category"],
      DateTime.now().toString().substring(0, 11),
      message.data["body"],
      message.data["title"],
      DateFormat('kk:mm:a').format(DateTime.now())
    ]).whenComplete(() => print("background notification is set !!!"));
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CompanyData(),
        ),
        ChangeNotifierProvider(
          create: (context) => DaysOffData(),
        ),
        ChangeNotifierProvider(
          create: (context) => ReportsData(),
        ),
        ChangeNotifierProvider(
          create: (context) => ShiftsData(),
        ),
        ChangeNotifierProvider(
          create: (context) => MemberData(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserData(),
        ),
        ChangeNotifierProvider(
          create: (context) => SiteData(),
        ),
        ChangeNotifierProvider(
          create: (context) => ShiftApi(),
        ),
        ChangeNotifierProvider(
          create: (context) => PermissionHan(),
        ),
        ChangeNotifierProvider(
          create: (context) => VacationData(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserPermessionsData(),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationDataService(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserHolidaysData(),
        ),
        ChangeNotifierProvider(
          create: (context) => MissionsData(),
        )
      ],
      child: ScreenUtilInit(
        designSize: Size(392.72, 807.27),
        builder: () {
          return StreamProvider<ConnectivityStatus>(
              create: (context) =>
                  ConnectivityService().connectionStatusController.stream,
              builder: (context, snapshot) {
                return MaterialApp(
                    title: "Chilango v3",
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(fontFamily: "Almarai-Regular"),
                    home: SplashScreen());
              });
        },
      ),
    );
  }
}
