import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/Reports/Services/Attend_Proof_Model.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Reports/DailyReport/dailyReportTableHeader.dart';

import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/Shared/Single_day_datePicker.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';

import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

class AttendProofReport extends StatefulWidget {
  @override
  _AttendProofReportState createState() => _AttendProofReportState();
}

class _AttendProofReportState extends State<AttendProofReport> {
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  String date;
  String selectedDateString;
  DateTime selectedDate;
  DateTime today;
  void initState() {
    super.initState();
    date = apiFormatter.format(DateTime.now());
    getReportData(date);
    selectedDateString = DateTime.now().toString();
    var now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    selectedDate = DateTime(now.year, now.month, now.day);
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    print("starrt refresh");
    await getReportData(date);
    print("refresh");

    refreshController.refreshCompleted();
  }

  getReportData(date) async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var apiId = userProvider.user.userType == 3
        ? userProvider.user.id
        : Provider.of<CompanyData>(context, listen: false).com.id;
    await Provider.of<ReportsData>(context, listen: false)
        .getDailyAttendProofReport(userProvider.user.userToken, apiId, date,
            context, userProvider.user.userType);
  }

  final SlidableController slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    var comDate = Provider.of<CompanyData>(context, listen: false);
    var reprotData = Provider.of<ReportsData>(context, listen: true);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      floatingActionButton: MultipleFloatingButtonsNoADD(),
      endDrawer: NotificationItem(),
      backgroundColor: Colors.white,
      body: Consumer<ReportsData>(
        builder: (context, reportsData, child) {
          return Container(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (_) {
                FocusScope.of(context).unfocus();
              },
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Header(
                        goUserHomeFromMenu: false,
                        nav: false,
                        goUserMenu: false,
                      ),
                      Expanded(
                        child: FutureBuilder(
                            future: reportsData.futureListener,
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return LoadingIndicator();
                                case ConnectionState.done:
                                  log(snapshot.data);
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w),
                                            child: Container(
                                              child: Directionality(
                                                textDirection:
                                                    ui.TextDirection.rtl,
                                                child: Container(
                                                  child: Theme(
                                                      data: clockTheme,
                                                      child:
                                                          SingleDayDatePicker(
                                                        firstDate: comDate
                                                            .com.createdOn,
                                                        lastDate:
                                                            DateTime.now(),
                                                        selectedDateString:
                                                            selectedDateString,
                                                        functionPicker:
                                                            (value) {
                                                          if (value != date) {
                                                            date = value;
                                                            selectedDateString =
                                                                date;
                                                            setState(() {
                                                              getReportData(
                                                                  date);
                                                              selectedDate =
                                                                  DateTime.parse(
                                                                      selectedDateString);
                                                            });
                                                          }
                                                        },
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SmallDirectoriesHeader(
                                            Lottie.asset(
                                                "resources/report.json",
                                                repeat: false),
                                            "إثباتات الحضور",
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      orangeDivider,
                                      AttendProovTableHeader(),
                                      orangeDivider,
                                      Expanded(
                                        child: Container(
                                          color: Colors.white,
                                          child: Directionality(
                                            textDirection: ui.TextDirection.rtl,
                                            child: reportsData.attendProofList
                                                        .length ==
                                                    0
                                                ? CenterMessageText(
                                                    message:
                                                        "لا يوجد إثباتات حضور فى هذا اليوم")
                                                : reportsData.isLoading
                                                    ? Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.orange,
                                                        ),
                                                      )
                                                    : SmartRefresher(
                                                        onRefresh: _onRefresh,
                                                        controller:
                                                            refreshController,
                                                        enablePullDown: true,
                                                        header:
                                                            WaterDropMaterialHeader(
                                                          color: Colors.white,
                                                          backgroundColor:
                                                              Colors.orange,
                                                        ),
                                                        child: ListView.builder(
                                                          physics:
                                                              AlwaysScrollableScrollPhysics(),
                                                          itemCount: reportsData
                                                              .attendProofList
                                                              .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return Slidable(
                                                              enabled: !reprotData
                                                                  .attendProofList[
                                                                      index]
                                                                  .isAttended,
                                                              actionExtentRatio:
                                                                  0.10,
                                                              closeOnScroll:
                                                                  true,
                                                              controller:
                                                                  slidableController,
                                                              actionPane:
                                                                  SlidableDrawerActionPane(),
                                                              secondaryActions: [
                                                                ZoomIn(
                                                                    child:
                                                                        InkWell(
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(7),
                                                                    margin: EdgeInsets.only(
                                                                        bottom:
                                                                            10.h),
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .white,
                                                                        border: Border.all(
                                                                            width:
                                                                                2,
                                                                            color:
                                                                                Colors.red)),
                                                                    child: Icon(
                                                                      Icons
                                                                          .delete,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                  onTap: () {
                                                                    return showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return reprotData.isLoading
                                                                              ? Center(
                                                                                  child: CircularProgressIndicator(
                                                                                    backgroundColor: Colors.orange,
                                                                                  ),
                                                                                )
                                                                              : RoundedAlert(
                                                                                  onPressed: () async {
                                                                                    Navigator.pop(context);
                                                                                    String msg = await Provider.of<ReportsData>(context, listen: false).deleteAttendProofFromReport(Provider.of<UserData>(context, listen: false).user.userToken, reportsData.attendProofList[index].id, index);
                                                                                    if (msg == "Success : AttendProof Deleted!") {
                                                                                      Fluttertoast.showToast(msg: "تم حذف الإثبات بنجاح", backgroundColor: Colors.green);
                                                                                    } else {
                                                                                      Fluttertoast.showToast(msg: "خطأ في حذف الإثبات", backgroundColor: Colors.red);
                                                                                    }
                                                                                  },
                                                                                  content: "هل تريد مسح الإثبات",
                                                                                  onCancel: () {},
                                                                                  title: "حذف الإثبات",
                                                                                );
                                                                        });
                                                                  },
                                                                )),
                                                              ],
                                                              child:
                                                                  DisplayAttendProofList(
                                                                attendProofList:
                                                                    reportsData
                                                                            .attendProofList[
                                                                        index],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                default:
                                  return Center(child: LoadingIndicator());
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DisplayAttendProofList extends StatelessWidget {
  const DisplayAttendProofList({this.attendProofList});

  final AttendProofModel attendProofList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          child: Row(
            children: [
              Text(attendProofList.username,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Expanded(
                child: Container(),
              ),
              Container(
                width: 170.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    attendProofList.isAttended
                        ? Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 27,
                          )
                        : Icon(
                            FontAwesomeIcons.times,
                            color: Colors.red,
                            size: 25,
                          ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(attendProofList.time,
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}
