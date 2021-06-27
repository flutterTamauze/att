import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(builder: (context, userData, child) {
      return SafeArea(
        child: Scaffold(
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
                              height:
                                  (MediaQuery.of(context).size.height) / 2.75,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          ClipPath(
                            clipper: MyClipper(),
                            child: Container(
                              height:
                                  (MediaQuery.of(context).size.height) / 2.8,
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
                                              width: 2.w,
                                              color: Color(0xffFF7E00),
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black,
                                            radius: 60,
                                            child: Container(
                                              width: 200.w,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                // image: DecorationImage(
                                                //   image: headerImage,
                                                //   fit: BoxFit.fill,
                                                // ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(75.0),
                                                child: Image.asset(
                                                    "resources/TDSlogo.png"),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Container(
                                          height: 20,
                                          child: AutoSizeText(
                                            "TDS",
                                            maxLines: 1,
                                            style: TextStyle(
                                                letterSpacing: 2,
                                                fontWeight: FontWeight.bold,
                                                fontSize: ScreenUtil().setSp(17,
                                                    allowFontScalingSelf: true),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        // AutoSizeText('AMH Technology',
                                        //     textAlign: TextAlign.center,
                                        //     style: TextStyle(
                                        //       fontWeight: FontWeight.bold,
                                        //       color: Colors.orange,
                                        //       fontSize: 18,
                                        //     )),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        MyListTile(
                                          title: 'المقر الرئيسى',
                                          icon: Icons.location_on,
                                          link:
                                              'https://www.google.com/maps/place/Raven+%D8%B3%D9%8A%D8%AA%D9%8A+%D8%B3%D9%86%D8%AA%D8%B1+%D9%85%D9%83%D8%B1%D9%85+%D8%B9%D8%A8%D9%8A%D8%AF%E2%80%AD/@30.0683442,31.3425179,17z/data=!3m1!4b1!4m5!3m4!1s0x14583f50339ed26f:0x62296d6fcc1dc44!8m2!3d30.0683286!4d31.3445994',
                                        ),
                                        SizedBox(
                                          height: 10.0.h,
                                        ),
                                        InkWell(
                                          onTap: () {},
                                          child: MyListTile(
                                            title: 'رقم التليفون',
                                            icon: Icons.phone,

                                            // link: 'tel:+0223521011',
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0.h,
                                        ),
                                        MyListTile(
                                          title: 'البريد الإلكترونى',
                                          icon: Icons.email,
                                          link: 'mailto:info@tamauzeds.com',
                                        ),
                                        SizedBox(
                                          height: 10.0.h,
                                        ),
                                        MyListTile(
                                          title: "الموقع الإلكترونى",
                                          icon: FontAwesomeIcons.globe,
                                          link: 'https://tamauzeds.com/',
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircletTile(
                                            link:
                                                'https://www.facebook.com/TDS-103104271938358',
                                            icon: Typicons.social_facebook,
                                          ),
                                          CircletTile(
                                            link:
                                                'https://twitter.com/TDS39064875',
                                            icon: Typicons.social_twitter,
                                          ),
                                          CircletTile(
                                            link:
                                                'https://www.instagram.com/socialtds24/',
                                            icon: Typicons.social_instagram,
                                          ),
                                          CircletTile(
                                            link:
                                                'https://www.youtube.com/channel/UCjcZRlnLQxzMw9iCAyVIQRA',
                                            icon: Typicons.social_youtube,
                                          ),
                                        ]),
                                  ],
                                ),
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
                      size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
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
  MyListTile({this.title, this.icon, this.link});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      color: Colors.white,
      child: ListTile(
        onTap: () {
          title == "رقم التليفون"
              ? buildShowModalBottomSheet(context)
              : title == "المقر الرئيسى"
                  ? showModalBottomSheet<dynamic>(
                      context: context,
                      isScrollControlled: false,
                      builder: (context) => Container(
                            padding: EdgeInsets.all(10),
                            height: 80.h,
                            color: Colors.black,
                            child: InkWell(
                              onTap: () => launch(link),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red[700],
                                  ),
                                  Container(
                                    width: 340.w,
                                    child: Container(
                                      height: 30,
                                      child: AutoSizeText(
                                        "سيتى سنتر ، 3 مكرم عبيد ، مدينة نصر ، الدور السادس ، مكتب 604، محافظة القاهرة",
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.orange[800],
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                            height: 2,
                                            fontSize: 14),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                  : launch(link);
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 6,
                child: Container(
                  height: 20,
                  child: AutoSizeText(title,
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
                  transform: Matrix4.rotationY(math.pi),
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

  Future buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: false,
        builder: (context) => Container(
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              height: 90.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      launch("tel:0223521011");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.call,
                          color: Colors.green[700],
                        ),
                        Container(
                          height: 20,
                          child: AutoSizeText(
                            "0223521011",
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w700,
                                fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  InkWell(
                    onTap: () {
                      launch("tel:0223521010");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.call,
                          color: Colors.green[700],
                        ),
                        Container(
                          height: 20,
                          child: AutoSizeText(
                            "0223521010",
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w700,
                                fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
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
