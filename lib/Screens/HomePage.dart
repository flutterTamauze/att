import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';
import 'package:qr_users/Screens/AttendScanner.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

import 'package:qr_users/services/permissions_data.dart';
import 'dart:ui' as ui;
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';

import '../constants.dart';

var cron1;
var cron2;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

Future<bool> detectJailBreak() async {
  bool jaibreak;

  try {
    jaibreak = await FlutterJailbreakDetection.jailbroken;
  } on PlatformException {
    jaibreak = true;
  }

  return jaibreak;
}

Future<bool> isConnectedToInternet(String url) async {
  try {
    final result = await InternetAddress.lookup(url);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      return true;
    }
  } on SocketException catch (_) {
    print('not connected');
    return false;
  }
  return false;
}

AudioCache player = AudioCache();
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
void notificationPermessions() async {
  NotificationSettings settings = await firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print("User granted permession ${settings.authorizationStatus}");
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const MethodChannel _channel =
      MethodChannel('tdsChilango.com/channel_test');
  Map<String, String> channelMap = {
    "id": "ChilangoNotifications",
    "name": "tdsChilango",
    "description": "notifications",
  };
  createNewChannel() async {
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // test();

    checkBackgroundNotification();
    checkForegroundNotification();
    checkForNotificationData();
    notificationPermessions();
    Provider.of<NotificationDataService>(context, listen: false)
        .firebaseMessagingConfig(context);

    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print("App resumed !");

      // checkForNotificationData();
    }
  }

  saveNotificationToCache(RemoteMessage event) async {
    await db.insertNotification(
        NotificationMessage(
          category: event.data["category"],
          dateTime: DateTime.now().toString().substring(0, 10),
          message: event.notification.body,
          messageSeen: 0,
          title: event.notification.title,
        ),
        context);
    player.play("notification.mp3");
  }

  checkBackgroundNotification() async {
    await FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        print(value.notification.body);
        print(value.notification.title);
        saveNotificationToCache(value);
        player.play("notification.mp3");
      }
    });
  }

  checkForegroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      print("####Recveiving data on message tapped ####");
      print(event.notification.body);
      print(event.notification.title);
      saveNotificationToCache(event);
      player.play("notification.mp3");
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          Future.delayed(Duration(minutes: 1), () {
            Navigator.of(context).pop();
          });
          return Stack(
            children: [
              Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0)), //this right here
                  child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Container(
                        height: 200.h,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50.h,
                              ),
                              InkWell(
                                onTap: () {},
                                child: Text(
                                  "اثبات حضور",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Divider(),
                              Text("برجاء اثبات حضورك قبل انتهاء الوقت المحدد"),
                              SizedBox(
                                height: 20.h,
                              ),
                              RoundedButton(
                                  title: "اثبات",
                                  onPressed: () {
                                    Fluttertoast.showToast(
                                        msg: "تم اثبات الحضور بنجاح",
                                        backgroundColor: Colors.green,
                                        gravity: ToastGravity.CENTER);

                                    Navigator.pop(context);
                                  }),
                            ],
                          ),
                        ),
                      ))),
              Positioned(
                  right: 125.w,
                  top: 200.h,
                  child: Container(
                    width: 150.w,
                    height: 150.h,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Lottie.asset("resources/notificationalarm.json",
                          fit: BoxFit.fill),
                    ),
                  ))
            ],
          );
        },
      );
    });
  }

  checkForNotificationData() async {
    final prefs = await SharedPreferences.getInstance();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    if (prefs.getString("notifCategory") == 'attend') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          Future.delayed(Duration(minutes: 5), () {
            Navigator.of(context).pop();
          });
          return Stack(
            children: [
              Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0)), //this right here
                  child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Container(
                        height: 200.h,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50.h,
                              ),
                              InkWell(
                                onTap: () {},
                                child: Text(
                                  "اثبات حضور",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Divider(),
                              Text("برجاء اثبات حضورك قبل انتهاء الوقت المحدد"),
                              SizedBox(
                                height: 20.h,
                              ),
                              RoundedButton(
                                  title: "اثبات",
                                  onPressed: () async {
                                    Fluttertoast.showToast(
                                        msg: "تم اثبات الحضور بنجاح",
                                        backgroundColor: Colors.green,
                                        gravity: ToastGravity.CENTER);
                                    Provider.of<PermissionHan>(context,
                                            listen: false)
                                        .setNotificationbool(false);
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setString("notifCategory", "");

                                    Navigator.pop(context);
                                  }),
                            ],
                          ),
                        ),
                      ))),
              Positioned(
                  right: 125.w,
                  top: 200.h,
                  child: Container(
                    width: 150.w,
                    height: 150.h,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Lottie.asset("resources/notificationalarm.json",
                          fit: BoxFit.fill),
                    ),
                  ))
            ],
          );
        },
      );

      // startTimer();
    }
  }

  int levelClock = 300;
  DateTime currentBackPressTime;
  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);

    return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () async {
            // await createNewChannel();
            print(Provider.of<UserData>(context, listen: false).user.userToken);
            print(await firebaseMessaging.getToken());
          },
          child: Scaffold(
            endDrawer: NotificationItem(),
            backgroundColor: Colors.white,
            drawer: userDataProvider.user.userType == 0 ? DrawerI() : null,
            body: Container(
                padding: EdgeInsets.only(bottom: 15.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    userDataProvider.user.userType == 0
                        ? Header(
                            nav: true,
                          )
                        : Container(),
                    Expanded(
                      child: Center(
                        child: Lottie.asset("resources/qrlottie.json",
                            repeat: true),
                      ),
                    ),
                    Column(
                      children: [
                        Provider.of<PermissionHan>(context, listen: true)
                                    .showNotification ==
                                true
                            ? Container()
                            : Container(
                                child: RoundedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ScanPage(),
                                      ),
                                    );
                                  },
                                  title: "سجل الأن",
                                ),
                              ),
                        SizedBox(
                          height: 15.h,
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        ));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    ///check if he pressed back twich in the 2 seconds duration
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: "اضغط مره اخرى للخروج من التطبيق",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.orange,
        fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
      );
      return Future.value(false);
    } else {
      SystemNavigator.pop();
      return Future.value(false);
    }
  }
}
