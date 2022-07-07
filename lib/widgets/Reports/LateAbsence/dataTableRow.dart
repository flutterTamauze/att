import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';

import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

class DataTableRow extends StatelessWidget {
  final LateAbsenceReportUnit userAttendanceReportUnit;
  final siteId;
  final DateTime fromDate, toDate;

  DataTableRow(
      this.userAttendanceReportUnit, this.siteId, this.fromDate, this.toDate);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();

        final userProvider = Provider.of<UserData>(context, listen: false).user;

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedLoadingIndicator();
            });

        final x = await Provider.of<ReportsData>(context, listen: false)
            .getUserReportUnits(
                userProvider.userToken,
                userAttendanceReportUnit.userId,
                formatter.format(fromDate),
                formatter.format(toDate),
                context);

        if (x == "Success") {
          Navigator.pop(context);
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) => UserAttendanceReportScreen(
                name: userAttendanceReportUnit.userName,
                reportName: "late report",
                userFromDate: fromDate,
                id: userAttendanceReportUnit.userId,
                userToDate: toDate,
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
                width: 100.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 144.w,
                      child: AutoSizeText(
                        userAttendanceReportUnit.userName,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(13, allowFontScalingSelf: true),
                          color: ColorManager.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
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
                      child: Container(
                          height: 50.h,
                          child: Center(
                              child: Container(
                            height: 20.h,
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
                    Expanded(
                      child: Container(
                          height: 50.h,
                          child: Center(
                              child: Container(
                            height: 20.h,
                            child: AutoSizeText(
                              userAttendanceReportUnit.totalDeduction
                                  .toStringAsFixed(1),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(14, allowFontScalingSelf: true),
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
