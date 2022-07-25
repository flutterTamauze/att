import 'dart:developer';
import 'dart:io';

import 'package:get_it/get_it.dart';
// import 'package:huawei_push/huawei_push_library.dart' as hawawi;
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
import 'GetitLocator/locator.dart';
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
// HuaweiServices huaweiServices = HuaweiServices();
InitLocator locator = InitLocator();
GetIt getIt = GetIt.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp();
  // await hawawi.Push.registerBackgroundMessageHandler(
  //     backgroundMessageCallback);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  const bool isError = false;
  if (Platform.isAndroid) {
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
    } catch (e) {
      log(e);
    }
  }
  locator.intalizeLocator();
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // prefs.setStringList("bgNotifyList", []);
    if (message.data["category"] != "reloadData") {
      await prefs
          .setString("notifCategory", message.data["category"])
          .whenComplete(() =>
              debugPrint("category added !!! ${message.data["category"]}"));

      final List<String> cachedList = await prefs.getStringList("bgNotifyList");
      cachedList.add(message.data["category"]);
      // ignore: cascade_invocations
      cachedList.add(
        DateTime.now().toString().substring(0, 11),
      );
      // ignore: cascade_invocations
      cachedList.add(message.data["body"]);
      // ignore: cascade_invocations
      cachedList.add(message.data["title"]);
      // ignore: cascade_invocations
      cachedList.add(DateFormat('kk:mm:a').format(DateTime.now()));
      await prefs.setStringList("bgNotifyList", cachedList).whenComplete(() =>
          debugPrint(
              "cached list update with total length ${cachedList.length}"));
    }
  } catch (e) {
    log(e);
  }
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
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
    // if (Platform.isAndroid) huaweiHandler();

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
          create: (context) => getIt<CompanyData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<DaysOffData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<ReportsData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<ShiftsData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<MemberData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<UserData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<SiteData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<ShiftApi>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<PermissionHan>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<VacationData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<UserPermessionsData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<NotificationDataService>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<UserHolidaysData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<MissionsData>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<SiteShiftsData>(),
        )
      ],
      child: ScreenUtilInit(
        designSize: const Size(392.72, 807.27),
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
                    supportedLocales: [
                      const Locale('ar', 'SA'),
                      const Locale('en', 'US'),
                    ],
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
// }
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:qr_users/GetitLocator/locator.dart';

// void main() {
//   runApp(MyApp());
// }

// InitLocator locator = InitLocator();
// GetIt getIt = GetIt.instance;
// final navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({this.title}) : super();
//   static void setLocale(BuildContext context, Locale newLocale) {
//     // ignore: cascade_invocations
//   }

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   Locale _locale;
//   setLocale(Locale locale) {
//     setState(() {
//       _locale = locale;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
// void backgroundMessageCallback(hawawi.RemoteMessage remoteMessage) async {
//   final String data = remoteMessage.data;
//   final decodedResponse = json.decode(data);
//   debugPrint(data);

//   hawawi.Push.localNotification({
//     hawawi.HMSLocalNotificationAttr.TITLE: decodedResponse["pushbody"]["title"],
//     hawawi.HMSLocalNotificationAttr.MESSAGE: decodedResponse["pushbody"]
//         ["description"],
//     hawawi.HMSLocalNotificationAttr.PLAY_SOUND: true,
//     hawawi.HMSLocalNotificationAttr.SMALL_ICON: "@mipmap/launcher_icon",
//     hawawi.HMSLocalNotificationAttr.LARGE_ICON: "@mipmap/launcher_icon",
//     hawawi.HMSLocalNotificationAttr.ACTIONS: ["OPEN"],
//     hawawi.HMSLocalNotificationAttr.PRIORITY: "HIGH",
//     hawawi.HMSLocalNotificationAttr.SOUND_NAME: "your_sweet_sound.wav",
//     hawawi.HMSLocalNotificationAttr.VIBRATE: false,
//   });
// }

// huaweiHandler() async {
//   final HuaweiServices _huawei = HuaweiServices();
//   if (await _huawei.isHuaweiDevice()) {
//     await hawawi.Push.turnOnPush();
//     final bool backgroundMessageHandler =
//         await hawawi.Push.registerBackgroundMessageHandler(
//             backgroundMessageCallback);
//     debugPrint("backgroundMessageHandler registered: $backgroundMessageHandler");
//   }
// }