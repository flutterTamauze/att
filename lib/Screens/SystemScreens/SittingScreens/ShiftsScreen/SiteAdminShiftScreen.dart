import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/SiteAdminUsersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Shift.dart';

import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import "package:qr_users/services/Sites_data.dart";
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

import '../../../../services/ShiftsData.dart';
import '../../../../services/Sites_data.dart';
import 'ShiftsScreen.dart';

class SiteAdminShiftScreen extends StatefulWidget {
  final siteId;
  final isFromSites;

  const SiteAdminShiftScreen(this.siteId, this.isFromSites);

  @override
  _SiteAdminShiftScreenState createState() => _SiteAdminShiftScreenState();
}

class _SiteAdminShiftScreenState extends State<SiteAdminShiftScreen> {
  int siteId = 0;

  // String getTimeToString(int time) {
  //   debugPrint(time);
  //   double hoursDouble = time / 100.0;
  //   int h = hoursDouble.toInt();
  //   debugPrint(h);
  //   double minDouble = time.toDouble() % 100;
  //   int m = minDouble.toInt();
  //   debugPrint(m);
  //   NumberFormat formatter = new NumberFormat("00");
  //   return "${formatter.format(h)}:${formatter.format(m)}";
  // }

  @override
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    Provider.of<ShiftsData>(context, listen: false)
        .getShifts(
            Provider.of<UserData>(context, listen: false).user.userSiteId,
            Provider.of<UserData>(context, listen: false).user.userToken,
            context,
            2,
            Provider.of<UserData>(context, listen: false).user.userSiteId)
        .then((value) => fillList());

