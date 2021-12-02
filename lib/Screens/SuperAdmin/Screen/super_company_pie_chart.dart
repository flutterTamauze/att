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
import 'package:qr_users/widgets/Shared/RoundBorderImage.dart';
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
                      child: RoundBorderedImage(
                    radius: 13,
                    width: 200,
                    height: 200,
                    imageUrl: comData.com.logo,
                  )),
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
                              Container(
                                width: 190.w,
                                child: Container(
                                  padding: EdgeInsets.only(right: 5.w),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 35.w,
                                        height: 25.h,
                                        child: Center(
                                          child: Text(
                                            userData.superCompaniesChartModel
                                                .totalEmp
                                                .toString(),
                                            style: TextStyle(
                                                fontSize:
                                                    setResponsiveFontSize(15),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      AutoSizeText(
                                        "عدد مستخدمين الشركة",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: setResponsiveFontSize(14),
                                            color: Colors.blueAccent),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              Row(
                                children: [
                                  SinglePieChartItem(
                                    title: "الموجود",
                                    color: Colors.green[600],
                                    count: userData
                                        .superCompaniesChartModel.totalAttend
                                        .toString(),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SinglePieChartItem(
                                title: "الأجازة",
                                color: Colors.orange[600],
                                count: userData
                                    .superCompaniesChartModel.totalHolidays
                                    .toString(),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              SinglePieChartItem(
                                count: userData.superCompaniesChartModel
                                    .totalExternalMissions
                                    .toString(),
                                title: "المأموريات الخارجية",
                                color: Colors.purple[600],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              // SinglePieChartItem(
                              //   title: "الغياب",
                              //   color: Colors.red[600],
                              //   count: userData
                              //       .superCompaniesChartModel.totalAbsent
                              //       .toString(),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Container(
                  //     padding: EdgeInsets.only(right: 10.w),
                  //     width: 202.w,
                  //     child: Row(
                  //       children: [
                  //         Container(
                  //           width: 25.w,
                  //           height: 25.h,
                  //           child: Center(
                  //             child: Text(
                  //               userData
                  //                   .superCompaniesChartModel.totalPermessions
                  //                   .toString(),
                  //               style: TextStyle(fontWeight: FontWeight.w500),
                  //             ),
                  //           ),
                  //           decoration: BoxDecoration(
                  //               shape: BoxShape.circle,
                  //               border:
                  //                   Border.all(width: 1, color: Colors.black)),
                  //         ),
                  //         Expanded(
                  //           child: Container(),
                  //         ),
                  //         AutoSizeText(
                  //           "مجموع الأذونات",
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //           textAlign: TextAlign.right,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      //  onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NavScreenTwo(2),
                          ));
                      // })
                    },
                    child: Container(
                        width: 80.w,
                        height: 80.w,
                        child: Lottie.asset('resources/proceed.json')),
                  )
                  // RoundedButton(
                  //     title: "متابعة",
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
