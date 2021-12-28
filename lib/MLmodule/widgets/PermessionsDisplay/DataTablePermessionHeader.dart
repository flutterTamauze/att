import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'dart:ui' as ui;

import 'package:qr_users/widgets/Reports/DailyReport/dailyReportTableHeader.dart';

class DataTablePermessionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
          child: Row(
        children: [
          DataTableHeaderTitles("نوع الأذن", Colors.orange),
          DataTableHeaderTitles(
              getTranslated(
                context,
                "التاريخ",
              ),
              Colors.orange),
          DataTableHeaderTitles("الوقت", Colors.orange),
        ],
      )),
    );
  }
}
