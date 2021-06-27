import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_users/MLmodule/db/database.dart';
import 'package:qr_users/MLmodule/services/facenet.service.dart';
import 'package:qr_users/MLmodule/services/ml_kit_service.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/CameraPickerScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:ui' as ui;

import 'package:qr_users/widgets/roundedAlert.dart';

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

              return Container(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: shiftApiConsumer.isConnected
                                      ? shiftApiConsumer.permissionOff
                                          ? shiftApiConsumer
                                                      .isLocationServiceOn !=
                                                  0
                                              ? shiftApiConsumer
                                                          .isLocationServiceOn !=
                                                      2
                                                  ? shiftApiConsumer
                                                          .isOnLocation
                                                      ? shiftApiConsumer
                                                              .isOnShift
                                                          ? Column(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  height: 250.h,
                                                                  child: Center(
                                                                    child:
                                                                        Container(
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                              width: 2.w,
                                                                              color: Colors.black)),
                                                                      child:
                                                                          QrImage(
                                                                        foregroundColor:
                                                                            Colors.black,
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        //plce where the QR Image will be shown
                                                                        data: shiftDataProvider
                                                                            .shiftQrCode,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 20,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "تسجيل عن طريق مسح الكود",
                                                                    maxLines: 1,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Container(
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                150),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.orange,
                                                                            width: 2)),
                                                                    child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(150),
                                                                        child: Image.network(
                                                                          '${Provider.of<CompanyData>(context, listen: true).com.logo}',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          loadingBuilder: (BuildContext context,
                                                                              Widget child,
                                                                              ImageChunkEvent loadingProgress) {
                                                                            if (loadingProgress ==
                                                                                null)
                                                                              return child;
                                                                            return Center(
                                                                              child: CircularProgressIndicator(
                                                                                backgroundColor: Colors.white,
                                                                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
                                                                                value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                                              ),
                                                                            );
                                                                          },
                                                                        )),
                                                                    height:
                                                                        150.h,
                                                                    width:
                                                                        150.w,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5.h,
                                                                  ),
                                                                  Directionality(
                                                                    textDirection: ui
                                                                        .TextDirection
                                                                        .rtl,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          45.h,
                                                                      child:
                                                                          AutoSizeText(
                                                                        " تسجيل الحضور من ${amPmChanger(shiftApiConsumer.shiftsListProvider[0].shiftStartTime)} إلى ${amPmChanger(shiftApiConsumer.shiftsListProvider[0].shiftEndTime)} \n تسجيل الانصراف من ${amPmChanger(shiftApiConsumer.shiftsListProvider[1].shiftStartTime)} إلى ${amPmChanger((shiftApiConsumer.shiftsListProvider[1].shiftEndTime) % 2400)}",
                                                                        maxLines:
                                                                            3,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: ScreenUtil().setSp(18, allowFontScalingSelf: true)),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                      : Container(
                                                          height: 100,
                                                          child: AutoSizeText(
                                                            "برجاء التواجد بالموقع المخصص لك\n${Provider.of<UserData>(context, listen: true).siteName}",
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 4,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                height: 2,
                                                                fontSize: ScreenUtil().setSp(
                                                                    18,
                                                                    allowFontScalingSelf:
                                                                        true)),
                                                          ),
                                                        )
                                                  : Container(
                                                      height: 100,
                                                      child: AutoSizeText(
                                                        "برجاء التواجد بالموقع المخصص لك\n${Provider.of<UserData>(context, listen: true).siteName}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 4,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            height: 2,
                                                            fontSize: ScreenUtil()
                                                                .setSp(18,
                                                                    allowFontScalingSelf:
                                                                        true)),
                                                      ),
                                                    )
                                              : Container(
                                                  height: 20,
                                                  child: AutoSizeText(
                                                    "برجاء تفعيل الموقع الجغرافى للهاتف ",
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: ScreenUtil()
                                                            .setSp(18,
                                                                allowFontScalingSelf:
                                                                    true)),
                                                  ),
                                                )
                                          : Container(
                                              height: 20,
                                              child: AutoSizeText(
                                                "برجاء تفعيل تصريح الموقع الجغرافي ",
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: ScreenUtil().setSp(
                                                        18,
                                                        allowFontScalingSelf:
                                                            true)),
                                              ),
                                            )
                                      : Column(
                                          children: [
                                            Container(
                                              child: Lottie.asset(
                                                  "resources/21485-wifi-outline-icon.json",
                                                  repeat: false),
                                              height: 200.h,
                                              width: 200.w,
                                            ),
                                            Container(
                                              height: 20,
                                              child: AutoSizeText(
                                                "لا يوجد اتصال بالانترنت ",
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: ScreenUtil().setSp(
                                                        18,
                                                        allowFontScalingSelf:
                                                            true)),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: shiftApiConsumer.permissionOff
                                  ? Provider.of<ShiftApi>(context, listen: true)
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
                                                            color: Colors.black,
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
                                                            CameraPicker(
                                                          camera:
                                                              cameraDescription,
                                                        ),
                                                      )),
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
                                                          "التسجيل ببطاقة التعريف الشخصية",
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
                                              child: CircularProgressIndicator(
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
                                                              ShiftApi>(context,
                                                          listen: false)
                                                      .getShiftData(
                                                          Provider.of<UserData>(
                                                                  context,
                                                                  listen: false)
                                                              .user
                                                              .id,
                                                          Provider.of<UserData>(
                                                                  context,
                                                                  listen: false)
                                                              .user
                                                              .userToken);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  width: getkDeviceWidthFactor(
                                                      context, 330.w),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: Colors.orange),
                                                  child: Center(
                                                    child: Container(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        "اضغط للمحاولة مره اخرى",
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
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
