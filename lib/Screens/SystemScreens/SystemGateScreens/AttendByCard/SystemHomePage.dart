import 'dart:async';
// import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/AttendByCard/attendByCardRetryButton.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/QR/qr_display.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'attendByCardButton.dart';

class SystemHomePage extends StatefulWidget {
  @override
  _SystemHomePageState createState() => _SystemHomePageState();
}

class _SystemHomePageState extends State<SystemHomePage> {
  CameraDescription cameraDescription;
  DateTime currentBackPressTime;
  Future futureShift;
  // AudioCache player = AudioCache();
  _startUp() async {
    final List<CameraDescription> cameras = await availableCameras();

    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
  }

  Timer timer;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initState() {
    Provider.of<NotificationDataService>(context, listen: false)
        .notificationPermessions();
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
          Timer(const Duration(seconds: 2), () async {
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
                            builder: (context) => const NavScreenTwo(0),
                          ));
                    }
                  }
                },
                onCancel: () {
                  // Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NavScreenTwo(0),
                      ));
                });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final userData = Provider.of<UserData>(context, listen: false);
    return Consumer<ShiftApi>(builder: (context, shiftApiConsumer, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: FutureBuilder(
            future: futureShift,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                );
              }

              // if (shiftApiConsumer.isOnLocation) {
              //   _croneScheduler.shecdularFetching(context);
              // }

              return Container(
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
                                                      child: const Divider(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 20,
                                                      child: AutoSizeText(
                                                        getTranslated(
                                                            context, "او"),
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
                                                      child: const Divider(
                                                        color: Colors.black,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 20.h,
                                                ),
                                                const AttendByCardButton()
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
                                          return const Center(
                                              child: CircularProgressIndicator(
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(Colors.orange),
                                          ));
                                        } else {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  futureShift =
                                                      Provider.of<ShiftApi>(
                                                              context,
                                                              listen: false)
                                                          .getShiftData(
                                                              userData.user.id,
                                                              userData.user
                                                                  .userToken);
                                                  setState(() {});
                                                },
                                                child:
                                                    const AttendByCardRetryButton(),
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
          builder: (context) => const NavScreenTwo(0),
        ));
    return Future.value(false);
  }
}

final qrdataFeed = TextEditingController();