    refreshController.refreshCompleted();
  }

  void didChangeDependencies() async {
    isLoading = false;
    if (mounted) {}

    super.didChangeDependencies();
    // Provider.of<SiteData>(context, listen: false).setCurrentSiteName(
    //     Provider.of<UserData>(context, listen: false).siteName);
  }

  fillList() async {
    await Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(
        Provider.of<UserData>(context, listen: false).user.userSiteId, false);
  }

  bool isLoading = false;
  int getSiteName(String siteName) {
    final list = Provider.of<SiteData>(context, listen: false).sitesList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return Consumer<ShiftsData>(builder: (context, shiftsData, child) {
      return WillPopScope(
          onWillPop: onWillPop,
          child: Scaffold(
            endDrawer: NotificationItem(),
            backgroundColor: Colors.white,
            body: Container(
              child: Stack(
                children: [
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Header(nav: false),

                    ///Title
                    SmallDirectoriesHeader(
                      Lottie.asset("resources/shiftLottie.json", repeat: false),
                      getTranslated(context, "دليل المناوبات"),
                    ),

                    Expanded(
                        child: Column(
                      children: [
                        Consumer<ShiftsData>(
                          builder: (context, value, child) {
                            return Expanded(
                                child: value.shiftsList.isNotEmpty
                                    ? SmartRefresher(
                                        onRefresh: _onRefresh,
                                        controller: refreshController,
                                        enablePullDown: true,
                                        header: const WaterDropMaterialHeader(
                                          color: Colors.white,
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: isLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor: Colors.white,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.orange),
                                                ),
                                              )
                                            : ListView.builder(
                                                itemCount:
                                                    value.shiftsList.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return ShiftTile(
                                                    siteName: value
                                                        .shiftsList[index]
                                                        .shiftName,
                                                    siteIndex: siteId,
                                                    index: index,
                                                    shift:
                                                        value.shiftsList[index],
                                                    onTapDelete: () {
                                                      final token =
                                                          Provider.of<UserData>(
                                                                  context,
                                                                  listen: false)
                                                              .user
                                                              .userToken;
                                                      return showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return RoundedAlert(
                                                                onPressed:
                                                                    () async {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return RoundedLoadingIndicator();
                                                                      });
                                                                  final msg = await shiftsData.deleteShift(
                                                                      value
                                                                          .shiftsList[
                                                                              index]
                                                                          .shiftId,
                                                                      token,
                                                                      index,
                                                                      context);

                                                                  if (msg ==
                                                                      "Success") {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Fluttertoast.showToast(
                                                                        msg: getTranslated(
                                                                            context,
                                                                            "تم الحذف بنجاح"),
                                                                        toastLength:
                                                                            Toast
                                                                                .LENGTH_SHORT,
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        backgroundColor:
                                                                            Colors
                                                                                .green,
                                                                        gravity:
                                                                            ToastGravity
                                                                                .CENTER,
                                                                        textColor:
                                                                            Colors
                                                                                .white,
                                                                        fontSize: ScreenUtil().setSp(
                                                                            16,
                                                                            allowFontScalingSelf:
                                                                                true));
                                                                  } else if (msg ==
                                                                      "hasData") {
                                                                    Fluttertoast.showToast(
                                                                        msg: getTranslated(
                                                                            context,
                                                                            "خطأ في الحذف: هذه المناوبة تحتوي على مستخدمين. برجاء حذف المستخدمين اولا"),
                                                                        toastLength:
                                                                            Toast
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
                                                                        fontSize: ScreenUtil().setSp(
                                                                            16,
                                                                            allowFontScalingSelf:
                                                                                true));
                                                                  } else if (msg ==
                                                                      "failed") {
                                                                    Fluttertoast.showToast(
                                                                        msg: getTranslated(
                                                                            context,
                                                                            "خطأ في الحذف"),
                                                                        gravity:
                                                                            ToastGravity
                                                                                .CENTER,
                                                                        toastLength:
                                                                            Toast
                                                                                .LENGTH_SHORT,
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        backgroundColor:
                                                                            Colors
                                                                                .red,
                                                                        textColor:
                                                                            Colors
                                                                                .black,
                                                                        fontSize: ScreenUtil().setSp(
                                                                            16,
                                                                            allowFontScalingSelf:
                                                                                true));
                                                                  } else if (msg ==
                                                                      "noInternet") {
                                                                    Fluttertoast.showToast(
                                                                        msg: getTranslated(
                                                                            context,
                                                                            "خطأ في الحذف : لا يوجد اتصال بالانترنت"),
                                                                        gravity:
                                                                            ToastGravity
                                                                                .CENTER,
                                                                        toastLength:
                                                                            Toast
                                                                                .LENGTH_SHORT,
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        backgroundColor:
                                                                            Colors
                                                                                .red,
                                                                        textColor:
                                                                            Colors
                                                                                .black,
                                                                        fontSize: ScreenUtil().setSp(
                                                                            16,
                                                                            allowFontScalingSelf:
                                                                                true));
                                                                  } else {
                                                                    Fluttertoast.showToast(
                                                                        msg: getTranslated(
                                                                          context,
                                                                          "خطأ في الحذف",
                                                                        ),
                                                                        gravity: ToastGravity.CENTER,
                                                                        toastLength: Toast.LENGTH_SHORT,
                                                                        timeInSecForIosWeb: 1,
                                                                        backgroundColor: Colors.red,
                                                                        textColor: Colors.black,
                                                                        fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                  }
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                title: getTranslated(
                                                                    context,
                                                                    'إزالة مناوبة'),
                                                                content:
                                                                    "${getTranslated(context, "هل تريد إزالة")}${value.shiftsList[index].shiftName} ؟");
                                                          });
                                                    },
                                                    onTapEdit: () {
                                                      debugPrint(
                                                          "aaaaaaaaa :${value.shiftsList[index].shiftId}");
                                                      Navigator.of(context)
                                                          .push(
                                                        new MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddShiftScreen(
                                                                  value.shiftsList[
                                                                      index],
                                                                  index,
                                                                  true,
                                                                  siteId,
                                                                  0),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }),
                                      )
                                    : Center(
                                        child: Container(
                                          height: 50,
                                          child: AutoSizeText(
                                            getTranslated(context,
                                                "لا يوجد مناوبات بهذا الموقع\nبرجاء اضافة مناوبة"),
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                height: 2,
                                                fontSize: ScreenUtil().setSp(16,
                                                    allowFontScalingSelf: true),
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ));
                          },
                        ),
                      ],
                    ))
                  ]),
                  Positioned(
                    left: 5.0.w,
                    top: 5.0.h,
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      child: InkWell(
                        onTap: () {
                          if (widget.isFromSites == 0) {
                            Navigator.pop(context);
                            return Future.value(false);
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => NavScreenTwo(3)),
                                (Route<dynamic> route) => false);
                            return Future.value(false);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: MultipleFloatingButtonsNoADD(),
          ));
    });
  }

  Future<bool> onWillPop() {
    if (widget.isFromSites == 0) {
      Navigator.pop(context);
      return Future.value(false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const NavScreenTwo(3)),
          (Route<dynamic> route) => false);
      return Future.value(false);
    }
  }
}

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
                              child: const Icon(
                                Icons.person,
                                size: 18,
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

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final onTap;

  const CircularIconButton({this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          backgroundColor: Colors.orange,
          radius: 20,
          child: Icon(
            icon,
            size: ScreenUtil().setSp(20, allowFontScalingSelf: true),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class dateDataField extends StatelessWidget {
  final IconData icon;

  final String labelText;
  final TextEditingController controller;

  const dateDataField({this.icon, this.controller, this.labelText});

  Widget build(BuildContext context) {
    return Container(
      height: getkDeviceHeightFactor(context, 40),
      child: TextFormField(
        enabled: false,
        controller: controller,
        style: TextStyle(
            color: Colors.black,
            fontSize: ScreenUtil().setSp(11, allowFontScalingSelf: true),
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: const Color(0xffD7D7D7), width: 1.0.w),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}
