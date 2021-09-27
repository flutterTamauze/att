import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets//XlsxExportButton.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';

import 'package:qr_users/widgets/UserReport/UserReportDataTable.dart';
import 'package:qr_users/widgets/UserReport/UserReportDataTableEnd.dart';
import 'package:qr_users/widgets/UserReport/UserReportTableHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../services/report_data.dart';
import 'package:intl/intl.dart';

class UserAttendanceReportScreen extends StatefulWidget {
  final String name, id;
  final int siteId;
  final DateTime userFromDate, userToDate;
  // getUserReportUnits
  UserAttendanceReportScreen(
      {this.name, this.siteId, this.id, this.userFromDate, this.userToDate});

  @override
  _UserAttendanceReportScreenState createState() =>
      _UserAttendanceReportScreenState();
}

class _UserAttendanceReportScreenState
    extends State<UserAttendanceReportScreen> {
  TextEditingController _dateController = TextEditingController();

  TextEditingController _nameController = TextEditingController();
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Member>> key = new GlobalKey();

  DateTime toDate;
  DateTime fromDate;

  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');

  String dateToString = "";
  String dateFromString = "";

  String selectedId = "";
  Site siteData;
  DateTime yesterday;

  @override
  void initState() {
    DateTime companyDate =
        Provider.of<CompanyData>(context, listen: false).com.createdOn;

    super.initState();
    print("id $widget.id");
    var now = DateTime.now();
    selectedId = widget.id;
    toDate = DateTime(now.year, now.month, now.day - 1);
    fromDate = DateTime(now.year, now.month,
        Provider.of<CompanyData>(context, listen: false).com.legalComDate);

    if (fromDate.isBefore(companyDate)) {
      fromDate = companyDate;
    }
    if (widget.userFromDate != null && widget.userToDate != null) {
      fromDate = widget.userFromDate;
      toDate = widget.userToDate;
    }

    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    String fromText = " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    String toText = " إلى ${DateFormat('yMMMd').format(toDate).toString()}";

    _dateController.text = "$fromText $toText";

    if (widget.name != "") {
      _nameController.text = widget.name;
      print("widget.siteId${widget.siteId}");
      siteIdIndex = widget.siteId;
    } else {
      getMembersData();
      Provider.of<ReportsData>(context, listen: false).userAttendanceReport =
          new UserAttendanceReport([], 0, 0, "0", -1, 0, 0, 0, 0);
    }
  }

  getMembersData() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);

    if (userProvider.user.userType == 2) {
      siteId = userProvider.user.userSiteId;
      siteData = await Provider.of<SiteData>(context, listen: false)
          .getSpecificSite(siteId, userProvider.user.userToken, context);
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

  String msg = "";
  int siteId = 0;
  int siteIdIndex = 0;
  final focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    var userToken = Provider.of<UserData>(context, listen: false);

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    var siteProv = Provider.of<SiteData>(context, listen: false);
    return Consumer<ReportsData>(
      builder: (context, reportsData, child) {
        return WillPopScope(
          onWillPop: onWillPop,
          child: GestureDetector(
            onTap: () {
              print(widget.id);
              print(_nameController.text);
              _nameController.text == ""
                  ? FocusScope.of(context).unfocus()
                  : SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            child: Scaffold(
              endDrawer: NotificationItem(),
              backgroundColor: Colors.white,
              body: Container(
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
                                "تقرير حضور مستخدم",
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
                                            msg = snapshot.data;
                                            return reportsData
                                                            .userAttendanceReport
                                                            .isDayOff ==
                                                        0 ||
                                                    reportsData
                                                            .userAttendanceReport
                                                            .userAttendListUnits
                                                            .length !=
                                                        0
                                                ? XlsxExportButton(
                                                    reportType: 2,
                                                    title: "تقرير حضور مستخدم",
                                                    day: _dateController.text,
                                                    userName:
                                                        _nameController.text,
                                                    site: Provider.of<SiteData>(
                                                            context)
                                                        .sitesList[siteIdIndex]
                                                        .name,
                                                  )
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
                                  Provider.of<MemberData>(context, listen: true)
                                      .futureListener,
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
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Theme(
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
                                                                firstDate: Provider.of<
                                                                            CompanyData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .com
                                                                    .createdOn,
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

                                                          if (_nameController
                                                                      .text !=
                                                                  "" ||
                                                              Provider.of<UserData>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .user
                                                                      .userType ==
                                                                  2) {
                                                            await Provider.of<
                                                                        ReportsData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .getUserReportUnits(
                                                                    userToken
                                                                        .user
                                                                        .userToken,
                                                                    selectedId,
                                                                    dateFromString,
                                                                    dateToString,
                                                                    context);
                                                          }
                                                        }
                                                      },
                                                      child: Directionality(
                                                        textDirection: ui
                                                            .TextDirection.rtl,
                                                        child: Container(
                                                          width: 330.w,
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
                                            ),
                                          ],
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
                                                width: 330.w,
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
                                                  onChange: (value) {
                                                    // print()

                                                    siteIdIndex =
                                                        getSiteId(value);
                                                    if (siteId !=
                                                        siteProv
                                                            .sitesList[
                                                                siteIdIndex]
                                                            .id) {
                                                      _nameController.text = "";
                                                      siteId = siteProv
                                                          .sitesList[
                                                              siteIdIndex]
                                                          .id;

                                                      Provider.of<MemberData>(
                                                              context,
                                                              listen: false)
                                                          .getAllSiteMembers(
                                                              siteId,
                                                              Provider.of<UserData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .user
                                                                  .userToken,
                                                              context);
                                                      setState(() {});
                                                    }
                                                    print(value);
                                                  },
                                                  selectedvalue: siteProv
                                                      .sitesList[siteIdIndex]
                                                      .name,
                                                  textColor: Colors.orange,
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Container(
                                          width: 330.w,
                                          child: Directionality(
                                            textDirection: ui.TextDirection.rtl,
                                            child: searchTextField =
                                                AutoCompleteTextField<Member>(
                                              key: key,
                                              clearOnSubmit: false,
                                              controller: _nameController,
                                              suggestions:
                                                  Provider.of<MemberData>(
                                                          context)
                                                      .dropDownMembersList,
                                              style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(
                                                      16,
                                                      allowFontScalingSelf:
                                                          true),
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                              decoration: kTextFieldDecorationFromTO
                                                  .copyWith(
                                                      hintStyle: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(16,
                                                                  allowFontScalingSelf:
                                                                      true),
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      hintText: 'الأسم',
                                                      prefixIcon: Icon(
                                                        Icons.person,
                                                        color: Colors.orange,
                                                      )),
                                              itemFilter: (item, query) {
                                                return item.name
                                                    .toLowerCase()
                                                    .contains(
                                                        query.toLowerCase());
                                              },
                                              itemSorter: (a, b) {
                                                return a.name.compareTo(b.name);
                                              },
                                              itemSubmitted: (item) async {
                                                if (_nameController.text !=
                                                    item.name) {
                                                  setState(() {
                                                    searchTextField
                                                        .textField
                                                        .controller
                                                        .text = item.name;
                                                  });
                                                  selectedId = item.id;

                                                  await Provider.of<
                                                              ReportsData>(
                                                          context,
                                                          listen: false)
                                                      .getUserReportUnits(
                                                          userToken
                                                              .user.userToken,
                                                          item.id,
                                                          dateFromString,
                                                          dateToString,
                                                          context);
                                                }
                                              },
                                              itemBuilder: (context, item) {
                                                // ui for the autocompelete row
                                                return Directionality(
                                                  textDirection:
                                                      ui.TextDirection.rtl,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 10,
                                                      bottom: 5,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 50.w,
                                                              height: 50.h,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      width:
                                                                          1.w,
                                                                      color: Colors
                                                                              .orange[
                                                                          700]),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: DecorationImage(
                                                                      image: NetworkImage(
                                                                          "$baseURL/${item.userImageURL}"))),
                                                            ),
                                                            SizedBox(
                                                              width: 10.w,
                                                            ),
                                                            Container(
                                                              height: 20,
                                                              child:
                                                                  AutoSizeText(
                                                                item.name,
                                                                maxLines: 1,
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(
                                                                        16,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Divider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        _nameController.text != ""
                                            ? Expanded(
                                                child: FutureBuilder(
                                                    future: Provider.of<
                                                                ReportsData>(
                                                            context)
                                                        .futureListener,
                                                    builder:
                                                        (context, snapshot) {
                                                      switch (snapshot
                                                          .connectionState) {
                                                        case ConnectionState
                                                            .waiting:
                                                          return Container(
                                                            color: Colors.white,
                                                            child: Center(
                                                              child: Platform
                                                                      .isIOS
                                                                  ? CupertinoActivityIndicator()
                                                                  : CircularProgressIndicator(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      valueColor: new AlwaysStoppedAnimation<
                                                                              Color>(
                                                                          Colors
                                                                              .orange),
                                                                    ),
                                                            ),
                                                          );
                                                        case ConnectionState
                                                            .done:
                                                          return reportsData
                                                                      .userAttendanceReport
                                                                      .isDayOff !=
                                                                  1
                                                              ? reportsData
                                                                          .userAttendanceReport
                                                                          .userAttendListUnits
                                                                          .length !=
                                                                      0
                                                                  ? Container(
                                                                      color: Colors
                                                                          .white,
                                                                      child: Directionality(
                                                                          textDirection: ui.TextDirection.rtl,
                                                                          child: Column(
                                                                            children: [
                                                                              Divider(thickness: 1, color: Colors.orange[600]),
                                                                              UserReportTableHeader(),
                                                                              Divider(thickness: 1, color: Colors.orange[600]),
                                                                              Expanded(
                                                                                  child: Container(
                                                                                      child: snapshot.data == "user created after period"
                                                                                          ? Container(
                                                                                              child: Center(
                                                                                                child: Text("المستخدم لم يكن مقيدا فى هذة الفترة", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                              ),
                                                                                            )
                                                                                          : ListView.builder(
                                                                                              itemCount: reportsData.userAttendanceReport.userAttendListUnits.length,
                                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                                return UserReportDataTableRow(reportsData.userAttendanceReport.userAttendListUnits[index]);
                                                                                              }))),
                                                                              UserReprotDataTableEnd(reportsData.userAttendanceReport)
                                                                            ],
                                                                          )),
                                                                    )
                                                                  : Row(
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              height: 20,
                                                                              child: AutoSizeText(
                                                                                "لا يوجد تسجيلات بهذا المستخدم",
                                                                                maxLines: 1,
                                                                                style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true), fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                      ],
                                                                    )
                                                              : Row(
                                                                  children: [
                                                                    Expanded(
                                                                        child:
                                                                            Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              20,
                                                                          child:
                                                                              AutoSizeText(
                                                                            "لا يوجد تسجيلات: يوم اجازة",
                                                                            maxLines:
                                                                                1,
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
                                                                                fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )),
                                                                  ],
                                                                );
                                                        default:
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
                                                            ),
                                                          );
                                                      }
                                                    }),
                                              )
                                            : Row(
                                                children: [
                                                  Expanded(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: 20,
                                                        child: AutoSizeText(
                                                          "برجاء اختيار اسم مستخدم",
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.orange,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(16,
                                                                      allowFontScalingSelf:
                                                                          true),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                ],
                                              ),
                                      ],
                                    );
                                  default:
                                    return Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
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
                            widget.name != ""
                                ? Navigator.pop(context)
                                : Navigator.of(context).pushAndRemoveUntil(
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
      },
    );
  }

  Future<bool> onWillPop() {
    widget.name != ""
        ? Navigator.pop(context)
        : Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => NavScreenTwo(2)),
            (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

List<Vacation> listAfterFilter(
    List<Vacation> vacationList, DateTime filterFrom, DateTime fliterTo) {
  List<Vacation> output = [];
  vacationList.forEach((element) {
    if (isDateBetweenTheRange(element, filterFrom, fliterTo)) {
      output.add(element);
    }
  });
  return output;
}

bool isDateBetweenTheRange(
    Vacation vacation, DateTime filterFromDate, DateTime filterToDate) {
  return ((filterFromDate.isBefore(vacation.vacationDate) ||
          (vacation.vacationDate.year == filterFromDate.year &&
              vacation.vacationDate.day == filterFromDate.day &&
              vacation.vacationDate.month == filterFromDate.month)) &&
      (filterToDate.isAfter(vacation.vacationDate) ||
          (vacation.vacationDate.year == filterToDate.year &&
              vacation.vacationDate.day == filterToDate.day &&
              vacation.vacationDate.month == filterToDate.month)));
}
