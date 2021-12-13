import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';

import 'DataTableEndRowInfo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserReprotDataTableEnd extends StatelessWidget {
  final UserAttendanceReport _attendanceReport;

  UserReprotDataTableEnd(
    this._attendanceReport,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          thickness: 1,
          color: Colors.orange,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10.h,
            ),
            child: Container(
              height: 70.h,
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
                          infoTitle: 'مدة التأخير:',
                          info: _attendanceReport.totalLateDuration,
                        ),
                        DataTableEndRowInfo(
                            info: _attendanceReport.totalLateDay.toString(),
                            infoTitle: "ايام التأخير:"),
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
                        info: _attendanceReport.totalLateDeduction
                            .toStringAsFixed(1),
                        infoTitle: ' خصم التأخير:',
                      ),
                      DataTableEndRowInfo(
                        info:
                            _attendanceReport.totalDeduction.toStringAsFixed(1),
                        infoTitle: ' إجمالى الخصومات:',
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
