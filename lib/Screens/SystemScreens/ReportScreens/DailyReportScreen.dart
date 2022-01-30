import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
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
  int siteIndex = 0;
  Site siteData;
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  bool showTable = false, showFB = true, showViewTableButton = true;
  String date;
  String selectedDateString;
  DateTime selectedDate;
  DateTime today;
  ScrollController _scrollController = ScrollController();
  final _visableNotifier = ValueNotifier<bool>(true);
  var percent = 0;
  Timer timer;
  @override
  void dispose() {
    _visableNotifier.dispose();
    if (percent != 0) {
      timer.cancel();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    showTable = false;
    siteIndex = getSiteIndexBySiteId(
        Provider.of<UserData>(context, listen: false).user.userSiteId);
    date = apiFormatter.format(DateTime.now());
    // getDailyReport(siteIndex, date, context);
    selectedDateString = DateTime.now().toString();
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    selectedDate = DateTime(now.year, now.month, now.day);
  }

  int getSiteIndexBySiteName(String siteName) {
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

  int getSiteIndexBySiteId(int siteId) {
    final list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteId == list[i].siteId) {
        return i;
      }
    }
    return 0;
  }

  loadProgressIndicator() {
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
  }

  void setFBvisability(bool show) {
    _visableNotifier.value = show;
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
                .siteShiftList[siteIndex]
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
          print(showViewTableButton);
        },
        child: NotificationListener(
          onNotification: (notificationInfo) {
            if (showTable) {
              if (_scrollController.position.userScrollDirection ==
                  ScrollDirection.reverse) {
                setFBvisability(false);
                //the setState function
              } else if (_scrollController.position.userScrollDirection ==
                  ScrollDirection.forward) {
                setFBvisability(true);
                //setState function
              } else if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent) {
                setFBvisability(false);
              }
            }

            return true;
          },
          child: Scaffold(
            floatingActionButton: ValueListenableBuilder(
              valueListenable: _visableNotifier,
              builder: (context, value, child) {
                return Visibility(
                    visible: value,
                    child: FadeIn(
                        duration: Duration(seconds: 1),
                        child: MultipleFloatingButtonsNoADD()));
              },
            ),
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
                                getTranslated(context, "تقرير الحضور اليومى"),
                              ),
                              showTable
                                  ? Container(
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
                                                                title: getTranslated(
                                                                    context,
                                                                    "تقرير الحضور اليومى"),
                                                                site: userType ==
                                                                        2
                                                                    ? ""
                                                                    : Provider.of<SiteShiftsData>(
                                                                            context)
                                                                        .siteShiftList[
                                                                            siteIndex]
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
                                  : Container()
                            ],
                          ),
                        ),
                        Container(
                            height: 40.h,
                            child: userType == 4 || userType == 3
                                ? Row(
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: SiteDropdown(
                                          edit: true,
                                          list: Provider.of<SiteShiftsData>(
                                                  context)
                                              .siteShiftList,
                                          colour: Colors.white,
                                          icon: Icons.location_on,
                                          borderColor: Colors.black,
                                          hint:
                                              getTranslated(context, "الموقع"),
                                          hintColor: Colors.black,
                                          onChange: (value) async {
                                            siteIndex =
                                                getSiteIndexBySiteName(value);

                                            setState(() {
                                              showViewTableButton = true;
                                              showTable = false;
                                            });
                                          },
                                          selectedvalue:
                                              Provider.of<SiteShiftsData>(
                                                      context)
                                                  .siteShiftList[siteIndex]
                                                  .siteName,
                                          textColor: Colors.orange,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Container(
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            child: Theme(
                                                data: clockTheme,
                                                child: SingleDayDatePicker(
                                                  firstDate: DateTime(
                                                      comDate.com.createdOn.year -
                                                          1,
                                                      comDate
                                                          .com.createdOn.month,
                                                      comDate
                                                          .com.createdOn.day),
                                                  lastDate: DateTime.now(),
                                                  selectedDateString:
                                                      selectedDateString,
                                                  functionPicker: (value) {
                                                    if (value != date) {
                                                      date = value;
                                                      selectedDateString = date;
                                                      setState(() {
                                                        selectedDate =
                                                            DateTime.parse(
                                                                selectedDateString);
                                                        showViewTableButton =
                                                            true;
                                                        showTable = false;
                                                      });
                                                      // getDailyReport(siteIndex,
                                                      //     date, context);
                                                    }
                                                  },
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SingleDayDatePicker(
                                    firstDate: comDate.com.createdOn,
                                    lastDate: DateTime.now(),
                                    selectedDateString: selectedDateString,
                                    functionPicker: (value) {
                                      if (value != date) {
                                        setState(() {
                                          date = value;
                                          selectedDateString = date;
                                        });
                                        // getDailyReport(siteIndex,
                                        //     date, context);
                                      }
                                    },
                                  )),
                        SizedBox(
                          height: 5,
                        ),
                        Visibility(
                          visible: showViewTableButton,
                          child: Container(
                            width: 170.w,
                            child: OutlinedButton(
                                style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0),
                                    side: MaterialStateProperty.all(BorderSide(
                                        width: 1, color: ColorManager.primary)),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)))),
                                onPressed: () {
                                  loadProgressIndicator();
                                  setState(() {
                                    getDailyReport(siteIndex, date, context);
                                    showTable = true;
                                    showViewTableButton = false;
                                  });
                                },
                                child: Center(
                                  child: Container(
                                    width: 160.w,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(FontAwesomeIcons.eye,
                                            color: ColorManager.accentColor),
                                        AutoSizeText(
                                          getTranslated(context, "عرض التقرير"),
                                          style: TextStyle(
                                              color: ColorManager.accentColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize:
                                                  setResponsiveFontSize(16)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
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
                                    if (percent != 0) {
                                      timer.cancel();
                                    }

                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        showTable
                                            ? Expanded(
                                                child: SmartRefresher(
                                                  onRefresh: _onRefresh,
                                                  controller: refreshController,
                                                  header:
                                                      WaterDropMaterialHeader(
                                                    color: Colors.white,
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                  child: Container(
                                                    color: Colors.white,
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
                                                                      getTranslated(
                                                                          context,
                                                                          "لا يوجد تسجيلات : عطلة رسمية"),
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          fontSize: ScreenUtil().setSp(
                                                                              16,
                                                                              allowFontScalingSelf:
                                                                                  true),
                                                                          fontWeight:
                                                                              FontWeight.w700),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10.h,
                                                                  ),
                                                                  Container(
                                                                    height: 20,
                                                                    child: AutoSizeText(
                                                                        reportsData
                                                                            .dailyReport
                                                                            .officialHoliday,
                                                                        maxLines:
                                                                            1,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize: ScreenUtil().setSp(
                                                                              17,
                                                                              allowFontScalingSelf: true),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.orange,
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
                                                                    getTranslated(
                                                                        context,
                                                                        "لا يوجد تسجيلات : عطلة اسبوعية"),
                                                              )
                                                            : snapshot.data !=
                                                                    "wrong"
                                                                ? Column(
                                                                    children: [
                                                                      orangeDivider,
                                                                      DataTableHeader(),
                                                                      orangeDivider,
                                                                      Expanded(
                                                                          child: snapshot.data == "Date is older than company date"
                                                                              ? CenterMessageText(
                                                                                  message: getTranslated(context, "التاريخ قبل إنشاء الشركة"),
                                                                                )
                                                                              : ListView.builder(
                                                                                  controller: _scrollController,
                                                                                  physics: AlwaysScrollableScrollPhysics(),
                                                                                  itemCount: reportsData.dailyReport.attendListUnits.length,
                                                                                  itemBuilder: (BuildContext context, int index) {
                                                                                    return DataTableRow(reportsData.dailyReport.attendListUnits[index], siteIndex, selectedDate);
                                                                                  })),
                                                                      !isToday(
                                                                              selectedDate)
                                                                          ? snapshot.data == "Success"
                                                                              ? DailyReportTableEnd(totalAbsents: reportsData.dailyReport.totalAbsent.toString(), totalAttend: reportsData.dailyReport.totalAttend.toString())
                                                                              : snapshot.data == "Success : Official Vacation Day"
                                                                                  ? DailyReportTodayTableEnd(
                                                                                      titleHeader: "${getTranslated(context, "عطلة رسمية")} :",
                                                                                      title: reportsData.dailyReport.officialHoliday,
                                                                                    )
                                                                                  : snapshot.data == "user created after period" || snapshot.data == "Date is older than company date" || snapshot.data == "failed"
                                                                                      ? Container()
                                                                                      : DailyReportTodayTableEnd(
                                                                                          titleHeader: getTranslated(context, "عطلة اسبوعية"),
                                                                                          title: "",
                                                                                        )
                                                                          : snapshot.data == "Success"
                                                                              ? Container()
                                                                              : snapshot.data == "Success : Official Vacation Day"
                                                                                  ? DailyReportTodayTableEnd(
                                                                                      titleHeader: "${getTranslated(context, "عطلة رسمية")} :",
                                                                                      title: reportsData.dailyReport.officialHoliday,
                                                                                    )
                                                                                  : snapshot.data == "user created after period" || snapshot.data == "Date is older than company date" || snapshot.data == "failed"
                                                                                      ? Container()
                                                                                      : DailyReportTodayTableEnd(
                                                                                          titleHeader: getTranslated(context, "عطلة اسبوعية"),
                                                                                          title: "",
                                                                                        ),
                                                                    ],
                                                                  )
                                                                : CenterMessageText(
                                                                    message:
                                                                        getTranslated(
                                                                    context,
                                                                    "لا يوجد تسجيلات بهذا اليوم",
                                                                  )),
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    );
                                  default:
                                    return Center(child: Container());
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
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 50),
      child: Column(
        children: [
          Container(
            width: 400.w,
            height: 300.h,
            child: Lottie.asset("resources/kiteLoader.json"),
          ),
          AutoSizeText(
            percent > maxPercent
                ? getTranslated(context, "على وشك الأنتهاء")
                : getTranslated(context, "برجاء الأنتظار"),
            style: TextStyle(
                fontSize: setResponsiveFontSize(17),
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 30.h,
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
