import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/AddSite.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/LocationTile.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/ShowMylocation.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';

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

class FilteredSitesDisplay extends StatefulWidget {
  final List<Site> filteredSites;
  final SlidableController slidableController;

  FilteredSitesDisplay({this.filteredSites, this.slidableController});

  @override
  _FilteredSitesDisplayState createState() => _FilteredSitesDisplayState();
}

class _FilteredSitesDisplayState extends State<FilteredSitesDisplay> {
  getIndexBySiteName(String name) {
    for (int i = 1;
        i < Provider.of<SiteShiftsData>(context, listen: false).sites.length;
        i++) {
      if (Provider.of<SiteShiftsData>(context, listen: false).sites[i].name ==
          name) {
        return i - 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          // controller: _scrollController,
          itemCount: widget.filteredSites.length,
          itemBuilder: (BuildContext context, int index) {
            return widget.filteredSites[index].name == "كل المواقع"
                ? Container()
                : LocationTile(
                    slidableController: widget.slidableController,
                    index: getIndexBySiteName(widget.filteredSites[index].name),
                    site: widget.filteredSites[index],
                    title: widget.filteredSites[index].name,
                    onTapDelete: () {
                      final token =
                          Provider.of<UserData>(context, listen: false)
                              .user
                              .userToken;
                      return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return RoundedAlert(
                                onPressed: () async {
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return RoundedLoadingIndicator();
                                      });
                                  var msg = await Provider.of<SiteData>(context,
                                          listen: false)
                                      .deleteSite(
                                          widget.filteredSites[index].id,
                                          token,
                                          index,
                                          context);
                                  if (msg == "Success") {
                                    // Navigator.pop(
                                    //     context);
                                    successfullDelete(context);
                                  } else if (msg == "hasData") {
                                    Fluttertoast.showToast(
                                        msg: getTranslated(context,
                                            "خطأ في الحذف: هذا الموقع يحتوي على مناوبات\nبرجاء حذف المناوبات اولا"),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.black,
                                        fontSize: ScreenUtil().setSp(16,
                                            allowFontScalingSelf: true));
                                  } else if (msg == "failed") {
                                    Fluttertoast.showToast(
                                        msg: getTranslated(
                                            context, "خطأ في الحذف"),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.black,
                                        fontSize: ScreenUtil().setSp(16,
                                            allowFontScalingSelf: true));
                                  } else if (msg == "noInternet") {
                                    Fluttertoast.showToast(
                                        msg: getTranslated(context,
                                            "خطأ في الحذف : لا يوجد اتصال بالانترنت"),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.black,
                                        fontSize: ScreenUtil().setSp(16,
                                            allowFontScalingSelf: true));
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: getTranslated(
                                            context, "خطأ في الحذف"),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.black,
                                        fontSize: ScreenUtil().setSp(16,
                                            allowFontScalingSelf: true));
                                  }
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                title: getTranslated(context, 'إزالة موقع'),
                                content:
                                    "${getTranslated(context, "هل تريد إزالة")}${widget.filteredSites[index].name} ؟");
                          });
                    },
                    onTapEdit: () async {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return RoundedLoadingIndicator();
                          });
                      await Provider.of<SiteData>(context, listen: false)
                          .getSiteBySiteId(
                              widget.filteredSites[index].id,
                              Provider.of<UserData>(context, listen: false)
                                  .user
                                  .userToken)
                          .then((site) async {
                        await Navigator.of(context).push(
                          new MaterialPageRoute(
                            builder: (context) =>
                                AddSiteScreen(site, index, true, false),
                          ),
                        );
                        Navigator.pop(context);
                      });
                    },
                  );
          }),
    );
  }
}
