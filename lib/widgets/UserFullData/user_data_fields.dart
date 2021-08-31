import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserDataField extends StatelessWidget {
  final IconData icon;
  final String text;

  UserDataField({this.icon, this.text});

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12, width: 1)),
      height: 35.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 3.h),
              child: Icon(
                icon,
                color: Colors.orange,
                size: 19,
              ),
            ),
            SizedBox(
              width: 15.w,
            ),
            Expanded(
                child: Container(
              height: 20.h,
              child: AutoSizeText(
                text ?? "",
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
