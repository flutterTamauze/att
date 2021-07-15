import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class DirectoriesHeader extends StatelessWidget {
  final lottie;
  final String title;

  DirectoriesHeader(this.lottie, this.title);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: Colors.orange,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 60,
            child: Container(
              // width: 100,
              decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: headerImage,
                //   fit: BoxFit.fill,
                // ),
                shape: BoxShape.circle,
              ),
              child: lottie,
            ),
          ),
        ),
        SizedBox(
          height: 2,
        ),
        Container(
          height: 30.h,
          child: AutoSizeText(title,
              maxLines: 1,
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              )),
        ),
      ],
    );
  }
}

class SmallDirectoriesHeader extends StatelessWidget {
  final lottie;
  final String title;

  SmallDirectoriesHeader(this.lottie, this.title);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 40.w,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: lottie,
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          height: 30.h,
          child: AutoSizeText(title,
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize:
                      ScreenUtil().setSp(20, allowFontScalingSelf: true))),
        ),
      ],
    );
  }
}
