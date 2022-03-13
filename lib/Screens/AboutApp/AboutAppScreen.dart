import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Notifications/Notifications.dart';
import '../SystemScreens/AppHelp.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String progress;
  Dio dio;
  @override
  void initState() {
    dio = Dio();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Consumer<UserData>(builder: (context, userData, child) {
      return SafeArea(
        child: Scaffold(
            endDrawer: NotificationItem(),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipPath(
                                clipper: MyClipper(),
                                child: Container(
                                  height: (MediaQuery.of(context).size.height) /
                                      2.75,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                              ClipPath(
                                clipper: MyClipper(),
                                child: Container(
                                  height: (MediaQuery.of(context).size.height) /
                                      2.8,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  width: 1.w,
                                                  color:
                                                      const Color(0xffFF7E00),
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 60,
                                                child: Container(
                                                  width: 200.w,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.black,
                                                    // image: DecorationImage(
                                                    //   image: headerImage,
                                                    //   fit: BoxFit.fill,
                                                    // ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            75.0),
                                                    child: Image.asset(
                                                        "resources/Chilangu.png"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Container(
                                              height: 20,
                                              child: AutoSizeText(
                                                "Chilango",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: ScreenUtil().setSp(
                                                        20,
                                                        allowFontScalingSelf:
                                                            true),
                                                    color: Colors.orange),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        AboutUsCard(
                                          child: ListTile(
                                            onTap: () {
                                              Share.share(
                                                  'https://play.google.com/store/apps/details?id=com.tds.chilango');
                                            },
                                            title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Expanded(
                                                      flex: 6,
                                                      child: Container(
                                                        height: 20,
                                                        child: AutoSizeText(
                                                            getTranslated(
                                                                context,
                                                                "شارك التطبيق"),
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: const Color(
                                                                    0xFF3b3c40),
                                                                fontSize: ScreenUtil()
                                                                    .setSp(16,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      )),
                                                  SizedBox(
                                                    width: 5.w,
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Transform(
                                                        transform:
                                                            Matrix4.rotationY(
                                                                math.pi),
                                                        alignment:
                                                            Alignment.center,
                                                        child: IconButton(
                                                          onPressed: () {},
                                                          icon: const Icon(
                                                            Icons.share,
                                                            color: Color(
                                                                0xFF3b3c40),
                                                          ),
                                                        ),
                                                      ))
                                                ]),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0.h,
                                        ),
                                        MyListTile(
                                          title: getTranslated(
                                              context, "قيم التطبيق"),
                                          rotated: false,
                                          icon: FontAwesomeIcons.googlePlay,
                                          link:
                                              'https://play.google.com/store/apps/details?id=com.tds.chilango',
                                        ),
                                        SizedBox(
                                          height: 10.0.h,
                                        ),
                                        MyListTile(
                                          rotated: true,
                                          title: getTranslated(
                                              context, 'للشكاوى و المقترحات'),
                                          icon: Icons.email,
                                          link: 'mailto:chilango@tamauzeds.com',
                                        ),
                                        MyListTile(
                                          rotated: true,
                                          title: getTranslated(
                                              context, 'دليل الأستخدام'),
                                          icon: Icons.info,
                                          link: 'help',
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 200.h,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 5.0.w,
                  top: 5.0.h,
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    color: Colors.black,
                    child: IconButton(
                        icon: Icon(
                          locator.locator<PermissionHan>().isEnglishLocale()
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                          color: const Color(0xffF89A41),
                          size: ScreenUtil()
                              .setSp(40, allowFontScalingSelf: true),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ),
              ],
            )),
      );
    });
  }
}

class AboutUsCard extends StatelessWidget {
  final Widget child;

  const AboutUsCard({this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        color: Colors.white,
        child: child);
  }
}

class MyListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String link;
  final bool rotated;
  const MyListTile({this.title, this.icon, this.link, this.rotated});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      color: Colors.white,
      child: ListTile(
        onTap: () {
          if (link == "help") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppHelpPage(),
                ));
          } else
            launch(link);
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 6,
                child: Container(
                  height: 20,
                  child: AutoSizeText(title,
                      maxLines: 1,
                      style: TextStyle(
                          color: const Color(0xFF3b3c40),
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          fontWeight: FontWeight.bold)),
                )),
            SizedBox(
              width: 5.w,
            ),
            Expanded(
                flex: 1,
                child: Transform(
                  transform: rotated
                      ? Matrix4.rotationY(math.pi)
                      : Matrix4.rotationX(0),
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      icon,
                      color: const Color(0xFF3b3c40),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class CircletTile extends StatelessWidget {
  final IconData icon;
  final String link;
  final iconColor;
  const CircletTile({this.icon, this.link, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: IconButton(
        onPressed: () {
          launch(link);
        },
        icon: Icon(
          icon,
          color: const Color(0xffFF7E00),
        ),
      ),
    );
  }
}
