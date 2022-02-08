import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';

class ReportTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final icon;
  final onTap;
  const ReportTile({this.title, this.subTitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        trailing: Icon(
          Icons.chevron_right,
          size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
          color: ColorManager.primary,
        ),
        onTap: onTap,
        title: Container(
          height: 20,
          child: AutoSizeText(
            title,
            maxLines: 1,
          ),
        ),
        subtitle: Container(
          child: AutoSizeText(
            subTitle,
            style: TextStyle(fontSize: setResponsiveFontSize(13)),
            maxLines: 1,
          ),
        ),
        leading: Icon(
          icon,
          size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
          color: ColorManager.primary,
        ),
      ),
    );
  }
}
