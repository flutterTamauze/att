import 'dart:async';
import 'dart:ui' as ui;
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
import 'package:qr_users/widgets/Reports/ProgressBar.dart';
import 'package:qr_users/widgets/Shared/HandleNetwork_ServerDown/handleState.dart';
import 'package:qr_users/widgets/Shared/Single_day_datePicker.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/XlsxExportButton.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen();

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
  String selectedDateString, currentSiteName = "";
  DateTime selectedDate;
  DateTime today;
  ScrollController _scrollController = ScrollController();
  final _visableNotifier = ValueNotifier<bool>(true);
  var percent = 0;
  Timer timer;
  @override
  void dispose() {
    _scrollController.dispose();
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
    if (Provider.of<UserData>(context, listen: false).user.userType != 2) {
      currentSiteName = Provider.of<SiteShiftsData>(context, listen: false)
          .siteShiftList[siteIndex]
          .siteName;
    }

    date = apiFormatter.format(DateTime.now());
    // getDailyReport(siteIndex, date, context);
    selectedDateString = DateTime.now().toString();
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    selectedDate = DateTime(now.year, now.month, now.day);
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
    if (mounted) percent = 0;
    timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (Provider.of<ReportsData>(context, listen: false).isLoading == false) {
        setState(() {
          percent = 100;
        });
      }
      setState(() {
        percent += 2;
        if (percent >= 65) {
          timer.cancel();
        }
      });
    });
  }

  void setFBvisability(bool show) {
    _visableNotifier.value = show;
  }

  // RefreshController refreshController =
  //     RefreshController(initialRefresh: false);

  // void _onRefresh() async {
  //   print("starrt refresh");
  //   final userProvider = Provider.of<UserData>(context, listen: false);
  //   print("refresh");
  //   setState(() {
  //     isLoading = true;
  //   });

  //   await Provider.of<ReportsData>(context, listen: false).getDailyReportUnits(
  //       userProvider.user.userToken,
  //       userProvider.user.userType == 2
  //           ? userProvider.user.userSiteId
  //           : Provider.of<SiteShiftsData>(context, listen: false)
  //               .siteShiftList[siteIndex]
  //               .siteId,
  //       date,
  //       context);
  //   refreshController.refreshCompleted();
  // }

  bool isToday(DateTime selectedDay) {
    if (selectedDay.difference(today).inDays == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final comDate = Provider.of<CompanyData>(context, listen: false);
    // SystemChrome.setEnabledSystemUIOverlays([]);
    final userType =
        Provider.of<UserData>(context, listen: false).user.userType;
    final reportsData = Provider.of<ReportsData>(context, listen: false);

    return WillPopScope(
      onWillPop: onWillPop,
      child: NotificationListener(
        onNotification: (notificationInfo) {
          if (showTable) {
            if (_scrollController.hasClients) {
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
                      duration: const Duration(seconds: 1),
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
                      Row(
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
                                                            site: userType == 2
                                                                ? ""
                                                                : Provider.of<
                                                                            SiteShiftsData>(
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
                      Container(
                          height: 40.h,
                          child: userType == 4 || userType == 3
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: 10,
                                      child: SiteDropdown(
                                          edit: true,
                                          height: 40,
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
                                            siteIndex = getSiteIndexBySiteName(
                                                value, context);

                                            setState(() {
                                              if (currentSiteName != value) {
                                                print(
                                                    "current $currentSiteName value $value");
                                                currentSiteName = value;
                                                showViewTableButton = true;
                                                showTable = false;
                                              }
                                            });
                                          },
                                          selectedvalue:
                                              Provider.of<SiteShiftsData>(
                                                      context)
                                                  .siteShiftList[siteIndex]
                                                  .siteName,
                                          textColor: ColorManager.primary),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Theme(
                                          data: clockTheme,
                                          child: SingleDayDatePicker(
                                            firstDate: DateTime(
                                                comDate.com.createdOn.year - 1,
                                                comDate.com.createdOn.month,
                                                comDate.com.createdOn.day),
                                            lastDate: DateTime.now(),
                                            selectedDateString:
                                                selectedDateString,
                                            functionPicker: (value) {
                                              if (value != date) {
                                                date = value;
                                                selectedDateString = date;
                                                setState(() {
                                                  selectedDate = DateTime.parse(
                                                      selectedDateString);
                                                  showViewTableButton = true;
                                                  showTable = false;
                                                });
                                                // getDailyReport(siteIndex,
                                                //     date, context);
                                              }
                                            },
                                          )),
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
                                        showViewTableButton = true;
                                        showTable = false;
                                      });
                                      // getDailyReport(siteIndex,
                                      //     date, context);
                                    }
                                  },
                                )),
                      showViewTableButton
                          ? SizedBox(
                              height: 20.h,
                            )
                          : Container(),
                      Visibility(
                        visible: showViewTableButton,
                        child: Expanded(
                          flex: 9,
                          child: Center(
                            child: Container(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 400.w,
                                    height: 300.h,
                                    child: Lottie.asset(
                                        "resources/displayReport.json",
                                        fit: BoxFit.fill),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(5),
                                    width: 150.w,
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2,
                                            color: ColorManager.primary),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: InkWell(
                                      onTap: () {
                                        loadProgressIndicator();
                                        setState(() {
                                          getDailyReport(
                                              siteIndex, date, context);
                                          showTable = true;
                                          showViewTableButton = false;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          AutoSizeText(
                                            getTranslated(
                                                context, "عرض التقرير"),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                              width: 2,
                                              height: 80.h,
                                              color: ColorManager.primary),
                                          const Icon(FontAwesomeIcons.fileAlt)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                  // log("data ${snapshot.data}");
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
                                                                  maxLines: 1,
                                                                  style:
                                                                      boldStyle,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
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
                                                            message: getTranslated(
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
                                                                    child: snapshot.data ==
                                                                            "Date is older than company date"
                                                                        ? CenterMessageText(
                                                                            message:
                                                                                getTranslated(context, "التاريخ قبل إنشاء الشركة"),
                                                                          )
                                                                        : ListView.builder(
                                                                            controller: _scrollController,
                                                                            physics: const AlwaysScrollableScrollPhysics(),
                                                                            itemCount: reportsData.dailyReport.attendListUnits.length,
                                                                            itemBuilder: (BuildContext context, int index) {
                                                                              return DataTableRow(reportsData.dailyReport.attendListUnits[index], siteIndex, selectedDate);
                                                                            }),
                                                                  ),
                                                                ],
                                                              )
                                                            : CenterMessageText(
                                                                message:
                                                                    getTranslated(
                                                                        context,
                                                                        "لا يوجد تسجيلات بهذا اليوم"),
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
                                  builder: (context) => const NavScreenTwo(2)),
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
        MaterialPageRoute(builder: (context) => const NavScreenTwo(2)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}
