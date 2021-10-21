import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/DailyReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/LateCommersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';

import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'DisplayPermessionAndVacations.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    List<ReportTile> reports = [
      ReportTile(
          title: "الحضور اليومى",
          subTitle: "تقرير الحضور اليومى",
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
          title: "التأخير و الغياب",
          subTitle: "تقرير التأخير و الغياب",
          icon: Icons.timer,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => LateAbsenceScreen(),
              ),
            );
            print("الموظفين");
          }),
      ReportTile(
          title: "حضور مستخدم",
          subTitle: "تقرير حضور بالمستخدم",
          icon: Icons.person,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => UserAttendanceReportScreen(
                  name: "",
                ),
              ),
            );
            print("الموظفين");
          }),
      ReportTile(
          title: "الأجازات و المأموريات",
          subTitle: "تقرير الأجازات المأموريات",
          icon: FontAwesomeIcons.calendarCheck,
          onTap: () async {
            var userProvider = Provider.of<UserData>(context, listen: false);
            var comProvider = Provider.of<CompanyData>(context, listen: false);
            if (Provider.of<MemberData>(context, listen: false)
                .membersList
                .isEmpty) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return RoundedLoadingIndicator();
                  });

              await Provider.of<MemberData>(context, listen: false)
                  .getAllCompanyMember(-1, comProvider.com.id,
                      userProvider.user.userToken, context, -1);
              Navigator.pop(context);
            }
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
                        "التقارير"),

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
          size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
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
