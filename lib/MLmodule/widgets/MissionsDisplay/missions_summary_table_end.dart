import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';

class MissionsSummaryTableEnd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final permProv = Provider.of<MissionsData>(context);
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
                    (permProv.internalMissionsCount +
                            permProv.externalMissionsCount)
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
                    permProv.externalMissionsCount.toString(),
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
                    ' : ${getTranslated(context, "مأمورية خارجية")}',
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
                    permProv.internalMissionsCount.toString(),
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
                    ' : ${getTranslated(context, "مأمورية داخلية")}',
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
