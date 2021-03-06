import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/AddSite.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/LocationTile.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Sites_data.dart';

import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class SitesDisplay extends StatelessWidget {
  final SlidableController slidableController = SlidableController();
  final List<Site> sites;
  SitesDisplay({this.sites});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          // controller: _scrollController,
          itemCount: sites.length - 1,
          itemBuilder: (BuildContext context, int index) {
            return LocationTile(
              slidableController: slidableController,
              index: index,
              site: sites[index + 1],
              title: sites[index + 1].name,
              onTapDelete: () {
                final token = Provider.of<UserData>(context, listen: false)
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
                                    sites[index + 1].id, token, index, context);
                            if (msg == "Success") {
                              // Navigator.pop(
                              //     context);
                              successfullDelete();
                            } else if (msg == "hasData") {
                              Fluttertoast.showToast(
                                  msg:
                                      "?????? ???? ??????????: ?????? ???????????? ?????????? ?????? ??????????????\n?????????? ?????? ?????????????????? ????????.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.black,
                                  fontSize: ScreenUtil()
                                      .setSp(16, allowFontScalingSelf: true));
                            } else if (msg == "failed") {
                              Fluttertoast.showToast(
                                  msg: "?????? ???? ?????????? ??????????.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.black,
                                  fontSize: ScreenUtil()
                                      .setSp(16, allowFontScalingSelf: true));
                            } else if (msg == "noInternet") {
                              Fluttertoast.showToast(
                                  msg: "?????? ???? ??????????: ???? ???????? ?????????? ??????????????????.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.black,
                                  fontSize: ScreenUtil()
                                      .setSp(16, allowFontScalingSelf: true));
                            } else {
                              Fluttertoast.showToast(
                                  msg: "?????? ???? ??????????.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.black,
                                  fontSize: ScreenUtil()
                                      .setSp(16, allowFontScalingSelf: true));
                            }
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          title: '?????????? ????????',
                          content: "???? ???????? ??????????${sites[index + 1].name} ??");
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
                        sites[index + 1].id,
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
