import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';

class SuperCompanyChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SuperCompanyChartState();
}

class SuperCompanyChartState extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AspectRatio(
        aspectRatio: 1,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: Provider.of<PermissionHan>(context, listen: false)
                        .isEnglishLocale()
                    ? EdgeInsets.only(right: 70.w)
                    : EdgeInsets.only(left: 70.w),
                child: PieChart(
                  PieChartData(
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 30,
                      sections: showingSections(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(BuildContext context) {
    var ratio =
        Provider.of<UserData>(context, listen: false).superCompaniesChartModel;
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.orange,
            value: double.parse(ratio.totalHolidaysRatio.toString()),
            title: double.parse(ratio.totalHolidaysRatio.toString())
                    .toStringAsFixed(0) +
                " %",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red[600],
            value: double.parse(ratio.totalAbsentRatio.toString()),
            title: double.parse(ratio.totalAbsentRatio.toString())
                    .toStringAsFixed(0) +
                " %",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );

        case 2:
          return PieChartSectionData(
            color: Colors.green[600],
            value: double.parse(ratio.totalAttendRatio.toString()),
            title: double.parse(ratio.totalAttendRatio.toString())
                    .toStringAsFixed(0) +
                " %",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.purple[600],
            value: double.parse(ratio.totalExternalMissionRatio.toString()),
            title: double.parse(ratio.totalExternalMissionRatio.toString())
                    .toStringAsFixed(0) +
                " %",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }
}
