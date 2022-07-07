import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'UserReportTableHeader.dart';

class TodayUserReport extends StatelessWidget {
  final String apiStatus;
  const TodayUserReport({Key key, this.apiStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, snapshot) {
      return Consumer<ReportsData>(
        builder: (BuildContext context, value, Widget child) {
          return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                  child: ZoomIn(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    insetPadding: EdgeInsets.symmetric(
                      horizontal: 20.0.w,
                      vertical: 20.0.h,
                    ),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    content: Container(
                      height: 100.h,
                      width: 300.w,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              apiStatus == "fail"
                                  ? Expanded(
                                      child: CenterMessageText(
                                          message: getTranslated(context,
                                              "لا يوجد بيانات لهذا المستخدم اليوم")),
                                    )
                                  : SingleUserReportTableHeader(
                                      lateTime: value.todayUserReport.lateTime
                                          .toString(),
                                      leaveTime: value.todayUserReport.leave
                                          .toString(),
                                      attendTime: value.todayUserReport.attend,
                                    ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              )));
        },
      );
    });
  }
}
