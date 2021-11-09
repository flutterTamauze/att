import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
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
import 'package:qr_users/widgets/roundedButton.dart';

import '../../../../services/ShiftsData.dart';
import '../../../../services/Sites_data.dart';
import 'package:qr_users/constants.dart';

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
    Provider.of<SiteData>(context, listen: false).setCurrentSiteName(
        Provider.of<SiteShiftsData>(context, listen: false)
            .siteShiftList[0]
            .siteName);
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
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvier = Provider.of<CompanyData>(context, listen: false);
    // monitor network fetch
    print("refresh");
    // if failed,use refreshFailed()
    print(siteId);
    setState(() {
      isLoading = true;
    });
    await getData(Provider.of<SiteShiftsData>(context, listen: false)
        .siteShiftList[siteId]
        .siteId);
    // await Provider.of<ShiftsData>(context, listen: false)
    //     .getShifts(comProvier.com.id, userProvider.user.userToken, context,
    //         userProvider.user.userType, userProvider.user.userSiteId)
    //     .then((value) async {
    //   print("got Shifts");
    // });
    setState(() {
      isLoading = false;
    });

    // await Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(
    //     Provider.of<SiteShiftsData>(context, listen: false)
    //         .siteShiftList[siteId]
    //         .siteId,
    //     false);
    refreshController.refreshCompleted();
  }

  void didChangeDependencies() async {
    isLoading = false;
    print("start state");
    super.didChangeDependencies();
    // await getData();
    getData(Provider.of<SiteShiftsData>(context, listen: false)
        .siteShiftList[siteId]
        .siteId);
    fillSites();
  }

  Future loadShift;
  getData(int siteId) async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    loadShift = Provider.of<ShiftsData>(context, listen: false)
        .getShiftsBySiteId(siteId, userProvider.user.userToken, context);
    // await fillList();
  }

  fillSites() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvier = Provider.of<CompanyData>(context);

    await Provider.of<SiteData>(context, listen: false)
        .getSitesByCompanyId(
      comProvier.com.id,
      userProvider.user.userToken,
      context,
    )
        .then((value) async {
      print("GOt Sites");
    });
  }

  bool isLoading = false;
  int getSiteName(String siteName) {
    var list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].siteName) {
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
        child: GestureDetector(
          onTap: () {
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
                          child: FutureBuilder(
                              future: loadShift,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.orange),
                                        ),
                                      ),
                                    );
                                  case ConnectionState.done:
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 5),
                                          child: SiteDropdown(
                                            edit: true,
                                            list: Provider.of<SiteShiftsData>(
                                                    context,
                                                    listen: true)
                                                .siteShiftList,
                                            colour: Colors.white,
                                            icon: Icons.location_on,
                                            borderColor: Colors.black,
                                            hint: "الموقع",
                                            hintColor: Colors.black,
                                            onChange: (value) async {
                                              // print()

                                              siteId = getSiteName(value);
                                              _onRefresh();
                                              Provider.of<SiteData>(context,
                                                      listen: false)
                                                  .setCurrentSiteName(value);
                                              print(
                                                  "site name from monawbat $value");
                                              print(Provider.of<SiteShiftsData>(
                                                      context,
                                                      listen: false)
                                                  .siteShiftList[siteId]
                                                  .siteId);
                                              // Provider.of<ShiftsData>(context,
                                              //         listen: false)
                                              //     .findMatchingShifts(
                                              //         Provider.of<SiteShiftsData>(
                                              //                 context,
                                              //                 listen: false)
                                              //             .siteShiftList[siteId]
                                              //             .siteId,
                                              //         false);
                                            },
                                            selectedvalue:
                                                Provider.of<SiteShiftsData>(
                                                        context)
                                                    .siteShiftList[siteId]
                                                    .siteName,
                                            textColor: Colors.orange,
                                          ),
                                        ),
                                        Consumer<ShiftsData>(
                                          builder: (context, value, child) {
                                            return Expanded(
                                                child:
                                                    value.shiftsList.isNotEmpty
                                                        ? SmartRefresher(
                                                            onRefresh:
                                                                _onRefresh,
                                                            controller:
                                                                refreshController,
                                                            enablePullDown:
                                                                true,
                                                            header:
                                                                WaterDropMaterialHeader(
                                                              color:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  Colors.orange,
                                                            ),
                                                            child: isLoading
                                                                ? Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      valueColor: new AlwaysStoppedAnimation<
                                                                              Color>(
                                                                          Colors
                                                                              .orange),
                                                                    ),
                                                                  )
                                                                : ListView
                                                                    .builder(
                                                                        itemCount: value
                                                                            .shiftsList
                                                                            .length,
                                                                        itemBuilder:
                                                                            (BuildContext context,
                                                                                int index) {
                                                                          return ShiftTile(
                                                                            siteName:
                                                                                value.shiftsList[index].shiftName,
                                                                            siteIndex:
                                                                                siteId,
                                                                            index:
                                                                                index,
                                                                            shift:
                                                                                value.shiftsList[index],
                                                                            onTapDelete:
                                                                                () {
                                                                              var token = Provider.of<UserData>(context, listen: false).user.userToken;
                                                                              return showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return RoundedAlert(
                                                                                        onPressed: () async {
                                                                                          showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return RoundedLoadingIndicator();
                                                                                              });
                                                                                          var msg = await shiftsData.deleteShift(value.shiftsList[index].shiftId, token, index, context);

                                                                                          if (msg == "Success") {
                                                                                            Navigator.pop(context);
                                                                                            Fluttertoast.showToast(msg: "تم الحذف بنجاح", toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1, backgroundColor: Colors.green, gravity: ToastGravity.CENTER, textColor: Colors.white, fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                                          } else if (msg == "hasData") {
                                                                                            Fluttertoast.showToast(msg: "خطأ في الحذف: هذه المناوبة تحتوي على مستخدمين. برجاء حذف المستخدمين اولا.", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.black, fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                                          } else if (msg == "failed") {
                                                                                            Fluttertoast.showToast(msg: "خطأ في اثناء الحذف.", gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.black, fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                                          } else if (msg == "noInternet") {
                                                                                            Fluttertoast.showToast(msg: "خطأ في الحذف: لا يوجد اتصال بالانترنت.", gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.black, fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                                          } else {
                                                                                            Fluttertoast.showToast(msg: "خطأ في الحذف.", gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.black, fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                                          }
                                                                                          Navigator.pop(context);
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        title: 'إزالة مناوبة',
                                                                                        content: "هل تريد إزالة${value.shiftsList[index].shiftName} ؟");
                                                                                  });
                                                                            },
                                                                            onTapEdit:
                                                                                () {
                                                                              print("aaaaaaaaa :${value.shiftsList[index].shiftId}");
                                                                              Navigator.of(context).push(
                                                                                new MaterialPageRoute(
                                                                                  builder: (context) => AddShiftScreen(value.shiftsList[index], index, true, siteId, widget.siteIndex),
                                                                                ),
                                                                              );
                                                                            },
                                                                          );
                                                                        }),
                                                          )
                                                        : Center(
                                                            child: Container(
                                                              height: 50,
                                                              child:
                                                                  AutoSizeText(
                                                                "لا يوجد مناوبات بهذا الموقع\nبرجاء اضافة مناوبة",
                                                                maxLines: 1,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    height: 2,
                                                                    fontSize: ScreenUtil().setSp(
                                                                        16,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                            ),
                                                          ));
                                          },
                                        ),
                                      ],
                                    );
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
                      : MultipleFloatingButtons(
                          mainTitle: "",
                          shiftName: "",
                          siteId: siteId,
                          comingFromShifts: false,
                          mainIconData: Icons.alarm_add_sharp)),
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
  var index;

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
      this.onTapDelete});

  @override
  _ShiftTileState createState() => _ShiftTileState();
}

