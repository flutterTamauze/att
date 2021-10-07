import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';

import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/QR/qr_display.dart';

import 'package:qr_users/widgets/roundedAlert.dart';

import 'SystemGateScreens/SytemScanner.dart';

class SystemHomePage extends StatefulWidget {
  @override
  _SystemHomePageState createState() => _SystemHomePageState();
}

class _SystemHomePageState extends State<SystemHomePage> {
  CameraDescription cameraDescription;
  DateTime currentBackPressTime;
  Future futureShift;
  AudioCache player = AudioCache();

  String amPmChanger(int intTime) {
    int hours = (intTime ~/ 100);
    int min = intTime - (hours * 100);

    var ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours != 0 ? hours : 12; //

    String hoursStr = hours < 10
        ? '0$hours'
        : hours.toString(); // the hour '0' should be '12'
    String minStr = min < 10 ? '0$min' : min.toString();

    var strTime = '$hoursStr:$minStr$ampm';

    return strTime;
  }

  _startUp() async {
    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
  }

  shecdularFetching() {
    cron1 = new Cron();
    var now = DateTime.now();
    var formater = DateFormat("Hm");
    int currentTime = int.parse(formater.format(now).replaceAll(":", ""));

    if (Provider.of<ShiftApi>(context, listen: false)
        .searchForCurrentShift(currentTime)) {
      shecdularFetching2(
        Provider.of<ShiftApi>(context, listen: false).currentShift.shiftEndTime,
      );
    } else {
      print("cron 1: you are not in working timeline");

      cron1.schedule(new Schedule.parse('*/1 * * * *'), () async {
        now = DateTime.now();
        formater = DateFormat("Hm");
        currentTime = int.parse(formater.format(now).replaceAll(":", ""));

        print(currentTime);
        if (Provider.of<ShiftApi>(context, listen: false)
            .searchForCurrentShift(currentTime)) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NavScreenTwo(1),
              ));
        } else {
          print("cron 1: continue");
        }
        print('cron 1: every 1 minutes ');
      });
    }
  }

  shecdularFetching2(int endTime) async {
    var end = endTime % 2400;
    print("crrent shift end Time = $end");
    player.play("clock.mp3");
    int hours = (end ~/ 100);
    int min = end - (hours * 100);
    cron1.close();
    print("cron2: start,  working to $hours:$min");
    Provider.of<ShiftApi>(context, listen: false).changeFlag(true);
    cron2 = new Cron();
    cron2.schedule(new Schedule.parse('$min $hours * * *'), () async {
      player.play("clock.mp3");
      print("cron2: end working");
      shecdularFetching();
      Provider.of<ShiftApi>(context, listen: false).changeFlag(false);
      cron2.close();

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavScreenTwo(1),
          ));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initState() {
    Provider.of<NotificationDataService>(context, listen: false)
        .notificationPermessions();
    Provider.of<NotificationDataService>(context, listen: false)
        .firebaseMessagingConfig(context);
    super.initState();
    _startUp();
    firstget();
  }

  getData() async {
    if (mounted) {
      futureShift = Provider.of<ShiftApi>(context, listen: false)
          .getShiftData(Provider.of<UserData>(context, listen: false).user.id,
              Provider.of<UserData>(context, listen: false).user.userToken)
          .then((value) {
        print(value);
        if (value == true) {
          return true;
        } else {
          Provider.of<ShiftApi>(context, listen: false).firstCall = true;
          Timer(Duration(seconds: 2), () async {
            // 5s over, navigate to a new page
            if (mounted) {
              futureShift = Provider.of<ShiftApi>(context, listen: false)
                  .getShiftData(
                      Provider.of<UserData>(context, listen: false).user.id,
                      Provider.of<UserData>(context, listen: false)
                          .user
                          .userToken);
            }
          });
        }
        // firstget();
      });
    }
  }

  firstget() async {
    if (await Permission.microphone.isGranted) {
      getData();
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return RoundedAlertEn(
                title: 'Permission',
                content: "Please accept this permission to show start work",
                onPressed: () async {
                  if (await Permission.microphone.isPermanentlyDenied) {
                    openAppSettings();
                  } else {
                    await Permission.microphone.request();
                    if (await Permission.microphone.isGranted) {
                      Navigator.pop(context);
                      getData();
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NavScreenTwo(0),
                          ));
                    }
                  }
                },
                onCancel: () {
                  // Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavScreenTwo(0),
                      ));
                });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    var shiftDataProvider =
        Provider.of<ShiftApi>(context, listen: true).currentShift;
    return Consumer<ShiftApi>(builder: (context, shiftApiConsumer, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: FutureBuilder(
            future: futureShift,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                );
              }

              if (shiftApiConsumer.isOnLocation) {
                print('dd');
                shecdularFetching();
              }

              return GestureDetector(
                onTap: () {
                  print("qr code");
                  print(shiftDataProvider.shiftQrCode);
                },
                child: Container(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            QrAttendDisplay(),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: shiftApiConsumer.permissionOff
                                    ? Provider.of<ShiftApi>(context,
                                                listen: true)
                                            .isOnLocation
                                        ? Provider.of<ShiftApi>(context,
                                                    listen: true)
                                                .isOnShift
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Container(
                                                        width: 120.w,
                                                        child: Divider(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 20,
                                                        child: AutoSizeText(
                                                          "او",
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(20,
                                                                      allowFontScalingSelf:
                                                                          true)),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 120.w,
                                                        child: Divider(
                                                          color: Colors.black,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 20.h,
                                                  ),
                                                  InkWell(
                                                    onTap: () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              SystemScanPage(),
                                                        )),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      width:
                                                          getkDeviceWidthFactor(
                                                              context, 330.w),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                              width: 1,
                                                              color:
                                                                  Colors.orange[
                                                                      600])),
                                                      child: Center(
                                                        child: Container(
                                                          height: 20,
                                                          child: AutoSizeText(
                                                            "التسجيل ببطاقة التعريف الشخصية",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: ScreenUtil()
                                                                    .setSp(18,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                                color: Colors
                                                                        .orange[
                                                                    600]),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Container()
                                        : Container()
                                    : FutureBuilder<void>(
                                        future: futureShift,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // If the Future is complete, display the preview.
                                            return Center(
                                                child:
                                                    CircularProgressIndicator(
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(Colors.orange),
                                            ));
                                          } else {
                                            // Otherwise, display a loading indicator.

                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    futureShift = Provider.of<
                                                                ShiftApi>(
                                                            context,
                                                            listen: false)
                                                        .getShiftData(
                                                            Provider.of<UserData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .user
                                                                .id,
                                                            Provider.of<UserData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .user
                                                                .userToken);
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    width:
                                                        getkDeviceWidthFactor(
                                                            context, 330.w),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        color: Colors.orange),
                                                    child: Center(
                                                      child: Container(
                                                        height: 20,
                                                        child: AutoSizeText(
                                                          "اضغط للمحاولة مره اخرى",
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(18,
                                                                      allowFontScalingSelf:
                                                                          true),
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      );
    });
  }

  Future<bool> onWillPop() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NavScreenTwo(0),
        ));
    return Future.value(false);
  }
}

final qrdataFeed = TextEditingController();
