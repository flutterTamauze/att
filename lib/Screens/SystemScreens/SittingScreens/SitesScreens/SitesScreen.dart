import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/AddSite.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/SelectOnMapScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/ShowMylocation.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/ShiftsData.dart';

import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/headers.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

import 'dart:ui' as ui;

import 'package:qr_users/widgets/roundedButton.dart';

class SitesScreen extends StatefulWidget {
  @override
  _SitesScreenState createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<SiteData>(context, listen: false).pageIndex = 0;
    Provider.of<SiteData>(context, listen: false).keepRetriving = true;
    getData();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        log("reached end of list");

        var userProvider = Provider.of<UserData>(context, listen: false);
        var comProvier = Provider.of<CompanyData>(context, listen: false);
        if (Provider.of<SiteData>(context, listen: false).keepRetriving) {
          await Provider.of<SiteData>(context, listen: false)
              .getSitesByCompanyId(
            comProvier.com.id,
            userProvider.user.userToken,
            context,
          );
        }

        // if (Provider.of<MemberData>(context, listen: false).keepRetriving) {
        //   print("entered");

        //   await Provider.of<MemberData>(context, listen: false)
        //       .getAllCompanyMember(
        //           Provider.of<SiteData>(context, listen: false)
        //               .dropDownSitesList[siteIndex]
        //               .id,
        //           comProvier.com.id,
        //           userProvider.user.userToken,
        //           context);
      }
    });
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var companyProvider = Provider.of<CompanyData>(context, listen: false);
    // monitor network fetch
    print("refresh");
    // if failed,use refreshFailed()
    await Provider.of<SiteData>(context, listen: false).getSitesByCompanyId(
      companyProvider.com.id,
      userProvider.user.userToken,
      context,
    );
  }

  final ScrollController _scrollController = ScrollController();
  getData() async {
    var userProvider = Provider.of<UserData>(context);
    var companyProvider = Provider.of<CompanyData>(context, listen: false);

    await Provider.of<SiteData>(context, listen: false).getSitesByCompanyId(
      companyProvider.com.id,
      userProvider.user.userToken,
      context,
    );

    // await Provider.of<ShiftsData>(context, listen: false)
    //     .getShifts(companyProvider.com.id, userProvider.user.userToken, context,
    //         userProvider.user.userType, userProvider.user.userSiteId)
    //     .then((value) async {
    //   print("got Shifts");
    // });
  }

  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return Consumer<SiteData>(builder: (context, siteData, child) {
      return WillPopScope(
          onWillPop: onWillPop,
          child: Scaffold(
              endDrawer: NotificationItem(),
              backgroundColor: Colors.white,
              body: Container(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Header(
                            nav: false,
                            goUserHomeFromMenu: false,
                            goUserMenu: false,
                          ),
                          Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: SmallDirectoriesHeader(
                                Lottie.asset("resources/locaitonss.json",
                                    repeat: false),
                                "دليل المواقع"),
                          ),

                          ///List OF SITES

                          Expanded(
                            child: FutureBuilder(
                                future: siteData.futureListener,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.connectionState ==
                                              ConnectionState.waiting &&
                                          siteData.sitesList.length == 0 &&
                                          Provider.of<SiteData>(context)
                                              .keepRetriving) {
                                    return Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: Platform.isIOS
                                            ? CupertinoActivityIndicator(
                                                radius: 20,
                                              )
                                            : CircularProgressIndicator(
                                                backgroundColor: Colors.white,
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                        Color>(Colors.orange),
                                              ),
                                      ),
                                    );
                                  }
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:

                                    case ConnectionState.done:
                                      if (Provider.of<SiteData>(context)
                                              .pageIndex !=
                                          1) {
                                        Timer(
                                          Duration(milliseconds: 1),
                                          () => _scrollController.jumpTo(
                                              _scrollController.position
                                                      .maxScrollExtent -
                                                  10),
                                        );
                                      }

                                      return ListView.builder(
                                          controller: _scrollController,
                                          itemCount: siteData.sitesList.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return LocationTile(
                                              index: index,
                                              site: siteData.sitesList[index],
                                              title: siteData
                                                  .sitesList[index].name,
                                              onTapDelete: () {
                                                var token =
                                                    Provider.of<UserData>(
                                                            context,
                                                            listen: false)
                                                        .user
                                                        .userToken;
                                                return showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return RoundedAlert(
                                                          onPressed: () async {
                                                            showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return RoundedLoadingIndicator();
                                                                });
                                                            var msg = await siteData
                                                                .deleteSite(
                                                                    siteData
                                                                        .sitesList[
                                                                            index]
                                                                        .id,
                                                                    token,
                                                                    index,
                                                                    context);
                                                            if (msg ==
                                                                "Success") {
                                                              Navigator.pop(
                                                                  context);
                                                              successfullDelete();
                                                            } else if (msg ==
                                                                "hasData") {
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "خطأ في الحذف: هذا الموقع يحتوي على مناوبات\nبرجاء حذف المناوبات اولا.",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  textColor:
                                                                      Colors
                                                                          .black,
                                                                  fontSize:
                                                                      ScreenUtil().setSp(
                                                                          16,
                                                                          allowFontScalingSelf:
                                                                              true));
                                                            } else if (msg ==
                                                                "failed") {
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "خطأ في اثناء الحذف.",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  textColor:
                                                                      Colors
                                                                          .black,
                                                                  fontSize:
                                                                      ScreenUtil().setSp(
                                                                          16,
                                                                          allowFontScalingSelf:
                                                                              true));
                                                            } else if (msg ==
                                                                "noInternet") {
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "خطأ في الحذف: لا يوجد اتصال بالانترنت.",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  textColor:
                                                                      Colors
                                                                          .black,
                                                                  fontSize:
                                                                      ScreenUtil().setSp(
                                                                          16,
                                                                          allowFontScalingSelf:
                                                                              true));
                                                            } else {
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "خطأ في الحذف.",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  textColor:
                                                                      Colors
                                                                          .black,
                                                                  fontSize:
                                                                      ScreenUtil().setSp(
                                                                          16,
                                                                          allowFontScalingSelf:
                                                                              true));
                                                            }
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          title: 'إزالة موقع',
                                                          content:
                                                              "هل تريد إزالة${siteData.sitesList[index].name} ؟");
                                                    });
                                              },
                                              onTapEdit: () {
                                                Navigator.of(context).push(
                                                  new MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddSiteScreen(
                                                            siteData.sitesList[
                                                                index],
                                                            index,
                                                            true,
                                                            false),
                                                  ),
                                                );
                                              },
                                              onTapLocation: () {
                                                Navigator.of(context).push(
                                                  new MaterialPageRoute(
                                                    builder: (context) =>
                                                        ShowLocationMap(
                                                            siteData
                                                                .sitesList[
                                                                    index]
                                                                .lat,
                                                            siteData
                                                                .sitesList[
                                                                    index]
                                                                .long,
                                                            siteData
                                                                .sitesList[
                                                                    index]
                                                                .name),
                                                  ),
                                                );
                                              },
                                            );
                                          });
                                    default:
                                      return Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.orange),
                                        ),
                                      );
                                  }
                                }),
                          ),
                          siteData.sitesList.length != 0
                              ? Provider.of<SiteData>(context).isLoading
                                  ? Column(
                                      children: [
                                        Center(
                                            child: CupertinoActivityIndicator(
                                          radius: 15,
                                        )),
                                        Container(
                                          height: 30,
                                        )
                                      ],
                                    )
                                  : Container()
                              : Container()
                        ],
                      ),
                    ),
                    Positioned(
                      left: 5.0.w,
                      top: 5.0.h,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => NavScreenTwo(3)),
                                (Route<dynamic> route) => false);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton:
                  Provider.of<UserData>(context, listen: false).user.userType ==
                          4
                      ? MultipleFloatingButtons(
                          mainTitle: "إضافة موقع",
                          shiftName: "",
                          comingFromShifts: false,
                          mainIconData: Icons.add_location_alt,
                        )
                      : MultipleFloatingButtons(
                          mainTitle: "",
                          shiftName: "",
                          comingFromShifts: false,
                          mainIconData: Icons.add_location_alt,
                        )));
    });
  }

  Future<bool> onWillPop() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NavScreenTwo(3)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class LocationTile extends StatefulWidget {
  final String title;
  final Site site;
  final int index;
  final Function onTapLocation;
  final Function onTapEdit;
  final Function onTapDelete;
  LocationTile(
      {this.title,
      this.onTapEdit,
      this.onTapDelete,
      this.onTapLocation,
      this.site,
      this.index});

  @override
  _LocationTileState createState() => _LocationTileState();
}

