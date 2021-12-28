import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_users/Core/constants.dart';

class SuperAdminTile extends StatelessWidget {
  final String title;
  final onTap;
  SuperAdminTile({this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                height: 40,
                alignment: Alignment.center,
                child: AutoSizeText(
                  title,
                  maxLines: 3,
                  style: TextStyle(
                      fontSize: setResponsiveFontSize(16),
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Icon(
                Icons.chevron_right,
                size: ScreenUtil().setSp(35, allowFontScalingSelf: true),
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
