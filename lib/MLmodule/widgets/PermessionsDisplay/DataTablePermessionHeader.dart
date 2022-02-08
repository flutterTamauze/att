import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/widgets/Reports/DailyReport/dailyReportTableHeader.dart';

class DataTablePermessionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: [
        DataTableHeaderTitles(
            getTranslated(context, "نوع الأذن"), Colors.orange),
        DataTableHeaderTitles(
            getTranslated(
              context,
              "التاريخ",
            ),
            Colors.orange),
        DataTableHeaderTitles(getTranslated(context, "الوقت"), Colors.orange),
      ],
    ));
  }
}
