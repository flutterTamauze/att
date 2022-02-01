import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/colorManager.dart';

class DataTableEnd extends StatelessWidget {
  final lateRatio;
  final absenceRatio;
  final double totalDeduction;
  DataTableEnd(
      {this.absenceRatio, this.lateRatio, @required this.totalDeduction});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Divider(
            thickness: 1,
            color: ColorManager.primary,
          ),
          Container(
            height: 50.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Container(
                      height: 20.h,
                      child: AutoSizeText(
                        'التأخير:',
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                            color: ColorManager.primary),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      height: 20.h,
                      child: AutoSizeText(
                        lateRatio,
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                            color: ColorManager.primary),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 20,
                      child: AutoSizeText(
                        'الغياب:',
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                            color: ColorManager.primary),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      height: 20,
                      child: AutoSizeText(
                        absenceRatio.toString().split(".")[0],
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                            color: ColorManager.primary),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 20,
                      child: AutoSizeText(
                        'الخصومات:',
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                            color: ColorManager.primary),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      height: 20,
                      child: AutoSizeText(
                        totalDeduction.toStringAsFixed(3),
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                            color: ColorManager.primary),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
