import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/services/report_data.dart';

import 'DataTableEndRowInfo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserReprotDataTableEnd extends StatelessWidget {
  final UserAttendanceReport _attendanceReport;

  UserReprotDataTableEnd(
    this._attendanceReport,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          )),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Container(
          height: 65.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        child: DataTableEndRowInfo(
                      infoTitle: 'ايام الغياب:',
                      info: _attendanceReport.totalAbsentDay.toString(),
                    )),
                    DataTableEndRowInfo(
                      info: _attendanceReport.totalOfficialVacation.toString(),
                      infoTitle: 'العطل الرسمية:',
                    ),
                    DataTableEndRowInfo(
                        info: _attendanceReport.totalLateDay.toString(),
                        infoTitle: "ايام التأخير:"),
                    DataTableEndRowInfo(
                      infoTitle: 'مدة التأخير:',
                      info: _attendanceReport.totalLateDuration,
                    ),
                  ],
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DataTableEndRowInfo(
                    info: _attendanceReport.totalDeductionAbsent
                        .toStringAsFixed(1),
                    infoTitle: 'خصم الغياب:',
                  ),
                  DataTableEndRowInfo(
                    info: _attendanceReport.totalDeductionAbsent
                        .toStringAsFixed(1),
                    infoTitle: ' خصم التأخير:',
                  ),
                  DataTableEndRowInfo(
                    info: _attendanceReport.totalDeduction.toStringAsFixed(1),
                    infoTitle: ' إجمالى الخصومات:',
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}