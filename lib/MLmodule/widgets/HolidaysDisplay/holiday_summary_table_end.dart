import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';

class HolidaySummaryTableEnd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final permProv = Provider.of<UserHolidaysData>(context);
    return Container(
      child: Container(
        height: 50.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Container(
                  height: 20.h,
                  child: AutoSizeText(
                    (permProv.sickVacationCount +
                            permProv.suddenVacationCount +
                            permProv.vacationCreditCount)
                        .toString(),
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(14, allowFontScalingSelf: true),
                        color: ColorManager.primary),
                  ),
                ),
                Container(
                  height: 20.h,
                  child: AutoSizeText(
                    ' : ${getTranslated(context, "الإجمالى")} ',
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(14, allowFontScalingSelf: true),
                        color: ColorManager.primary),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 20,
                  child: AutoSizeText(
                    permProv.sickVacationCount.toString(),
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(14, allowFontScalingSelf: true),
                        color: ColorManager.primary),
                  ),
                ),
                Container(
                  height: 20,
                  child: AutoSizeText(
                    ' : ${getTranslated(context, "مرضى")}',
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(14, allowFontScalingSelf: true),
                        color: ColorManager.primary),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 20.h,
                  child: AutoSizeText(
                    permProv.vacationCreditCount.toString(),
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(14, allowFontScalingSelf: true),
                        color: ColorManager.primary),
                  ),
                ),
                Container(
                  height: 20.h,
                  child: AutoSizeText(
                    ' : ${getTranslated(context, "رصيد اجازات")}',
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(14, allowFontScalingSelf: true),
                        color: ColorManager.primary),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 20.h,
                  child: AutoSizeText(
                    permProv.suddenVacationCount.toString(),
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(14, allowFontScalingSelf: true),
                        color: ColorManager.primary),
                  ),
                ),
                Container(
                  height: 20.h,
                  child: AutoSizeText(
                    ' : ${getTranslated(context, "عارضة")}',
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ScreenUtil().setSp(14, allowFontScalingSelf: true),
                        color: ColorManager.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
