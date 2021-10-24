import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/Screens/AttendScanner.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_admin.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Download/download_service.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

var cron1;
var cron2;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

bool showApk = true;

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    //Check for updates
    if (Platform.isAndroid) {
      if (showApk) {
        showApk = false;

        if (kAndroidReleaseDate.isBefore(
            Provider.of<UserData>(context, listen: false).user.apkDate)) {
          Future.delayed(Duration.zero, () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  DownloadService downloadService = DownloadService();

                  return RoundedAlert(
                      onPressed: () async {
                        Navigator.pop(context);
                        downloadService.downloadApkFromUrl(
                            "ChilangoV3.apk", context);
                      },
                      title: 'تحديث التطبيق لأخر اصدار ؟',
                      content: "");
                });
          });
        }
      }
    } else {
      if (showApk) {
        showApk = false;

        if (kiosReleaseDate.isBefore(
            Provider.of<UserData>(context, listen: false).user.iosBundleDate)) {
          Future.delayed(Duration.zero, () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RoundedAlert(
                      onPressed: () async {
                        Navigator.pop(context);
                        launch(iosDownloadLink);
                      },
                      title: 'تحديث التطبيق لأخر اصدار ؟',
                      content: "");
                });
          });
        }
      }
    }

    Provider.of<NotificationDataService>(context, listen: false)
        .firebaseMessagingConfig(context);
    Provider.of<NotificationDataService>(context, listen: false)
        .huaweiMessagingConfig(context);
    Provider.of<NotificationDataService>(context, listen: false)
        .notificationPermessions();

    super.initState();
  }

  static Future<String> getDeviceUUID() async {
    String identifier;

    try {
      if (Platform.isAndroid) {
        identifier = await FlutterUdid.udid; //UUID for Android
      } else if (Platform.isIOS) {
        final storage = new FlutterSecureStorage();
        identifier = await storage.read(key: "deviceMac"); //UUID for iOS
      }
    } catch (e) {
      print('Failed to get platform version');
    }
//if (!mounted) return;
    return identifier;
  }

  DateTime currentBackPressTime;
  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    showApk = false;
    SystemChrome.setEnabledSystemUIOverlays([]);
    print(Provider.of<PermissionHan>(context, listen: false)
        .attendProovTriggered);
    return Provider.of<PermissionHan>(context, listen: true)
            .attendProovTriggered
        ? StackedNotificaitonAlert(
            popWidget: false,
            isFromBackground: true,
            notificationTitle: "اثبات حضور",
            notificationContent: "برجاء اثبات حضورك قبل انتهاء الوقت المحدد",
            roundedButtonTitle: "اثبات",
            lottieAsset: "resources/notificationalarm.json",
            notificationToast: "تم اثبات الحضور بنجاح",
            showToast: true,
            repeatAnimation: true,
          )
        : WillPopScope(
            onWillPop: onWillPop,
            child: GestureDetector(
              onTap: () async {},
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
