import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:qr_users/widgets/Reports/DailyReport/dailyReportTableHeader.dart';

class DataTableholidayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Row(
        children: [
          DataTableHeaderTitles("نوع الأجازة", Colors.orange[600]),
          DataTableHeaderTitles("من", Colors.orange[600]),
          DataTableHeaderTitles("الى", Colors.orange[600]),
        ],
      ),
    );
  }
}

class DataTableMissionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Row(
        children: [
          DataTableHeaderTitles("نوع المأمورية", Colors.orange[600]),
          DataTableHeaderTitles("من", Colors.orange[600]),
          DataTableHeaderTitles("الى", Colors.orange[600]),
        ],
      ),
    );
  }
}
