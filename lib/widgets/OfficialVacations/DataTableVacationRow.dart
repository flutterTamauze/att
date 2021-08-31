import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/services/VacationData.dart';

class DataTableVacationRow extends StatelessWidget {
  final Vacation vacation;
  final DateTime filterToDate, filterFromDate;
  DataTableVacationRow({this.vacation, this.filterFromDate, this.filterToDate});

  @override
  Widget build(BuildContext context) {
    return isDateBetweenTheRange(vacation, filterFromDate, filterToDate)
        ? Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 160.w,
                    height: 40.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          child: AutoSizeText(
                            vacation.vacationName,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(14, allowFontScalingSelf: true),
                                color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    child: AutoSizeText(
                      vacation.vacationDate.toString().substring(0, 11),
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
          )
        : Container();
  }
}
