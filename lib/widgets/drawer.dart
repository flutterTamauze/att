import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:qr_users/Screens/AboutAppScreen.dart';
import 'package:qr_users/Screens/AboutCompany.dart';
import 'package:qr_users/Screens/AboutUsScreen.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUser.dart';
import 'package:qr_users/Screens/intro.dart';
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                Platform.isIOS
                    ? Container(
                        height: 40.h,
                      )
                    : Container(),
                Card(
                  color: Colors.black,
                  elevation: 1,
                  child: Center(
                    child: Container(
                      height: 100.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Color(0xffFF7E00),
                          ),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage("resources/image.png"),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Container(
                    height: 20,
                    child: AutoSizeText(
                      "Chilango",
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize:
                            ScreenUtil().setSp(20, allowFontScalingSelf: true),
                      ),
                    ),
                  ),
                ),
                SizedBox(
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
                // MenuItem(
                //   onTap: () {
                //     Navigator.of(context).pushAndRemoveUntil(
                //         MaterialPageRoute(builder: (context) => HomePage()),
                //         (Route<dynamic> route) => false);
                //   },
                //   title: "الرئيسية",
                //   icon: Icons.logout,
                // ),
                // Divider(
                //   height: 30,
                //   thickness: 0.5,
                //   color: Colors.white.withOpacity(0.3),
                //   indent: 50,
                //   endIndent: 50,
                // ),
                ///---------------About Com-------------///
                Provider.of<UserData>(context, listen: true).user.userType != 4
                    ? MenuItem(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NormalUserMenu()));
                        },
                        title: "حسابى",
                        icon: Icons.person)
                    : Container(),
                Provider.of<UserData>(context, listen: true).user.userType != 4
                    ? Divider(
                        height: 30.h,
                        thickness: 0.5,
                        color: Colors.white.withOpacity(0.3),
                        indent: 50,
                        endIndent: 50,
                      )
                    : Container(),
                Provider.of<UserData>(context, listen: true).user.userType == 4
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
                                "عن ${Provider.of<CompanyData>(context, listen: true).com.nameAr}",
                            icon: Icons.apartment,
                          ),
                          Divider(
                            height: 30.h,
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
                  title: "عن التطبيق",
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
                              userType: Provider.of<UserData>(context)
                                          .user
                                          .userType ==
                                      0
                                  ? 0
                                  : 1,
                            )));
                  },
                  title: "المعرض",
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
                  title: "من نحن",
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
                              onPressed: () {
                                Provider.of<UserData>(context, listen: false)
                                    .logout();
                                Provider.of<MemberData>(context, listen: false)
                                    .membersList = [];
                                Provider.of<SiteData>(context, listen: false)
                                    .sitesList = [];
                                Provider.of<ShiftsData>(context, listen: false)
                                    .shiftsList = [];
                                Provider.of<ShiftsData>(context, listen: false)
                                    .shiftsBySite = [];

                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
                                    (Route<dynamic> route) => false);
                              },
                              title: 'تسجيل خروج',
                              content: "هل تريد تسجيل الخروج ؟");
                        });
                  },
                  title: "تسجيل خروج",
                  icon: Icons.logout,
                ),
                // Divider(
                //   height: 30,
                //   thickness: 0.5,
                //   color: Colors.white.withOpacity(0.3),
                //   indent: 50,
                //   endIndent: 50,
                // ),
                // MenuItem(
                //   onTap: () {
                //     SystemNavigator.pop();
                //   },
                //   title: "خروج من التطبيق",
                //   icon: Icons.exit_to_app,
                // )
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
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: SizedBox(
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: AutoSizeText(
                            title,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  Icon(
                    icon,
                    color: Colors.orange,
                    size: 30,
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
                          decoration: BoxDecoration(
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
            launch("http://amhtechnology.com/");
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
