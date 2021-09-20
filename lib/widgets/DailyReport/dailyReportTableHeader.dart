import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataTableHeader extends StatelessWidget {
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
                  child: Center(
                      child: Container(
                    height: 20,
                    child: AutoSizeText(
                      'الاسم',
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
                    DataTableHeaderTitles("التأخير", Colors.black),
                    DataTableHeaderTitles("حضور", Colors.black),
                    DataTableHeaderTitles("انصراف", Colors.black),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 50.h,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class DataTableHeaderTitles extends StatelessWidget {
  final String title;
  final Color color;
  DataTableHeaderTitles(this.title, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
          child: Center(
              child: Container(
        child: AutoSizeText(
          title,
          maxLines: 1,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
              color: color),
        ),
      ))),
    );
  }
}
