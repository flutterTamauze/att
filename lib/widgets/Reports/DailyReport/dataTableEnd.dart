import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/widgets/UserReport/DataTableEndRowInfo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailyReportTableEnd extends StatelessWidget {
  final totalAttend;
  final totalAbsents;
  DailyReportTableEnd({this.totalAbsents, this.totalAttend});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
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
                  DataTableEndRowInfo(
                    infoTitle: 'مجموع الحضور:',
                    info: totalAttend,
                  ),
                  DataTableEndRowInfo(
                      info: totalAbsents, infoTitle: "مجموع الغياب:")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyReportTodayTableEnd extends StatelessWidget {
  final String title, titleHeader;
  DailyReportTodayTableEnd({this.title, this.titleHeader});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
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
                  DataTableEndRowInfo(
                    infoTitle: titleHeader,
                    info: title,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
