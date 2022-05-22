import 'dart:developer';
// import 'package:huawei_push/huawei_push_library.dart' as hawawi;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';
import 'package:qr_users/Screens/AdminPanel/pending_company_permessions.dart';
import 'package:qr_users/Screens/AdminPanel/pending_company_vacations.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/ReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SettingsScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/AttendByCard/SystemHomePage.dart';
import 'package:qr_users/Screens/errorscreen2.dart';
import 'package:qr_users/enums/connectivity_status.dart';
import 'package:qr_users/services/CompanySettings/companySettings.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/Subscribtion_end_dialog.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';

class NavScreenTwo extends StatefulWidget {
  final int index;

  const NavScreenTwo(this.index);

  @override
  _NavScreenTwoState createState() => _NavScreenTwoState(index);
}

class _NavScreenTwoState extends State<NavScreenTwo>
    with WidgetsBindingObserver {
  _NavScreenTwoState(this.getIndex);

  final getIndex;
  var current = 0;
  var x = true;

  PageController _controller = PageController();

  List<Widget> _screens = [
    HomePage(),
    SystemHomePage(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  _onPageChange(int indx) {
    debugPrint("change");
    setState(() {
      current = indx;
    });
  }

  // Future<void> initPlatformState() async {
  //   if (!mounted) return;
  //   hawawi.Push.onNotificationOpenedApp.listen(_onNotificationOpenedApp);
  // }

  // Future<void> onHuaweiOpened() async {
  //   if (!mounted) return;
  //   hawawi.Push.onLocalNotificationClick.listen(_onLocalNotificationClickEvent);
  // }

  // _onLocalNotificationClickEvent(Map<String, dynamic> event) {
  //   debugPrint("onBACKGROUND click");
  //   debugPrint(event);
  // }

  // Future<void> initPlatformState() async {
  //   if (!mounted) return;
  //   hawawi.Push.onNotificationOpenedApp.listen(_onNotificationOpenedApp);
  // }

  @override
  void initState() {
    current = getIndex;
    // initPlatformState();
    // initPlatformState();
    final notificationProv =
        Provider.of<NotificationDataService>(context, listen: false);
    notificationProv.firebaseMessagingConfig(context);
    // if (Provider.of<UserData>(context, listen: false).user.osType == 3) {
    //   // notificationProv.huaweiMessagingConfig(context);

    //   notificationProv.getInitialNotification(context);
    // }
    checkNotificationWhenAppIsTerminate();
    checkForegroundNotification();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // void _onNotificationOpenedApp(RemoteMessage remoteMessage) {
  //   debugPrint("onNotificationOpenedApp: " + remoteMessage.data.toString());
  // }

  saveNotificationToCache(RemoteMessage event) async {
    if (mounted)
      await db.insertNotification(
          NotificationMessage(
            category: event.data["category"],
            dateTime: DateTime.now().toString().substring(0, 10),
            message: event.notification.body,
            messageSeen: 0,
            title: event.notification.title,
          ),
          context);
    // player.play("notification.mp3");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        final CompanySettingsService _companyService = CompanySettingsService();
        final userDataProvider = Provider.of<UserData>(context, listen: false);
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

  NotificationDataService _notifService = NotificationDataService();
  checkNotificationWhenAppIsTerminate() {
    FirebaseMessaging.instance.getInitialMessage().then((notification) {
      if (notification != null) {
        print("${notification.data['title']}");
        Provider.of<NotificationDataService>(context, listen: false)
            .readNotificationByTime(notification.data['title']);
        final userType =
            Provider.of<UserData>(context, listen: false).user.userType;
        if (userType == 3 || userType == 4 || userType == 6) {
          debugPrint(
              "####Recveiving data ontapped terminated app  with category equal ${notification.data['category']}####");
          handlePermessionVacOnRecieved(context, notification);
        }
      }
    });
  }

  handlePermessionVacOnRecieved(
      BuildContext context, RemoteMessage notification) {
    if (notification.data['category'] == "permessionRequest") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PendingCompanyPermessions(),
          ));
    } else if (notification.data['category'] == "vacationRequest") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PendingCompanyVacations(),
          ));
    }
  }

  checkForegroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      debugPrint(
          "####Recveiving data on message tapped with category equal ${event.data['category']}####");
      if (mounted) {
        saveNotificationToCache(event);
        // player.play("notification.mp3");
        if (event.data["category"] == "attend") {
          log("Opened an attend proov notification !");

          _notifService.showAttendanceCheckDialog(context);
        }
      } else {
        handlePermessionVacOnRecieved(context, event);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    final connectionStatus = Provider.of<ConnectivityStatus>(context);
    return connectionStatus == ConnectivityStatus.Offline &&
            userData.cachedUserData.isNotEmpty
        ? ErrorScreen2(
            child: Container(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            drawer: DrawerI(),
            endDrawer: NotificationItem(),
            bottomNavigationBar: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: CurvedNavigationBar(
                color: ColorManager.accentColor,
                index: current,
                backgroundColor: ColorManager.backGroundColor,
                onTap: (value) {
                  setState(() {
                    current = value;
                    _controller.jumpToPage(value);
                  });
                },
                items: userDataProvider.user.userType >= 2
                    ? userDataProvider.user.userType == 4 ||
                            userDataProvider.user.userType == 3 ||
                            userDataProvider.user.userType == 2
                        ? [
                            Icon(
                              Icons.home,
                              size: ScreenUtil()
                                  .setSp(30, allowFontScalingSelf: true),
                              color: ColorManager.primary,
                            ),
                            Icon(
                              Icons.qr_code,
                              size: ScreenUtil()
                                  .setSp(30, allowFontScalingSelf: true),
                              color: ColorManager.primary,
                            ),
                            Icon(
                              Icons.article_sharp,
                              size: ScreenUtil()
                                  .setSp(30, allowFontScalingSelf: true),
                              color: ColorManager.primary,
                            ),
                            Icon(
                              Icons.settings,
                              color: ColorManager.primary,
                              size: ScreenUtil()
                                  .setSp(30, allowFontScalingSelf: true),
                            ),
                          ]
                        : [
                            Icon(
                              Icons.home,
                              size: ScreenUtil()
                                  .setSp(30, allowFontScalingSelf: true),
                              color: ColorManager.primary,
                            ),
                            Icon(
                              Icons.qr_code,
                              size: ScreenUtil()
                                  .setSp(30, allowFontScalingSelf: true),
                              color: ColorManager.primary,
                            ),
                            Icon(
                              Icons.article_sharp,
                              size: ScreenUtil()
                                  .setSp(30, allowFontScalingSelf: true),
                              color: ColorManager.primary,
                            ),
                          ]
                    : [
                        Icon(
                          Icons.home,
                          color: ColorManager.primary,
                          size: ScreenUtil()
                              .setSp(30, allowFontScalingSelf: true),
                        ),
                        Icon(
                          Icons.qr_code,
                          color: Colors.orange,
                          size: ScreenUtil()
                              .setSp(30, allowFontScalingSelf: true),
                        ),
                      ],
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    Header(
                      nav: true,
                    ),
                    Expanded(
                      child: PageView.builder(
                        itemBuilder: (context, index) {
                          return _screens[current];
                        },
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _screens.length,
                        scrollDirection: Axis.horizontal,
                        controller: _controller,
                        onPageChanged: _onPageChange,
                      ),
                    ),
                  ],
                ),
              ],
            ));
  }
}
