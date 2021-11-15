import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/ShowMylocation.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/roundedButton.dart';

import 'CircularIconButton.dart';

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
                textDirection: TextDirection.rtl,
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
              textDirection: TextDirection.rtl,
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
                          CircularIconButtonn(
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
                          CircularIconButtonn(
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