class _ShiftTileState extends State<ShiftTile> {
  int siteId;

  String amPmChanger(int intTime) {
    int hours = (intTime ~/ 100);
    int min = intTime - (hours * 100);

    var ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours != 0 ? hours : 12; //

    String hoursStr = hours < 10
        ? '0$hours'
        : hours.toString(); // the hour '0' should be '12'
    String minStr = min < 10 ? '0$min' : min.toString();

    var strTime = '$hoursStr:$minStr$ampm';

    return strTime;
  }

  Widget build(BuildContext context) {
    var siteProv = Provider.of<SiteData>(context, listen: false);
    var shiftProv = Provider.of<ShiftsData>(context, listen: false);
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
                                    widget.shift.shiftName,
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
                              siteProv.setDropDownShift(
                                  widget.index); //الموقع علي حسب ال اندكس اللي
                              siteProv.setSiteValue(widget.siteName);
                              siteProv.fillCurrentShiftID(widget.shift.shiftId);
                              siteProv.setDropDownIndex(widget.siteIndex);
                              siteProv.fillCurrentShiftID(widget.shift.shiftId);

                              print("finding matching shifts");

                              var index = getSiteName(siteProv.currentSiteName);

                              Provider.of<SiteShiftsData>(context,
                                      listen: false)
                                  .getShiftsList(
                                      Provider.of<SiteShiftsData>(context,
                                              listen: false)
                                          .siteShiftList[index]
                                          .siteName,
                                      true);

                              siteProv.setDropDownShift(
                                  widget.index + 1); //+1 lw feh all shifts

                              // print(siteProv.sitesList[index].name);
                              // shiftProv.findMatchingShifts(siteProv.sitesList[0].name, ddallshiftsBool)
                              Navigator.of(context).push(
                                new MaterialPageRoute(
                                  builder: (context) => UsersScreen(
                                      widget.siteIndex + 1,
                                      true,
                                      widget.shift.shiftName),
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
    );
  }

  int getSiteName(String siteName) {
    var list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].siteName) {
        return i;
      }
    }
    return -1;
  }

  showShiftDetails() {
    String end = amPmChanger(widget.shift.shiftEndTime);
    String start = amPmChanger(widget.shift.shiftStartTime);
    String sunSt = amPmChanger(widget.shift.sunShiftstTime);
    String sunEn = amPmChanger(widget.shift.sunShiftenTime);
    String monSt = amPmChanger(widget.shift.monShiftstTime);
    String monEn = amPmChanger(widget.shift.mondayShiftenTime);
    String tuesSt = amPmChanger(widget.shift.tuesdayShiftstTime);
    String tuesEnd = amPmChanger(widget.shift.tuesdayShiftenTime);
    String wedSt = amPmChanger(widget.shift.wednesDayShiftstTime);
    String wedEn = amPmChanger(widget.shift.wednesDayShiftenTime);
    String thuSt = amPmChanger(widget.shift.thursdayShiftstTime);
    String thuEn = amPmChanger(widget.shift.thursdayShiftenTime);
    String friSt = amPmChanger(widget.shift.fridayShiftstTime);
    String friEn = amPmChanger(widget.shift.fridayShiftenTime);

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          var daysOff = Provider.of<DaysOffData>(context).weak;
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
                                      UserDataField(
                                        icon: Icons.location_on,
                                        text:
                                            Provider.of<SiteShiftsData>(context)
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
            child: Text(
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
