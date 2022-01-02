import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

class DataTableVacationHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50.h,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  child: Container(
                padding: EdgeInsets.only(right: 10.w),
                height: 20,
                child: AutoSizeText(
                  getTranslated(context, "أسم العطلة"),
                  maxLines: 1,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          ScreenUtil().setSp(16, allowFontScalingSelf: true),
                      color: Colors.orange[600]),
                ),
              )),
              Container(
                  child: Container(
                padding: EdgeInsets.only(right: 10.w),
                height: 20,
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
                      color: Colors.orange[600]),
                ),
              )),
            ],
          ),
        ));
  }
}
