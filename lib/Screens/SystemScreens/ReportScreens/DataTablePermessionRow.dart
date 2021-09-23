import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';

class DataTablePermessionRow extends StatelessWidget {
  final UserPermessions permessions;

  DataTablePermessionRow(this.permessions);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 30.h,
            alignment: Alignment.center,
            child: AutoSizeText(
              permessions.permessionType == 1
                  ? "تأخير عن الحضور"
                  : "انصراف مبكر",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true),
              ),
            ),
          ),
          Container(
            padding: permessions.permessionType != 1
                ? EdgeInsets.only(right: 20.w)
                : null,
            height: 35.h,
            width: 90.w,
            child: Center(
              child: Container(
                alignment: Alignment.center,
                height: 20.h,
                child: AutoSizeText(
                  permessions.date.toString().substring(0, 11),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize:
                        ScreenUtil().setSp(14, allowFontScalingSelf: true),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            padding: permessions.permessionType != 1
                ? EdgeInsets.only(right: 10.w)
                : null,
            height: 30.h,
            width: 80.w,
            child: Center(
              child: Container(
                alignment: Alignment.center,
                height: 20.h,
                child: AutoSizeText(
                  permessions.duration,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize:
                        ScreenUtil().setSp(14, allowFontScalingSelf: true),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
