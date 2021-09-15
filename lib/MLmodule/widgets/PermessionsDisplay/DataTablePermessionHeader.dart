import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/widgets/DailyReport/dailyReportTableHeader.dart';
import 'dart:ui' as ui;

class DataTablePermessionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
          child: Row(
        children: [
          DataTableHeaderTitles("نوع الأذن", Colors.orange),
          DataTableHeaderTitles("التاريخ", Colors.orange),
          DataTableHeaderTitles("الوقت", Colors.orange),
        ],
      )),
    );
  }
}
