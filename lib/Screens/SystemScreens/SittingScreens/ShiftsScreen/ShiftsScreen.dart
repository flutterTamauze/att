import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/site_shifts_all.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/api.dart';

import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import "package:qr_users/services/Sites_data.dart";
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

import '../../../../main.dart';
import '../../../../services/ShiftsData.dart';
import '../../../../services/Sites_data.dart';

class ShiftsScreen extends StatefulWidget {
  final siteId;
  final isFromSites;
  final siteIndex;

  ShiftsScreen(this.siteId, this.isFromSites, this.siteIndex);

  @override
  _ShiftsScreenState createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  int siteId = 0;
  @override
  void initState() {
    // x
    print(widget.siteIndex);
    super.initState();
    Provider.of<SiteData>(context, listen: false).pageIndex = 0;
    print("init state");
    siteId = widget.siteId;
  }

  // String getTimeToString(int time) {
  //   print(time);
  //   double hoursDouble = time / 100.0;
  //   int h = hoursDouble.toInt();
  //   print(h);
  //   double minDouble = time.toDouble() % 100;
  //   int m = minDouble.toInt();
  //   print(m);
  //   NumberFormat formatter = new NumberFormat("00");
  //   return "${formatter.format(h)}:${formatter.format(m)}";
  // }

  @override
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    print("refresh");
    // if failed,use refreshFailed()
    print(siteId);
    setState(() {
      isLoading = true;
    });
    // await getData(Provider.of<SiteShiftsData>(context, listen: false)
    //     .siteShiftList[siteId]
    //     .siteId);

    setState(() {
      isLoading = false;
    });

