import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/company.dart';

import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Shared/Charts/PieChartInfo.dart';
import 'package:qr_users/widgets/Shared/Charts/SuperCompanyChart.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import '../../../constants.dart';

class SuperCompanyPieChart extends StatefulWidget {
  @override
  _SuperCompanyPieChartState createState() => _SuperCompanyPieChartState();
}

class _SuperCompanyPieChartState extends State<SuperCompanyPieChart> {
  @override
  Widget build(BuildContext context) {
    var comData = Provider.of<CompanyData>(context);

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Consumer<UserData>(builder: (context, userData, child) {
      return Scaffold(
        endDrawer: NotificationItem(),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Header(
                    goUserHomeFromMenu: false,
                    goUserMenu: false,
                    nav: false,
                  ),
                  FadeIn(
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 2, color: Colors.orange),
                          image: DecorationImage(
                              image: NetworkImage(comData.com.logo))),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Directionality(
                      textDirection: TextDirection.rtl,
                      child: AutoSizeText(
                        "تمام شركة ${comData.com.nameAr}",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: ScreenUtil().setSp(16)),
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  AutoSizeText(
                    DateTime.now().toString().substring(0, 11),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: ScreenUtil().setSp(16)),
                  ),
                  SizedBox(
                    height: 90.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: FadeInRight(child: SuperCompanyChart())),
                        Expanded(child: Container()),
                        FadeInLeft(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  SinglePieChartItem(
                                    title: "الأجازة",
                                    color: Colors.orange[600],
                                    count: userData
                                        .superCompaniesChartModel.totalHolidays
                                        .toString(),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SinglePieChartItem(
                                title: "الموجود",
                                color: Colors.green[600],
                                count: userData
                                    .superCompaniesChartModel.totalAttend
                                    .toString(),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              SinglePieChartItem(
                                title: "الباقى",
                                color: Colors.red[600],
                                count: userData
                                    .superCompaniesChartModel.totalAbsent
                                    .toString(),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SinglePieChartItem(
                                count: userData.superCompaniesChartModel
                                    .totalExternalMissions
                                    .toString(),
                                title: "المأموريات الخارجية",
                                color: Colors.purple[600],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 180.w,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: [
                              Container(
                                width: 20.w,
                                height: 20.h,
                                child: Center(
                                  child: Text(
                                    userData.superCompaniesChartModel
                                        .totalPermessions
                                        .toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 1, color: Colors.black)),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              AutoSizeText(
                                "إذن تأخير عن الحضور",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 180.w,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: [
                              Container(
                                width: 20.w,
                                height: 20.h,
                                child: Center(
                                  child: Text(
                                    userData.superCompaniesChartModel.totalEmp
                                        .toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 1, color: Colors.black)),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              AutoSizeText(
                                "القوة",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  RoundedButton(
                      title: "المتابعة",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavScreenTwo(0),
                            ));
                      })
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
