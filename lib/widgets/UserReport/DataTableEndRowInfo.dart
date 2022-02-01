import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataTableEndRowInfo extends StatelessWidget {
  const DataTableEndRowInfo({@required this.info, @required this.infoTitle});

  final info;
  final String infoTitle;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 20.h,
          child: AutoSizeText(
            infoTitle,
            maxLines: 1,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(11, allowFontScalingSelf: true),
                color: Colors.orange[600]),
          ),
        ),
        SizedBox(
          width: 4.w,
        ),
        Container(
          height: 20.h,
          child: AutoSizeText(
            info,
            maxLines: 1,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(11, allowFontScalingSelf: true),
                color: Colors.orange[600]),
          ),
        ),
      ],
    );
  }
}
