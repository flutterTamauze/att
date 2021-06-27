import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets//XlsxExportButton.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  var toDate;
  var fromDate;  
  DateTime yesterday;
  Site siteData;
  String diff;

  void initState() {
    // TODO: implement initState
    super.initState();
    var now = DateTime.now();

    fromDate = DateTime(now.year, now.month, now.day - 1);
    toDate = DateTime(now.year, now.month, now.day - 1);
    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    String fromText = " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    String toText = " إلى ${DateFormat('yMMMd').format(toDate).toString()}";

    _dateController.text = "$fromText $toText";
    getData(siteIdIndex);
  }

  getData(int siteIndex) async {
    var siteID;
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);

    if (userProvider.user.userType == 2) {
      siteID = userProvider.user.userSiteId;
      siteData = await Provider.of<SiteData>(context, listen: false)
          .getSpecificSite(siteID, userProvider.user.userToken,context);
    } else {
      if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
        await Provider.of<SiteData>(context, listen: false)
            .getSitesByCompanyId(
                comProvider.com.id, userProvider.user.userToken,context)
            .then((value) {
          siteID = Provider.of<SiteData>(context, listen: false)
              .sitesList[siteIndex]
              .id;
        });
      } else {
        siteID = Provider.of<SiteData>(context, listen: false)
            .sitesList[siteIndex]
            .id;
      }
    }
    await Provider.of<ReportsData>(context, listen: false).getLateAbsenceReport(
        userProvider.user.userToken, siteID, dateFromString, dateToString,context);
    print(Provider.of<ReportsData>(context, listen: false)
        .lateAbsenceReport
        .absentRatio);
  }

  int getSiteId(String siteName) {
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
  }

  int siteIdIndex = 0;
  int siteId = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final userDataProvider = Provider.of<UserData>(context, listen: false);

    return Consumer<ReportsData>(builder: (context, reportsData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
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
                      Header(nav: false),
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
                                                  ? XlsxExportButton(
                                                      reportType: 1,
                                                      title:
                                                          "تقرير التأخير و الغياب",
                                                      day: _dateController.text,
                                                      site: userDataProvider
                                                                  .user
                                                                  .userType ==
                                                              2
                                                          ? siteData.name
                                                          : Provider.of<
                                                                      SiteData>(
                                                                  context)
                                                              .sitesList[
                                                                  siteIdIndex]
                                                              .name,
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
                                                                context:
                                                                    context,
                                                                initialFirstDate:
                                                                    fromDate,
                                                                initialLastDate:
                                                                    toDate,
                                                                firstDate:
                                                                    new DateTime(
                                                                        2021),
                                                                lastDate:
                                                                    yesterday);
                                                        var newString = "";
                                                        setState(() {
                                                          fromDate =
                                                              picked.first;
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
                                                              apiFormatter
                                                                  .format(
                                                                      fromDate);
                                                          dateToString =
                                                              apiFormatter
                                                                  .format(
                                                                      toDate);

                                                          var user = Provider
                                                                  .of<UserData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                              .user;
                                                          if (user.userType ==
                                                              2) {
                                                            await Provider.of<
                                                                        ReportsData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .getLateAbsenceReport(
                                                                    user.userToken,
                                                                    user.userSiteId,
                                                                    dateFromString,
                                                                    dateToString,context);
                                                          } else {
                                                            await Provider.of<
                                                                        ReportsData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .getLateAbsenceReport(
                                                                    user
                                                                        .userToken,
                                                                    Provider.of<SiteData>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .sitesList[
                                                                            siteIdIndex]
                                                                        .id,
                                                                    dateFromString,
                                                                    dateToString,context);
                                                          }
                                                        }
                                                      },
                                                      child: Directionality(
                                                        textDirection: ui
                                                            .TextDirection.rtl,
                                                        child: Container(
                                                          // width: 330,
                                                          width:
                                                              getkDeviceWidthFactor(
                                                                  context, 330),
                                                          child: IgnorePointer(
                                                            child:
                                                                TextFormField(
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              controller:
                                                                  _dateController,
                                                              decoration: kTextFieldDecorationFromTO
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
                                                    context, 330),
                                                child: SiteDropdown(
                                                  edit: true,
                                                  list: Provider.of<SiteData>(
                                                          context)
                                                      .sitesList,
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
                                                        Provider.of<SiteData>(
                                                                context,
                                                                listen: false)
                                                            .sitesList[
                                                                siteIdIndex]
                                                            .id) {
                                                      siteId =
                                                          Provider.of<SiteData>(
                                                                  context,
                                                                  listen: false)
                                                              .sitesList[
                                                                  siteIdIndex]
                                                              .id;

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
                                                              dateToString,context);
                                                    }
                                                    print(value);
                                                  },
                                                  selectedvalue: Provider.of<
                                                          SiteData>(context)
                                                      .sitesList[siteIdIndex]
                                                      .name,
                                                  textColor: Colors.orange,
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Expanded(
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
                                                              DataTableHeader(),
                                                              Expanded(
                                                                  child:
                                                                      Container(
                                                                child: ListView
                                                                    .builder(
                                                                        itemCount: reportsData
                                                                            .lateAbsenceReport
                                                                            .lateAbsenceReportUnitList
                                                                            .length,
                                                                        itemBuilder:
                                                                            (BuildContext context,
                                                                                int index) {
                                                                          return DataTableRow(
                                                                              reportsData.lateAbsenceReport.lateAbsenceReportUnitList[index],
                                                                              siteIdIndex);
                                                                        }),
                                                              )),
                                                              Directionality(
                                                                  textDirection:
                                                                      ui.TextDirection
                                                                          .rtl,
                                                                  child:
                                                                      DataTableEnd(
                                                                    lateRatio: reportsData
                                                                        .lateAbsenceReport
                                                                        .lateRatio,
                                                                    absenceRatio:
                                                                        reportsData
                                                                            .lateAbsenceReport
                                                                            .absentRatio,
                                                                  ))
                                                            ],
                                                          )
                                                        : Center(
                                                            child: Container(
                                                              height: 20,
                                                              child:
                                                                  AutoSizeText(
                                                                "لا يوجد تسجيلات بهذا الموقع",
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
                                                          )
                                                    : Center(
                                                        child: Container(
                                                          height: 20,
                                                          child: AutoSizeText(
                                                            "لا يوجد تسجيلات: يوم اجازة",
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                fontSize: ScreenUtil()
                                                                    .setSp(16,
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

class DataTableRow extends StatelessWidget {
  final LateAbsenceReportUnit userAttendanceReportUnit;
  final siteId;

  DataTableRow(this.userAttendanceReportUnit, this.siteId);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var now = DateTime.now();

        var toDate = DateTime(now.year, now.month, now.day - 1);
        var fromDate = DateTime(toDate.year, toDate.month - 1, toDate.day + 1);

        var userProvider = Provider.of<UserData>(context, listen: false).user;

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedLoadingIndicator();
            });

        var x = await Provider.of<ReportsData>(context, listen: false)
            .getUserReportUnits(
                userProvider.userToken,
                userAttendanceReportUnit.userId,
                formatter.format(fromDate),
                formatter.format(toDate),context);
        print("Success $x");
        if (x == "Success") {
          Navigator.pop(context);
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) => UserAttendanceReportScreen(
                name: userAttendanceReportUnit.userName,
                siteId: siteId,
              ),
            ),
          );
        }
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 160.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      child: AutoSizeText(
                        userAttendanceReportUnit.userName,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: ScreenUtil()
                                .setSp(16, allowFontScalingSelf: true),
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          height: 50.h,
                          child: Center(
                              child: userAttendanceReportUnit.totalLate == "-"
                                  ? Container(
                                      height: 20,
                                      child: AutoSizeText(
                                        userAttendanceReportUnit.totalLate,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true),
                                            color: Colors.black),
                                      ),
                                    )
                                  : Container(
                                      height: 20,
                                      child: AutoSizeText(
                                        userAttendanceReportUnit.totalLate,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true),
                                            color: Colors.red),
                                      ),
                                    ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          height: 50.h,
                          child: Center(
                              child: Container(
                            height: 20,
                            child: AutoSizeText(
                              userAttendanceReportUnit.totalLateDays,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(16, allowFontScalingSelf: true),
                                  color: Colors.black),
                            ),
                          ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          height: 50.h,
                          child: Center(
                              child: Container(
                            height: 20,
                            child: AutoSizeText(
                              userAttendanceReportUnit.totalAbsence,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(16, allowFontScalingSelf: true),
                                  color: Colors.black),
                            ),
                          ))),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DataTableEnd extends StatelessWidget {
  final lateRatio;
  final absenceRatio;
  DataTableEnd({this.absenceRatio, this.lateRatio});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          )),
      child: Container(
        height: 50.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Container(
                  height: 20,
                  child: AutoSizeText(
                    'نسبة التأخير:',
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(16, allowFontScalingSelf: true),
                        color: Colors.black),
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  height: 20,
                  child: AutoSizeText(
                    lateRatio,
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(16, allowFontScalingSelf: true),
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 20,
                  child: AutoSizeText(
                    'نسبة الغياب:',
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(16, allowFontScalingSelf: true),
                        color: Colors.black),
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  height: 20,
                  child: AutoSizeText(
                    absenceRatio,
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(16, allowFontScalingSelf: true),
                        color: Colors.black),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DataTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                  width: 160.w,
                  height: 50.h,
                  child: Center(
                      child: Container(
                    height: 20,
                    child: AutoSizeText(
                      'الاسم',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  ))),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20,
                        child: AutoSizeText(
                          'التأخير',
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black),
                        ),
                      ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20,
                        child: AutoSizeText(
                          'ايام التأخير',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black),
                        ),
                      ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20,
                        child: AutoSizeText(
                          'ايام الغياب',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black),
                        ),
                      ))),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//   int getSiteId(String siteName) {
