import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/AboutApp/AboutAppScreen.dart';
import 'package:qr_users/Screens/AboutCompany/AboutCompany.dart';
import 'package:qr_users/Screens/AboutUsScreen.dart';
import 'package:qr_users/Screens/AdminPanel/adminPanel.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUser.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_admin.dart';
import 'package:qr_users/Screens/intro.dart';
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';

import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';

import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Core/constants.dart';

class DrawerI extends StatelessWidget {
  var connectivityResult;
  checkNetwork() async {
    connectivityResult = await (Connectivity().checkConnectivity());
  }

  @override
  Widget build(BuildContext context) {
    checkNetwork();
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    final int userType =
        Provider.of<UserData>(context, listen: true).user.userType;
    final userData = Provider.of<UserData>(context, listen: false);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width / 1.3,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 17.h,
                ),
                Card(
                  color: Colors.black,
                  elevation: 1,
                  child: Center(
                    child: InkWell(
                      onTap: () =>
                          launch("https://chilangov3.tamauzeds.com/#/"),
                      child: Container(
                        height: 90.h,
                        width: 90.w,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(appLogo),
                            )),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 2,
                  thickness: 0.5,
                  color: Colors.white.withOpacity(0.3),
                  indent: 20,
                  endIndent: 20,
                ),
                SizedBox(
                  height: 25.h,
                ),
                Column(
                  children: [
                    MenuItem(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NormalUserMenu()));
                        },
                        title: getTranslated(context, "حسابى"),
                        icon: Icons.person),
                    Divider(
                      height: 31.h,
                      thickness: 0.5,
                      color: Colors.white.withOpacity(0.3),
                      indent: 50,
                      endIndent: 50,
                    ),
                    if (Provider.of<UserData>(context, listen: false)
                            .isSuperAdmin ||
                        (Provider.of<UserData>(context, listen: false)
                                .isTdsAdmin ||
                            Provider.of<UserData>(context, listen: false)
                                .isTechnicalSupport)) ...[
                      MenuItem(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SuperAdminScreen(),
                              ));
                        },
                        title: getTranslated(context, "شركاتى"),
                        icon: FontAwesomeIcons.building,
                      ),
                      Divider(
                        height: 31.h,
                        thickness: 0.5,
                        color: Colors.white.withOpacity(0.3),
                        indent: 50,
                        endIndent: 50,
                      ),
                    ],
                    userType == 4 || userType == 3
                        ? Column(
                            children: [
                              MenuItem(
                                  onTap: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminPanel(),
                                        ));
                                  },
                                  title: getTranslated(context, "لوحة التحكم"),
                                  icon: Icons.admin_panel_settings),
                              Divider(
                                height: 31.h,
                                thickness: 0.5,
                                color: Colors.white.withOpacity(0.3),
                                indent: 50,
                                endIndent: 50,
                              )
                            ],
                          )
                        : Container(),
                    userType == 4
                        ? Column(
                            children: [
                              MenuItem(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          CompanyProfileScreen()));
                                },
                                title:
                                    "${getTranslated(context, "عن")} ${Provider.of<CompanyData>(context, listen: true).com.nameAr}",
                                icon: Icons.apartment,
                              ),
                              Divider(
                                height: 31.h,
                                thickness: 0.5,
                                color: Colors.white.withOpacity(0.3),
                                indent: 50,
                                endIndent: 50,
                              )
                            ],
                          )
                        : Container(),
                    MenuItem(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ContactUsScreen()));
                      },
                      title: getTranslated(context, "عن التطبيق"),
                      icon: Icons.info_outlined,
                    ),
                    Divider(
                      height: 30.h,
                      thickness: 0.5,
                      color: Colors.white.withOpacity(0.3),
                      indent: 50,
                      endIndent: 50,
                    ),
                    MenuItem(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PageIntro(
                                  userType: userType == 0 ? 0 : 1,
                                )));
                      },
                      title: getTranslated(context, "المعرض"),
                      icon: Icons.image,
                    ),
                    Divider(
                      height: 30.h,
                      thickness: 0.5,
                      color: Colors.white.withOpacity(0.3),
                      indent: 50,
                      endIndent: 50,
                    ),
                    MenuItem(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AboutUsScreen()));
                      },
                      title: getTranslated(context, "من نحن"),
                      icon: FontAwesomeIcons.globe,
                    ),
                    Divider(
                      height: 30.h,
                      thickness: 0.5,
                      color: Colors.white.withOpacity(0.3),
                      indent: 50,
                      endIndent: 50,
                    ),
                    MenuItem(
                      onTap: () {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return RoundedAlert(
                                  onPressed: () async {
                                    if (userType == 4 ||
                                        userType == 3 ||
                                        userData.isSuperAdmin) {
                                      //subscribe admin channel
                                      bool isError = false;
                                      await _firebaseMessaging
                                          .getToken()
                                          .catchError((e) {
                                        log(e);
                                        isError = true;
                                      });
                                      if (isError == false) {
                                        debugPrint("topic name : ");
                                        log("attend${Provider.of<CompanyData>(context, listen: false).com.id}");
                                        await _firebaseMessaging
                                            .unsubscribeFromTopic(
                                                "attend${Provider.of<CompanyData>(context, listen: false).com.id}");
                                      }
                                    }
                                    Provider.of<UserData>(context,
                                            listen: false)
                                        .logout();
                                    Provider.of<MemberData>(context,
                                            listen: false)
                                        .membersList = [];
                                    Provider.of<SiteData>(context,
                                            listen: false)
                                        .sitesList = [];
                                    Provider.of<ShiftsData>(context,
                                            listen: false)
                                        .shiftsList = [];
                                    Provider.of<SiteShiftsData>(context,
                                            listen: false)
                                        .shifts = [];

                                    // await Phoenix.rebirth(context);
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()),
                                        (Route<dynamic> route) => false);
                                  },
                                  title: getTranslated(context, "تسجيل خروج"),
                                  content: getTranslated(
                                      context, "هل تريد تسجيل الخروج؟"));
                            });
                      },
                      title: getTranslated(context, "تسجيل خروج"),
                      icon: Icons.logout,
                    ),
                  ],
                ),
              ],
            ),
            AMHPoweredWidght(),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;

  const MenuItem({Key key, this.icon, this.title, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            //color: Colors.orange,
            child: Padding(
              padding: const EdgeInsets.only(right: 30, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    icon,
                    color: Colors.orange,
                    size: 30,
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: SizedBox(
                        child: Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: AutoSizeText(
                            title,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(15, allowFontScalingSelf: true),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AMHPoweredWidght extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black,
          child: ClipPath(
            clipper: PoweredByClipper(),
            child: Container(
              height: 60.h,
              color: Colors.orange,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: PoweredByClipper(),
                      child: Container(
                        child: Container(
                          height: 55.h,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            launch("https://tamauzeds.com/");
          },
          child: Container(
            height: 120.h,
            color: Colors.black,
            width: 150.w,
            child: Container(
                height: 100.h,
                child: Image.asset(
                  'resources/TDSlogo.png',
                  fit: BoxFit.fitHeight,
                )),
          ),
        )
      ],
    );
  }
}

class PoweredByClipper extends CustomClipper<Path> {
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }

  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(size.width, -0.1)
      ..lineTo(size.width, size.height)
      ..lineTo(0.0, size.height - 50.0)
      ..close();
    return path;
  }
}
