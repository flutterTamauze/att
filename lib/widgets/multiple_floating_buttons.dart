import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUser.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/AddVacationScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/AddUserScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/SelectOnMapScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

class MultipleFloatingButtons extends StatelessWidget {
  final bool comingFromShifts;
  final String shiftName;
  final String mainTitle;
  final IconData mainIconData;
  final int siteId;
  final int shiftIndex;
  MultipleFloatingButtons(
      {this.comingFromShifts,
      this.shiftName,
      @required this.mainIconData,
      @required this.mainTitle,
      this.siteId,
      this.shiftIndex});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: SpeedDial(
          overlayOpacity: 0,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22),
          backgroundColor: ColorManager.primary,
          visible: true,
          curve: Curves.bounceIn,
          children: [
            // FAB 1
            mainTitle == ""
                ? SpeedDialChild(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    labelBackgroundColor: Colors.white)
                : SpeedDialChild(
                    child: Icon(
                      mainIconData,
                    ),
                    backgroundColor: ColorManager.primary,
                    onTap: () {
                      switch (mainTitle) {
                        case "إضافة مستخدم":
                          if (Provider.of<SiteShiftsData>(context,
                                      listen: false)
                                  .shifts
                                  .isEmpty &&
                              Provider.of<SiteData>(context, listen: false)
                                      .siteValue !=
                                  "كل المواقع") {
                            Fluttertoast.showToast(
                                backgroundColor: Colors.red,
                                msg:
                                    "لا يوجد مناوبات بهذا الموقع برجاء إضافة مناوبة اولا",
                                gravity: ToastGravity.CENTER);
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddUserScreen(
                                          Member(),
                                          0,
                                          false,
                                          "",
                                          "",
                                          comingFromShifts,
                                          shiftName,
                                        )));
                          }

                          break;
                        case "إضافة عطلة":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddVacationScreen(
                                  edit: false,
                                ),
                              )).then((value) => Provider.of<VacationData>(
                                  context,
                                  listen: false)
                              .getOfficialVacations(
                                  Provider.of<CompanyData>(context,
                                          listen: false)
                                      .com
                                      .id,
                                  Provider.of<UserData>(context, listen: false)
                                      .user
                                      .userToken));

                          break;
                        case "إضافة موقع":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddLocationMapScreen(
                                    Site(
                                      lat: 0.0,
                                      long: 0.0,
                                      name: "",
                                    ),
                                    0)),
                          );
                          break;
                        case "إضافة مناوبة":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddShiftScreen(
                                      Shift(), 0, false, siteId, siteId)));
                          break;
                      }
                    },
                    label: mainTitle,
                    elevation: 5,
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: setResponsiveFontSize(15)),
                    labelBackgroundColor: Colors.black),
            // FAB 2

            SpeedDialChild(
                child: Icon(Icons.settings),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavScreenTwo(3),
                      ));
                },
                label: 'الاعدادات',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
            SpeedDialChild(
                child: Icon(Icons.article_sharp),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavScreenTwo(2),
                      ));
                },
                label: "التقارير",
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
            SpeedDialChild(
                child: Icon(Icons.qr_code),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavScreenTwo(1),
                      ));
                },
                label: 'التسجيل',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
            SpeedDialChild(
                child: Icon(Icons.home),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavScreenTwo(0),
                      ));
                },
                label: 'الرئيسية',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
            SpeedDialChild(
                child: Icon(FontAwesomeIcons.user),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NormalUserMenu(),
                      ));
                },
                label: 'حسابى',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
          ],
        ),
      ),
    );
  }
}

class MultipleFloatingButtonsNoADD extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: SpeedDial(
          overlayOpacity: 0,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22),
          backgroundColor: ColorManager.primary,
          visible: true,
          curve: Curves.bounceIn,
          children: [
            // FAB 1

            // FAB 2

            SpeedDialChild(
                child: Icon(Icons.settings),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavScreenTwo(3),
                      ));
                },
                label: 'الاعدادات',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
            SpeedDialChild(
                child: Icon(Icons.article_sharp),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavScreenTwo(2),
                      ));
                },
                label: "التقارير",
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
            SpeedDialChild(
                child: Icon(Icons.qr_code),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavScreenTwo(1),
                      ));
                },
                label: 'التسجيل',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
            SpeedDialChild(
                child: Icon(Icons.home),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavScreenTwo(0),
                      ));
                },
                label: 'الرئيسية',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
            SpeedDialChild(
                child: Icon(FontAwesomeIcons.user),
                backgroundColor: ColorManager.primary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NormalUserMenu(),
                      ));
                },
                label: 'حسابى',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: setResponsiveFontSize(15)),
                labelBackgroundColor: Colors.black),
          ],
        ),
      ),
    );
  }
}
