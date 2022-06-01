import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/SiteAdmin/site_admin_users_screen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/services/AllSiteShiftsData/site_shifts_all.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/api.dart';

import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import "package:qr_users/services/Sites_data.dart";
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';

import '../../../../services/Sites_data.dart';
import 'from_to_shift_display.dart';

class ShiftTile extends StatefulWidget {
  final Shift shift;
  final Shifts shifts;
  final index;
  final SlidableController slidableController;
  final String siteName;
  final siteIndex;
  final Function onTapEdit;
  final Function onTapDelete;
  const ShiftTile(
      {this.siteIndex,
      this.index,
      this.siteName,
      this.shift,
      this.onTapEdit,
      this.slidableController,
      this.onTapDelete,
      this.shifts});

  @override
  _ShiftTileState createState() => _ShiftTileState();
}

class _ShiftTileState extends State<ShiftTile> {
  int siteId;

  String amPmChanger(int intTime) {
    int hours = (intTime ~/ 100);
    final int min = intTime - (hours * 100);

    final ampm = hours >= 12
        ? getTranslated(context, "PM")
        : getTranslated(context, "AM");
    hours = hours % 12;
    hours = hours != 0 ? hours : 12; //

    final String hoursStr = hours < 10
        ? '0$hours'
        : hours.toString(); // the hour '0' should be '12'
    final String minStr = min < 10 ? '0$min' : min.toString();

    final strTime = '$hoursStr:$minStr$ampm';

    return strTime;
  }

  Widget build(BuildContext context) {
    final siteProv = Provider.of<SiteData>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: InkWell(
        onTap: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedLoadingIndicator();
              });
          await Provider.of<ShiftApi>(context, listen: false).getShiftByShiftId(
            widget.shifts.shiftId,
          );

          Navigator.pop(context);
          showShiftDetails(
              Provider.of<ShiftApi>(context, listen: false).userShift);
        },
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

                      // showDialog(
                      //     context: context,
                      //     builder: (BuildContext context) {
                      //       return RoundedLoadingIndicator();
                      //     });
                    })),
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
                        flex: 1,
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: ScreenUtil()
                                  .setSp(35, allowFontScalingSelf: true),
                              color: Colors.orange,
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Container(
                              child: AutoSizeText(
                                widget.shifts.shiftName,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(15, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          // siteProv.setDropDownShift(
                          //     widget.index); //الموقع علي حسب ال اندكس اللي
                          final userData =
                              Provider.of<UserData>(context, listen: false)
                                  .user;

                          if (userData.userType != 2) {
                            siteProv
                              ..setSiteValue(widget.siteName)
                              ..setDropDownIndex(widget.siteIndex)
                              ..fillCurrentShiftID(widget.shifts.shiftId);

                            debugPrint("finding matching shifts");
                            final index = getSiteName(siteProv.currentSiteName);

                            Provider.of<SiteShiftsData>(context, listen: false)
                                .getShiftsList(
                                    Provider.of<SiteShiftsData>(context,
                                            listen: false)
                                        .siteShiftList[index]
                                        .siteName,
                                    true);
                            siteProv.setDropDownShift(
                                widget.index + 1); //+1 lw feh all shifts
                          } else {
                            siteProv.setDropDownShift(
                                widget.index); //+1 lw feh all shifts
                          }

                          if (userData.userType == 2) {
                            Navigator.of(context).push(
                              new MaterialPageRoute(
                                builder: (context) => SiteAdminUserScreen(
                                    widget.siteIndex,
                                    true,
                                    widget.shifts.shiftName),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              new MaterialPageRoute(
                                builder: (context) => UsersScreen(
                                    widget.siteIndex + 1,
                                    true,
                                    widget.shifts.shiftName),
                              ),
                            );
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.orange, width: 1)),
                            padding: const EdgeInsets.all(9),
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: ColorManager.primary,
                            )),
                      )
                      // CircularIconButton(
                      //     icon: Icons.person,
                      //     onTap: () {
                      //       Navigator.of(context).push(
                      //         new MaterialPageRoute(
                      //           builder: (context) =>
                      //               UsersScreen(widget.index + 1),
                      //         ),
                      //       );
                      //     },
                      //   ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  int getSiteName(String siteName) {
    final list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].siteName) {
        return i;
      }
    }
    return -1;
  }

  showShiftDetails(Shift shift) {
    final String end = amPmChanger(shift.shiftEndTime);
    final String start = amPmChanger(shift.shiftStartTime);
    final String sunSt = amPmChanger(shift.sunShiftstTime);
    final String sunEn = amPmChanger(shift.sunShiftenTime);
    final String monSt = amPmChanger(shift.monShiftstTime);
    final String monEn = amPmChanger(shift.mondayShiftenTime);
    final String tuesSt = amPmChanger(shift.tuesdayShiftstTime);
    final String tuesEnd = amPmChanger(shift.tuesdayShiftenTime);
    final String wedSt = amPmChanger(shift.wednesDayShiftstTime);
    final String wedEn = amPmChanger(shift.wednesDayShiftenTime);
    final String thuSt = amPmChanger(shift.thursdayShiftstTime);
    final String thuEn = amPmChanger(shift.thursdayShiftenTime);
    final String friSt = amPmChanger(shift.fridayShiftstTime);
    final String friEn = amPmChanger(shift.fridayShiftenTime);

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          final userProv = Provider.of<UserData>(context, listen: false).user;
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Stack(
                children: [
                  Container(
                    height: 1000.h,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          DirectoriesHeader(
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40.0),
                              child: Lottie.asset("resources/shiftLottie.json",
                                  repeat: false),
                            ),
                            shift.shiftName,
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    userProv.userType == 2
                                        ? Container()
                                        : UserDataField(
                                            icon: Icons.location_on,
                                            text: Provider.of<SiteShiftsData>(
                                                    context,
                                                    listen: false)
                                                .siteShiftList[widget.siteIndex]
                                                .siteName,
                                          ),
                                    SizedBox(
                                      height: 10.0.h,
                                    ),
                                    FromToShiftDisplay(
                                      start: start,
                                      end: end,
                                      weekDay: weekDays[0],
                                    ),
                                    FromToShiftDisplay(
                                      start: sunSt,
                                      end: sunEn,
                                      weekDay: weekDays[1],
                                    ),
                                    FromToShiftDisplay(
                                        start: monSt,
                                        end: monEn,
                                        weekDay: weekDays[2]),
                                    FromToShiftDisplay(
                                        start: tuesSt,
                                        end: tuesEnd,
                                        weekDay: weekDays[3]),
                                    FromToShiftDisplay(
                                        start: wedSt,
                                        end: wedEn,
                                        weekDay: weekDays[4]),
                                    FromToShiftDisplay(
                                        start: thuSt,
                                        end: thuEn,
                                        weekDay: weekDays[5]),
                                    FromToShiftDisplay(
                                        start: friSt,
                                        end: friEn,
                                        weekDay: weekDays[6]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
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
}
