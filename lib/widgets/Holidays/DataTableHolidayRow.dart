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
                          height: 20.h,
                          child: AutoSizeText(
                            _holidays.userName,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(14, allowFontScalingSelf: true),
                                fontWeight: FontWeight.w300,
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
                              height: 30.h,
                              child: Center(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  height: 30.h,
                                  child: AutoSizeText(
                                    _holidays.holidayType == 1
                                        ? "عارضة"
                                        : _holidays.holidayType == 2
                                            ? "مرضى"
                                            : "رصيد اجازات",
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(14,
                                          allowFontScalingSelf: true),
                                    ),
                                  ),
                                ),
                              )),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(right: 15.w),
                            height: 35.h,
                            child: Center(
                              child: Container(
                                alignment: Alignment.center,
                                height: 20.h,
                                child: AutoSizeText(
                                  _holidays.fromDate
                                      .toString()
                                      .substring(0, 11),
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(14, allowFontScalingSelf: true),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _holidays.fromDate.isBefore(_holidays.toDate)
                            ? Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 20.w),
                                  height: 30.h,
                                  child: Center(
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 20.h,
                                      child: AutoSizeText(
                                        _holidays.toDate
                                            .toString()
                                            .substring(0, 11),
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(13,
                                              allowFontScalingSelf: true),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 20.w),
                                  alignment: Alignment.center,
                                  child: Text("---"),
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
