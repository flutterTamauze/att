import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

class DataTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
              width: 160.w,
              child: Center(
                  child: Container(
                height: 20,
                child: AutoSizeText(
                  getTranslated(context, 'الأسم'),
                  maxLines: 1,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          ScreenUtil().setSp(16, allowFontScalingSelf: true),
                      color: ColorManager.primary),
                ),
              ))),
          Expanded(
            child: Row(
              children: [
                DataTableHeaderTitles(
                    getTranslated(context, "التأخير"), ColorManager.primary),
                DataTableHeaderTitles(
                    getTranslated(context, "حضور"), ColorManager.primary),
                DataTableHeaderTitles(
                    getTranslated(context, "انصراف"), ColorManager.primary),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50.h,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}

class AttendProovTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                    width: 160.w,
                    child: Center(
                        child: Container(
                      height: 20,
                      child: AutoSizeText(
                        getTranslated(context, "الأسم"),
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(16, allowFontScalingSelf: true),
                            color: ColorManager.primary),
                      ),
                    ))),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50.h,
                  ),
                ),
                DataTableHeaderTitles(getTranslated(context, "حالة الإثبات"),
                    ColorManager.primary),
                SizedBox(
                  width: 10,
                ),
                DataTableHeaderTitles(
                    getTranslated(context, "التوقيت"), ColorManager.primary),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class DataTableHeaderTitles extends StatelessWidget {
  final String title;
  final Color color;
  DataTableHeaderTitles(this.title, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
          child: Center(
              child: Container(
        child: AutoSizeText(
          title,
          maxLines: 1,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
              color: color),
        ),
      ))),
    );
  }
}
