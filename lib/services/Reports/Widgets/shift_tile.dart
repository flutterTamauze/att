import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/MLmodule/widgets/ShiftsTile/from_to_shift_display.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/SiteAdmin/site_admin_users_screen.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Shift.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import "package:qr_users/services/Sites_data.dart";

import '../../../../services/ShiftsData.dart';
import '../../../../services/Sites_data.dart';

class ShiftTile extends StatefulWidget {
  final Shift shift;
  final index;

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
      this.onTapDelete});

  @override
  _ShiftTileState createState() => _ShiftTileState();
}

class _ShiftTileState extends State<ShiftTile> {
  int siteId;
  @override
  void initState() {
    super.initState();
  }

  String amPmChanger(int intTime) {
    int hours = (intTime ~/ 100);
    final int min = intTime - (hours * 100);

    final ampm = hours >= 12 ? 'PM' : 'AM';
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
    final shiftProv = Provider.of<ShiftsData>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: InkWell(
        onTap: () {
          showShiftDetails();
        },
        child: widget.shift.shiftId == -100
            ? Container()
            : Card(
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
                                  widget.shift.shiftName,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(16,
                                          allowFontScalingSelf: true),
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            //الموقع علي حسب ال اندكس اللي
                            siteProv
                              ..setDropDownShift(widget.index)
                              ..setSiteValue(widget.siteName)
                              ..fillCurrentShiftID(widget.shift.shiftId)
                              ..setDropDownIndex(widget.siteIndex)
                              ..fillCurrentShiftID(widget.shift.shiftId);

                            debugPrint("finding matching shifts");
                            // Provider.of<SiteShiftsData>(context,
                            //         listen: false)
                            //     .getShiftsList(
                            //         Provider.of<SiteShiftsData>(context,
                            //                 listen: false)
                            //             .siteShiftList[index]
                            //             .siteName,
                            //         true);

                            siteProv.setDropDownShift(
                                widget.index); //+1 lw feh all shifts
                            print('widget site index ${widget.siteIndex}');
                            Navigator.of(context).push(
                              new MaterialPageRoute(
                                builder: (context) => SiteAdminUserScreen(
                                    widget.siteIndex,
                                    true,
                                    widget.shift.shiftName),
                              ),
                            );
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: ColorManager.primary, width: 1)),
                              padding: const EdgeInsets.all(9),
                              child: Icon(
                                Icons.person,
                                size: setResponsiveFontSize(18),
                                color: Colors.orange,
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

  showShiftDetails() {
    final String end = amPmChanger(widget.shift.shiftEndTime);
    final String start = amPmChanger(widget.shift.shiftStartTime);

    final String sunSt = amPmChanger(widget.shift.sunShiftstTime);
    final String sunEn = amPmChanger(widget.shift.sunShiftenTime);
    final String monSt = amPmChanger(widget.shift.monShiftstTime);
    final String monEn = amPmChanger(widget.shift.mondayShiftenTime);
    final String tuesSt = amPmChanger(widget.shift.tuesdayShiftstTime);
    final String tuesEnd = amPmChanger(widget.shift.tuesdayShiftenTime);
    final String wedSt = amPmChanger(widget.shift.wednesDayShiftstTime);
    final String wedEn = amPmChanger(widget.shift.wednesDayShiftenTime);
    final String thuSt = amPmChanger(widget.shift.thursdayShiftstTime);
    final String thuEn = amPmChanger(widget.shift.thursdayShiftenTime);
    final String friSt = amPmChanger(widget.shift.fridayShiftstTime);
    final String friEn = amPmChanger(widget.shift.fridayShiftenTime);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Stack(
                children: [
                  Container(
                    height: 650.h,
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
                            widget.shift.shiftName,
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