class _LocationTileState extends State<LocationTile> {
  showShiftDetails(Site site) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: Stack(
                  children: [
                    Container(
                      height: 320.h,
                      width: double.infinity.w,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Expanded(
                                child: ShowLocationMap(
                                    site.lat, site.long, site.name)),
                            Provider.of<UserData>(context, listen: false)
                                        .user
                                        .userType !=
                                    3
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: RounderButton(
                                                "تعديل", widget.onTapEdit)),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        Expanded(
                                            child: RounderButton(
                                                "حذف", widget.onTapDelete))
                                      ],
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 5.0.w,
                      top: 5.0.h,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.orange,
                            size: ScreenUtil()
                                .setSp(25, allowFontScalingSelf: true),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                width: double.infinity.w,
                height: 60.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          showShiftDetails(widget.site);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: ScreenUtil()
                                  .setSp(35, allowFontScalingSelf: true),
                              color: Colors.orange,
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Container(
                              height: 27.h,
                              child: AutoSizeText(
                                widget.title,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(16, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20, left: 5),
                      child: Row(
                        children: [
                          CircularIconButton(
                            icon: Icons.alarm,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShiftsScreen(
                                        widget.index, 0, widget.index)),
                              );
                            },
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          CircularIconButton(
                            icon: Icons.person,
                            onTap: () async {
                              Provider.of<SiteShiftsData>(context,
                                      listen: false)
                                  .getShiftsList(
                                      Provider.of<SiteShiftsData>(context,
                                              listen: false)
                                          .siteShiftList[widget.index]
                                          .siteName,
                                      true);
                              // await Provider.of<ShiftsData>(context,
                              //         listen: false)
                              //     .findMatchingShifts(
                              //         Provider.of<SiteData>(context,
                              //                 listen: false)
                              //             .sitesList[widget.index]
                              //             .id,
                              //         true);

                              Provider.of<SiteData>(context, listen: false)
                                  .setDropDownIndex(widget.index);
                              print("selected index = ${widget.index}");

                              Provider.of<SiteData>(context, listen: false)
                                  .setDropDownShift(0);
                              log(Provider.of<SiteShiftsData>(context,
                                      listen: false)
                                  .siteShiftList[widget.index]
                                  .siteName);
                              Navigator.of(context).push(
                                new MaterialPageRoute(
                                  builder: (context) =>
                                      UsersScreen(widget.index, false, ""),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final onTap;

  CircularIconButton({this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: Icon(
            icon,
            size: ScreenUtil().setSp(20, allowFontScalingSelf: true),
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}
