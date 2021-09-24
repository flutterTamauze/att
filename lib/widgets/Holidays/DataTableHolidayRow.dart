import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';

class DataTableHolidayRow extends StatelessWidget {
  final UserHolidays _holidays;

  DataTableHolidayRow(this._holidays);

  @override
  Widget build(BuildContext context) {
    return _holidays.holidayType == 4
        ? Container()
        : Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    height: 30.h,
                    child: Center(
                      child: Container(
                        alignment: Alignment.centerRight,
                        height: 40.h,
                        width: 50,
                        child: AutoSizeText(
                          _holidays.holidayType == 1
                              ? "عارضة"
                              : _holidays.holidayType == 2
                                  ? "مرضى"
                                  : "رصيد اجازات",
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: ScreenUtil()
                                .setSp(14, allowFontScalingSelf: true),
                          ),
                        ),
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: Container(
                    height: 35.h,
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        height: 20.h,
                        child: AutoSizeText(
                          _holidays.fromDate.toString().substring(0, 11),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                _holidays.fromDate.isBefore(_holidays.toDate)
                    ? Container(
                        height: 30.h,
                        child: Center(
                          child: Container(
                            alignment: Alignment.center,
                            height: 20.h,
                            child: AutoSizeText(
                              _holidays.toDate.toString().substring(0, 11),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(13, allowFontScalingSelf: true),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 35.h,
                        child: Center(
                          child: Container(
                            alignment: Alignment.center,
                            height: 20.h,
                            child: AutoSizeText(
                              _holidays.fromDate.toString().substring(0, 11),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(13, allowFontScalingSelf: true),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          );
  }
}
