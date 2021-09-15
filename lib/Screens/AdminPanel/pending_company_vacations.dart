import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

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
                                      isAdmin: true,
                                      adminComment: pending.adminResponse,
                                      comments: pending.holidayDescription,
                                      date: pending.fromDate.toString(),
                                      response: pending.adminResponse,
                                      userName: pending.userName,
                                      vacationDaysCount: [
                                        pending.fromDate,
                                        pending.toDate
                                      ],
                                      holidayType: pending.holidayType,
                                      onAccept: () {
                                        return showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: RoundedAlert(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    String msg = await pendingList
                                                        .acceptOrRefusePendingVacation(
                                                      1,
                                                      pending.holidayNumber,
                                                      pending
                                                          .holidayDescription,
                                                      Provider.of<UserData>(
                                                              context,
                                                              listen: false)
                                                          .user
                                                          .userToken,
                                                    );

                                                    if (msg ==
                                                        "Success : Updated!") {
                                                      await sendFcmMessage(
                                                          category: "vacation",
                                                          topicName: "",
                                                          userToken:
                                                              pending.fcmToken,
                                                          title: "طلب اجازة",
                                                          message:
                                                              "تم الموافقة على طلب الأجازة");
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "تم الموافقة بنجاح",
                                                          backgroundColor:
                                                              Colors.green);
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "خطأ في الموافقة",
                                                          backgroundColor:
                                                              Colors.red);
                                                    }
                                                  },
                                                  content:
                                                      "هل تريد الموافقة على الأجازة",
                                                  onCancel: () {},
                                                  title:
                                                      "الموافقة على طلب ${pendingList.pendingCompanyHolidays[index].userName} ",
                                                ),
                                              );
                                            });
                                      },
                                      onRefused: () {
                                        return showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: RoundedAlert(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    String msg = await pendingList
                                                        .acceptOrRefusePendingVacation(
                                                      2,
                                                      pending.holidayNumber,
                                                      pending
                                                          .holidayDescription,
                                                      Provider.of<UserData>(
                                                              context,
                                                              listen: false)
                                                          .user
                                                          .userToken,
                                                    );

                                                    if (msg ==
                                                        "Success : Updated!") {
                                                      await sendFcmMessage(
                                                          category: "vacation",
                                                          topicName: "",
                                                          userToken:
                                                              pending.fcmToken,
                                                          title: "طلب اجازة",
                                                          message:
                                                              "تم رفض طلب الأذن");
                                                      Fluttertoast.showToast(
                                                          msg: "تم الرفض بنجاح",
                                                          backgroundColor:
                                                              Colors.green);
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg: "خطأ في الرفض",
                                                          backgroundColor:
                                                              Colors.red);
                                                    }
                                                  },
                                                  content:
                                                      "هل تريد رفض الأجازة",
                                                  onCancel: () {},
                                                  title:
                                                      "رفض  طلب ${pendingList.pendingCompanyHolidays[index].userName} ",
                                                ),
                                              );
                                            });
                                      },
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
