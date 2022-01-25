import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Reports/Views/daily_report_get.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/Reports/DailyReport/dailyReportTableHeader.dart';
import 'package:qr_users/widgets/Reports/DailyReport/dataTableEnd.dart';
import 'package:qr_users/widgets/Reports/DailyReport/dataTableRow.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/Shared/Single_day_datePicker.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/XlsxExportButton.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class DailyReportScreen extends StatefulWidget {
  DailyReportScreen();

  @override
  _DailyReportScreenState createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  var isLoading = false;
  int siteId = 0;
  Site siteData;
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  String date;
  String selectedDateString;
  DateTime selectedDate;
  DateTime today;
  int siteID;
  var percent = 0;
  Timer timer;
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    percent = 0;
    timer = Timer.periodic(Duration(milliseconds: 1000), (_) {
      if (Provider.of<ReportsData>(context, listen: false).isLoading == false) {
        setState(() {
          percent = 100;
        });
      }
      setState(() {
        percent += 2;
        print(percent);
        if (percent >= 65) {
          timer.cancel();
        }
      });
    });
    date = apiFormatter.format(DateTime.now());
    getDailyReport(siteId, date, context);
    selectedDateString = DateTime.now().toString();
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    selectedDate = DateTime(now.year, now.month, now.day);
  }

  int getSiteIndex(String siteName) {
    final list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].siteName) {
        return i;
      }
    }
    return -1;
  }

  @override
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    print("starrt refresh");
    final userProvider = Provider.of<UserData>(context, listen: false);
    print("refresh");
    setState(() {
      isLoading = true;
    });

    await Provider.of<ReportsData>(context, listen: false).getDailyReportUnits(
        userProvider.user.userToken,
        userProvider.user.userType == 2
            ? userProvider.user.userSiteId
            : Provider.of<SiteShiftsData>(context, listen: false)
                .siteShiftList[siteId]
                .siteId,
        date,
        context);
    refreshController.refreshCompleted();
  }

  bool isToday(DateTime selectedDay) {
    print(selectedDate.toString());
    if (selectedDay.difference(today).inDays == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final comDate = Provider.of<CompanyData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);
    final userType =
        Provider.of<UserData>(context, listen: false).user.userType;
    final reportsData = Provider.of<ReportsData>(context, listen: false);

    return WillPopScope(
      onWillPop: onWillPop,
      child: GestureDetector(
        onTap: () {
          print(selectedDate);
        },
        child: Scaffold(
          floatingActionButton: MultipleFloatingButtonsNoADD(),
          endDrawer: NotificationItem(),
          backgroundColor: Colors.white,
          body: Container(
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
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SmallDirectoriesHeader(
                              Lottie.asset("resources/report.json",
                                  repeat: false),
                              "تقرير الحضور اليومى",
                            ),
                            Container(
                                child: FutureBuilder(
                                    future: reportsData.futureListener,
                                    builder: (context, snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return Container();
                                        case ConnectionState.done:
                                          return Row(
                                            children: [
                                              !reportsData.dailyReport
                                                          .isHoliday ||
                                                      reportsData
                                                              .dailyReport
                                                              .attendListUnits
                                                              .length !=
                                                          0
                                                  ? isLoading
                                                      ? Container()
                                                      : XlsxExportButton(
                                                          reportType: 0,
                                                          title:
                                                              "تقرير الحضور اليومى",
                                                          site: userType == 2
                                                              ? ""
                                                              : Provider.of<
                                                                          SiteShiftsData>(
                                                                      context)
                                                                  .siteShiftList[
                                                                      siteId]
                                                                  .siteName,
                                                          day: date,
                                                        )
                                                  : Container(),
                                            ],
                                          );
                                        default:
                                          return Container();
                                      }
                                    }))
                          ],
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder(
                            future: reportsData.futureListener,
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return ProgressBar(percent, 70, 60);
                                case ConnectionState.done:
                                  log("data ${snapshot.data}");

                                  timer.cancel();
                                  return Column(
                                    children: [
                                      Container(
                                          height: 40.h,
                                          child: userType == 4 || userType == 3
                                              ? Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 10,
                                                      child: SiteDropdown(
                                                        edit: true,
                                                        list: Provider.of<
                                                                    SiteShiftsData>(
                                                                context)
                                                            .siteShiftList,
                                                        colour: Colors.white,
                                                        icon: Icons.location_on,
                                                        borderColor:
                                                            Colors.black,
                                                        hint: "الموقع",
                                                        hintColor: Colors.black,
                                                        onChange:
                                                            (value) async {
                                                          final lastRec =
                                                              siteId;

                                                          siteId = getSiteIndex(
                                                              value);

                                                          if (lastRec !=
                                                              siteId) {
                                                            setState(() {});
                                                            getDailyReport(
                                                                siteId,
                                                                date,
                                                                context);
                                                          }
                                                        },
                                                        selectedvalue: Provider
                                                                .of<SiteShiftsData>(
                                                                    context)
                                                            .siteShiftList[
                                                                siteId]
                                                            .siteName,
                                                        textColor:
                                                            Colors.orange,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5.w,
                                                    ),
                                                    Expanded(
                                                      flex: 8,
                                                      child: Container(
                                                        child: Directionality(
                                                          textDirection: ui
                                                              .TextDirection
                                                              .rtl,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    6),
                                                            child: Theme(
                                                                data:
                                                                    clockTheme,
                                                                child:
                                                                    SingleDayDatePicker(
                                                                  firstDate: DateTime(
                                                                      comDate.com.createdOn
                                                                              .year -
                                                                          1,
                                                                      comDate
                                                                          .com
                                                                          .createdOn
                                                                          .month,
                                                                      comDate
                                                                          .com
                                                                          .createdOn
                                                                          .day),
                                                                  lastDate:
                                                                      DateTime
                                                                          .now(),
                                                                  selectedDateString:
                                                                      selectedDateString,
                                                                  functionPicker:
                                                                      (value) {
                                                                    if (value !=
                                                                        date) {
                                                                      date =
                                                                          value;
                                                                      selectedDateString =
                                                                          date;
                                                                      setState(
                                                                          () {
                                                                        selectedDate =
                                                                            DateTime.parse(selectedDateString);
                                                                      });
                                                                      getDailyReport(
                                                                          siteId,
                                                                          date,
                                                                          context);
                                                                    }
                                                                  },
                                                                )),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : SingleDayDatePicker(
                                                  firstDate:
                                                      comDate.com.createdOn,
                                                  lastDate: DateTime.now(),
                                                  selectedDateString:
                                                      selectedDateString,
                                                  functionPicker: (value) {
                                                    if (value != date) {
                                                      setState(() {
                                                        date = value;
                                                        selectedDateString =
                                                            date;
                                                      });
                                                      getDailyReport(siteId,
                                                          date, context);
                                                    }
                                                  },
                                                )),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Expanded(
                                        child: SmartRefresher(
                                          onRefresh: _onRefresh,
                                          controller: refreshController,
                                          header: WaterDropMaterialHeader(
                                            color: Colors.white,
                                            backgroundColor: Colors.orange,
                                          ),
                                          child: Container(
                                            color: Colors.white,
                                            child: Directionality(
                                                textDirection:
                                                    ui.TextDirection.rtl,
                                                child: snapshot.data ==
                                                        "No records found official vacation"
                                                    ? Container(
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                height: 20,
                                                                child:
                                                                    AutoSizeText(
                                                                  "لا يوجد تسجيلات : عطلة رسمية",
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                      fontSize: ScreenUtil().setSp(
                                                                          16,
                                                                          allowFontScalingSelf:
                                                                              true),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10.h,
                                                              ),
                                                              Container(
                                                                height: 20,
                                                                child: AutoSizeText(
                                                                    reportsData
                                                                        .dailyReport
                                                                        .officialHoliday,
                                                                    maxLines: 1,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize: ScreenUtil().setSp(
                                                                          17,
                                                                          allowFontScalingSelf:
                                                                              true),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .orange,
                                                                    )),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : snapshot.data ==
                                                            "No records found holiday"
                                                        ? CenterMessageText(
                                                            message:
                                                                "لا يوجد تسجيلات: عطلة اسبوعية",
                                                          )
                                                        : snapshot.data !=
                                                                "wrong"
                                                            ? Column(
                                                                children: [
                                                                  orangeDivider,
                                                                  DataTableHeader(),
                                                                  orangeDivider,
                                                                  Expanded(
                                                                      child:
                                                                          SmartRefresher(
                                                                    onRefresh:
                                                                        _onRefresh,
                                                                    controller:
                                                                        refreshController,
                                                                    header:
                                                                        WaterDropMaterialHeader(
                                                                      color: Colors
                                                                          .white,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .orange,
                                                                    ),
                                                                    child: snapshot.data ==
                                                                            "Date is older than company date"
                                                                        ? CenterMessageText(
                                                                            message:
                                                                                "التاريخ قبل إنشاء الشركة",
                                                                          )
                                                                        : ListView.builder(
                                                                            physics: AlwaysScrollableScrollPhysics(),
                                                                            itemCount: reportsData.dailyReport.attendListUnits.length,
                                                                            itemBuilder: (BuildContext context, int index) {
                                                                              return DataTableRow(reportsData.dailyReport.attendListUnits[index], siteId, selectedDate);
                                                                            }),
                                                                  )),
                                                                  !isToday(
                                                                          selectedDate)
                                                                      ? snapshot.data ==
                                                                              "Success"
                                                                          ? DailyReportTableEnd(
                                                                              totalAbsents: reportsData.dailyReport.totalAbsent.toString(),
                                                                              totalAttend: reportsData.dailyReport.totalAttend.toString())
                                                                          : snapshot.data == "Success : Official Vacation Day"
                                                                              ? DailyReportTodayTableEnd(
                                                                                  titleHeader: "عطلة رسمية :",
                                                                                  title: reportsData.dailyReport.officialHoliday,
                                                                                )
                                                                              : snapshot.data == "user created after period" || snapshot.data == "Date is older than company date" || snapshot.data == "failed"
                                                                                  ? Container()
                                                                                  : DailyReportTodayTableEnd(
                                                                                      titleHeader: "عطلة اسبوعية",
                                                                                      title: "",
                                                                                    )
                                                                      : snapshot.data == "Success"
                                                                          ? Container()
                                                                          : snapshot.data == "Success : Official Vacation Day"
                                                                              ? DailyReportTodayTableEnd(
                                                                                  titleHeader: "عطلة رسمية :",
                                                                                  title: reportsData.dailyReport.officialHoliday,
                                                                                )
                                                                              : snapshot.data == "user created after period" || snapshot.data == "Date is older than company date" || snapshot.data == "failed"
                                                                                  ? Container()
                                                                                  : DailyReportTodayTableEnd(
                                                                                      titleHeader: "عطلة اسبوعية",
                                                                                      title: "",
                                                                                    ),
                                                                ],
                                                              )
                                                            : CenterMessageText(
                                                                message:
                                                                    "لا يوجد تسجيلات بهذا اليوم",
                                                              )),
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
                  Positioned(
                    left: 5.0.w,
                    top: 5.0.h,
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => NavScreenTwo(2)),
                              (Route<dynamic> route) => false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    print("back");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NavScreenTwo(2)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class ProgressBar extends StatelessWidget {
  final int percent;
  final int maxValue;
  final int maxPercent;

  ProgressBar(this.percent, this.maxValue, this.maxPercent);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 400,
            height: 300,
            child: Lottie.asset("resources/kiteLoader.json"),
          ),
          AutoSizeText(
            percent > maxPercent ? "على وشك الأنتهاء " : "برجاء الأنتظار ",
            style: TextStyle(
                fontSize: setResponsiveFontSize(17),
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FAProgressBar(
                currentValue: percent,
                backgroundColor: Colors.grey[200],
                maxValue: maxValue,
                progressColor: ColorManager.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
