import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'Widgets/display_pending_vacations.dart';

class PendingCompanyVacations extends StatefulWidget {
  PendingCompanyVacations();

  @override
  _PendingCompanyVacationsState createState() =>
      _PendingCompanyVacationsState();
}

class _PendingCompanyVacationsState extends State<PendingCompanyVacations> {
  String comment = "";
  Future pendingHolidays;
  Future getPendingHolidays() async {
    var comId = Provider.of<CompanyData>(context, listen: false).com.id;
    String token = Provider.of<UserData>(context, listen: false).user.userToken;
    pendingHolidays = Provider.of<UserHolidaysData>(context, listen: false)
        .getPendingCompanyHolidays(comId, token);
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getPendingHolidays();
  }

  void _onRefresh() async {
    setState(() {
      getPendingHolidays();
    });
  }

  @override
  Widget build(BuildContext context) {
    var pendingList = Provider.of<UserHolidaysData>(context);
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        floatingActionButton: MultipleFloatingButtons(
          mainTitle: "",
          shiftName: "",
          comingFromShifts: false,
          mainIconData: Icons.add_location_alt,
        ),
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
              FutureBuilder(
                  future: pendingHolidays,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Expanded(child: LoadingIndicator());
                    } else {
                      return Expanded(
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ))
                                  : SmartRefresher(
                                      onRefresh: _onRefresh,
                                      controller: refreshController,
                                      header: WaterDropMaterialHeader(
                                        color: Colors.white,
                                        backgroundColor: Colors.orange,
                                      ),
                                      child: ListView.builder(
                                        itemBuilder: (context, index) {
                                          var pending = pendingList
                                              .pendingCompanyHolidays[index];
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                ExpandedPendingVacation(
                                                  isAdmin: true,
                                                  createdOn: pending
                                                      .createdOnDate
                                                      .toString(),
                                                  adminComment:
                                                      pending.adminResponse,
                                                  comments: pending
                                                      .holidayDescription,
                                                  date: pending.fromDate
                                                      .toString(),
                                                  response:
                                                      pending.adminResponse,
                                                  userName: pending.userName,
                                                  vacationDaysCount: [
                                                    pending.fromDate,
                                                    pending.toDate
                                                  ],
                                                  holidayType:
                                                      pending.holidayType,
                                                  onAccept: () {
                                                    return showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Directionality(
                                                            textDirection:
                                                                TextDirection
                                                                    .rtl,
                                                            child:
                                                                RoundedAlertWithComment(
                                                              onTapped: (comm) {
                                                                comment = comm;
                                                              },
                                                              hint: "التفاصيل",
                                                              onPressed:
                                                                  () async {
                                                                Navigator.pop(
                                                                    context);
                                                                String msg = await pendingList.acceptOrRefusePendingVacation(
                                                                    1,
                                                                    pending
                                                                        .holidayNumber,
                                                                    pending
                                                                        .holidayDescription,
                                                                    Provider.of<UserData>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .user
                                                                        .userToken,
                                                                    comment,
                                                                    pending
                                                                        .fromDate,
                                                                    pending
                                                                        .toDate);

                                                                if (msg ==
                                                                    "Success : Updated!") {
                                                                  HuaweiServices
                                                                      _huawei =
                                                                      HuaweiServices();
                                                                  if (pending
                                                                          .osType ==
                                                                      3) {
                                                                    await _huawei.huaweiPostNotification(
                                                                        pending
                                                                            .fcmToken,
                                                                        "طلب اجازة",
                                                                        "تم الموافقة على طلب الأجازة",
                                                                        "vacation");
                                                                  } else {
                                                                    await sendFcmMessage(
                                                                        category:
                                                                            "vacation",
                                                                        topicName:
                                                                            "",
                                                                        userToken:
                                                                            pending
                                                                                .fcmToken,
                                                                        title:
                                                                            "طلب اجازة",
                                                                        message:
                                                                            "تم الموافقة على طلب الأجازة");
                                                                  }

                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "تم الموافقة بنجاح",
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green);
                                                                } else if (msg ==
                                                                    "Fail : User not found") {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "خطأ فى بيانات المستخدم",
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red);
                                                                } else if (msg ==
                                                                    "Fail: holiday time out!") {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "خطأ فى الموافقة : انتهى وقت الرد",
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red);
                                                                } else {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "خطأ في الموافقة",
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red);
                                                                }
                                                              },
                                                              content:
                                                                  "تأكيد الموافقة على الاجازة",
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
                                                        builder: (BuildContext
                                                            context) {
                                                          return Directionality(
                                                            textDirection:
                                                                TextDirection
                                                                    .rtl,
                                                            child:
                                                                RoundedAlertWithComment(
                                                              hint: "سبب الرفض",
                                                              onTapped: (comm) {
                                                                comment = comm;
                                                              },
                                                              onPressed:
                                                                  () async {
                                                                Navigator.pop(
                                                                    context);
                                                                String msg = await pendingList.acceptOrRefusePendingVacation(
                                                                    2,
                                                                    pending
                                                                        .holidayNumber,
                                                                    pending
                                                                        .holidayDescription,
                                                                    Provider.of<UserData>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .user
                                                                        .userToken,
                                                                    comment,
                                                                    pending
                                                                        .fromDate,
                                                                    pending
                                                                        .toDate);

                                                                if (msg ==
                                                                    "Success : Updated!") {
                                                                  HuaweiServices
                                                                      _huawei =
                                                                      HuaweiServices();
                                                                  if (pending
                                                                          .osType ==
                                                                      3) {
                                                                    await _huawei.huaweiPostNotification(
                                                                        pending
                                                                            .fcmToken,
                                                                        "طلب اجازة",
                                                                        "تم رفض طلب الأجازة",
                                                                        "vacation");
                                                                  } else {
                                                                    await sendFcmMessage(
                                                                        category:
                                                                            "vacation",
                                                                        topicName:
                                                                            "",
                                                                        userToken:
                                                                            pending
                                                                                .fcmToken,
                                                                        title:
                                                                            "طلب اجازة",
                                                                        message:
                                                                            "تم رفض طلب الأجازة");
                                                                  }

                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "تم الرفض بنجاح",
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green);
                                                                } else if (msg ==
                                                                    "Fail : User not found") {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "خطأ فى بيانات المستخدم",
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red);
                                                                } else if (msg ==
                                                                    "Fail: holiday time out!") {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "خطأ فى الرفض : انتهى وقت الرد",
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red);
                                                                } else {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "خطأ في الرفض",
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red);
                                                                }
                                                              },
                                                              content:
                                                                  "تأكيد رفض الأجازة",
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
                                        itemCount: pendingList
                                            .pendingCompanyHolidays.length,
                                      ),
                                    ));
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
