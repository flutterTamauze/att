import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'dart:ui' as ui;

import 'package:qr_users/widgets/Reports/DailyReport/dailyReportTableHeader.dart';

class DataTableholidayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Row(
        children: [
          DataTableHeaderTitles("نوع الأجازة", ColorManager.primary),
          DataTableHeaderTitles("من", ColorManager.primary),
          DataTableHeaderTitles("الى", ColorManager.primary),
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
          DataTableHeaderTitles("نوع المأمورية", ColorManager.primary),
          DataTableHeaderTitles("من", ColorManager.primary),
          DataTableHeaderTitles("الى", ColorManager.primary),
        ],
      ),
    );
  }
}
