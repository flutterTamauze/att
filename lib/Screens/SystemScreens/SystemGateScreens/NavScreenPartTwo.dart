
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/ReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SettingsScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemHomePage.dart';
import 'package:qr_users/Screens/errorscreen2.dart';
import 'package:qr_users/enums/connectivity_status.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavScreenTwo extends StatefulWidget {
  final int index;

  NavScreenTwo(this.index);

  @override
  _NavScreenTwoState createState() => _NavScreenTwoState(index);
}

class _NavScreenTwoState extends State<NavScreenTwo> {
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

  @override
  void initState() {
    current = getIndex;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {var userData=Provider.of<UserData>(context);
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    return connectionStatus == ConnectivityStatus.Offline && userData.cachedUserData.isNotEmpty
        ? ErrorScreen2(
            child: Container(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            drawer: DrawerI(),
            bottomNavigationBar: CurvedNavigationBar(
              color: Colors.black,
              height: 60.h,
              index: current,
              backgroundColor: Colors.white,
              onTap: (value) {
                setState(() {
                  current = value;
                  _controller.jumpToPage(value);
                });
              },
              items: userDataProvider.user.userType >= 2
                  ? userDataProvider.user.userType == 4
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
