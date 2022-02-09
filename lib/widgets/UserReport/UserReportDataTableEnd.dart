import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/permissions_data.dart';

import 'DataTableEndRowInfo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserReprotDataTableEnd extends StatelessWidget {
  final UserAttendanceReport _attendanceReport;

  const UserReprotDataTableEnd(
    this._attendanceReport,
  );

  @override
  Widget build(BuildContext context) {
    final bool isEnglishLocale =
        Provider.of<PermissionHan>(context, listen: false).isEnglishLocale();
    return Column(
      children: [
        const Divider(
          thickness: 1,
          color: Colors.orange,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10.h,
            ),
            child: Container(
              height: 70.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            child: DataTableEndRowInfo(
                          infoTitle: isEnglishLocale
                              ? ' ${getTranslated(context, 'ايام الغياب')}'
                              : '${getTranslated(context, 'ايام الغياب')} : ',
                          info: _attendanceReport.totalAbsentDay.toString(),
                        )),
                        DataTableEndRowInfo(
                          infoTitle: isEnglishLocale
                              ? '${getTranslated(context, 'مدة التأخير')}'
                              : '${getTranslated(context, 'مدة التأخير')} :',
                          info: _attendanceReport.totalLateDuration,
                        ),
                        DataTableEndRowInfo(
                            info: _attendanceReport.totalLateDay.toString(),
                            infoTitle: isEnglishLocale
                                ? '${getTranslated(context, 'ايام التأخير')}'
                                : '${getTranslated(context, 'ايام التأخير')} :'),
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DataTableEndRowInfo(
                        info: _attendanceReport.totalDeductionAbsent
                            .toStringAsFixed(1),
                        infoTitle: '${getTranslated(context, 'خصم الغياب')}',
                      ),
                      DataTableEndRowInfo(
                          info: _attendanceReport.totalLateDeduction
                              .toStringAsFixed(1),
                          infoTitle:
                              '${getTranslated(context, 'خصم التأخير')}'),
                      DataTableEndRowInfo(
                        info:
                            _attendanceReport.totalDeduction.toStringAsFixed(1),
                        infoTitle: '${getTranslated(context, 'الإجمالى')}',
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
