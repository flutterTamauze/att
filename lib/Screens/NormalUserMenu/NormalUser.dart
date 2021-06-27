import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/DailyReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/LateCommersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';

import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/headers.dart';

import 'NormalUserReport.dart';
import 'NormalUserVacationRequest.dart';
import 'NormalUsersOrders.dart';

class NormalUserMenu extends StatefulWidget {
  @override
  _NormalUserMenuState createState() => _NormalUserMenuState();
}

class _NormalUserMenuState extends State<NormalUserMenu> {
  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    List<ReportTile> reports = [
      ReportTile(
          title: "التقرير",
          subTitle: "تقرير الحضور ",
          icon: Icons.calendar_today_rounded,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => NormalUserReport(),
              ),
            );

            print("الموظفين");
          }),
      ReportTile(
          title: "الطلبات",
          subTitle: "طلب اذن/ اجازة",
          icon: Icons.person,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => UserVacationRequest(),
              ),
            );
          }),
      ReportTile(
          title: "متابعة طلباتى ",
          subTitle: "متابعة حالة الطلبات ",
          icon: FontAwesomeIcons.clipboardList,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => UserOrdersView(),
              ),
            );
          }),
    ];
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///Title
                    Header(
                      nav: false,
                    ),
                    DirectoriesHeader(
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.0),
                            child: Lottie.asset("resources/user.json",
                                repeat: false),
                          ),
                        ),
                        "حسابى"),
                    SizedBox(
                      height: 20,
                    ),

                    ///List OF SITES
                    Expanded(
                        child: ListView.builder(
                            itemCount: reports.length,
                            itemBuilder: (BuildContext context, int index) {
                              return reports[index];
                            }))
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<bool> onWillPop() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NavScreenTwo(0)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class ReportTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final icon;
  final onTap;
  ReportTile({this.title, this.subTitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        trailing: Icon(
          icon,
          size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
        onTap: onTap,
        title: Container(
          height: 20,
          child: AutoSizeText(
            title,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        subtitle: Container(
          height: 20,
          child: AutoSizeText(
            subTitle,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        leading: Icon(
          Icons.chevron_left,
          size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
      ),
    );
  }
}