//     var list = Provider.of<SiteData>(context, listen: false).sitesList;
//     int index = list.length;
//     for (int i = 0; i < index; i++) {
//       if (siteName == list[i].name) {
//         return i;
//       }
//     }
//     return -1;
//   }
//
//   int siteId = 0;
//   @override
//   Widget build(BuildContext context) {
//     // final userDataProvider = Provider.of<UserData>(context, listen: false);
//
//     SystemChrome.setEnabledSystemUIOverlays([]);
//     return Consumer<ReportsData>(builder: (context, reportsData, child) {
//       return WillPopScope(
//         onWillPop: onWillPop,
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: Container(
//             child: GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onPanDown: (_) {
//                 FocusScope.of(context).unfocus();
//               },
//               child: Stack(
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Header(),
//                       Directionality(
//                         textDirection: ui.TextDirection.rtl,
//                         child: ReportsDirectoriesHeader(
//                           Lottie.asset("resources/report.json", repeat: false),
//                           "تقرير المتأخرين اليومى",
//                         ),
//                       ),
//                       Container(
//                         height: 50,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Provider.of<UserData>(context, listen: false)
//                                       .user
//                                       .userType ==
//                                   "1"
//                               ? Row(
//                                   children: [
//                                     Expanded(
//                                       flex: 1,
//                                       child: SiteDropdown(
//                                         edit: true,
//                                         list: Provider.of<SiteData>(context)
//                                             .sitesList,
//                                         colour: Colors.white,
//                                         icon: Icons.location_on,
//                                         borderColor: Colors.black,
//                                         hint: "الموقع",
//                                         hintColor: Colors.black,
//                                         onChange: (value) {
//                                           // print()
//                                           siteId = getSiteId(value);
//                                           print(value);
//                                         },
//                                         selectedvalue:
//                                             Provider.of<SiteData>(context)
//                                                 .sitesList[siteId]
//                                                 .name,
//                                         textColor: Colors.orange,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 5,
//                                     ),
//                                     Expanded(
//                                       flex: 1,
//                                       child: Container(
//                                         child: Directionality(
//                                           textDirection: ui.TextDirection.rtl,
//                                           child: Container(
//                                             child: DateTimePicker(
//                                               type: DateTimePickerType.date,
//                                               firstDate: DateTime(2021),
//                                               lastDate: DateTime.now(),
//                                               //controller: _endTimeController,
//                                               textAlign: TextAlign.center,
//                                               decoration:
//                                                   kTextFieldDecorationTime
//                                                       .copyWith(
//                                                           hintStyle: TextStyle(
//                                                             color: Colors.black,
//                                                           ),
//                                                           hintText: 'اليوم',
//                                                           prefixIcon: Icon(
//                                                             Icons.access_time,
//                                                             color:
//                                                                 Colors.orange,
//                                                           )),
//                                               validator: (val) {
//                                                 if (val.length == 0) {
//                                                   return 'مطلوب';
//                                                 }
//                                                 return null;
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : Container(
//                                   width: 200,
//                                   child: Directionality(
//                                     textDirection: ui.TextDirection.rtl,
//                                     child: Container(
//                                       child: DateTimePicker(
//                                         type: DateTimePickerType.date,
//                                         firstDate: DateTime(2021),
//                                         lastDate: DateTime.now(),
//                                         //controller: _endTimeController,
//                                         textAlign: TextAlign.center,
//                                         decoration:
//                                             kTextFieldDecorationTime.copyWith(
//                                                 hintText: 'اليوم',
//                                                 prefixIcon: Icon(
//                                                   Icons.access_time,
//                                                   color: Colors.orange,
//                                                 )),
//                                         validator: (val) {
//                                           if (val.length == 0) {
//                                             return 'مطلوب';
//                                           }
//                                           return null;
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Expanded(
//                         child: Container(
//                           color: Colors.white,
//                           child: Directionality(
//                               textDirection: ui.TextDirection.rtl,
//                               child: Column(
//                                 children: [
//                                   DataTableHeader(),
//                                   Expanded(
//                                       child: ListView.builder(
//                                           itemCount: reportsData
//                                               .lateComersReportList.length,
//                                           itemBuilder: (BuildContext context,
//                                               int index) {
//                                             return DataTableRow(reportsData
//                                                 .lateComersReportList[index]);
//                                           })),
//                                 ],
//                               )),
//                         ),
//                       ),
//                       Directionality(
//                           textDirection: ui.TextDirection.rtl,
//                           child: DataTableEnd(
//                               total: reportsData.lateComersReportList.length
//                                   .toString()))
//                     ],
//                   ),
//                   Positioned(
//                     left: 5.0,
//                     top: 5.0,
//                     child: Container(
//                       width: 50,
//                       height: 50,
//                       color: Colors.black,
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.chevron_left,
//                           color: Color(0xffF89A41),
//                           size: 40,
//                         ),
//                         onPressed: () {
//                           Navigator.of(context).pushAndRemoveUntil(
//                               MaterialPageRoute(
//                                   builder: (context) => NavScreen(2)),
//                               (Route<dynamic> route) => false);
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
//
//   Future<bool> onWillPop() {
//     print("back");
//     Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => NavScreen(2)),
//         (Route<dynamic> route) => false);
//     return Future.value(false);
//   }
// }
//
// class DataTableRow extends StatelessWidget {
//   final LateComersReportUnit lateComersReportUnit;
//
//   DataTableRow(this.lateComersReportUnit);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Row(
//           children: [
//             Container(
//               width: 180,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   AutoSizeText(
//                     lateComersReportUnit.reportUnit.userName,
//                     style: TextStyle(fontSize: 16, color: Colors.black),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 1,
//                     child: Container(
//                         height: 50,
//                         child: Center(
//                             child: AutoSizeText(
//                           lateComersReportUnit.lateTime,
//                           style: TextStyle(fontSize: 16, color: Colors.red),
//                         ))),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Container(
//                         height: 50,
//                         child: Center(
//                             child: lateComersReportUnit.reportUnit.timeIn == "-"
//                                 ? AutoSizeText(
//                                     "غياب",
//                                     style: TextStyle(
//                                         fontSize: 14, color: Colors.red),
//                                   )
//                                 : AutoSizeText(
//                                     lateComersReportUnit.reportUnit.timeIn,
//                                     style: TextStyle(
//                                         fontSize: 16, color: Colors.black),
//                                   ))),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Container(
//                         height: 50,
//                         child: Center(
//                             child: AutoSizeText(
//                           lateComersReportUnit.reportUnit.timeOut,
//                           style: TextStyle(fontSize: 16, color: Colors.black),
//                         ))),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DataTableEnd extends StatelessWidget {
//   final total;
//   DataTableEnd({this.total});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.orange,
//           borderRadius: BorderRadius.only(
//             bottomRight: Radius.circular(15),
//             bottomLeft: Radius.circular(15),
//           )),
//       child: Container(
//         height: 50,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Row(
//               children: [
//                 AutoSizeText(
//                   'مجموع المتاخرين:',
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.black),
//                 ),
//                 SizedBox(width: 20),
//                 AutoSizeText(
//                   total,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.black),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DataTableHeader extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         decoration: BoxDecoration(
//             color: Colors.orange,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(15),
//               topRight: Radius.circular(15),
//             )),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: Row(
//             children: [
//               Container(
//                   width: 180,
//                   height: 50,
//                   child: Center(
//                       child: AutoSizeText(
//                     'الاسم',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: Colors.black),
//                   ))),
//               Expanded(
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: Container(
//                           child: Center(
//                               child: AutoSizeText(
//                         'التأخير',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: Colors.black),
//                       ))),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Container(
//                           child: Center(
//                               child: AutoSizeText(
//                         'الحضور',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: Colors.black),
//                       ))),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Container(
//                           child: Center(
//                               child: AutoSizeText(
//                         'الانصراف',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: Colors.black),
//                       ))),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ));
//   }
// }
