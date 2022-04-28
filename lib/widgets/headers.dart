import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUser.dart';
import 'package:qr_users/Screens/ProfileScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Shared/RoundBorderImage.dart';

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
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

// ignore: must_be_immutable
class Header extends StatelessWidget {
  final String text;
  final onTab;
  bool goUserMenu = false;
  bool goUserHomeFromMenu = false;
  final bool nav;
  Header(
      {this.onTab,
      this.text,
      this.nav,
      this.goUserMenu,
      this.goUserHomeFromMenu});
  @override
  Widget build(BuildContext context) {
    final User _userData = Provider.of<UserData>(context, listen: true).user;
    return Stack(
      children: [
        ClipPath(
          clipper: locator.locator<PermissionHan>().isEnglishLocale()
              ? DiagonalPathClipperOne()
              : DiagonalPathClipperTwo(),
          child: Container(
            height: 135.h,
            color: ColorManager.primary,
            child: Stack(
              children: [
                ClipPath(
                  clipper: locator.locator<PermissionHan>().isEnglishLocale()
                      ? DiagonalPathClipperOne()
                      : DiagonalPathClipperTwo(),
                  child: Container(
                    height: 130.h,
                    decoration: BoxDecoration(
                      color: ColorManager.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        !locator.locator<PermissionHan>().isEnglishLocale()
            ? Positioned(
                left: 10.w,
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
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen(),
                                          ));
                                    },
                                    child: Container(
                                      height: 30.h,
                                      child: AutoSizeText(
                                        _userData.name,
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: setResponsiveFontSize(17),
                                        ),
                                      ),
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
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: RoundBorderedImage(
                              radius: 25,
                              width: 70,
                              height: 75,
                              imageUrl:
                                  Provider.of<UserData>(context, listen: true)
                                      .user
                                      .userImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        left: 0,
                        top: 8.w,
                        child: GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Consumer<NotificationDataService>(
                            builder: (context, value, child) {
                              return Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xffFF7E00)
                                                .withOpacity(0.9),
                                          ),
                                          child: const Icon(
                                            Icons.notification_important,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  value.getUnSeenNotifications() == 0
                                      ? Container()
                                      : Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: AutoSizeText(
                                                value
                                                    .getUnSeenNotifications()
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        setResponsiveFontSize(
                                                            11)),
                                              )),
                                        )
                                ],
                              );
                            },
                          ),
                        ))
                  ],
                ))
            : Positioned(
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
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen(),
                                          ));
                                    },
                                    child: Container(
                                      height: 30.h,
                                      child: AutoSizeText(
                                        _userData.name,
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: setResponsiveFontSize(17),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30.h,
                                    child: AutoSizeText(
                                      _userData.userJob,
                                      textAlign: TextAlign.right,
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
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: RoundBorderedImage(
                              radius: 25,
                              width: 70,
                              height: 75,
                              imageUrl:
                                  Provider.of<UserData>(context, listen: true)
                                      .user
                                      .userImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        right: 0,
                        top: 8.w,
                        child: GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Consumer<NotificationDataService>(
                            builder: (context, value, child) {
                              return Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xffFF7E00)
                                                .withOpacity(0.9),
                                          ),
                                          child: const Icon(
                                            Icons.notification_important,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  value.getUnSeenNotifications() == 0
                                      ? Container()
                                      : Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: AutoSizeText(
                                                value
                                                    .getUnSeenNotifications()
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        setResponsiveFontSize(
                                                            11)),
                                              )),
                                        )
                                ],
                              );
                            },
                          ),
                        ))
                  ],
                )),
        if (!locator.locator<PermissionHan>().isEnglishLocale()) ...[
          Positioned(
            top: getkDeviceHeightFactor(context, 50),
            right: 40.w,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: ColorManager.primary,
                ),
                // image: DecorationImage(
                //   image: headerImage,
                //   fit: BoxFit.fill,
                // ),
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(MediaQuery.of(context).size.height),
                  child: Container(
                    decoration: BoxDecoration(color: ColorManager.accentColor),
                    child: CachedNetworkImage(
                      imageUrl: Provider.of<CompanyData>(context, listen: true)
                          .com
                          .logo,
                      fit: BoxFit.cover,
                      httpHeaders: {
                        "Authorization": "Bearer " +
                            Provider.of<UserData>(context, listen: false)
                                .user
                                .userToken
                      },
                      placeholder: (context, url) => Platform.isIOS
                          ? const CupertinoActivityIndicator(
                              radius: 20,
                            )
                          : const CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                      errorWidget: (context, url, error) =>
                          Provider.of<UserData>(context, listen: true)
                              .changedWidget,
                    ),
                  )),
            ),
            width: MediaQuery.of(context).size.height / 12,
            height: MediaQuery.of(context).size.height / 12,
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              width: 50.w,
              height: 50.h,
              child: InkWell(
                onTap: () {
                  nav == false
                      ? goUserHomeFromMenu
                          ? Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const NavScreenTwo(0),
                              ),
                              (Route<dynamic> route) => false)
                          : goUserMenu == false
                              ? Navigator.maybePop(context)
                              : Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => NormalUserMenu(),
                                  ),
                                  (Route<dynamic> route) => false)
                      : Scaffold.of(context).openDrawer();
                },
                child: Padding(
                  padding: Platform.isIOS
                      ? const EdgeInsets.only(top: 20)
                      : const EdgeInsets.only(top: 0),
                  child: Icon(
                    nav ? Icons.menu : Icons.keyboard_arrow_left,
                    size: nav ? 23.w : 40.w,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            width: 60.w,
            height: 60.h,
          ),
        ] else ...[
          Positioned(
            top: getkDeviceHeightFactor(context, 50),
            left: 40.w,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: ColorManager.primary,
                ),
                // image: DecorationImage(
                //   image: headerImage,
                //   fit: BoxFit.fill,
                // ),
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(MediaQuery.of(context).size.height),
                  child: Container(
                    decoration: BoxDecoration(color: ColorManager.accentColor),
                    child: CachedNetworkImage(
                      imageUrl: Provider.of<CompanyData>(context, listen: true)
                          .com
                          .logo,
                      fit: BoxFit.cover,
                      httpHeaders: {
                        "Authorization": "Bearer " +
                            Provider.of<UserData>(context, listen: false)
                                .user
                                .userToken
                      },
                      placeholder: (context, url) => Platform.isIOS
                          ? const CupertinoActivityIndicator(
                              radius: 20,
                            )
                          : const CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                      errorWidget: (context, url, error) =>
                          Provider.of<UserData>(context, listen: true)
                              .changedWidget,
                    ),
                  )),
            ),
            width: MediaQuery.of(context).size.height / 12,
            height: MediaQuery.of(context).size.height / 12,
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
                      ? goUserHomeFromMenu
                          ? Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const NavScreenTwo(0),
                              ),
                              (Route<dynamic> route) => false)
                          : goUserMenu == false
                              ? Navigator.maybePop(context)
                              : Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => NormalUserMenu(),
                                  ),
                                  (Route<dynamic> route) => false)
                      : Scaffold.of(context).openDrawer();
                },
                child: Padding(
                  padding: Platform.isIOS
                      ? const EdgeInsets.only(top: 20)
                      : const EdgeInsets.only(top: 0),
                  child: Icon(
                    nav ? Icons.menu : Icons.keyboard_arrow_left,
                    size: nav ? 23.w : 40.w,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            width: 60.w,
            height: 60.h,
          ),
        ]
      ],
    );
  }
}

