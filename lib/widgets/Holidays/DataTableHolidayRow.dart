import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/permissions_data.dart';

class DataTableHolidayRow extends StatelessWidget {
  final UserHolidays _holidays;

  DataTableHolidayRow(this._holidays);
  final bool isEnglish = locator.locator<PermissionHan>().isEnglishLocale();
  @override
  Widget build(BuildContext context) {
    return _holidays.holidayType == 4
        ? Container()
        : Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: AutoSizeText(
                    getTranslated(
                        context, getVacationType(_holidays.holidayType)),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(13, allowFontScalingSelf: true),
                    ),
                  ),
                ),
                Padding(
                  padding: !isEnglish
                      ? EdgeInsets.only(right: 20.w)
                      : EdgeInsets.only(left: 20.w),
                  child: Container(
                    child: AutoSizeText(
                      _holidays.fromDate.toString().substring(0, 11),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize:
                            ScreenUtil().setSp(13, allowFontScalingSelf: true),
                      ),
                    ),
                  ),
                ),
                _holidays.fromDate.isBefore(_holidays.toDate)
                    ? Container(
                        child: AutoSizeText(
                          _holidays.toDate.toString().substring(0, 11),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                          ),
                        ),
                      )
                    : Container(
                        child: AutoSizeText(
                          _holidays.fromDate.toString().substring(0, 11),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                          ),
                        ),
                      ),
              ],
            ),
          );
  }
}
