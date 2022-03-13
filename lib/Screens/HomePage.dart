import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';
import 'package:qr_users/Screens/AttendScanner.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/main.dart';
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
import 'package:http/http.dart' as http;
// var cron1;
// var cron2;

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
      final notificationProv =
          Provider.of<NotificationDataService>(context, listen: false);
      notificationProv.firebaseMessagingConfig(context);
      notificationProv.tokenRefresh();
    }
    final newVersion = NewVersion();
    // ignore: cascade_invocations
    // newVersion.showAlertIfNecessary(
    //   context: context,
    // );

    //Check for updates
    final DownloadService downloadService = DownloadService();
    downloadService.checkReleaseDate(showApk, context);
    // Provider.of<NotificationDataService>(context, listen: false)
    //     .huaweiMessagingConfig(context);
    Provider.of<NotificationDataService>(context, listen: false)
        .notificationPermessions();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  bool displayAttendDialog =
      locator.locator<PermissionHan>().attendProovTriggered;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        final userDataProvider = Provider.of<UserData>(context, listen: false);
        final CompanySettingsService _companyService = CompanySettingsService();

        if (userDataProvider.user.userType == 0) {
          _companyService
              .isCompanySuspended(
                  Provider.of<CompanyData>(context, listen: false).com.id,
                  userDataProvider.user.userToken)
              .then((value) {
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

    return displayAttendDialog
        ? StackedNotificaitonAlert(
            popWidget: false,
            callBackFun: () {
              setState(() {
                displayAttendDialog = !displayAttendDialog;
                locator.locator<PermissionHan>().setAttendProoftoDefault();
              });
            },
            isFromBackground: true,
            notificationTitle: getTranslated(context, "اثبات حضور"),
            notificationContent: getTranslated(
                context, "برجاء اثبات حضورك قبل انتهاء الوقت المحدد"),
            roundedButtonTitle: getTranslated(context, "اثبات"),
            lottieAsset: "resources/notificationalarm.json",
            notificationToast: getTranslated(context, "تم اثبات الحضور بنجاح"),
            showToast: true,
            repeatAnimation: true,
          )
        : WillPopScope(
            onWillPop: onWillPop,
            child: GestureDetector(
              onTap: () async {
                final response = await http.get(
                  Uri.parse(
                      "https://iid.googleapis.com/iid/info/eT_lIIZZSGKty7uxfyeVba:APA91bFM95bxyfbVCXyOfA-EILER6EkUk2CxIUZHMPu1VNrdkK3Ud9c7_aOW5dcfGJTR7NUtvpBE1X5xiDC-Bo0WgslxDTsCBaTxkB9Zea-HvUTNEzN96cgQJT4Hx4u9vB_E97Bae1H-?details=true"),
                  headers: {
                    "Authorization": "Bearer $serverToken",
                  },
                );
                print(response.body);
                // print(_startTime.hour);
                // print(locator.locator<PermissionHan>().isServerDown);
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
                                            builder: (context) =>
                                                const ScanPage(),
                                          ),
                                        );
                                      },
                                      title: getTranslated(context, "سجل الأن"),
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
    final DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: getTranslated(context, "اضغط مره اخرى للخروج من التطبيق"),
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
