import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            color: Colors.orange[600],
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
                            color: Colors.orange[600]),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      height: 20,
                      child: AutoSizeText(
                        lateRatio,
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(13, allowFontScalingSelf: true),
                            color: Colors.orange[600]),
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
                            color: Colors.orange[600]),
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
                            color: Colors.orange[600]),
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
                            color: Colors.orange[600]),
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
                            color: Colors.orange[600]),
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
