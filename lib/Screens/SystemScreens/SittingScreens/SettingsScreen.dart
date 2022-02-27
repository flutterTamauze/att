import 'package:auto_size_text/auto_size_text.dart';
// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/Screens/ErrorScreen.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/SiteAdminUsersScreen.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/SiteAdminShiftScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/SitesScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';

import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/Settings/LanguageSettings.dart';

import 'CompanySettings/MainCompanySettings.dart';
import 'MembersScreens/UsersScreen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime currentBackPressTime;
  @override
  void initState() {
    super.initState();
  }

  Future getDaysOff() async {
    final userProvider = Provider.of<UserData>(context, listen: false);
    final comProvider = Provider.of<CompanyData>(context, listen: false);

    await Provider.of<DaysOffData>(context, listen: false)
        .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    final userProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.only(bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DirectoriesHeader(
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60.0),
                        child: Lottie.asset("resources/settings1.json",
                            repeat: false),
                      ),
                    ),
                    getTranslated(context, "الاعدادات")),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        userProvider.user.userType == 2
                            ? Container()
                            : ServiceTile(
                                title: getTranslated(context, "المواقع"),
                                subTitle:
                                    getTranslated(context, "ادارة المواقع"),
                                icon: Icons.location_on,
                                onTap: () async {
                                  Navigator.of(context).push(
                                    new MaterialPageRoute(
                                      builder: (context) => SitesScreen(),
                                    ),
                                  );
                                }),
                        ServiceTile(
                            title: getTranslated(context, "المناوبات"),
                            subTitle: getTranslated(context, "ادارة المناوبات"),
                            icon: Icons.alarm,
                            onTap: () async {
                              if (userProvider.user.userType != 2) {
                                Provider.of<SiteShiftsData>(context,
                                        listen: false)
                                    .getShiftsList(
                                        Provider.of<SiteShiftsData>(context,
                                                listen: false)
                                            .siteShiftList[0]
                                            .siteName,
                                        false);
                                Provider.of<SiteData>(context, listen: false)
                                    .setCurrentSiteName(
                                        Provider.of<SiteShiftsData>(context,
                                                listen: false)
                                            .siteShiftList[0]
                                            .siteName);
                              }

                              userProvider.user.userType == 2
                                  ? Navigator.of(context).push(
                                      new MaterialPageRoute(
                                        builder: (context) =>
                                            const SiteAdminShiftScreen(0, -1),
                                      ),
                                    )
                                  : Navigator.of(context).push(
                                      new MaterialPageRoute(
                                        builder: (context) =>
                                            ShiftsScreen(0, -1, 0),
                                      ),
                                    );
                            }),
                        ServiceTile(
                            title: getTranslated(context, "المستخدمين"),
                            subTitle:
                                getTranslated(context, "ادارة المستخدمين"),
                            icon: Icons.person,
                            onTap: () async {
                              if (userProvider.user.userType == 2) {
                                final siteShiftData =
                                    Provider.of<SiteShiftsData>(context,
                                        listen: false);
                                final siteProv = Provider.of<SiteData>(context,
                                    listen: false);

                                if (userProvider.user.userType == 4 ||
                                    userProvider.user.userType == 3) {
                                  if (siteShiftData.shifts.isEmpty) {
                                    siteShiftData.getShiftsList(
                                        siteShiftData.siteShiftList[0].siteName,
                                        true);
                                  }

                                  siteProv.fillCurrentShiftID(
                                      Provider.of<ShiftsData>(context,
                                              listen: false)
                                          .shiftsBySite[0]
                                          .shiftId);
                                }

                                siteProv.setDropDownShift(
                                    0); //الموقع علي حسب ال اندكس اللي
                                // ignore: cascade_invocations
                                siteProv.setDropDownShift(0);
                                // ignore: cascade_invocations
                                siteProv.setDropDownIndex(
                                    userDataProvider.user.userSiteId);

                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) => SiteAdminUserScreen(
                                        userProvider.user.userSiteId + 1,
                                        true,
                                        ""),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) =>
                                        UsersScreen(-1, false, ""),
                                  ),
                                );
                              }
                            }),
                        userProvider.user.userType == 2
                            ? Container()
                            : ServiceTile(
                                title: getTranslated(context, "اعدادات الشركة"),
                                subTitle: getTranslated(
                                    context, "ادارة اعدادات الشركة"),
                                icon: Icons.settings,
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CompanySettings(),
                                      ));
                                }),
                        // ServiceTile(
                        //     title: getTranslated(context, "اعدادات اللغة"),
                        //     subTitle:
                        //         getTranslated(context, "ضبط اعدادات اللغة"),
                        //     icon: Icons.language,
                        //     onTap: () async {
                        //       showDialog(
                        //         context: context,
                        //         builder: (context) {
                        //           return ChangeLanguage(
                        //               callBackFun: () {},
                        //               locale: Provider.of<PermissionHan>(
                        //                           context,
                        //                           listen: false)
                        //                       .isEnglishLocale()
                        //                   ? "En"
                        //                   : "Ar");
                        //         },
                        //       );
                        //     }),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<bool> onWillPop() {
    //If user on home Screen
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NavScreenTwo(0)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class ServiceTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final icon;
  final onTap;
  ServiceTile({this.title, this.subTitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        trailing: Icon(
          Icons.chevron_right,
          size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
        onTap: onTap,
        title: AutoSizeText(
          title,
        ),
        subtitle: AutoSizeText(
          subTitle,
        ),
        leading: Icon(
          icon,
          size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
      ),
    );
  }
}

class CustomRow extends StatelessWidget {
  final Day model;
  final Function onTap;
  CustomRow({this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 12.0, right: 12.0, top: 3.0, bottom: 3.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          child: Row(
            children: [
              AutoSizeText(
                model.dayName,
                style: TextStyle(
                    fontSize:
                        ScreenUtil().setSp(16, allowFontScalingSelf: true),
                    fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Container(),
              ),
              this.model.isDayOff == true
                  ? Container(
                      width: 100,
                      child: const Icon(
                        Icons.radio_button_checked,
                        color: Colors.orange,
                      ),
                    )
                  : Container(
                      width: 100,
                      child: const Icon(Icons.radio_button_unchecked)),
            ],
          ),
        ),
      ),
    );
  }
}
