import 'dart:developer';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:huawei_push/huawei_push_library.dart' as hawawi;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
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

class NavScreenTwo extends StatefulWidget {
  final int index;

  NavScreenTwo(this.index);

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
    print("change");
    setState(() {
      current = indx;
    });
  }

  // Future<void> initPlatformState() async {
  //   if (!mounted) return;
  //   hawawi.Push.onNotificationOpenedApp.listen(_onNotificationOpenedApp);
  // }

  Future<void> onHuaweiOpened() async {
    if (!mounted) return;
    hawawi.Push.onLocalNotificationClick.listen(_onLocalNotificationClickEvent);
  }

  _onLocalNotificationClickEvent(Map<String, dynamic> event) {
    print("onBACKGROUND click");
    print(event);
  }

  // Future<void> initPlatformState() async {
  //   if (!mounted) return;
  //   hawawi.Push.onNotificationOpenedApp.listen(_onNotificationOpenedApp);
  // }

  @override
  void initState() {
    current = getIndex;
    // initPlatformState();
    // initPlatformState();
    var notificationProv =
        Provider.of<NotificationDataService>(context, listen: false);
    notificationProv.firebaseMessagingConfig(context);
    if (Provider.of<UserData>(context, listen: false).user.osType == 3) {
      notificationProv.huaweiMessagingConfig(context);

      notificationProv.getInitialNotification(context);
    }

    checkForegroundNotification();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // void _onNotificationOpenedApp(RemoteMessage remoteMessage) {
  //   print("onNotificationOpenedApp: " + remoteMessage.data.toString());
  // }

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
    // player.play("notification.mp3");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        CompanySettingsService _companyService = CompanySettingsService();
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
  checkForegroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      print("####Recveiving data on message tapped ####");
      print(event.notification.body);
      print(event.notification.title);
      print(event.data["category"] == "attend");
      saveNotificationToCache(event);
      // player.play("notification.mp3");
      if (event.data["category"] == "attend") {
        log("Opened an attend proov notification !");
        print(event.notification.body);
        print(event.notification.title);
        _notifService.showAttendanceCheckDialog(context);
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
    var userData = Provider.of<UserData>(context);
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    return connectionStatus == ConnectivityStatus.Offline &&
            userData.cachedUserData.isNotEmpty
        ? ErrorScreen2(
            child: Container(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            drawer: DrawerI(),
            endDrawer: NotificationItem(),
            bottomNavigationBar: CurvedNavigationBar(
              color: Colors.black,
              index: current,
              backgroundColor: Colors.white,
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
                            color: Colors.orange,
                          ),
                          Icon(
                            Icons.qr_code,
                            size: ScreenUtil()
                                .setSp(30, allowFontScalingSelf: true),
                            color: Colors.orange,
                          ),
                          Icon(
                            Icons.article_sharp,
                            size: ScreenUtil()
                                .setSp(30, allowFontScalingSelf: true),
                            color: Colors.orange,
                          ),
                          Icon(
                            Icons.settings,
                            color: Colors.orange,
                            size: ScreenUtil()
                                .setSp(30, allowFontScalingSelf: true),
                          ),
                        ]
                      : [
                          Icon(
                            Icons.home,
                            size: ScreenUtil()
                                .setSp(30, allowFontScalingSelf: true),
                            color: Colors.orange,
                          ),
                          Icon(
                            Icons.qr_code,
                            size: ScreenUtil()
                                .setSp(30, allowFontScalingSelf: true),
                            color: Colors.orange,
                          ),
                          Icon(
                            Icons.article_sharp,
                            size: ScreenUtil()
                                .setSp(30, allowFontScalingSelf: true),
                            color: Colors.orange,
                          ),
                        ]
                  : [
                      Icon(
                        Icons.home,
                        color: Colors.orange,
                        size:
                            ScreenUtil().setSp(30, allowFontScalingSelf: true),
                      ),
                      Icon(
                        Icons.qr_code,
                        color: Colors.orange,
                        size:
                            ScreenUtil().setSp(30, allowFontScalingSelf: true),
                      ),
                    ],
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
                        physics: new NeverScrollableScrollPhysics(),
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
