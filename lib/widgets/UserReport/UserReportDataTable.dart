import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';

class UserReportDataTableRow extends StatelessWidget {
  final UserAttendanceReportUnit userAttendanceReportUnit;

  UserReportDataTableRow(this.userAttendanceReportUnit);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    alignment: Alignment.center,
                    height: 20,
                    child: AutoSizeText(
                      userAttendanceReportUnit.date ?? "",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(14, allowFontScalingSelf: true),
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
                          child: userAttendanceReportUnit.late == "-"
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
                                  height: 20,
                                  child: AutoSizeText(
                                    userAttendanceReportUnit.late,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(14,
                                            allowFontScalingSelf: true),
                                        color: Colors.red),
                                  ),
                                ),
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 50.h,
                      child: Center(
                        child: userAttendanceReportUnit.timeIn == "-"
                            ? Container(
                                height: 20,
                                child: AutoSizeText(
                                  getTranslated(context, "غياب"),
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(16,
                                          allowFontScalingSelf: true),
                                      color: Colors.red),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  userAttendanceReportUnit.timeIn
                                          .toString()
                                          .contains(":")
                                      ? Icon(
                                          userAttendanceReportUnit.timeInIsPm ==
                                                  "am"
                                              ? Icons.wb_sunny
                                              : Icons.nightlight_round,
                                          size: ScreenUtil().setSp(10,
                                              allowFontScalingSelf: true),
                                        )
                                      : Container(
                                          child: Text(""),
                                        ),
                                  Container(
                                    height: 20,
                                    child: AutoSizeText(
                                      userAttendanceReportUnit.timeIn == "*"
                                          ? "غير مقيد"
                                          : userAttendanceReportUnit.timeIn ==
                                                  "1"
                                              ? "عارضة"
                                              : userAttendanceReportUnit
                                                          .timeIn ==
                                                      "2"
                                                  ? "مرضى"
                                                  : userAttendanceReportUnit
                                                              .timeIn ==
                                                          "3"
                                                      ? "رصيد اجازات"
                                                      : userAttendanceReportUnit
                                                                  .timeIn ==
                                                              "4"
                                                          ? "مأمورية خارجية"
                                                          : userAttendanceReportUnit
                                                                  .timeIn ??
                                                              "-",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(12,
                                              allowFontScalingSelf: true),
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 50.h,
                      child: Center(
                        child: userAttendanceReportUnit.timeOut == "-"
                            ? userAttendanceReportUnit.timeIn == "-"
                                ? Container(
                                    height: 20,
                                    child: AutoSizeText(
                                      "",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16,
                                              allowFontScalingSelf: true),
                                          color: Colors.red),
                                    ),
                                  )
                                : Container(
                                    height: 20,
                                    child: AutoSizeText(
                                      getTranslated(context, "غياب"),
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16,
                                              allowFontScalingSelf: true),
                                          color: Colors.red),
                                    ),
                                  )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  userAttendanceReportUnit.timeIn
                                          .toString()
                                          .contains(":")
                                      ? userAttendanceReportUnit.status == 3
                                          ? Container()
                                          : Icon(
                                              userAttendanceReportUnit
                                                          .timeOutIsPm ==
                                                      "am"
                                                  ? Icons.wb_sunny
                                                  : Icons.nightlight_round,
                                              size: ScreenUtil().setSp(10,
                                                  allowFontScalingSelf: true),
                                            )
                                      : Container(),
                                  Container(
                                    height: userAttendanceReportUnit.status == 3
                                        ? 30.h
                                        : 20.h,
                                    width: 60.w,
                                    child: AutoSizeText(
                                        userAttendanceReportUnit.status == 3
                                            ? "لم يتم اثبات الحضور"
                                            : userAttendanceReportUnit
                                                    .timeOut ??
                                                "",
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(12,
                                                allowFontScalingSelf: true),
                                            color: Colors.black),
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
