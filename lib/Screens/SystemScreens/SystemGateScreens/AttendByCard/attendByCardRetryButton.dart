import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

class AttendByCardRetryButton extends StatelessWidget {
  const AttendByCardRetryButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 330.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.orange),
      child: Center(
        child: Container(
          height: 20,
          child: AutoSizeText(
            getTranslated(context, "اضغط للمحاولة مره اخرى"),
            maxLines: 1,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(18, allowFontScalingSelf: true),
                color: Colors.black),
          ),
        ),
      ),
    );
  }
}
