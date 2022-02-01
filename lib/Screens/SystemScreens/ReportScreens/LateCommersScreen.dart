import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/DailyReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets//XlsxExportButton.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/Reports/LateAbsence/dataTableEnd.dart';
import 'package:qr_users/widgets/Reports/LateAbsence/dataTableHeader.dart';
import 'package:qr_users/widgets/Reports/LateAbsence/dataTableRow.dart';
import 'package:qr_users/widgets/Shared/Charts/PieChart.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

import '../../../Core/constants.dart';

class LateAbsenceScreen extends StatefulWidget {
  @override
  _LateAbsenceScreenState createState() => _LateAbsenceScreenState();
}

class _LateAbsenceScreenState extends State<LateAbsenceScreen> {
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  String dateFromString = "", currentSiteName = "", dateToString = "";
  TextEditingController _dateController = TextEditingController();
  int selectedDuration;
  DateTime toDate;
  DateTime fromDate;
  bool showTable, showViewTableButton = true;
  DateTime yesterday;
  Site siteData;
  ScrollController _scrollController = ScrollController();
  var percent = 0;
  Timer timer;
  String diff;
  final _visableNotifier = ValueNotifier<bool>(true);
  var isLoading = false;
  @override
  void dispose() {
    _visableNotifier.dispose();
    if (percent != 0) timer.cancel();
    super.dispose();
  }

