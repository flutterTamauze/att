import 'dart:io';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DailyReport/dailyReportTableHeader.dart';
import 'package:qr_users/widgets/DailyReport/dataTableEnd.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/XlsxExportButton.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../services/MemberData.dart';

class DailyReportScreen extends StatefulWidget {
  DailyReportScreen();

  @override
  _DailyReportScreenState createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  @override
  void initState() {
    super.initState();
    date = apiFormatter.format(DateTime.now());
    getData(siteId, date);
    selectedDateString = DateTime.now().toString();
    var now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    selectedDate = DateTime(now.year, now.month, now.day);
  }

  var isLoading = false;
  int siteId = 0;
  Site siteData;
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  String date;

  String selectedDateString;
  DateTime selectedDate;
  DateTime today;
  int siteID;

  getData(int siteIndex, String date) async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);
    if (userProvider.user.userType == 2) {
      if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
        await Provider.of<SiteData>(context, listen: false).getSpecificSite(
            userProvider.user.userSiteId, userProvider.user.userToken, context);
      }
    } else {
      if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
        await Provider.of<SiteData>(context, listen: false)
            .getSitesByCompanyId(
                comProvider.com.id, userProvider.user.userToken, context)
            .then((value) {
          siteID = Provider.of<SiteData>(context, listen: false)
              .sitesList[siteIndex]
              .id;
          print("SiteIndex $siteIndex");
        });
      } else {
        siteID = Provider.of<SiteData>(context, listen: false)
            .sitesList[siteIndex]
            .id;
      }
    }
    print(siteID);
    print(date);
    await Provider.of<ReportsData>(context, listen: false).getDailyReportUnits(
        userProvider.user.userToken,
        userProvider.user.userType == 2 ? userProvider.user.userSiteId : siteID,
        date,
        context);
  }

  int getSiteIndex(String siteName) {
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
  }

  @override
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    // monitor network fetch
    print("refresh");
    // if failed,use refreshFailed()
    setState(() {
      isLoading = true;
    });

    await Provider.of<ReportsData>(context, listen: false).getDailyReportUnits(
        userProvider.user.userToken,
        userProvider.user.userType == 2 ? userProvider.user.userSiteId : siteID,
        date,
        context);
    refreshController.refreshCompleted();
  }

  bool isToday(DateTime selectedDay) {
    print(selectedDate.toString());
    if (selectedDay.difference(today).inDays == 0) {
      print("asdsad ${selectedDay.difference(today).inDays}");
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final userDataProvider = Provider.of<UserData>(context, listen: false);
    return Consumer<ReportsData>(builder: (context, reportsData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          endDrawer: NotificationItem(),
          backgroundColor: Colors.white,
          body: Container(
            child: GestureDetector(
              onTap: () => print(siteID),
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
                                                          site: Provider.of<
                                                                      SiteData>(
                                                                  context)
                                                              .sitesList[siteId]
                                                              .name,
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
                                  return Container(
                                    color: Colors.white,
                                    child: Center(
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
                                    ),
                                  );
                                case ConnectionState.done:
                                  return Column(
                                    children: [
                                      Container(
                                        height: 50.h,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Provider.of<UserData>(context,
                                                              listen: false)
                                                          .user
                                                          .userType ==
                                                      4 ||
                                                  Provider.of<UserData>(context,
                                                              listen: false)
                                                          .user
                                                          .userType ==
                                                      3
                                              ? Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 11,
                                                      child: SiteDropdown(
                                                        edit: true,
                                                        list: Provider.of<
                                                                    SiteData>(
                                                                context)
                                                            .sitesList,
                                                        colour: Colors.white,
                                                        icon: Icons.location_on,
                                                        borderColor:
                                                            Colors.black,
                                                        hint: "الموقع",
                                                        hintColor: Colors.black,
                                                        onChange:
                                                            (value) async {
                                                          var lastRec = siteId;

                                                          siteId = getSiteIndex(
                                                              value);

                                                          if (lastRec !=
                                                              siteId) {
                                                            setState(() {});
                                                            getData(
                                                                siteId, date);
                                                            print(
                                                                "call back value $value");
                                                          }
                                                        },
                                                        selectedvalue: Provider
                                                                .of<SiteData>(
                                                                    context)
                                                            .sitesList[siteId]
                                                            .name,
                                                        textColor:
                                                            Colors.orange,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5.w,
                                                    ),
                                                    Expanded(
                                                      flex: 7,
                                                      child: Container(
                                                        child: Directionality(
                                                          textDirection: ui
                                                              .TextDirection
                                                              .rtl,
                                                          child: Container(
                                                            child: Theme(
                                                              data: clockTheme,
                                                              child:
                                                                  DateTimePicker(
                                                                initialValue:
                                                                    selectedDateString,

                                                                onChanged:
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
                                                                          DateTime.parse(
                                                                              selectedDateString);
                                                                    });
                                                                    getData(
                                                                        siteId,
                                                                        date);
                                                                  }

                                                                  print(value);
                                                                },
                                                                type:
                                                                    DateTimePickerType
                                                                        .date,
                                                                firstDate: Provider.of<
                                                                            CompanyData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .com
                                                                    .createdOn,
                                                                lastDate:
                                                                    DateTime
                                                                        .now(),
                                                                //controller: _endTimeController,
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(
                                                                        14,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),

                                                                decoration: kTextFieldDecorationTime
                                                                    .copyWith(
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        hintText:
                                                                            'اليوم',
                                                                        prefixIcon:
                                                                            Icon(
                                                                          Icons
                                                                              .access_time,
                                                                          color:
                                                                              Colors.orange,
                                                                        )),
                                                                validator:
                                                                    (val) {
                                                                  if (val.length ==
                                                                      0) {
                                                                    return 'مطلوب';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(
                                                  width: 200.w,
                                                  child: DateTimePicker(
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    initialValue:
                                                        selectedDateString,
                                                    onChanged: (value) {
                                                      if (value != date) {
                                                        date = value;
                                                        selectedDateString =
                                                            date;
                                                        setState(() {});
                                                        getData(siteId, date);
                                                      }
                                                      selectedDate =
                                                          DateTime.parse(
                                                              selectedDateString);
                                                      print(value);
                                                    },
                                                    type:
                                                        DateTimePickerType.date,
                                                    firstDate: DateTime(2021),
                                                    lastDate: DateTime.now(),
                                                    //controller: _endTimeController,
                                                    textAlign: TextAlign.right,
                                                    decoration:
                                                        kTextFieldDecorationTime
                                                            .copyWith(
                                                                hintStyle:
                                                                    TextStyle(
                                                                  fontSize: ScreenUtil().setSp(
                                                                      16,
                                                                      allowFontScalingSelf:
                                                                          true),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                hintText:
                                                                    'اليوم',
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons
                                                                      .access_time,
                                                                  color: Colors
                                                                      .orange,
                                                                )),
                                                    validator: (val) {
                                                      if (val.length == 0) {
                                                        return 'مطلوب';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                        ),
                                      ),
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
                                                        "officialHoliday"
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
                                                    : !reportsData.dailyReport
                                                            .isHoliday
                                                        ? reportsData
                                                                    .dailyReport
                                                                    .attendListUnits
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
                                                                    child: ListView.builder(
                                                                        physics: AlwaysScrollableScrollPhysics(),
                                                                        itemCount: reportsData.dailyReport.attendListUnits.length,
                                                                        itemBuilder: (BuildContext context, int index) {
                                                                          return DataTableRow(
                                                                              reportsData.dailyReport.attendListUnits[index],
                                                                              siteId);
                                                                        }),
                                                                  )),
                                                                  !isToday(selectedDate)
                                                                      ? DailyReportTableEnd(
                                                                          totalAbsents: reportsData
                                                                              .dailyReport
                                                                              .totalAbsent
                                                                              .toString(),
                                                                          totalAttend: reportsData
                                                                              .dailyReport
                                                                              .totalAttend
                                                                              .toString())
                                                                      : Container()
                                                                ],
                                                              )
                                                            : Center(
                                                                child:
                                                                    Container(
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
                                        ),
                                      ),
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

class DataTableRow extends StatefulWidget {
  final DailyReportUnit attendUnit;
  final int siteId;
  DataTableRow(this.attendUnit, this.siteId);

  @override
  _DataTableRowState createState() => _DataTableRowState();
}

class _DataTableRowState extends State<DataTableRow> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  getMembersData() async {
    print("inside");
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);
    var siteId;
    if (userProvider.user.userType == 2) {
      siteId = userProvider.user.userSiteId;
      await Provider.of<MemberData>(context, listen: false)
          .getAllSiteMembers(siteId, userProvider.user.userToken, context);
    } else {
      if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
        await Provider.of<SiteData>(context, listen: false)
            .getSitesByCompanyId(
                comProvider.com.id, userProvider.user.userToken, context)
            .then((value) async {
          print("Got Sites");
        });
      }
      siteId = Provider.of<SiteData>(context, listen: false).sitesList[0].id;

      await Provider.of<MemberData>(context, listen: false)
          .getAllSiteMembers(siteId, userProvider.user.userToken, context);
    }
  }

  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            InkWell(
              onTap: () async {
                var now = DateTime.now();

                var toDate = DateTime(now.year, now.month, now.day - 1);
                var fromDate =
                    DateTime(toDate.year, toDate.month - 1, toDate.day + 1);

                var userProvider =
                    Provider.of<UserData>(context, listen: false).user;

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                getMembersData();
                DateTime companyDate =
                    Provider.of<CompanyData>(context, listen: false)
                        .com
                        .createdOn;
                if (fromDate.isBefore(companyDate)) {
                  fromDate = companyDate;
                }
                await Provider.of<ReportsData>(context, listen: false)
                    .getUserReportUnits(
                        userProvider.userToken,
                        widget.attendUnit.userId,
                        formatter.format(fromDate),
                        formatter.format(toDate),
                        context)
                    .then((value) {
                  print("value $value");
                  if (value == "Success" ||
                      value == "user created after period") {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      new MaterialPageRoute(
                        builder: (context) => UserAttendanceReportScreen(
                          name: widget.attendUnit.userName,

                          userToDate: DateTime.now(),
                          id: widget.attendUnit.userId,
                          siteId: widget.siteId,
                          // siteIndex:
                        ),
                      ),
                    );
                  }
                });
              },
              //USERNAME IN LISTVIEW//
              child: widget.attendUnit.timeOut == null
                  ? Container()
                  : Container(
                      width: 160.w,
                      child: Container(
                        height: 30.h,
                        child: AutoSizeText(
                          widget.attendUnit.userName,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(14, allowFontScalingSelf: true),
                              color: Colors.black),
                        ),
                      ),
                    ),
            ),
            widget.attendUnit.timeOut == null
                ? Container()
                : Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                              height: 50.h,
                              child: Center(
                                  child: widget.attendUnit.lateTime == "-"
                                      ? Container(
                                          height: 20,
                                          child: AutoSizeText(
                                            "-",
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: ScreenUtil().setSp(16,
                                                    allowFontScalingSelf: true),
                                                color: Colors.black),
                                          ),
                                        )
                                      : Container(
                                          child: AutoSizeText(
                                            widget.attendUnit.lateTime,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: ScreenUtil().setSp(13,
                                                    allowFontScalingSelf: true),
                                                color: Colors.red),
                                          ),
                                        ))),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                              child: Center(
                                  child: widget.attendUnit.timeIn == "-"
                                      ? Container(
                                          child: AutoSizeText(
                                            "غياب",
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: ScreenUtil().setSp(14,
                                                    allowFontScalingSelf: true),
                                                color: Colors.red),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            !widget.attendUnit.timeIn
                                                    .contains(":")
                                                ? Container()
                                                : Icon(
                                                    widget.attendUnit
                                                                .timeInIcon ==
                                                            "am"
                                                        ? Icons.wb_sunny
                                                        : Icons
                                                            .nightlight_round,
                                                    size: ScreenUtil().setSp(11,
                                                        allowFontScalingSelf:
                                                            true),
                                                  ),
                                            Container(
                                              child: AutoSizeText(
                                                widget.attendUnit.timeIn,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: ScreenUtil().setSp(
                                                        13,
                                                        allowFontScalingSelf:
                                                            true),
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ))),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                              height: 50.h,
                              child: Center(
                                  child: widget.attendUnit.timeOut == "-"
                                      ? widget.attendUnit.timeIn == "-"
                                          ? Container(
                                              height: 20,
                                              child: AutoSizeText(
                                                "",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(
                                                        16,
                                                        allowFontScalingSelf:
                                                            true),
                                                    color: Colors.red),
                                              ),
                                            )
                                          : Container(
                                              height: 20,
                                              width: 0,
                                              child: AutoSizeText(
                                                "-",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(
                                                        16,
                                                        allowFontScalingSelf:
                                                            true),
                                                    color: Colors.black),
                                              ),
                                            )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              widget.attendUnit.timeOutIcon ==
                                                      "am"
                                                  ? Icons.wb_sunny
                                                  : Icons.nightlight_round,
                                              size: ScreenUtil().setSp(12,
                                                  allowFontScalingSelf: true),
                                            ),
                                            Container(
                                              child: AutoSizeText(
                                                widget.attendUnit.timeOut ?? "",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(
                                                        13,
                                                        allowFontScalingSelf:
                                                            true),
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ))),
                        ),
                        !widget.attendUnit.timeIn.contains(":")
                            ? Padding(
                                padding: EdgeInsets.only(left: 20.w),
                                child: Container(),
                              )
                            : Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    if (widget.attendUnit.attendType == 1) {
                                      showAttendByCameraDetails();
                                    } else {
                                      print("mob");
                                    }
                                  },
                                  child: widget.attendUnit.timeOut != "-" ||
                                          widget.attendUnit.timeIn != "-"
                                      ? Icon(
                                          widget.attendUnit.attendType == 0
                                              ? Icons.phone_android
                                              : Icons.image,
                                          color: Colors.orange,
                                          size: ScreenUtil().setSp(28,
                                              allowFontScalingSelf: true),
                                        )
                                      : Container(),
                                ),
                              )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }

  showAttendByCameraDetails() {
    print("${widget.attendUnit.timeOut} ====== ${widget.attendUnit.timeIn}");
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: Stack(
                  children: [
                    Container(
                      height: 180.h,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Container(
                              height: 50.h,
                              child: Center(
                                child: Container(
                                  height: 20.h,
                                  child: AutoSizeText(
                                    "تسجيل ببطاقة التعريف الشخصية",
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: ScreenUtil().setSp(14,
                                            allowFontScalingSelf: true),
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.attendUnit.timeIn != "-"
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2.w,
                                                color: Color(0xffFF7E00),
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 40,
                                              child: Container(
                                                width: 80.w,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          75.0),
                                                  child: Image.network(
                                                    '$baseURL/${widget.attendUnit.userAttendPictureURL}',
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.white,
                                                          valueColor:
                                                              new AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors
                                                                      .orange),
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Container(
                                            height: 20,
                                            child: AutoSizeText(
                                              "تسجيل الحضور",
                                              maxLines: 1,
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(),
                                widget.attendUnit.timeIn != "-" &&
                                        widget.attendUnit.timeOut != "-"
                                    ? SizedBox(
                                        width: 30.w,
                                      )
                                    : Container(),
                                widget.attendUnit.timeOut != "-"
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2.w,
                                                color: Color(0xffFF7E00),
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 40,
                                              child: Container(
                                                width: 80.w,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          75.0),
                                                  child: Image.network(
                                                    '$baseURL/${widget.attendUnit.userLeavePictureURL}',
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.white,
                                                          valueColor:
                                                              new AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors
                                                                      .orange),
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Container(
                                            height: 20,
                                            child: AutoSizeText(
                                              "تسجيل الانصراف",
                                              maxLines: 1,
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 5.0.w,
                      top: 5.0.h,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.orange,
                            size: ScreenUtil()
                                .setSp(25, allowFontScalingSelf: true),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }
}
