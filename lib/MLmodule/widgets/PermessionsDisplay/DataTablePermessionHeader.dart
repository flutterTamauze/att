import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/DailyReport/dailyReportTableHeader.dart';
import 'dart:ui' as ui;

class DataTablePermessionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
          decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              )),
          child: Row(
            children: [
              Container(
                  width: 160.w,
                  child: Container(
                    padding: EdgeInsets.only(right: 10.w),
                    height: 20.h,
                    child: AutoSizeText(
                      ' أسم المستخدم',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  )),
              Expanded(
                child: Row(
                  children: [
                    DataTableHeaderTitles("نوع الأذن"),
                    DataTableHeaderTitles("التاريخ"),
                    DataTableHeaderTitles("الوقت"),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
