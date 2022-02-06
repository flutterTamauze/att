import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/DailyReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/LateCommersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';

import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'DisplayPermessionAndVacations.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    List<ReportTile> reports = [
      ReportTile(
          title: getTranslated(context, "الحضور اليومى"),
          subTitle: getTranslated(context, "تقرير الحضور اليومى"),
          icon: Icons.calendar_today_rounded,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => DailyReportScreen(),
              ),
            );

            print("الموظفين");
          }),
      ReportTile(
          title: getTranslated(context, "التأخير و الغياب"),
          subTitle: getTranslated(context, "تقرير التأخير و الغياب"),
          icon: Icons.timer,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => LateAbsenceScreen(),
              ),
            );
          }),
      ReportTile(
          title: getTranslated(context, "حضور مستخدم"),
          subTitle: getTranslated(context, "تقرير حضور المستخدم"),
          icon: Icons.person,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => UserAttendanceReportScreen(
                  name: "",
                ),
              ),
            );
          }),
      ReportTile(
          title: getTranslated(context, "الأجازات و المأموريات"),
          subTitle:
              getTranslated(context, "تقرير الأجازات و المأموريات و الأذونات"),
          icon: FontAwesomeIcons.calendarCheck,
          onTap: () async {
            Provider.of<UserHolidaysData>(context, listen: false)
                .singleUserHoliday
                .clear();
            Provider.of<UserPermessionsData>(context, listen: false)
                .singleUserPermessions
                .clear();
            Provider.of<MissionsData>(context, listen: false)
                .singleUserMissionsList
                .clear();
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => VacationAndPermessionsReport(),
              ),
            );
          }),
    ];
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///Title
                    DirectoriesHeader(
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.0),
                            child: Lottie.asset("resources/report.json",
                                repeat: false),
                          ),
                        ),
                        getTranslated(context, "التقارير")),

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
          Icons.chevron_right,
          size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
          color: ColorManager.primary,
        ),
        onTap: onTap,
        title: Container(
          height: 20,
          child: AutoSizeText(
            title,
            maxLines: 1,
          ),
        ),
        subtitle: Container(
          child: AutoSizeText(
            subTitle,
            style: TextStyle(fontSize: setResponsiveFontSize(13)),
            maxLines: 1,
          ),
        ),
        leading: Icon(
          icon,
          size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
          color: ColorManager.primary,
        ),
      ),
    );
  }
}
