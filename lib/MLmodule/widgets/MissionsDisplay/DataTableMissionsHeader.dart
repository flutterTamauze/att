import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import 'package:qr_users/widgets/DailyReport/dailyReportTableHeader.dart';

class DataTableMissionsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
          child: Row(
        children: [
          DataTableHeaderTitles("النوع", Colors.orange[600]),
          DataTableHeaderTitles("من", Colors.orange[600]),
          DataTableHeaderTitles("الى", Colors.orange[600]),
          Container(
            height: 50.h,
          ),
        ],
      )),
    );
  }
}

class SingleUserMissionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
          height: 50.h,
          decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DataTableHeaderTitles("النوع", Colors.black),
                DataTableHeaderTitles("من", Colors.black),
                DataTableHeaderTitles("الى", Colors.black),
              ],
            ),
          )),
    );
  }
}
