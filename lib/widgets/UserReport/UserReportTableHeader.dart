import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserReportTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                  width: 160.w,
                  height: 50.h,
                  child: Center(
                      child: Container(
                    height: 20,
                    child: AutoSizeText(
                      'التاريخ',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
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
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black),
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
                          'حضور',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black),
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
                          'انصراف',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black),
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