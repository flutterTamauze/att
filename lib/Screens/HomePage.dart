import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/AttendScanner.dart';

import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class _HomePageState extends State<HomePage> {
  DateTime currentBackPressTime;
  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);

    return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () async {
            print(await detectJailBreak());
            await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.best)
                .then((value) {
              print(value.latitude);
              print(value.longitude);
              print(value.speed);
              print(value.speedAccuracy);
            });

            print(await Geolocator.isLocationServiceEnabled());

            // ignore: cancel_subscriptions
            // try {
            //   StreamSubscription<Position> positionStream =
            //       Geolocator.getPositionStream().listen((Position position) {
            //     print(position == null
            //         ? 'Unknown'
            //         : position.latitude.toString() +
            //             ', ' +
            //             position.longitude.toString());
            //   });
            // } catch (e) {
            //   print(e);
            // }
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
                    Expanded(
                      child: Center(
                        child: Lottie.asset("resources/qrlottie.json",
                            repeat: true),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
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
