import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/ProfileScreen.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class Header extends StatelessWidget {
  final String text;
  final onTab;
  final bool nav;
  Header({this.onTab, this.text, this.nav});
  @override
  Widget build(BuildContext context) {
    User _userData = Provider.of<UserData>(context, listen: true).user;
    return Stack(
      children: [
        ClipPath(
          clipper: DiagonalPathClipperOne(),
          child: Container(
            height: 135.h,
            color: Colors.orange,
            child: Stack(
              children: [
                ClipPath(
                  clipper: DiagonalPathClipperOne(),
                  child: Container(
                    height: 130.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            right: 10.w,
            top: 10.h,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 10.w,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.only(right: 5.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 30.h,
                                child: AutoSizeText(
                                  _userData.name,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 17,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Container(
                                height: 30.h,
                                child: AutoSizeText(
                                  _userData.userJob,
                                  maxLines: 1,
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(13,
                                          allowFontScalingSelf: true),
                                      fontWeight: FontWeight.w300),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(),
                              ));
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Container(
                            height: 75.h,
                            width: 70.w,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Color(0xffFF7E00),
                              ),
                              // image: DecorationImage(
                              //   image: headerImage,
                              //   fit: BoxFit.fill,
                              // ),
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(75.0),
                              child: CachedNetworkImage(
                                imageUrl:
                                    Provider.of<UserData>(context, listen: true)
                                        .user
                                        .userImage,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Platform.isIOS
                                    ? CupertinoActivityIndicator(
                                        radius: 20,
                                      )
                                    : CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                      ),
                                errorWidget: (context, url, error) =>
                                    Provider.of<UserData>(context, listen: true)
                                        .changedWidget,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
        Positioned(
          top: getkDeviceHeightFactor(context, 50),
          left: 40,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Color(0xffFF7E00),
              ),
              // image: DecorationImage(
              //   image: headerImage,
              //   fit: BoxFit.fill,
              // ),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black),
                  child: CachedNetworkImage(
                    imageUrl: Provider.of<CompanyData>(context, listen: true)
                        .com
                        .logo,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Platform.isIOS
                        ? CupertinoActivityIndicator(
                            radius: 20,
                          )
                        : CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.orange),
                          ),
                    errorWidget: (context, url, error) =>
                        Provider.of<UserData>(context, listen: true)
                            .changedWidget,
                  ),
                )),
          ),
          width: getkDeviceWidthFactor(context, 60),
          height: getkDeviceWidthFactor(context, 60),
        ),
        Positioned(
          top: 5,
          left: 5,
          child: Container(
            width: 50.w,
            height: 50.h,
            child: InkWell(
              onTap: () {
                nav == false
                    ? Navigator.pop(context)
                    : Scaffold.of(context).openDrawer();
              },
              child: Padding(
                padding: Platform.isIOS
                    ? EdgeInsets.only(top: 20)
                    : EdgeInsets.only(top: 0),
                child: Icon(
                  nav ? Icons.menu : Icons.keyboard_arrow_left,
                  size: nav ? 23 : 40,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
          width: 60.w,
          height: 60.h,
        ),
      ],
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final headerImage;
  final onPressed;
  final title;
  ProfileHeader({@required this.headerImage, this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: MyClipper(),
          child: Container(
            height: (MediaQuery.of(context).size.height) / 2.75.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
          ),
        ),
        ClipPath(
          clipper: MyClipper(),
          child: Container(
            height: (MediaQuery.of(context).size.height) / 2.8.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: InkWell(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1,
                              color: Color(0xffFF7E00),
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 60,
                            child: Container(
                              width: 200.w,
                              decoration: BoxDecoration(
                                // image: DecorationImage(
                                //   image: headerImage,
                                //   fit: BoxFit.fill,
                                // ),
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(75.0),
                                child: headerImage,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title != null
                        ? Column(
                            children: [
                              SizedBox(
                                height:
                                    (MediaQuery.of(context).size.height) / 70,
                              ),
                              Container(
                                height: 20,
                                child: AutoSizeText(
                                  title,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: ScreenUtil().setSp(17,
                                          allowFontScalingSelf: true),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : Container()
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HeaderBeforeLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: DiagonalPathClipperOne(),
          child: Container(
            height: 135.h,
            color: Colors.orange,
            child: Stack(
              children: [
                ClipPath(
                  clipper: DiagonalPathClipperOne(),
                  child: Container(
                    child: Container(
                      height: 130.h,
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            right: 10.w,
            top: 20.h,
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 20,
                        child: AutoSizeText(
                          "Chilango",
                          maxLines: 1,
                          style: TextStyle(color: Colors.orange, fontSize: 17),
                        ),
                      ),
                    ),
                    Container(
                      height: 70.h,
                      width: 70.w,
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
                  ],
                ),
              ],
            )),
      ],
    );
  }
}

class DiagonalPathClipperOne extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0.0, size.height - 50.0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0.0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class NewHeader extends StatelessWidget {
  final List<String> cachedUserData;

  NewHeader(this.cachedUserData);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: DiagonalPathClipperOne(),
          child: Container(
            height: getkDeviceHeightFactor(context, 135),
            color: Colors.orange,
            child: Stack(
              children: [
                ClipPath(
                  clipper: DiagonalPathClipperOne(),
                  child: Container(
                    child: Container(
                      height: getkDeviceHeightFactor(context, 130),
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            right: 10.w,
            top: 10.h,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 10.w,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AutoSizeText(
                              cachedUserData[0],
                              maxLines: 1,
                              style:
                                  TextStyle(color: Colors.orange, fontSize: 17),
                            ),
                            AutoSizeText(
                              cachedUserData[1],
                              maxLines: 1,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil()
                                      .setSp(15, allowFontScalingSelf: true),
                                  fontWeight: FontWeight.w300),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Container(
                            height: 75.h,
                            width: 70.w,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Color(0xffFF7E00),
                              ),
                              // image: DecorationImage(
                              //   image: headerImage,
                              //   fit: BoxFit.fill,
                              // ),
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(75.0),
                              child: CachedNetworkImage(
                                imageUrl: cachedUserData[2],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Platform.isIOS
                                    ? CupertinoActivityIndicator(
                                        radius: 20,
                                      )
                                    : CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                      ),
                                errorWidget: (context, url, error) =>
                                    Provider.of<UserData>(context, listen: true)
                                        .changedWidget,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
        Positioned(
          top: 50.h,
          left: 40.w,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Color(0xffFF7E00),
              ),
              // image: DecorationImage(
              //   image: headerImage,
              //   fit: BoxFit.fill,
              // ),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black),
                  child: CachedNetworkImage(
                    imageUrl: cachedUserData[4],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Platform.isIOS
                        ? CupertinoActivityIndicator(
                            radius: 20,
                          )
                        : CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.orange),
                          ),
                    errorWidget: (context, url, error) =>
                        Provider.of<UserData>(context, listen: true)
                            .changedWidget,
                  ),
                )),
          ),
          width: 60.w,
          height: 60.h,
        ),
//        Positioned(
//          top: getkDeviceHeightFactor(context, 45),
//          left: getkDeviceWidthFactor(context, 30),
//          child: ClipRRect(
//              borderRadius: BorderRadius.circular(40),
//              child: Container(
//                decoration: BoxDecoration(color: Colors.black),
//                padding: EdgeInsets.all(5),
//                child: Image.file(
//                  File(cachedUserData[4]),
//                  fit: BoxFit.cover,
//                ),
//              )),
//          width: getkDeviceWidthFactor(context, 60),
//          height: getkDeviceWidthFactor(context, 60),
//        ),
        Positioned(
          top: 5.h,
          left: 5.w,
          child: Container(
            width: 50.w,
            height: 50.h,
            child: InkWell(
              onTap: () {
                print("s");
                Scaffold.of(context).openDrawer();
              },
              child: Icon(
                Icons.menu,
                size: 23,
                color: Colors.orange,
              ),
            ),
          ),
          width: getkDeviceWidthFactor(context, 60),
          height: getkDeviceHeightFactor(context, 60),
        ),
      ],
    );
  }
}