    refreshController.refreshCompleted();
  }

  String siteName;
  void didChangeDependencies() async {
    isLoading = false;
    print("start state");
    super.didChangeDependencies();
    // await getData();
    if (mounted)
      // getData(Provider.of<SiteShiftsData>(context, listen: false)
      //     .siteShiftList[siteId]
      //     .siteId);
      siteName = Provider.of<SiteShiftsData>(context, listen: false)
          .siteShiftList[siteId]
          .siteName;

    filSitesStringsList();
  }

  // Future loadShift;
  // getData(int siteId) async {
  //   var userProvider = Provider.of<UserData>(context, listen: false);
  //   loadShift = Provider.of<ShiftsData>(context, listen: false)
  //       .getShiftsBySiteId(siteId, userProvider.user.userToken, context);
  //   // await fillList();
  // }

  filSitesStringsList() async {
    await Provider.of<SiteData>(context, listen: false)
        .filSitesStringsList(context);
  }

  bool isLoading = false;
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

  final SlidableController slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return Consumer<ShiftsData>(builder: (context, shiftsData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () {
            print(siteId);
            print(Provider.of<SiteData>(context, listen: false)
                .dropDownShiftIndex);
          },
          child: Scaffold(
              endDrawer: NotificationItem(),
              backgroundColor: Colors.white,
              body: Container(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Header(nav: false),

                        ///Title
                        Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: SmallDirectoriesHeader(
                              Lottie.asset("resources/shiftLottie.json",
                                  repeat: false),
                              "دليل المناوبات"),
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: SiteDropdown(
                                  edit: true,
                                  list: Provider.of<SiteShiftsData>(context,
                                          listen: false)
                                      .siteShiftList,
                                  colour: Colors.white,
                                  icon: Icons.location_on,
                                  borderColor: Colors.black,
                                  hint: "الموقع",
                                  hintColor: Colors.black,
                                  onChange: (value) async {
                                    // print()

                                    siteId = getSiteName(value);
                                    siteName = Provider.of<SiteShiftsData>(
                                            context,
                                            listen: false)
                                        .siteShiftList[siteId]
                                        .siteName;
                                    _onRefresh();
                                    Provider.of<SiteData>(context,
                                            listen: false)
                                        .setCurrentSiteName(value);
                                    print("site name from monawbat $value");
                                    print(Provider.of<SiteShiftsData>(context,
                                            listen: false)
                                        .siteShiftList[siteId]
                                        .siteId);
                                    Provider.of<SiteShiftsData>(context,
                                            listen: false)
                                        .getShiftsList(siteName, false);
                                  },
                                  selectedvalue: siteName,
                                  textColor: Colors.orange,
                                ),
                              ),
                              Consumer<SiteShiftsData>(
                                builder: (context, value, child) {
                                  return Expanded(
                                      child:
                                          value.dropDownShifts[0].shiftId == 0
                                              ? Center(
                                                  child: Container(
                                                    height: 50.h,
                                                    child: AutoSizeText(
                                                      "لا يوجد مناوبات بهذا الموقع\nبرجاء اضافة مناوبة",
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          height: 2,
                                                          fontSize: ScreenUtil()
                                                              .setSp(17,
                                                                  allowFontScalingSelf:
                                                                      true),
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  itemCount: value
                                                      .dropDownShifts.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return ShiftTile(
                                                      shifts:
                                                          value.dropDownShifts[
                                                              index],
                                                      slidableController:
                                                          slidableController,
                                                      siteName: value
                                                          .dropDownShifts[index]
                                                          .shiftName,
                                                      siteIndex: siteId,
                                                      index: index,
                                                      // shift: value
                                                      //     .shifts[index],
                                                      onTapDelete: () {
                                                        final token =
                                                            Provider.of<UserData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .user
                                                                .userToken;
                                                        return showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Directionality(
                                                                textDirection:
                                                                    TextDirection
                                                                        .rtl,
                                                                child:
                                                                    RoundedAlert(
                                                                        onPressed:
                                                                            () async {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return RoundedLoadingIndicator();
                                                                              });
                                                                          final msg = await shiftsData.deleteShift(
                                                                              value.dropDownShifts[index].shiftId,
                                                                              token,
                                                                              index,
                                                                              context);

                                                                          if (msg ==
                                                                              "Success") {
                                                                            Provider.of<SiteShiftsData>(context, listen: false).getShiftsList(Provider.of<SiteShiftsData>(context, listen: false).siteShiftList[widget.siteIndex].siteName,
                                                                                false);
                                                                            // Navigator.pop(context);
                                                                            Fluttertoast.showToast(
                                                                                msg: "تم الحذف بنجاح",
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.green,
                                                                                gravity: ToastGravity.CENTER,
                                                                                textColor: Colors.white,
                                                                                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                          } else if (msg ==
                                                                              "hasData") {
                                                                            Fluttertoast.showToast(
                                                                                msg: "خطأ في الحذف: هذه المناوبة تحتوي على مستخدمين. برجاء حذف المستخدمين اولا.",
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                gravity: ToastGravity.CENTER,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.red,
                                                                                textColor: Colors.black,
                                                                                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                          } else if (msg ==
                                                                              "failed") {
                                                                            Fluttertoast.showToast(
                                                                                msg: "خطأ في اثناء الحذف.",
                                                                                gravity: ToastGravity.CENTER,
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.red,
                                                                                textColor: Colors.black,
                                                                                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                          } else if (msg ==
                                                                              "noInternet") {
                                                                            Fluttertoast.showToast(
                                                                                msg: "خطأ في الحذف: لا يوجد اتصال بالانترنت.",
                                                                                gravity: ToastGravity.CENTER,
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.red,
                                                                                textColor: Colors.black,
                                                                                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                          } else {
                                                                            Fluttertoast.showToast(
                                                                                msg: "خطأ في الحذف.",
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
                                                                        title:
                                                                            'إزالة مناوبة',
                                                                        content:
                                                                            "هل تريد إزالة ${value.dropDownShifts[index].shiftName} ؟"),
                                                              );
                                                            });
                                                      },
                                                      onTapEdit: () async {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return RoundedLoadingIndicator();
                                                            });
                                                        await Provider.of<
                                                                    ShiftApi>(
                                                                context,
                                                                listen: false)
                                                            .getShiftByShiftId(
                                                                value
                                                                    .dropDownShifts[
                                                                        index]
                                                                    .shiftId,
                                                                Provider.of<UserData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .user
                                                                    .userToken);

                                                        Navigator.pop(context);

                                                        Navigator.of(context)
                                                            .push(
                                                          new MaterialPageRoute(
                                                            builder: (context) => AddShiftScreen(
                                                                Provider.of<ShiftApi>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .userShift,
                                                                index,
                                                                true,
                                                                siteId,
                                                                widget
                                                                    .siteIndex),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
              floatingActionButton:
                  Provider.of<UserData>(context, listen: false).user.userType ==
                          4
                      ? MultipleFloatingButtons(
                          mainTitle: "إضافة مناوبة",
                          shiftName: "",
                          siteId: siteId,
                          comingFromShifts: false,
                          mainIconData: Icons.alarm_add_sharp)
                      : MultipleFloatingButtonsNoADD()),
        ),
      );
    });
  }

  Future<bool> onWillPop() {
    if (widget.isFromSites == 0) {
      Navigator.pop(context);
      return Future.value(false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => NavScreenTwo(3)),
          (Route<dynamic> route) => false);
      return Future.value(false);
    }
  }
}

class ShiftTile extends StatefulWidget {
  final Shift shift;
  final Shifts shifts;
  var index;
  final SlidableController slidableController;
  final String siteName;
  final siteIndex;
  final Function onTapEdit;
  final Function onTapDelete;
  ShiftTile(
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
    final DataConnectionChecker dataConnectionChecker = DataConnectionChecker();
    final NetworkInfoImp networkInfoImp = NetworkInfoImp(dataConnectionChecker);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: InkWell(
        onTap: () async {
          final bool isConnected = await networkInfoImp.isConnected;
          if (isConnected) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RoundedLoadingIndicator();
                });
            await Provider.of<ShiftApi>(context, listen: false)
                .getShiftByShiftId(
                    widget.shifts.shiftId,
                    Provider.of<UserData>(context, listen: false)
                        .user
                        .userToken);

            Navigator.pop(context);
            showShiftDetails(
                Provider.of<ShiftApi>(context, listen: false).userShift);
          } else {
            return weakInternetConnection(
              navigatorKey.currentState.overlay.context,
            );
          }
        },
        child: Slidable(
          enabled:
              Provider.of<UserData>(context, listen: false).user.userType == 4,
          actionExtentRatio: 0.10,
          closeOnScroll: true,
          controller: widget.slidableController,
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: [
            ZoomIn(
                child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(width: 2, color: Colors.orange)),
                      child: Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.orange,
                      ),
                    ),
                    onTap: () async {
                      final bool isConnected = await networkInfoImp.isConnected;
                      if (isConnected) {
                        widget.onTapEdit();
                      } else {
                        return weakInternetConnection(
                          navigatorKey.currentState.overlay.context,
                        );

                        // showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       return RoundedLoadingIndicator();
                        //     });

                      }
                    })),
            ZoomIn(
                child: InkWell(
              child: Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(width: 2, color: Colors.red)),
                child: Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                final DataConnectionChecker dataConnectionChecker =
                    DataConnectionChecker();
                final NetworkInfoImp networkInfoImp =
                    NetworkInfoImp(dataConnectionChecker);
                final bool isConnected = await networkInfoImp.isConnected;
                if (isConnected) {
                  widget.onTapDelete();
                } else {
                  return weakInternetConnection(
                    navigatorKey.currentState.overlay.context,
                  );
                }
              },
            )),
          ],
          child: Card(
              elevation: 3,
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
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
                                      fontSize: ScreenUtil().setSp(15,
                                          allowFontScalingSelf: true),
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
                            siteProv.setSiteValue(widget.siteName);

                            siteProv.fillCurrentShiftID(widget.shifts.shiftId);
                            siteProv.setDropDownIndex(widget.siteIndex);
                            siteProv.fillCurrentShiftID(widget.shifts.shiftId);
                            print(widget.index);

                            print("finding matching shifts");
                            print(siteProv.currentSiteName);
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

                            Navigator.of(context).push(
                              new MaterialPageRoute(
                                builder: (context) => UsersScreen(
                                    widget.siteIndex + 1,
                                    true,
                                    widget.shifts.shiftName),
                              ),
                            );
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.orange, width: 1)),
                              padding: EdgeInsets.all(9),
                              child: Icon(
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
          final daysOff = Provider.of<DaysOffData>(context).weak;
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
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
                                child: Lottie.asset(
                                    "resources/shiftLottie.json",
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
                                      UserDataField(
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
                ),
              ));
        });
  }
}

class FromToShiftDisplay extends StatelessWidget {
  const FromToShiftDisplay(
      {Key key, @required this.start, @required this.end, this.weekDay})
      : super(key: key);

  final String start;
  final String weekDay;
  final String end;

  @override
  Widget build(BuildContext context) {
    return SlideInUp(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AutoSizeText(
              weekDay,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: dateDataField(
                    controller: TextEditingController(text: start),
                    icon: Icons.alarm,
                    labelText: "من"),
              ),
              SizedBox(
                width: 5.0.w,
              ),
              Expanded(
                flex: 1,
                child: dateDataField(
                    controller: TextEditingController(text: end),
                    icon: Icons.alarm,
                    labelText: "الى"),
              ),
            ],
          ),
        ],
      ),
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

  dateDataField({this.icon, this.controller, this.labelText});

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
            borderSide: BorderSide(color: Color(0xffD7D7D7), width: 1.0.w),
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
