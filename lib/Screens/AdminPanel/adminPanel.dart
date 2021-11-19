import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Screens/AdminPanel/pending_company_permessions.dart';
import 'package:qr_users/Screens/AdminPanel/pending_company_vacations.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/AttendProovReport.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';

import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/headers.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

RefreshController refreshController = RefreshController(initialRefresh: false);

class _AdminPanelState extends State<AdminPanel> {
  @override
  void _onRefresh() async {
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    await Provider.of<UserPermessionsData>(context, listen: false)
        .getPendingCompanyPermessions(
            Provider.of<CompanyData>(context, listen: false).com.id,
            userDataProvider.user.userToken);
    await Provider.of<UserHolidaysData>(context, listen: false)
        .getPendingCompanyHolidays(
            Provider.of<CompanyData>(context, listen: false).com.id,
            userDataProvider.user.userToken);

    refreshController.refreshCompleted();
  }

  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ///Title
                      Header(
                        nav: false,
                        goUserMenu: false,
                        goUserHomeFromMenu: true,
                      ),
                      DirectoriesHeader(
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60.0),
                              child: Lottie.asset("resources/adminPanel.json",
                                  repeat: false),
                            ),
                          ),
                          "لوحة التحكم"),
                      SizedBox(
                        height: 20.h,
                      ),

                      ///List OF SITES
                      Expanded(
                          child: SmartRefresher(
                        onRefresh: _onRefresh,
                        controller: refreshController,
                        enablePullDown: true,
                        header: WaterDropMaterialHeader(
                          color: Colors.white,
                          backgroundColor: Colors.orange,
                        ),
                        child: ListView(children: [
                          Consumer<UserPermessionsData>(
                            builder: (context, value, child) {
                              return AdminPanelTile(
                                  title: "طلبات الأذن",
                                  subTitle: "طلبات اذن المستخدمين",
                                  icon: Icons.calendar_today_sharp,
                                  requestsCount: value
                                      .pendingCompanyPermessions.length
                                      .toString(),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PendingCompanyPermessions(),
                                        ));
                                  });
                            },
                          ),
                          Consumer<UserHolidaysData>(
                            builder: (context, value, child) {
                              return AdminPanelTile(
                                  title: "طلبات الأجازة",
                                  subTitle: "طلبات اجازة المستخدمين",
                                  icon: Icons.calendar_today_sharp,
                                  requestsCount: value
                                      .pendingCompanyHolidays.length
                                      .toString(),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PendingCompanyVacations(),
                                        ));
                                  });
                            },
                          ),
                          AdminPanelTile(
                              requestsCount: null,
                              title: "إثباتات الحضور",
                              subTitle: "تقرير إثباتات الحضور",
                              icon: Icons.check,
                              onTap: () {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) => AttendProofReport(),
                                  ),
                                );
                              }),
                        ]),
                      ))
                    ],
                  ),
                ),
              ],
            ),
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
          size: ScreenUtil().setSp(35, allowFontScalingSelf: true),
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
          size: ScreenUtil().setSp(35, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
      ),
    );
  }
}

class AdminPanelTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final String requestsCount;
  final icon;
  final onTap;
  AdminPanelTile(
      {this.title, this.subTitle, this.icon, this.onTap, this.requestsCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
          trailing: Icon(
            icon,
            size: ScreenUtil().setSp(35, allowFontScalingSelf: true),
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
          leading: requestsCount == null
              ? Container(
                  width: 30,
                  height: 30,
                )
              : Container(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: Text(
                      requestsCount,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange[600], width: 3)),
                )),
    );
  }
}
