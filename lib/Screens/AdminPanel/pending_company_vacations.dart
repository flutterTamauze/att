import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';

import 'Widgets/display_pending_vacations.dart';

class PendingCompanyVacations extends StatelessWidget {
  PendingCompanyVacations();
  @override
  Widget build(BuildContext context) {
    var pendingList = Provider.of<UserHolidaysData>(context);
    return Scaffold(
      endDrawer: NotificationItem(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Header(
              nav: false,
              goUserMenu: false,
              goUserHomeFromMenu: false,
            ),
            SmallDirectoriesHeader(
              Lottie.asset("resources/calender.json", repeat: false),
              "طلبات الأجازات",
            ),
            Expanded(
                child: pendingList.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.orange,
                        ),
                      )
                    : pendingList.pendingCompanyHolidays.length == 0
                        ? Center(
                            child: Text(
                            "لا يوجد اجازات لم يتم الرد عليها",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ))
                        : ListView.builder(
                            itemBuilder: (context, index) {
                              var pending =
                                  pendingList.pendingCompanyHolidays[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    ExpandedPendingVacation(
                                      userId: pending.userId,
                                      index: index,
                                      isAdmin: true,
                                      adminComment: pending.adminResponse,
                                      comments: pending.holidayDescription,
                                      date: pending.fromDate.toString(),
                                      iconData: pending.holidayStatus == 1
                                          ? Icons.check
                                          : FontAwesomeIcons.times,
                                      response: pending.adminResponse,
                                      status: pending.holidayStatus,
                                      orderNum:
                                          pending.holidayNumber.toString(),
                                      vacationDaysCount: [
                                        pending.fromDate,
                                        pending.toDate
                                      ],
                                      holidayType: pending.holidayType,
                                    )
                                  ],
                                ),
                              );
                            },
                            itemCount:
                                pendingList.pendingCompanyHolidays.length,
                          ))
          ],
        ),
      ),
    );
  }
}
