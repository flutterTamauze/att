import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';

class UserReportPieChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserReportPieChartState();
}

class UserReportPieChartState extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 18.h,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Column(
                children: [
                  AutoSizeText(
                    getTranslated(
                      context,
                      "تحليل بيانات الموظف",
                    ),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(16),
                        color: Colors.orange[600]),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Expanded(
                    flex: 1,
                    child: PieChart(
                      PieChartData(
                          pieTouchData: PieTouchData(touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection.touchedSectionIndex;
                            });
                          }),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 0,
                          centerSpaceRadius: 30,
                          sections: showingSections()),
                    ),
                  ),
                ],
              ),
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
                    width: 20.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red[600]),
                  ),
                  AutoSizeText(
                    getTranslated(context, "الغياب"),
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                          shape: BoxShape.circle, color: Colors.orange)),
                  AutoSizeText(
                    getTranslated(context, "التأخير"),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  )
                ],
              ),
              SizedBox(
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
    var reportsData = Provider.of<ReportsData>(context);
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.orange,
            value: reportsData.userAttendanceReport.totalLateDay /
                (reportsData.userAttendanceReport.userAttendListUnits.length) *
                100,
            title: (reportsData.userAttendanceReport.totalLateDay /
                    (reportsData
                        .userAttendanceReport.userAttendListUnits.length) *
                    100)
                .toStringAsFixed(1),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red[600],
            value: (reportsData.userAttendanceReport.totalAbsentDay /
                (reportsData.userAttendanceReport.userAttendListUnits.length) *
                100),
            title: (reportsData.userAttendanceReport.totalAbsentDay /
                    (reportsData
                        .userAttendanceReport.userAttendListUnits.length) *
                    100)
                .toStringAsFixed(1),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );

        case 2:
          return PieChartSectionData(
            color: Colors.green[600],
            value: ((reportsData
                            .userAttendanceReport.userAttendListUnits.length -
                        (reportsData.userAttendanceReport.totalAbsentDay +
                            reportsData.userAttendanceReport.totalLateDay)) /
                    reportsData
                        .userAttendanceReport.userAttendListUnits.length) *
                100,
            title: (((reportsData.userAttendanceReport.userAttendListUnits
                                .length -
                            (reportsData.userAttendanceReport.totalAbsentDay +
                                reportsData
                                    .userAttendanceReport.totalLateDay)) /
                        reportsData
                            .userAttendanceReport.userAttendListUnits.length) *
                    100)
                .toStringAsFixed(1),
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
