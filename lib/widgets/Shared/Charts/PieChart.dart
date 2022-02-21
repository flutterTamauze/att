import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';

class LateReportPieChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LateReportPieChartState();
}

class LateReportPieChartState extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  child: AutoSizeText(
                    getTranslated(context, "تحليل بيانات الموظفين عن فترة"),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                        fontSize: setResponsiveFontSize(16)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 0,
                          centerSpaceRadius: 30,
                          sections: showingSections()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red[600]),
                  ),
                  AutoSizeText(
                    getTranslated(context, "الغياب"),
                    style: boldStyle,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: ColorManager.primary)),
                  AutoSizeText(
                    getTranslated(context, "التأخير"),
                    style: boldStyle,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.green[600])),
                  AutoSizeText(
                    getTranslated(context, "الأنتظام"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(
                height: 18,
              ),
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final reportsData = Provider.of<ReportsData>(context);
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.orange,
            value: double.parse(
                    reportsData.lateAbsenceReport.lateRatio.replaceAll("%", ""))
                .ceilToDouble(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red,
            value: double.parse(reportsData.lateAbsenceReport.absentRatio
                    .replaceAll("%", ""))
                .ceilToDouble(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.green,
            value: 100 -
                (double.parse(reportsData.lateAbsenceReport.lateRatio
                            .replaceAll("%", "")) +
                        double.parse(reportsData.lateAbsenceReport.absentRatio
                            .replaceAll("%", "")))
                    .ceilToDouble(),
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
