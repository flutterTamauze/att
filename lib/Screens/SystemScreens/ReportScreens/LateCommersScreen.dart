import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/MemberData.dart';
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
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LateAbsenceScreen extends StatefulWidget {
  @override
  _LateAbsenceScreenState createState() => _LateAbsenceScreenState();
}

class _LateAbsenceScreenState extends State<LateAbsenceScreen> {
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  String dateToString = "";
  String dateFromString = "";
  ScrollController _scrollController = ScrollController();
  TextEditingController _dateController = TextEditingController();
  int selectedDuration;
  var toDate;
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
    CompanyData comProvider = Provider.of<CompanyData>(context, listen: false);
    var siteProv = Provider.of<SiteData>(context, listen: false);
    var memProv = Provider.of<MemberData>(context, listen: false);
    if (userProvider.user.userType == 2) {
      setState(() {
        isLoading = true;
      });
      siteID = userProvider.user.userSiteId;
      siteData = await siteProv.getSpecificSite(
          siteID, userProvider.user.userToken, context);
      if (memProv.membersList.isEmpty) {
        print("getting all members for site");
        await memProv.getAllSiteMembers(
            siteID, userProvider.user.userToken, context);
      }
      setState(() {
        isLoading = false;
      });
    } else {
      if (memProv.membersList.isEmpty) {
        await memProv.getAllCompanyMember(
            siteId, comProvider.com.id, userProvider.user.userToken, context);
      }
      if (siteProv.sitesList.isEmpty) {
        await siteProv
            .getSitesByCompanyId(
          comProvider.com.id,
          userProvider.user.userToken,
          context,
        )
            .then((value) {
          siteID = siteProv.sitesList[siteIndex].id;
        });
      } else {
        siteID = siteProv.sitesList[siteIndex].id;
      }
    }
    await Provider.of<ReportsData>(context, listen: false).getLateAbsenceReport(
        userProvider.user.userToken,
        siteID,
        dateFromString,
        dateToString,
        context);
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
    var comProv = Provider.of<CompanyData>(context, listen: false);
    return Consumer<ReportsData>(builder: (context, reportsData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
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
                                                      : XlsxExportButton(
                                                          reportType: 1,
                                                          title:
                                                              "تقرير التأخير و الغياب",
                                                          day: _dateController
                                                              .text,
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
                                                    final List<
                                                            DateTime> picked =
                                                        await DateRagePicker
                                                            .showDatePicker(
                                                                context:
                                                                    context,
                                                                initialFirstDate:
                                                                    fromDate,
                                                                initialLastDate:
                                                                    toDate,
                                                                firstDate: comProv
                                                                    .com
                                                                    .createdOn,
                                                                lastDate:
                                                                    yesterday);
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

                                                    if (_dateController.text !=
                                                        newString) {
                                                      _dateController.text =
                                                          newString;

                                                      dateFromString =
                                                          apiFormatter
                                                              .format(fromDate);
                                                      dateToString =
                                                          apiFormatter
                                                              .format(toDate);

                                                      var user =
                                                          Provider.of<UserData>(
                                                                  context,
                                                                  listen: false)
                                                              .user;
                                                      if (user.userType == 2) {
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
                                                                user.userToken,
                                                                Provider.of<SiteData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .sitesList[
                                                                        siteIdIndex]
                                                                    .id,
                                                                dateFromString,
                                                                dateToString,
                                                                context);
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
                                                              dateToString,
                                                              context);
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
                                                              Divider(
                                                                thickness: 1,
                                                                color: Colors
                                                                        .orange[
                                                                    600],
                                                              ),
                                                              DataTableHeader(),
                                                              Divider(
                                                                thickness: 1,
                                                                color: Colors
                                                                        .orange[
                                                                    600],
                                                              ),
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
                                                                              siteIdIndex,
                                                                              fromDate,
                                                                              toDate);
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