class SuperAdminHeader extends StatelessWidget {
  final String text;

  const SuperAdminHeader({
    this.text,
  });
  @override
  Widget build(BuildContext context) {
    final User _userData = Provider.of<UserData>(context, listen: true).user;
    return Stack(
      children: [
        ClipPath(
          clipper: locator.locator<PermissionHan>().isEnglishLocale()
              ? DiagonalPathClipperOne()
              : DiagonalPathClipperTwo(),
          child: Container(
            height: 135.h,
            color: ColorManager.primary,
            child: Stack(
              children: [
                ClipPath(
                  clipper: locator.locator<PermissionHan>().isEnglishLocale()
                      ? DiagonalPathClipperOne()
                      : DiagonalPathClipperTwo(),
                  child: Container(
                    height: 130.h,
                    decoration: BoxDecoration(
                      color: ColorManager.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        !locator.locator<PermissionHan>().isEnglishLocale()
            ? Positioned(
                left: 10.w,
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
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen(),
                                          ));
                                    },
                                    child: Container(
                                      height: 30.h,
                                      child: AutoSizeText(
                                        _userData.name,
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: setResponsiveFontSize(17),
                                        ),
                                      ),
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
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: RoundBorderedImage(
                              radius: 25,
                              width: 70,
                              height: 75,
                              imageUrl:
                                  Provider.of<UserData>(context, listen: true)
                                      .user
                                      .userImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        left: 0,
                        top: 8.w,
                        child: GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Consumer<NotificationDataService>(
                            builder: (context, value, child) {
                              return Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xffFF7E00)
                                                .withOpacity(0.9),
                                          ),
                                          child: const Icon(
                                            Icons.notification_important,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  value.getUnSeenNotifications() == 0
                                      ? Container()
                                      : Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: AutoSizeText(
                                                value
                                                    .getUnSeenNotifications()
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        setResponsiveFontSize(
                                                            11)),
                                              )),
                                        )
                                ],
                              );
                            },
                          ),
                        ))
                  ],
                ))
            : Positioned(
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
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen(),
                                          ));
                                    },
                                    child: Container(
                                      height: 30.h,
                                      child: AutoSizeText(
                                        _userData.name,
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: setResponsiveFontSize(17),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30.h,
                                    child: AutoSizeText(
                                      _userData.userJob,
                                      textAlign: TextAlign.right,
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
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: RoundBorderedImage(
                              radius: 25,
                              width: 70,
                              height: 75,
                              imageUrl:
                                  Provider.of<UserData>(context, listen: true)
                                      .user
                                      .userImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        right: 0,
                        top: 8.w,
                        child: GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Consumer<NotificationDataService>(
                            builder: (context, value, child) {
                              return Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xffFF7E00)
                                                .withOpacity(0.9),
                                          ),
                                          child: const Icon(
                                            Icons.notification_important,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  value.getUnSeenNotifications() == 0
                                      ? Container()
                                      : Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: AutoSizeText(
                                                value
                                                    .getUnSeenNotifications()
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        setResponsiveFontSize(
                                                            11)),
                                              )),
                                        ),
                                ],
                              );
                            },
                          ),
                        ))
                  ],
                )),
        if (!locator.locator<PermissionHan>().isEnglishLocale()) ...[
          Positioned(
            top: getkDeviceHeightFactor(context, 50),
            right: 40.w,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: ColorManager.primary,
                ),
                // image: DecorationImage(
                //   image: headerImage,
                //   fit: BoxFit.fill,
                // ),
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(MediaQuery.of(context).size.height),
                  child: Container(
                    decoration: BoxDecoration(color: ColorManager.accentColor),
                    child: CachedNetworkImage(
                      imageUrl: Provider.of<CompanyData>(context, listen: true)
                          .com
                          .logo,
                      fit: BoxFit.cover,
                      httpHeaders: {
                        "Authorization": "Bearer " +
                            Provider.of<UserData>(context, listen: false)
                                .user
                                .userToken
                      },
                      placeholder: (context, url) => Platform.isIOS
                          ? const CupertinoActivityIndicator(
                              radius: 20,
                            )
                          : const CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                      errorWidget: (context, url, error) =>
                          Provider.of<UserData>(context, listen: true)
                              .changedWidget,
                    ),
                  )),
            ),
            width: MediaQuery.of(context).size.height / 12,
            height: MediaQuery.of(context).size.height / 12,
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              width: 50.w,
              height: 50.h,
              child: InkWell(
                child: Padding(
                  padding: Platform.isIOS
                      ? const EdgeInsets.only(top: 20)
                      : const EdgeInsets.only(top: 0),
                ),
              ),
            ),
            width: 60.w,
            height: 60.h,
          ),
        ] else ...[
          Positioned(
            top: getkDeviceHeightFactor(context, 50),
            left: 40.w,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: ColorManager.primary,
                ),
                // image: DecorationImage(
                //   image: headerImage,
                //   fit: BoxFit.fill,
                // ),
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(MediaQuery.of(context).size.height),
                  child: Container(
                    decoration: BoxDecoration(color: ColorManager.accentColor),
                    child: CachedNetworkImage(
                      imageUrl: Provider.of<CompanyData>(context, listen: true)
                          .com
                          .logo,
                      fit: BoxFit.cover,
                      httpHeaders: {
                        "Authorization": "Bearer " +
                            Provider.of<UserData>(context, listen: false)
                                .user
                                .userToken
                      },
                      placeholder: (context, url) => Platform.isIOS
                          ? const CupertinoActivityIndicator(
                              radius: 20,
                            )
                          : const CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                      errorWidget: (context, url, error) =>
                          Provider.of<UserData>(context, listen: true)
                              .changedWidget,
                    ),
                  )),
            ),
            width: MediaQuery.of(context).size.height / 12,
            height: MediaQuery.of(context).size.height / 12,
          ),
        ]
      ],
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final headerImage;
  final onPressed;
  final title;
  const ProfileHeader({@required this.headerImage, this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: MyClipper(),
          child: Container(
            height: (MediaQuery.of(context).size.height) / 2.75.h,
            width: double.infinity,
            decoration: const BoxDecoration(
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
              color: ColorManager.accentColor,
            ),
            child: InkWell(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 1,
                                  color: ColorManager.accentColor,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 60,
                                child: Container(
                                  width: 200.w,
                                  decoration: const BoxDecoration(
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
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 5.w),
                              child: AutoSizeText(
                                  Provider.of<UserData>(context, listen: false)
                                      .user
                                      .name,
                                  style: TextStyle(
                                    color: ColorManager.primary,
                                    fontWeight: FontWeight.bold,
                                  )),
                            )
                          ],
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
                                      fontSize: ScreenUtil().setSp(16,
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
                        color: ColorManager.accentColor,
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
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: setResponsiveFontSize(17)),
                        ),
                      ),
                    ),
                    Container(
                      height: 70.h,
                      width: 70.w,
                      decoration: const BoxDecoration(
                          // border: Border.all(
                          //   width: 1,
                          //   color: Color(0xffFF7E00),
                          // ),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(appLogo),
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

  const NewHeader(this.cachedUserData);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: locator.locator<PermissionHan>().isEnglishLocale()
              ? DiagonalPathClipperOne()
              : DiagonalPathClipperTwo(),
          child: Container(
            height: getkDeviceHeightFactor(context, 135),
            color: ColorManager.primary,
            child: Stack(
              children: [
                ClipPath(
                  clipper: locator.locator<PermissionHan>().isEnglishLocale()
                      ? DiagonalPathClipperOne()
                      : DiagonalPathClipperTwo(),
                  child: Container(
                    child: Container(
                      height: getkDeviceHeightFactor(context, 130),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        !locator.locator<PermissionHan>().isEnglishLocale()
            ? Positioned(
                left: 10.w,
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
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen(),
                                          ));
                                    },
                                    child: Container(
                                      height: 30.h,
                                      child: AutoSizeText(
                                        cachedUserData[0],
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: setResponsiveFontSize(17),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30.h,
                                    child: AutoSizeText(
                                      cachedUserData[1],
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
                              Scaffold.of(context).openEndDrawer();
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
                                    color: ColorManager.primary,
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
                                    httpHeaders: {
                                      "Authorization": "Bearer " +
                                          Provider.of<UserData>(context,
                                                  listen: false)
                                              .user
                                              .userToken
                                    },
                                    imageUrl: cachedUserData[2],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Platform
                                            .isIOS
                                        ? const CupertinoActivityIndicator(
                                            radius: 20,
                                          )
                                        : const CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.orange),
                                          ),
                                    errorWidget: (context, url, error) =>
                                        Provider.of<UserData>(context,
                                                listen: true)
                                            .changedWidget,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        left: 0,
                        top: 8.w,
                        child: GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Consumer<NotificationDataService>(
                            builder: (context, value, child) {
                              return Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xffFF7E00)
                                                .withOpacity(0.9),
                                          ),
                                          child: const Icon(
                                            Icons.notification_important,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  value.getUnSeenNotifications() == 0
                                      ? Container()
                                      : Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: AutoSizeText(
                                                value
                                                    .getUnSeenNotifications()
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        setResponsiveFontSize(
                                                            11)),
                                              )),
                                        )
                                ],
                              );
                            },
                          ),
                        ))
                  ],
                ))
            : Positioned(
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
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen(),
                                          ));
                                    },
                                    child: Container(
                                      height: 30.h,
                                      child: AutoSizeText(
                                        cachedUserData[0],
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: setResponsiveFontSize(17),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30.h,
                                    child: AutoSizeText(
                                      cachedUserData[1],
                                      textAlign: TextAlign.right,
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
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            child: Container(
                              height: 75.h,
                              width: 70.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: ColorManager.primary,
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
                                  httpHeaders: {
                                    "Authorization": "Bearer " +
                                        Provider.of<UserData>(context,
                                                listen: false)
                                            .user
                                            .userToken
                                  },
                                  imageUrl: cachedUserData[2],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Platform.isIOS
                                      ? const CupertinoActivityIndicator(
                                          radius: 20,
                                        )
                                      : const CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.orange),
                                        ),
                                  errorWidget: (context, url, error) =>
                                      Provider.of<UserData>(context,
                                              listen: true)
                                          .changedWidget,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        right: 0,
                        top: 8.w,
                        child: GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Consumer<NotificationDataService>(
                            builder: (context, value, child) {
                              return Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xffFF7E00)
                                                .withOpacity(0.9),
                                          ),
                                          child: const Icon(
                                            Icons.notification_important,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  value.getUnSeenNotifications() == 0
                                      ? Container()
                                      : Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: AutoSizeText(
                                                value
                                                    .getUnSeenNotifications()
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        setResponsiveFontSize(
                                                            11)),
                                              )),
                                        )
                                ],
                              );
                            },
                          ),
                        ))
                  ],
                )),
        if (!locator.locator<PermissionHan>().isEnglishLocale()) ...[
          Positioned(
            top: getkDeviceHeightFactor(context, 50),
            right: 40.w,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Container(
                height: 75.h,
                width: 70.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: ColorManager.primary,
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
                    httpHeaders: {
                      "Authorization": "Bearer " +
                          Provider.of<UserData>(context, listen: false)
                              .user
                              .userToken
                    },
                    imageUrl: cachedUserData[4],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Platform.isIOS
                        ? const CupertinoActivityIndicator(
                            radius: 20,
                          )
                        : const CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                    errorWidget: (context, url, error) =>
                        Provider.of<UserData>(context, listen: true)
                            .changedWidget,
                  ),
                ),
              ),
            ),
            width: MediaQuery.of(context).size.height / 12,
            height: MediaQuery.of(context).size.height / 12,
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              width: 50.w,
              height: 50.h,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: Platform.isIOS
                      ? const EdgeInsets.only(top: 20)
                      : const EdgeInsets.only(top: 0),
                ),
              ),
            ),
            width: 60.w,
            height: 60.h,
          ),
        ] else ...[
          Positioned(
            top: getkDeviceHeightFactor(context, 50),
            left: 40.w,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Container(
                height: 75.h,
                width: 70.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: ColorManager.primary,
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
                    httpHeaders: {
                      "Authorization": "Bearer " +
                          Provider.of<UserData>(context, listen: false)
                              .user
                              .userToken
                    },
                    imageUrl: cachedUserData[4],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Platform.isIOS
                        ? const CupertinoActivityIndicator(
                            radius: 20,
                          )
                        : const CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                    errorWidget: (context, url, error) =>
                        Provider.of<UserData>(context, listen: true)
                            .changedWidget,
                  ),
                ),
              ),
            ),
            width: MediaQuery.of(context).size.height / 12,
            height: MediaQuery.of(context).size.height / 12,
          ),
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              width: 50.w,
              height: 50.h,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: Platform.isIOS
                      ? const EdgeInsets.only(top: 20)
                      : const EdgeInsets.only(top: 0),
                ),
              ),
            ),
            width: 60.w,
            height: 60.h,
          ),
        ]
      ],
    );
  }
}
