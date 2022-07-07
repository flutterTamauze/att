import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

class UserReportTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
              width: 160.w,
              height: 50.h,
              child: Center(
                  child: Container(
                height: 20.h,
                child: AutoSizeText(
                  getTranslated(
                    context,
                    "التاريخ",
                  ),
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
                Expanded(
                  flex: 1,
                  child: Container(
                      child: Center(
                          child: Container(
                    height: 20,
                    child: AutoSizeText(
                      getTranslated(context, "التأخير"),
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: ColorManager.primary),
                    ),
                  ))),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      child: Center(
                          child: Container(
                    height: 20,
                    child: AutoSizeText(
                      getTranslated(context, "حضور"),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: ColorManager.primary),
                    ),
                  ))),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      child: Center(
                          child: Container(
                    height: 20,
                    child: AutoSizeText(
                      getTranslated(context, "انصراف"),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: ColorManager.primary),
                    ),
                  ))),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}

class SingleUserReportTableHeader extends StatelessWidget {
  final String lateTime, attendTime, leaveTime;
  const SingleUserReportTableHeader(
      {this.attendTime, this.lateTime, this.leaveTime});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20,
                        child: AutoSizeText(
                          getTranslated(context, "التأخير"),
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: ColorManager.primary),
                        ),
                      ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20.h,
                        child: AutoSizeText(
                          getTranslated(context, "حضور"),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: ColorManager.primary),
                        ),
                      ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20.h,
                        child: AutoSizeText(
                          getTranslated(context, 'انصراف'),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: ColorManager.primary),
                        ),
                      ))),
                    ),
                  ],
                ),
              )
            ],
          ),
          Divider(
            thickness: 1,
            color: ColorManager.primary,
          ),
          SizedBox(height: 30.h),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20.h,
                        child: AutoSizeText(
                          lateTime ?? ' - ',
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: ColorManager.accentColor),
                        ),
                      ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20.h,
                        child: AutoSizeText(
                          attendTime ?? ' - ',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: ColorManager.accentColor),
                        ),
                      ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20.h,
                        child: AutoSizeText(
                          leaveTime,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: ColorManager.accentColor),
                        ),
                      ))),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    ));
  }
}
