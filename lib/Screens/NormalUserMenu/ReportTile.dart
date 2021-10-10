import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';

class ReportTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final icon;
  final onTap;
  ReportTile({this.title, this.subTitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        trailing: Icon(
          icon,
          size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
        onTap: onTap,
        title: Container(
          height: 20,
          child: AutoSizeText(
            title,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        subtitle: Container(
          height: 20,
          child: AutoSizeText(
            subTitle,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        leading: Icon(
          Icons.chevron_left,
          size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
      ),
    );
  }
}
