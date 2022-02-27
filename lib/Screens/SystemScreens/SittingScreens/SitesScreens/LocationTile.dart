import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'CircularIconButton.dart';
import 'ShowMylocation.dart';

class LocationTile extends StatefulWidget {
  final String title;
  final Site site;
  final int index;
  final SlidableController slidableController;
  final Function onTapLocation;
  final Function onTapEdit;
  final Function onTapDelete;
  const LocationTile(
      {this.title,
      this.onTapEdit,
      this.onTapDelete,
      this.onTapLocation,
      this.slidableController,
      this.site,
      this.index});

  @override
  _LocationTileState createState() => _LocationTileState();
}

class _LocationTileState extends State<LocationTile> {
  showShiftDetails(Site site) {
    print(widget.index);
    print(site.name);
    Navigator.pop(context);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
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
                            site.lat,
                            site.long,
                            site.name,
                          )),
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
              ));
        });
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Slidable(
        enabled:
            Provider.of<UserData>(context, listen: false).user.userType == 4,
        actionExtentRatio: 0.10,
        closeOnScroll: true,
        controller: widget.slidableController,
        actionPane: const SlidableDrawerActionPane(),
        secondaryActions: [
          ZoomIn(
              child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(width: 2, color: Colors.orange)),
              child: const Icon(
                Icons.edit,
                size: 18,
                color: Colors.orange,
              ),
            ),
            onTap: () async {
              widget.onTapEdit();
            },
          )),
          ZoomIn(
              child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(width: 2, color: Colors.red)),
              child: const Icon(
                Icons.delete,
                size: 18,
                color: Colors.red,
              ),
            ),
            onTap: () async {
              widget.onTapDelete();
            },
          )),
        ],
        child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: double.infinity.w,
                height: 60.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return RoundedLoadingIndicator();
                            },
                          );

                          final SiteData siteData =
                              Provider.of<SiteData>(context, listen: false);
                          await siteData
                              .getSiteBySiteId(
                                  Provider.of<SiteShiftsData>(context,
                                          listen: false)
                                      .sites[widget.index + 1]
                                      .id,
                                  Provider.of<UserData>(context, listen: false)
                                      .user
                                      .userToken)
                              .then((value) => {showShiftDetails(value)});

                          //
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
                              Provider.of<SiteData>(context, listen: false)
                                  .setCurrentSiteName(
                                      Provider.of<SiteShiftsData>(context,
                                              listen: false)
                                          .siteShiftList[widget.index]
                                          .siteName);
                              Provider.of<SiteShiftsData>(context,
                                      listen: false)
                                  .getShiftsList(widget.site.name, false);
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
                                  .setDropDownIndex(widget.index + 1);
                              print("selected index = ${widget.index}");
                              Provider.of<SiteData>(context, listen: false)
                                  .setCurrentSiteName(
                                      Provider.of<SiteShiftsData>(context,
                                              listen: false)
                                          .siteShiftList[widget.index]
                                          .siteName);
                              Provider.of<SiteData>(context, listen: false)
                                  .setDropDownShift(0);

                              Navigator.of(context).push(
                                new MaterialPageRoute(
                                  builder: (context) =>
                                      UsersScreen(widget.index + 1, false, ""),
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
            )),
      ),
    );
  }
}
