import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserShifts.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/DaysOff.dart';

import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import '../HomePage.dart';
import 'NormalUserReport.dart';
import 'NormalUserVacationRequest.dart';
import 'NormalUsersOrders.dart';
import 'ReportTile.dart';

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
                builder: (context) => UserVacationRequest(1),
              ),
            );
          }),
      ReportTile(
          title: " طلباتى ",
          subTitle: "متابعة حالة الطلبات ",
          icon: FontAwesomeIcons.clipboardList,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => UserOrdersView(
                  selectedOrder: "الأجازات",
                ),
              ),
            );
          }),
      ReportTile(
          title: "مناوباتى",
          subTitle: "عرض مناوبات الأسبوع",
          icon: FontAwesomeIcons.clock,
          onTap: () async {
            var user = Provider.of<UserData>(context, listen: false).user;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RoundedLoadingIndicator();
                });
            await Provider.of<ShiftsData>(context, listen: false)
                .getFirstAvailableSchedule(user.userToken, user.id);

            await Provider.of<ShiftApi>(context, listen: false)
                .getShiftByShiftId(user.userShiftId, user.userToken);
            await Provider.of<DaysOffData>(context, listen: false).getDaysOff(
                Provider.of<CompanyData>(context, listen: false).com.id,
                Provider.of<UserData>(context, listen: false).user.userToken,
                context);
            Navigator.pop(context);
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => UserCurrentShifts(),
              ),
            );
          }),
    ];
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          endDrawer: NotificationItem(),
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
                      goUserMenu: false,
                      goUserHomeFromMenu:
                          Provider.of<UserData>(context, listen: false)
                                      .user
                                      .userType ==
                                  0
                              ? false
                              : true,
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
    if (Provider.of<UserData>(context, listen: false).user.userType != 0) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => NavScreenTwo(0)),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false);
    }
    return Future.value(false);
  }
}
