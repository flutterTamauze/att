import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';

import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/Shared/Charts/PieChartInfo.dart';
import 'package:qr_users/widgets/Shared/Charts/SuperCompanyChart.dart';
import 'package:qr_users/widgets/Shared/RoundBorderImage.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                  if (userData.user.userType == 4 &&
                      !userData.isSuperAdmin &&
                      !userData.isTdsAdmin &&
                      !userData.isTechnicalSupport) ...[
                    const SuperAdminHeader()
                  ] else ...[
                    Header(
                      goUserHomeFromMenu: false,
                      goUserMenu: false,
                      nav: false,
                    ),
                  ],

                  FadeIn(
                      child: RoundBorderedImage(
                    radius: 13,
                    width: 200.w,
                    height: 200.h,
                    imageUrl: comData.com.logo,
                  )),
                  SizedBox(
                    height: 20.h,
                  ),
                  AutoSizeText(
                    "${getTranslated(context, "تمام شركة")} ${comData.com.nameAr}",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: ScreenUtil().setSp(16)),
                  ),
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
                                      AutoSizeText(
                                        getTranslated(
                                            context, "عدد مستخدمين الشركة"),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: setResponsiveFontSize(14),
                                            color: Colors.blueAccent),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Container(
                                        width: 35.w,
                                        height: 25.h,
                                        child: Center(
                                          child: AutoSizeText(
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
                                    title: getTranslated(context, "الموجود"),
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
                              if (!userData
                                      .superCompaniesChartModel.isHoliday &&
                                  !userData.superCompaniesChartModel
                                      .isOfficialVac) ...[
                                SinglePieChartItem(
                                  title: getTranslated(context, "الأجازة"),
                                  color: ColorManager.primary,
                                  count: userData
                                      .superCompaniesChartModel.totalHolidays
                                      .toString(),
                                ),
                              ],
                              const SizedBox(
                                height: 5,
                              ),
                              SinglePieChartItem(
                                count: userData.superCompaniesChartModel
                                    .totalExternalMissions
                                    .toString(),
                                title: getTranslated(
                                    context, "المأموريات الخارجية"),
                                color: Colors.purple[600],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: Container()),
                        Expanded(
                            child: FadeInRight(child: SuperCompanyChart())),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 60.h,
                  ),
                  userData.superCompaniesChartModel.isOfficialVac
                      ? Container(
                          child: AutoSizeText(
                            getTranslated(context, "عطلة رسمية"),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: setResponsiveFontSize(16)),
                          ),
                        )
                      : userData.superCompaniesChartModel.isHoliday
                          ? Container(
                              child: AutoSizeText(
                                getTranslated(context, "عطلة اسبوعية"),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: setResponsiveFontSize(16)),
                              ),
                            )
                          : Container(),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Provider.of<SiteData>(context, listen: false)
                          .dropDownSitesStrings
                          .clear();
                      Provider.of<SiteData>(context, listen: false)
                          .filSitesStringsList(context);
                      if (userData.isTechnicalSupport) {
                        debugPrint("overiding tech supporrt rule from 4 to 3");
                        Provider.of<UserData>(context, listen: false)
                            .user
                            .userType = 3;
                      }
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
                      child: Lottie.asset(
                        'resources/proceed.json',
                      ),
                    ),
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
