import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';

class PermessionsSummaryTableEnd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var permProv = Provider.of<UserPermessionsData>(context);
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
                    (permProv.earlyLeaversCount + permProv.lateAbesenceCount)
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
                    ' : الإجمالى',
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
                    permProv.lateAbesenceCount.toString(),
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
                    ': تأخير عن الحضور',
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
                    permProv.earlyLeaversCount.toString(),
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
                    ' : انصراف مبكر',
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
