import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/Screens/AttendScanner.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/CompanySettings/companySettings.dart';
import 'package:qr_users/services/Download/download_service.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/Subscribtion_end_dialog.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
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

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

bool showApk = true;

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    if (Provider.of<UserData>(context, listen: false).user.userType == 0) {
      var notificationProv =
          Provider.of<NotificationDataService>(context, listen: false);
      notificationProv.firebaseMessagingConfig(context);
    }
    //Check for updates
    DownloadService downloadService = DownloadService();
    downloadService.checkReleaseDate(showApk, context);
    // Provider.of<NotificationDataService>(context, listen: false)
    //     .huaweiMessagingConfig(context);
    Provider.of<NotificationDataService>(context, listen: false)
        .notificationPermessions();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        final userDataProvider = Provider.of<UserData>(context, listen: false);
        CompanySettingsService _companyService = CompanySettingsService();

        if (userDataProvider.user.userType == 0) {
          _companyService
              .isCompanySuspended(
                  Provider.of<CompanyData>(context, listen: false).com.id,
                  userDataProvider.user.userToken)
              .then((value) {
            log(value.toString());
            if (value == true) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return DisplaySubscrtibitionEndDialog(
                      companyService: _companyService);
                },
              );
            }
          });
        }
      }
    }
  }

  DateTime currentBackPressTime;
  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    showApk = false;
    SystemChrome.setEnabledSystemUIOverlays([]);

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
