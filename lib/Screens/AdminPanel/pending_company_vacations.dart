import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/constants.dart';
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
    final int comId = Provider.of<CompanyData>(context, listen: false).com.id;
    final String token =
        Provider.of<UserData>(context, listen: false).user.userToken;
    pendingHolidays = Provider.of<UserHolidaysData>(context, listen: false)
        .getPendingCompanyHolidays(comId, token);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Provider.of<UserHolidaysData>(context, listen: false).pageIndex = 0;
    Provider.of<UserHolidaysData>(context, listen: false).isLoading = false;
    Provider.of<UserHolidaysData>(context, listen: false).keepRetriving = true;
    getPendingHolidays();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        log("reached end of list");

        if (Provider.of<UserHolidaysData>(context, listen: false)
            .keepRetriving) {
          await getPendingHolidays();
        }
      }
    });
  }

  void _onRefresh() async {
    setState(() {
      getPendingHolidays();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingList = Provider.of<UserHolidaysData>(context);
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: MultipleFloatingButtonsNoADD(),
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
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        pendingList.pendingCompanyHolidays.length == 0 &&
                        pendingList.keepRetriving) {
                      return Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Center(
                            child: Platform.isIOS
                                ? CupertinoActivityIndicator(
                                    radius: 20,
                                  )
                                : CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.orange),
                                  ),
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                          child: pendingList.pendingCompanyHolidays.length == 0
                              ? Center(
                                  child: AutoSizeText(
                                  "لا يوجد اجازات لم يتم الرد عليها",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: setResponsiveFontSize(16)),
                                  textAlign: TextAlign.center,
                                ))
                              : ListView.builder(
                                  controller: _scrollController,
                                  itemBuilder: (context, index) {
                                    final pending = pendingList
                                        .pendingCompanyHolidays[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          ExpandedPendingVacation(
                                            holidayId: pending.holidayNumber,
                                            isAdmin: true,
                                            createdOn: pending.createdOnDate
                                                .toString(),
                                            adminComment: pending.adminResponse,
                                            comments:
                                                pending.holidayDescription,
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
                                                  builder:
                                                      (BuildContext context) {
                                                    return Directionality(
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      child:
                                                          RoundedAlertWithComment(
                                                        onTapped: (comm) {
                                                          comment = comm;
                                                        },
                                                        hint: "التفاصيل",
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                              context: _scaffoldKey
                                                                  .currentContext,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return RoundedLoadingIndicator();
                                                              });

                                                          final String msg = await pendingList.acceptOrRefusePendingVacation(
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
                                                              pending.fromDate,
                                                              pending.toDate);
                                                          Navigator.pop(
                                                              _scaffoldKey
                                                                  .currentContext);
                                                          if (msg ==
                                                              "Success : Updated!") {
                                                            final HuaweiServices
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
                                                                  topicName: "",
                                                                  userToken: pending
                                                                      .fcmToken,
                                                                  title:
                                                                      "طلب اجازة",
                                                                  message:
                                                                      "تم الموافقة على طلب الأجازة");
                                                            }

                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "تم الموافقة بنجاح",
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green);
                                                          } else if (msg ==
                                                              "Fail : User not found") {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ فى بيانات المستخدم",
                                                                backgroundColor:
                                                                    Colors.red);
                                                          } else if (msg ==
                                                              "Fail: holiday time out!") {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ فى الموافقة : انتهى وقت الرد",
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                backgroundColor:
                                                                    Colors.red);
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ في الموافقة",
                                                                backgroundColor:
                                                                    Colors.red);
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
                                                  builder:
                                                      (BuildContext context) {
                                                    return Directionality(
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      child:
                                                          RoundedAlertWithComment(
                                                        hint: "سبب الرفض",
                                                        onTapped: (comm) {
                                                          comment = comm;
                                                        },
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                              context: _scaffoldKey
                                                                  .currentContext,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return RoundedLoadingIndicator();
                                                              });

                                                          final String msg = await pendingList.acceptOrRefusePendingVacation(
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
                                                              pending.fromDate,
                                                              pending.toDate);
                                                          Navigator.pop(
                                                              _scaffoldKey
                                                                  .currentContext);
                                                          if (msg ==
                                                              "Success : Updated!") {
                                                            final HuaweiServices
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
                                                                  topicName: "",
                                                                  userToken: pending
                                                                      .fcmToken,
                                                                  title:
                                                                      "طلب اجازة",
                                                                  message:
                                                                      "تم رفض طلب الأجازة");
                                                            }

                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "تم الرفض بنجاح",
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green);
                                                          } else if (msg ==
                                                              "Fail : User not found") {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ فى بيانات المستخدم",
                                                                backgroundColor:
                                                                    Colors.red);
                                                          } else if (msg ==
                                                              "Fail: holiday time out!") {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ فى الرفض : انتهى وقت الرد",
                                                                backgroundColor:
                                                                    Colors.red);
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ في الرفض",
                                                                backgroundColor:
                                                                    Colors.red);
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
                                  itemCount:
                                      pendingList.pendingCompanyHolidays.length,
                                ));
                    }
                  }),
              Provider.of<UserHolidaysData>(context)
                          .pendingCompanyHolidays
                          .length !=
                      0
                  ? Provider.of<UserHolidaysData>(context).paginatedIsLoading
                      ? Column(
                          children: [
                            Center(
                                child: CupertinoActivityIndicator(
                              radius: 15,
                            )),
                            Container(
                              height: 30,
                            )
                          ],
                        )
                      : Container()
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
