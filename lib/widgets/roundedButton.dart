import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:qr_users/constants.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({
    @required this.title,
    @required this.onPressed,
  });

  final String title;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: getkDeviceWidthFactor(context, 160),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(10),
        child: Center(
          child: Container(
            height: 20,
            child: AutoSizeText(
              title,
              maxLines: 1,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      ScreenUtil().setSp(17.0, allowFontScalingSelf: true)),
            ),
          ),
        ),
      ),
    );
  }
}

class RounderButton extends StatelessWidget {
  @override
  final text;
  final onTap;

  RounderButton(this.text, this.onTap);

  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.orange),
        padding: EdgeInsets.all(5),
        child: Center(
          child: Container(
            height: 20,
            child: AutoSizeText(
              text,
              maxLines: 1,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true)),
            ),
          ),
        ),
      ),
    );
  }
}
