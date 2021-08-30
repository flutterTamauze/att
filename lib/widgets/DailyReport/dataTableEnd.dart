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
      decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          )),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
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
      ),
    );
  }
}
