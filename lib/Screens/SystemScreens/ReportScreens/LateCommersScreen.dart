import 'dart:io';
import 'dart:ui' as ui;
import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
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
  String dateToString = "";
  String dateFromString = "";
  TextEditingController _dateController = TextEditingController();
  int selectedDuration;
  DateTime toDate;
  DateTime fromDate;
  DateTime yesterday;
  Site siteData;

  String diff;
  var isLoading = false;

  void initState() {
    super.initState();
    var now = DateTime.now();
    fromDate = DateTime(now.year, now.month,
        Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    toDate = DateTime(now.year, now.month, now.day - 1);
    yesterday = DateTime(now.year, now.month, now.day - 1);
    if (toDate.isBefore(fromDate)) {
      fromDate = DateTime(now.year, now.month - 1,
          Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    }
    var comProv = Provider.of<CompanyData>(context, listen: false);
    if (fromDate.isBefore(comProv.com.createdOn)) {
      fromDate = comProv.com.createdOn;
    }
    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    String fromText = " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    String toText = " إلى ${DateFormat('yMMMd').format(toDate).toString()}";

    _dateController.text = "$fromText $toText";
    getData(siteIdIndex);
  }

  getData(int siteIndex) async {
    int siteID;
    UserData userProvider = Provider.of<UserData>(context, listen: false);

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

  int getSiteId(String siteName) {
    var list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    int index = list.length;
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
    DateTime maxDate = currentDate.add(Duration(days: 31));
    DateTime minDate = currentDate.subtract(Duration(days: 31));

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
    var comProv = Provider.of<CompanyData>(context, listen: false);
    return Consumer<ReportsData>(builder: (context, reportsData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          endDrawer: NotificationItem(),
          backgroundColor: Colors.white,
          body: Container(
            child: GestureDetector(
              onTap: () {
                print(reportsData.lateAbsenceReport.lateRatio);
                print(comProv.com.createdOn);
                print(fromDate);
                print(comProv.com.legalComDate);
              },
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
                                                                        width: double
                                                                            .infinity,
                                                                        child:
                                                                            FadeInRight(
                                                                          child: Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: ZoomIn(child: LateReportPieChart())),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Icon(
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
                                                                  : Provider.of<
                                                                              SiteShiftsData>(
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
                      Expanded(
                        child: FutureBuilder(
                            future:
                                Provider.of<ReportsData>(context, listen: true)
                                    .futureListener,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.orange),
                                        ),
                                      ),
                                    );
                                  case ConnectionState.done:
                                    return Column(
                                      children: [
                                        Container(
                                            child: Theme(
                                          data: clockTheme1,
                                          child: Builder(
                                            builder: (context) {
                                              return InkWell(
                                                  onTap: () async {
                                                    final List<DateTime>
                                                        picked =
                                                        await DateRagePicker.showDatePicker(
                                                            context: context,
                                                            initialFirstDate:
                                                                fromDate,
                                                            initialLastDate:
                                                                toDate,
                                                            selectableDayPredicate:
                                                                (day) =>
                                                                    datePickerPeriodAvailable(
                                                                        fromDate,
                                                                        day),
                                                            firstDate: DateTime(
                                                                comProv
                                                                        .com
                                                                        .createdOn
                                                                        .year -
                                                                    1,
                                                                comProv
                                                                    .com
                                                                    .createdOn
                                                                    .month,
                                                                comProv
                                                                    .com
                                                                    .createdOn
                                                                    .day),
                                                            lastDate:
                                                                yesterday);

                                                    if (picked.last
                                                            .difference(
                                                                picked.first)
                                                            .inDays >
                                                        31) {
                                                      print(picked.last
                                                          .difference(
                                                              picked.first)
                                                          .inDays);
                                                      Fluttertoast.showToast(
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          msg:
                                                              "يجب ان يتم اختيار اقل من 32 يوم",
                                                          backgroundColor:
                                                              Colors.red);
                                                    } else {
                                                      var newString = "";
                                                      setState(() {
                                                        fromDate = picked.first;
                                                        toDate = picked.last;

                                                        String fromText =
                                                            " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                        String toText =
                                                            " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
                                                        newString =
                                                            "$fromText $toText";
                                                      });

                                                      if (_dateController
                                                              .text !=
                                                          newString) {
                                                        _dateController.text =
                                                            newString;

                                                        dateFromString =
                                                            apiFormatter.format(
                                                                fromDate);
                                                        dateToString =
                                                            apiFormatter
                                                                .format(toDate);

                                                        var user = Provider.of<
                                                                    UserData>(
                                                                context,
                                                                listen: false)
                                                            .user;
                                                        if (user.userType ==
                                                            2) {
                                                          await Provider.of<
                                                                      ReportsData>(
                                                                  context,
                                                                  listen: false)
                                                              .getLateAbsenceReport(
                                                                  user.userToken,
                                                                  user.userSiteId,
                                                                  dateFromString,
                                                                  dateToString,
                                                                  context);
                                                        } else {
                                                          await Provider.of<
                                                                      ReportsData>(
                                                                  context,
                                                                  listen: false)
                                                              .getLateAbsenceReport(
                                                                  user
                                                                      .userToken,
                                                                  Provider.of<SiteShiftsData>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .siteShiftList[
                                                                          siteIdIndex]
                                                                      .siteId,
                                                                  dateFromString,
                                                                  dateToString,
                                                                  context);
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Directionality(
                                                    textDirection:
                                                        ui.TextDirection.rtl,
                                                    child: Container(
                                                      // width: 330,
                                                      width:
                                                          getkDeviceWidthFactor(
                                                              context, 330),
                                                      child: IgnorePointer(
                                                        child: TextFormField(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          controller:
                                                              _dateController,
                                                          decoration:
                                                              kTextFieldDecorationFromTO
                                                                  .copyWith(
                                                                      hintText:
                                                                          'المدة من / إلى',
                                                                      prefixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .calendar_today_rounded,
                                                                        color: Colors
                                                                            .orange,
                                                                      )),
                                                        ),
                                                      ),
                                                    ),
                                                  ));
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Provider.of<UserData>(context,
                                                            listen: false)
                                                        .user
                                                        .userType ==
                                                    3 ||
                                                Provider.of<UserData>(context,
                                                            listen: false)
                                                        .user
                                                        .userType ==
                                                    4
                                            ? Container(
                                                // width: 330,
                                                width: getkDeviceWidthFactor(
                                                    context, 345),
                                                child: SiteDropdown(
                                                  edit: true,
                                                  list: Provider.of<
                                                              SiteShiftsData>(
                                                          context)
                                                      .siteShiftList,
                                                  colour: Colors.white,
                                                  icon: Icons.location_on,
                                                  borderColor: Colors.black,
                                                  hint: "الموقع",
                                                  hintColor: Colors.black,
                                                  onChange: (value) async {
                                                    // print()
                                                    siteIdIndex =
                                                        getSiteId(value);
                                                    if (siteId !=
                                                        Provider.of<SiteShiftsData>(
                                                                context,
                                                                listen: false)
                                                            .siteShiftList[
                                                                siteIdIndex]
                                                            .siteId) {
                                                      siteId = Provider.of<
                                                                  SiteShiftsData>(
                                                              context,
                                                              listen: false)
                                                          .siteShiftList[
                                                              siteIdIndex]
                                                          .siteId;

                                                      var userToken =
                                                          Provider.of<UserData>(
                                                                  context,
                                                                  listen: false)
                                                              .user
                                                              .userToken;
                                                      setState(() {});

                                                      await Provider.of<
                                                                  ReportsData>(
                                                              context,
                                                              listen: false)
                                                          .getLateAbsenceReport(
                                                              userToken,
                                                              siteId,
                                                              dateFromString,
                                                              dateToString,
                                                              context);
                                                    }
                                                    print(value);
                                                  },
                                                  selectedvalue: Provider.of<
                                                              SiteShiftsData>(
                                                          context)
                                                      .siteShiftList[
                                                          siteIdIndex]
                                                      .siteName,
                                                  textColor: Colors.orange,
                                                ),
                                              )
                                            : Container(),
                                        snapshot.data ==
                                                "Date is older than company date"
                                            ? Expanded(
                                                child: CenterMessageText(
                                                    message:
                                                        "التاريخ قبل إنشاء الشركة"),
                                              )
                                            : Expanded(
                                                child: Container(
                                                  color: Colors.white,
                                                  child: Directionality(
                                                      textDirection:
                                                          ui.TextDirection.rtl,
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
                                                                      color: Colors
                                                                              .orange[
                                                                          600],
                                                                    ),
                                                                    DataTableHeader(),
                                                                    Divider(
                                                                      thickness:
                                                                          1,
                                                                      color: Colors
                                                                              .orange[
                                                                          600],
                                                                    ),
                                                                    Expanded(
                                                                        child:
                                                                            Container(
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          ListView.builder(
                                                                              itemCount: reportsData.lateAbsenceReport.lateAbsenceReportUnitList.length,
                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                return DataTableRow(reportsData.lateAbsenceReport.lateAbsenceReportUnitList[index], siteIdIndex, fromDate, toDate);
                                                                              }),
                                                                          Positioned(
                                                                              child: Container(width: 110, height: 1000, child: MultipleFloatingButtonsNoADD()),
                                                                              bottom: 0,
                                                                              left: 0),
                                                                        ],
                                                                      ),
                                                                    )),
                                                                    Directionality(
                                                                        textDirection: ui
                                                                            .TextDirection
                                                                            .rtl,
                                                                        child:
                                                                            DataTableEnd(
                                                                          lateRatio: reportsData
                                                                              .lateAbsenceReport
                                                                              .lateRatio,
                                                                          absenceRatio: reportsData
                                                                              .lateAbsenceReport
                                                                              .absentRatio,
                                                                          totalDeduction: reportsData
                                                                              .lateAbsenceReport
                                                                              .totalDecutionForAllUsers,
                                                                        ))
                                                                  ],
                                                                )
                                                              : Center(
                                                                  child:
                                                                      Container(
                                                                    height: 20,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "لا يوجد تسجيلات بهذا الموقع",
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
                                                                )
                                                          : Center(
                                                              child: Container(
                                                                height: 20,
                                                                child:
                                                                    AutoSizeText(
                                                                  "لا يوجد تسجيلات: يوم اجازة",
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
                                                            )),
                                                ),
                                              )
                                      ],
                                    );
                                  default:
                                    return Center(
                                      child: Platform.isIOS
                                          ? CupertinoActivityIndicator(
                                              radius: 20,
                                            )
                                          : CircularProgressIndicator(
                                              backgroundColor: Colors.white,
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(Colors.orange),
                                            ),
                                    );
                                }
                              }
                              return Center(
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
                              );
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
