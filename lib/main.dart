import 'dart:convert';
import 'dart:io';

import 'package:huawei_push/huawei_push_library.dart' as hawawi;
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SplashScreen.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'Core/lang/Localization/localization.dart';
import 'Core/themeManager.dart';
import 'FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/connectivity_service.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'enums/connectivity_status.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey alertKey =
    GlobalKey<NavigatorState>(debugLabel: 'AppNavigator');
List<CameraDescription> cameras;
const MethodChannel _channel = MethodChannel('tdsChilango.com/channel_test');
Map<String, String> channelMap = {
  "id": "ChilangoNotifications",
  "name": "tdsChilango.com/channel_test",
  "description": "notifications",
};
HuaweiServices huaweiServices = HuaweiServices();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (Platform.isAndroid)
    await hawawi.Push.registerBackgroundMessageHandler(
        backgroundMessageCallback);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  cameras = await availableCameras();
  if (Platform.isAndroid) {
    await _channel.invokeMethod('createNotificationChannel', channelMap);
  }

  runApp(MyApp());
}

void backgroundMessageCallback(hawawi.RemoteMessage remoteMessage) async {
  String data = remoteMessage.data;
  var decodedResponse = json.decode(data);
  print(data);

  hawawi.Push.localNotification({
    hawawi.HMSLocalNotificationAttr.TITLE: decodedResponse["pushbody"]["title"],
    hawawi.HMSLocalNotificationAttr.MESSAGE: decodedResponse["pushbody"]
        ["description"],
    hawawi.HMSLocalNotificationAttr.PLAY_SOUND: true,
    hawawi.HMSLocalNotificationAttr.SMALL_ICON: "@mipmap/launcher_icon",
    hawawi.HMSLocalNotificationAttr.LARGE_ICON: "@mipmap/launcher_icon",
    hawawi.HMSLocalNotificationAttr.ACTIONS: ["OPEN"],
    hawawi.HMSLocalNotificationAttr.PRIORITY: "HIGH",
    hawawi.HMSLocalNotificationAttr.SOUND_NAME: "your_sweet_sound.wav",
    hawawi.HMSLocalNotificationAttr.VIBRATE: false,
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    prefs.setStringList("bgNotifyList", []);
    if (message.data["category"] != "reloadData") {
      if (prefs.getString('notifCategory') == "" ||
          prefs.getString('notifCategory') == null) {
        prefs.setString("notifCategory", message.data["category"]);
      }
      await prefs.setStringList("bgNotifyList", [
        message.data["category"],
        DateTime.now().toString().substring(0, 11),
        message.data["body"],
        message.data["title"],
        DateFormat('kk:mm:a').format(DateTime.now())
      ]).whenComplete(() => print("background notification is set !!!"));
    }
  } catch (e) {
    print(e);
  }
}

huaweiHandler() async {
  HuaweiServices _huawei = HuaweiServices();
  if (await _huawei.isHuaweiDevice()) {
    await hawawi.Push.turnOnPush();
    final bool backgroundMessageHandler =
        await hawawi.Push.registerBackgroundMessageHandler(
            backgroundMessageCallback);
    print("backgroundMessageHandler registered: $backgroundMessageHandler");
  }
}

void _changeLangugage(Langugage) {}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    // ignore: cascade_invocations
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

final navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    if (Platform.isAndroid) huaweiHandler();

    super.initState();
  }

  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

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
        ),
        ChangeNotifierProvider(
          create: (context) => SiteShiftsData(),
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
                    locale: _locale,
                    localizationsDelegates: [
                      DemoLocalization.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: [Locale('en', 'US'), Locale('ar', 'SA')],
                    localeResolutionCallback: (locale, supportedLocales) {
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                                locale.languageCode &&
                            supportedLocale.countryCode == locale.countryCode) {
                          return supportedLocale;
                        }
                      }
                      return supportedLocales.first;
                    },
                    navigatorKey: navigatorKey,
                    title: "Chilango",
                    debugShowCheckedModeBanner: false,
                    theme: getApplicationTheme(),
                    home: SplashScreen());
              });
        },
      ),
    );
  }
}
