import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'dart:ui' as ui;

import 'package:qr_users/widgets/Reports/DailyReport/dailyReportTableHeader.dart';

class DataTableholidayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DataTableHeaderTitles(
            getTranslated(
              context,
              "نوع الأجازة",
            ),
            ColorManager.primary),
        DataTableHeaderTitles(
            getTranslated(
              context,
              "من",
            ),
            ColorManager.primary),
        DataTableHeaderTitles(
            getTranslated(context, "إلى"), ColorManager.primary),
      ],
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
          DataTableHeaderTitles(
              getTranslated(context, "نوع المأمورية"), ColorManager.primary),
          DataTableHeaderTitles(
              getTranslated(context, "من"), ColorManager.primary),
          DataTableHeaderTitles(
              getTranslated(context, "إلى"), ColorManager.primary),
        ],
      ),
    );
  }
}
