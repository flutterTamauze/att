import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/Screens/AttendScanner.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/MainCompanySettings.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'dart:ui' as ui;
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    // test();

    checkForNotificationData();
    WidgetsBinding.instance.addObserver(this);

    notificationPermessions();
    Provider.of<NotificationDataService>(context, listen: false)
        .firebaseMessagingConfig(context);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print("App resumed !");

      // checkForNotificationData();
    }
  }

  Timer _timer;
  int seconds = 60;
  int minutes = 4;
  String timerText = "5:00";
  void startTimer() async {
    final prefs = await SharedPreferences.getInstance();
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      if (timerText == "0:01") {
        prefs.setString("notifCategory", "");

        timer.cancel();
        if (mounted)
          Provider.of<PermissionHan>(context, listen: false)
              .setNotificationbool(false);
      } else {
        setState(() {
          seconds = seconds - 1;
          if (seconds < 1) {
            minutes -= 1;
            seconds = 59;
          }
        });
      }
      timerText =
          '${minutes.remainder(60).toString()}:${seconds.remainder(60).toString().padLeft(2, '0')}';
      print(timerText);
    });
  }

  checkForNotificationData() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString("notifCategory") == 'attend') {
      Provider.of<PermissionHan>(context, listen: false)
          .setNotificationbool(true);
      startTimer();
    }
  }

  int levelClock = 300;
  DateTime currentBackPressTime;
  @override
  Widget build(BuildContext context) {
    if (Provider.of<PermissionHan>(context).currentDialogOnstream == false) {
      if (Provider.of<PermissionHan>(context, listen: false).showNotification) {
        startTimer();
        Provider.of<PermissionHan>(context).setDialogonStreambool(true);
      }
    }

    final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);

    return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () async {
            DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
            print('Running on ${androidInfo.androidId}');
            String udid = await FlutterUdid.udid;
            print(udid);
          },
          child: Scaffold(
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
                    Provider.of<PermissionHan>(context, listen: true)
                                .showNotification ==
                            false
                        ? Expanded(
                            child: Center(
                              child: Lottie.asset("resources/qrlottie.json",
                                  repeat: true),
                            ),
                          )
                        : Stack(
                            children: [
                              Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.0)), //this right here
                                  child: Directionality(
                                      textDirection: ui.TextDirection.rtl,
                                      child: Container(
                                        height: 250,
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
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              Divider(),
                                              Text(
                                                  "برجاء اثبات حضورك قبل انتهاء الوقت المحدد"),
                                              SizedBox(
                                                height: 20.h,
                                              ),
                                              RoundedButton(
                                                  title: "اثبات",
                                                  onPressed: () async {
                                                    Provider.of<PermissionHan>(
                                                            context,
                                                            listen: false)
                                                        .setNotificationbool(
                                                            false);
                                                    final prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    prefs.setString(
                                                        "notifCategory", "");
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "تم اثبات الحضور بنجاح",
                                                        backgroundColor:
                                                            Colors.green,
                                                        gravity: ToastGravity
                                                            .CENTER);

                                                    // Navigator.pop(context);
                                                  }),
                                              Spacer(),
                                              Text(
                                                "$timerText",
                                                style: TextStyle(
                                                    fontSize: 60,
                                                    color: Colors.orange),
                                              )
                                            ],
                                          ),
                                        ),
                                      ))),
                              Positioned(
                                  right: 125.w,
                                  top: 0.h,
                                  child: Container(
                                    width: 150.w,
                                    height: 150.h,
                                    padding: EdgeInsets.all(20),
                                    decoration:
                                        BoxDecoration(shape: BoxShape.circle),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: Lottie.network(
                                          "https://assets5.lottiefiles.com/packages/lf20_ktrj1k3o.json",
                                          fit: BoxFit.fill),
                                    ),
                                  ))
                            ],
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
