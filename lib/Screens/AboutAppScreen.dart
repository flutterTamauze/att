import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:animate_do/animate_do.dart';
import 'package:open_file/open_file.dart' as open_file;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'Notifications/Notifications.dart';
import 'SystemScreens/AppHelp.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String _filePath;
  bool _isLoading = false;
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
                                  decoration: BoxDecoration(
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
                                  decoration: BoxDecoration(
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
                                                  color: Color(0xffFF7E00),
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 60,
                                                child: Container(
                                                  width: 200.w,
                                                  decoration: BoxDecoration(
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
                                                        "resources/image.png"),
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
                                                            "شارك التطبيق",
                                                            maxLines: 1,
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                color: Color(
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
                                                          icon: Icon(
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
                                          title: "قيم التطبيق",
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
                                          title: 'للشكاوى و المقترحات',
                                          icon: Icons.email,
                                          link: 'mailto:info@tamauzeds.com',
                                        ),
                                        // MyListTile(
                                        //   rotated: true,
                                        //   title: 'دليل الأستخدام',
                                        //   icon: Icons.help,
                                        //   link: 'help',
                                        // ),
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
                          Icons.chevron_left,
                          color: Color(0xffF89A41),
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

  AboutUsCard({this.child});

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
  MyListTile({this.title, this.icon, this.link, this.rotated});

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
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Color(0xFF3b3c40),
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
                      color: Color(0xFF3b3c40),
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
  CircletTile({this.icon, this.link, this.iconColor});

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
          color: Color(0xffFF7E00),
        ),
      ),
    );
  }
}
