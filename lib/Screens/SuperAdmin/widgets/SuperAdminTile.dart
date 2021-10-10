import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuperAdminTile extends StatelessWidget {
  final String title;
  final String compPicture;
  final onTap;
  SuperAdminTile({this.title, this.compPicture, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_left,
              size: ScreenUtil().setSp(35, allowFontScalingSelf: true),
              color: Colors.orange,
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              height: 40,
              alignment: Alignment.center,
              child: AutoSizeText(
                title,
                maxLines: 3,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(
                image: NetworkImage(
                  compPicture,
                ),
                width: 65.w,
                fit: BoxFit.cover,
                height: 55.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
