import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserShifts.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/UserReport/TodayUserReport.dart';
import 'package:qr_users/widgets/UserReport/UserReportTableHeader.dart';
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
    List<ReportTile> reports = [
      ReportTile(
          title: getTranslated(context, "تقرير اليوم"),
          subTitle: getTranslated(context, "تقرير الحضور / الأنصراف عن اليوم"),
          icon: Icons.calendar_today_rounded,
          onTap: () async {
            final reportData = Provider.of<ReportsData>(context, listen: false);
            final userDataProvider =
                Provider.of<UserData>(context, listen: false);
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RoundedLoadingIndicator();
                });
            final String msg = await reportData.getTodayUserReport(
                userDataProvider.user.userToken, userDataProvider.user.id);
            Navigator.pop(context);

            return showDialog(
              context: context,
              builder: (context) {
                return TodayUserReport(
                  apiStatus: msg,
                );
              },
            );
          }),
      ReportTile(
          title: getTranslated(context, "تقرير عن فترة"),
          subTitle: getTranslated(context, "تقرير الحضور / الأنصراف عن فترة"),
          icon: Icons.calendar_today_rounded,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => NormalUserReport(),
              ),
            );
          }),
      ReportTile(
          title: getTranslated(context, "تقرير الحضور / الأنصراف عن فترة"),
          subTitle: getTranslated(context, "طلب اذن / اجازة"),
          icon: Icons.person,
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => UserVacationRequest(1, [
                  getTranslated(context, "تأخير عن الحضور"),
                  getTranslated(context, "انصراف مبكر")
                ], [
                  getTranslated(context, "عارضة"),
                  getTranslated(context, "مرضية"),
                  getTranslated(context, "رصيد اجازات")
                ]),
              ),
            );
          }),
      ReportTile(
          title: getTranslated(context, "طلباتى"),
          subTitle: getTranslated(context, "متابعة حالة الطلبات"),
          icon: FontAwesomeIcons.clipboardList,
          onTap: () {
            Provider.of<UserHolidaysData>(context, listen: false)
                .singleUserHoliday
                .clear();
            Provider.of<UserPermessionsData>(context, listen: false)
                .singleUserPermessions
                .clear();
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) => UserOrdersView(
                  selectedOrder: getTranslated(context, "الأجازات"),
                  ordersList: [
                    getTranslated(context, "الأجازات"),
                    getTranslated(context, "الأذونات")
                  ],
                ),
              ),
            );
          }),
      ReportTile(
          title: getTranslated(context, "مناوباتى"),
          subTitle: getTranslated(context, "عرض مناوبات الأسبوع"),
          icon: FontAwesomeIcons.clock,
          onTap: () async {
            final user = Provider.of<UserData>(context, listen: false).user;
            final DataConnectionChecker dataConnectionChecker =
                DataConnectionChecker();
            final NetworkInfoImp networkInfoImp =
                NetworkInfoImp(dataConnectionChecker);
            final bool isConnected = await networkInfoImp.isConnected;
            if (isConnected) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return RoundedLoadingIndicator();
                  });
              await Provider.of<ShiftsData>(context, listen: false)
                  .getFirstAvailableSchedule(user.userToken, user.id);

              await Provider.of<ShiftApi>(context, listen: false)
                  .getShiftByShiftId(user.userShiftId, user.userToken);

              Navigator.pop(context);
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (context) => UserCurrentShifts(),
                ),
              );
            } else {
              return weakInternetConnection(context);
            }
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
                        getTranslated(context, "حسابى")),
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
