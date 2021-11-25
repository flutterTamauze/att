import 'dart:io';
import 'dart:ui' as ui;
import 'package:animate_do/animate_do.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/Reports/DailyReport/attend_details_camera.dart';
import 'package:qr_users/widgets/Reports/DailyReport/userDetailsInReport.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/UserFullData/user_properties.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import '../../../constants.dart';

class DataTableRow extends StatefulWidget {
  final DailyReportUnit attendUnit;
  final int siteId;
  DataTableRow(this.attendUnit, this.siteId);

  @override
  _DataTableRowState createState() => _DataTableRowState();
}

class _DataTableRowState extends State<DataTableRow> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  var now = DateTime.now();
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
          comProvider.com.id,
          userProvider.user.userToken,
          context,
        )
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
              onLongPress: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                await Provider.of<MemberData>(context, listen: false)
                    .getUserById(
                        widget.attendUnit.userId,
                        Provider.of<UserData>(context, listen: false)
                            .user
                            .userToken);
                Navigator.pop(context);
                var userData = Provider.of<MemberData>(context, listen: false)
                    .singleMember;
                showDialog(
                  context: context,
                  builder: (context) {
                    return UserDetailsInReport(userData: userData);
                  },
                );
              },
              onTap: () async {
                var now = DateTime.now();
                int legalDay = Provider.of<CompanyData>(context, listen: false)
                    .com
                    .legalComDate;
                var toDate = DateTime(now.year, now.month, now.day - 1);
                var fromDate = DateTime(now.year, now.month, legalDay);

                var userProvider =
                    Provider.of<UserData>(context, listen: false).user;

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                // getMembersData();
                DateTime companyDate =
                    Provider.of<CompanyData>(context, listen: false)
                        .com
                        .createdOn;
                if (fromDate.isBefore(companyDate)) {
                  fromDate = companyDate;
                }
                if (toDate.isBefore(fromDate)) {
                  print("to date is before from date");
                  fromDate = DateTime(
                      now.year,
                      now.month - 1,
                      Provider.of<CompanyData>(context, listen: false)
                          .com
                          .legalComDate);
                }
                await Provider.of<ReportsData>(context, listen: false)
                    .getUserReportUnits(
                        userProvider.userToken,
                        widget.attendUnit.userId,
                        formatter.format(fromDate),
                        formatter.format(toDate),
                        context)
                    .then((value) async {
                  print("value $value");
                  if (value == "Success" ||
                      value == "user created after period") {
                    Navigator.pop(context);
                    await Navigator.of(context).push(
                      new MaterialPageRoute(
                        builder: (context) => UserAttendanceReportScreen(
                          name: widget.attendUnit.userName,
                          userFromDate: fromDate,
                          userToDate: toDate,
                          id: widget.attendUnit.userId,
                          siteId: widget.siteId,
                          // siteIndex:
                        ),
                      ),
                    );
                  } else if (value == "failed") {
                    Fluttertoast.showToast(
                        msg: 'حدث خطأ',
                        backgroundColor: Colors.red,
                        gravity: ToastGravity.CENTER);
                    Navigator.pop(context);
                  }
                });
              },
              //USERNAME IN LISTVIEW//
              child: widget.attendUnit.timeOut == null
                  ? Container()
                  : Container(
                      width: 160.w,
                      child: Container(
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
                                      AttendDetails attendDetails =
                                          AttendDetails();
                                      attendDetails.showAttendByCameraDetails(
                                          context: context,
                                          timeIn: widget.attendUnit.timeIn,
                                          timeOut: widget.attendUnit.timeOut,
                                          userAttendPictureURL: widget
                                              .attendUnit.userAttendPictureURL,
                                          userLeavePictureURL: widget
                                              .attendUnit.userLeavePictureURL);
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
}