  void initState() {
    super.initState();
    siteIdIndex = getSiteIndexBySiteID(
        Provider.of<UserData>(context, listen: false).user.userSiteId);
    if (Provider.of<UserData>(context, listen: false).user.userType != 2) {
      currentSiteName = Provider.of<SiteShiftsData>(context, listen: false)
          .siteShiftList[siteIdIndex]
          .siteName;
    }
    showTable = false;
    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month,
        Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    toDate = DateTime(now.year, now.month, now.day - 1);
    yesterday = DateTime(now.year, now.month, now.day - 1);
    if (toDate.isBefore(fromDate)) {
      fromDate = DateTime(now.year, now.month - 1,
          Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    }
    final comProv = Provider.of<CompanyData>(context, listen: false);
    if (fromDate.isBefore(comProv.com.createdOn)) {
      fromDate = comProv.com.createdOn;
    }
    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    final String fromText =
        " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    final String toText =
        " إلى ${DateFormat('yMMMd').format(toDate).toString()}";

    _dateController.text = "$fromText $toText";
    // getData(siteIdIndex);
  }

  void setFBvisability(bool show) {
    _visableNotifier.value = show;
  }

  loadProgressIndicator() {
    percent = 0;
    timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (Provider.of<ReportsData>(context, listen: false).isLoading == false) {
        setState(() {
          percent = 300;
        });
      }
      setState(() {
        percent += 3;
        print(percent);
        if (percent >= 295) {
          timer.cancel();
        }
      });
    });
  }

  getData(int siteIndex) async {
    int siteID;
    final UserData userProvider = Provider.of<UserData>(context, listen: false);

    if (userProvider.user.userType != 2) {
      siteID = Provider.of<SiteShiftsData>(context, listen: false)
          .siteShiftList[siteIndex]
          .siteId;
    } else {
      siteID = userProvider.user.userSiteId;
    }
    await Provider.of<ReportsData>(context, listen: false).getLateAbsenceReport(
        userProvider.user.userToken,
        siteID,
        dateFromString,
        dateToString,
        context);
  }

  int getSiteIndexBySiteID(int siteId) {
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

  int siteIdIndex = 0;
  int siteId = 0;
  bool datePickerPeriodAvailable(DateTime currentDate, DateTime val) {
    print("val $val");
    final DateTime maxDate = currentDate.add(const Duration(days: 31));
    final DateTime minDate = currentDate.subtract(const Duration(days: 31));

    if (val.isBefore(maxDate) && val.isAfter(minDate)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final userDataProvider = Provider.of<UserData>(context, listen: false);
    final comProv = Provider.of<CompanyData>(context, listen: false);
    return Consumer<ReportsData>(builder: (context, reportsData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: NotificationListener(
          onNotification: (notificationInfo) {
            if (showTable) {
              if (_scrollController.position.userScrollDirection ==
                  ScrollDirection.reverse) {
                setFBvisability(false);
              } else if (_scrollController.position.userScrollDirection ==
                  ScrollDirection.forward) {
                setFBvisability(true);
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
                onTap: () {},
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
                          nav: false,
                          goUserMenu: false,
                          goUserHomeFromMenu: false,
                        ),
                        Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SmallDirectoriesHeader(
                                Lottie.asset("resources/report.json",
                                    repeat: false),
                                "تقرير التأخير و الغياب",
                              ),
                              Container(
                                  child: FutureBuilder(
                                      future: Provider.of<ReportsData>(context,
                                              listen: true)
                                          .futureListener,
                                      builder: (context, snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.waiting:
                                            return Container();
                                          case ConnectionState.done:
                                            return !reportsData
                                                    .lateAbsenceReport.isDayOff
                                                ? reportsData
                                                            .lateAbsenceReport
                                                            .lateAbsenceReportUnitList
                                                            .length !=
                                                        0
                                                    ? isLoading
                                                        ? Container()
                                                        : Row(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return Dialog(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0)),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              300.h,
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              FadeInRight(
                                                                            child:
                                                                                Padding(padding: const EdgeInsets.all(8.0), child: ZoomIn(child: LateReportPieChart())),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                                child:
                                                                    const Icon(
                                                                  FontAwesomeIcons
                                                                      .chartBar,
                                                                  color: Colors
                                                                      .orange,
                                                                ),
                                                              ),
                                                              XlsxExportButton(
                                                                reportType: 1,
                                                                title:
                                                                    "تقرير التأخير و الغياب",
                                                                day:
                                                                    _dateController
                                                                        .text,
                                                                site: userDataProvider
                                                                            .user
                                                                            .userType ==
                                                                        2
                                                                    ? ""
                                                                    //  Provider.of<
                                                                    //             UserData>(
                                                                    //         context,
                                                                    //         listen:
                                                                    //             false)
                                                                    //     .siteName
                                                                    : Provider.of<SiteShiftsData>(
                                                                            context)
                                                                        .siteShiftList[
                                                                            siteIdIndex]
                                                                        .siteName,
                                                              ),
                                                            ],
                                                          )
                                                    : Container()
                                                : Container();
                                          default:
                                            return Container();
                                        }
                                      }))
                            ],
                          ),
                        ),
                        Container(
                            child: Theme(
                          data: clockTheme1,
                          child: Builder(
                            builder: (context) {
                              return InkWell(
                                  onTap: () async {
                                    final List<DateTime> picked =
                                        await DateRagePicker.showDatePicker(
                                            context: context,
                                            initialFirstDate: fromDate,
                                            initialLastDate: toDate,
                                            selectableDayPredicate: (day) =>
                                                datePickerPeriodAvailable(
                                                    fromDate, day),
                                            firstDate: DateTime(
                                                comProv.com.createdOn.year - 1,
                                                comProv.com.createdOn.month,
                                                comProv.com.createdOn.day),
                                            lastDate: yesterday);

                                    if (picked.last
                                            .difference(picked.first)
                                            .inDays >
                                        31) {
                                      print(picked.last
                                          .difference(picked.first)
                                          .inDays);
                                      Fluttertoast.showToast(
                                          gravity: ToastGravity.CENTER,
                                          msg:
                                              "يجب ان يتم اختيار اقل من 32 يوم",
                                          backgroundColor: Colors.red);
                                    } else {
                                      var newString = "";
                                      setState(() {
                                        fromDate = picked.first;
                                        toDate = picked.last;
                                        showTable = false;
                                        showViewTableButton = true;
                                        final String fromText =
                                            " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                                        final String toText =
                                            " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
                                        newString = "$fromText $toText";
                                      });

                                      if (_dateController.text != newString) {
                                        _dateController.text = newString;

                                        dateFromString =
                                            apiFormatter.format(fromDate);
                                        dateToString =
                                            apiFormatter.format(toDate);
                                      }
                                    }
                                  },
                                  child: Directionality(
                                    textDirection: ui.TextDirection.rtl,
                                    child: Container(
                                      // width: 330,
                                      width:
                                          getkDeviceWidthFactor(context, 330),
                                      child: IgnorePointer(
                                        child: TextFormField(
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                          textInputAction: TextInputAction.next,
                                          controller: _dateController,
                                          decoration: kTextFieldDecorationFromTO
                                              .copyWith(
                                                  hintText: 'المدة من / إلى',
                                                  prefixIcon: const Icon(
                                                    Icons
                                                        .calendar_today_rounded,
                                                    color: Colors.orange,
                                                  )),
                                        ),
                                      ),
                                    ),
                                  ));
                            },
                          ),
                        )),
                        const SizedBox(
                          height: 10,
                        ),
                        Provider.of<UserData>(context, listen: false)
                                        .user
                                        .userType ==
                                    3 ||
                                Provider.of<UserData>(context, listen: false)
                                        .user
                                        .userType ==
                                    4
                            ? Container(
                                // width: 330,
                                width: getkDeviceWidthFactor(context, 345),
                                child: SiteDropdown(
                                  edit: true,
                                  list: Provider.of<SiteShiftsData>(context)
                                      .siteShiftList,
                                  colour: Colors.white,
                                  icon: Icons.location_on,
                                  borderColor: Colors.black,
                                  hint: "الموقع",
                                  hintColor: Colors.black,
                                  onChange: (value) async {
                                    // print()
                                    siteIdIndex = getSiteIndexBySiteName(value);
                                    if (siteId !=
                                        Provider.of<SiteShiftsData>(context,
                                                listen: false)
                                            .siteShiftList[siteIdIndex]
                                            .siteId) {
                                      siteId = Provider.of<SiteShiftsData>(
                                              context,
                                              listen: false)
                                          .siteShiftList[siteIdIndex]
                                          .siteId;

                                      setState(() {
                                        showTable = false;
                                        showViewTableButton = true;
                                      });

                                      // await Provider.of<
                                      //             ReportsData>(
                                      //         context,
                                      //         listen: false)
                                      //     .getLateAbsenceReport(
                                      //         userToken,
                                      //         siteId,
                                      //         dateFromString,
                                      //         dateToString,
                                      //         context);
                                    }
                                    print(value);
                                  },
                                  selectedvalue:
                                      Provider.of<SiteShiftsData>(context)
                                          .siteShiftList[siteIdIndex]
                                          .siteName,
                                  textColor: Colors.orange,
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 5,
                        ),
                        Visibility(
                          visible: showViewTableButton,
                          child: Expanded(
                            flex: 9,
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  loadProgressIndicator();
                                  setState(() {
                                    getData(siteIdIndex);
                                    showTable = true;
                                    showViewTableButton = false;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  width: 150.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2,
                                          color: ColorManager.primary),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const AutoSizeText(
                                        "عرض التقرير",
                                        style: TextStyle(
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
                            ),
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder(
                              future: Provider.of<ReportsData>(context,
                                      listen: true)
                                  .futureListener,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return ProgressBar(percent, 300, 290);
                                  case ConnectionState.done:
                                    if (percent != 0) {
                                      timer.cancel();
                                    }
                                    return showTable
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              snapshot.data ==
                                                      "Date is older than company date"
                                                  ? const Expanded(
                                                      child: CenterMessageText(
                                                          message:
                                                              "التاريخ قبل إنشاء الشركة"),
                                                    )
                                                  : Expanded(
                                                      child: Container(
                                                        color: Colors.white,
                                                        child: Directionality(
                                                            textDirection: ui
                                                                .TextDirection
                                                                .rtl,
                                                            child: !reportsData
                                                                    .lateAbsenceReport
                                                                    .isDayOff
                                                                ? reportsData
                                                                            .lateAbsenceReport
                                                                            .lateAbsenceReportUnitList
                                                                            .length !=
                                                                        0
                                                                    ? Column(
                                                                        children: [
                                                                          Divider(
                                                                            thickness:
                                                                                1,
                                                                            color:
                                                                                Colors.orange[600],
                                                                          ),
                                                                          DataTableHeader(),
                                                                          Divider(
                                                                            thickness:
                                                                                1,
                                                                            color:
                                                                                Colors.orange[600],
                                                                          ),
                                                                          Expanded(
                                                                              child: Container(
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                ListView.builder(
                                                                                    controller: _scrollController,
                                                                                    itemCount: reportsData.lateAbsenceReport.lateAbsenceReportUnitList.length,
                                                                                    itemBuilder: (BuildContext context, int index) {
                                                                                      return DataTableRow(reportsData.lateAbsenceReport.lateAbsenceReportUnitList[index], siteIdIndex, fromDate, toDate);
                                                                                    }),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                          Directionality(
                                                                              textDirection: ui.TextDirection.rtl,
                                                                              child: DataTableEnd(
                                                                                lateRatio: reportsData.lateAbsenceReport.lateRatio,
                                                                                absenceRatio: reportsData.lateAbsenceReport.absentRatio,
                                                                                totalDeduction: reportsData.lateAbsenceReport.totalDecutionForAllUsers,
                                                                              ))
                                                                        ],
                                                                      )
                                                                    : Center(
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              20,
                                                                          child:
                                                                              AutoSizeText(
                                                                            "لا يوجد تسجيلات بهذا الموقع",
                                                                            maxLines:
                                                                                1,
                                                                            style:
                                                                                TextStyle(fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true), fontWeight: FontWeight.w700),
                                                                          ),
                                                                        ),
                                                                      )
                                                                : Center(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          20,
                                                                      child:
                                                                          AutoSizeText(
                                                                        "لا يوجد تسجيلات: يوم اجازة",
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                ScreenUtil().setSp(16, allowFontScalingSelf: true),
                                                                            fontWeight: FontWeight.w700),
                                                                      ),
                                                                    ),
                                                                  )),
                                                      ),
                                                    )
                                            ],
                                          )
                                        : Container();
                                  default:
                                    return Container();
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
    });
  }

  Future<bool> onWillPop() {
    print("back");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NavScreenTwo(2)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}
