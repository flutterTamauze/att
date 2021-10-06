import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
              width: 100.w,
              height: 50.h,
              child: Center(
                  child: Container(
                height: 20,
                child: AutoSizeText(
                  'الاسم',
                  maxLines: 1,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          ScreenUtil().setSp(14, allowFontScalingSelf: true),
                      color: Colors.orange[600]),
                ),
              ))),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                      child: Center(
                          child: Container(
                    height: 20,
                    child: AutoSizeText(
                      'التأخير',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(14, allowFontScalingSelf: true),
                          color: Colors.orange[600]),
                    ),
                  ))),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      child: Center(
                          child: Container(
                    height: 20,
                    child: AutoSizeText(
                      'ايام التأخير',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(14, allowFontScalingSelf: true),
                          color: Colors.orange[600]),
                    ),
                  ))),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      child: Center(
                          child: Container(
                    height: 20,
                    child: AutoSizeText(
                      'ايام الغياب',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(14, allowFontScalingSelf: true),
                          color: Colors.orange[600]),
                    ),
                  ))),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      child: Center(
                          child: Container(
                    child: AutoSizeText(
                      'مجموع الخصومات',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(13, allowFontScalingSelf: true),
                          color: Colors.orange[600]),
                    ),
                  ))),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
