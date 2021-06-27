import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Shift.dart';

import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import "package:qr_users/services/Sites_data.dart";

import '../../../../services/ShiftsData.dart';
import '../../../../services/Sites_data.dart';

class ShiftsScreen extends StatefulWidget {
  final siteId;
  final isFromSites;

  ShiftsScreen(this.siteId, this.isFromSites);

  @override
  _ShiftsScreenState createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  int siteId = 0;
  @override
  void initState() {
    // x
    super.initState();
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
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvier = Provider.of<CompanyData>(context, listen: false);
    // monitor network fetch
    print("refresh");
    // if failed,use refreshFailed()
    setState(() {
      isLoading = true;
    });
    await Provider.of<ShiftsData>(context, listen: false)
        .getAllCompanyShifts(
            comProvier.com.id, userProvider.user.userToken, context)
        .then((value) async {
      print("got Shifts");
    });
    setState(() {
      isLoading = false;
    });

    await Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(
        Provider.of<SiteData>(context, listen: false).sitesList[siteId].id,
        false);
    refreshController.refreshCompleted();
  }

  void didChangeDependencies() async {
    isLoading = false;
    if (mounted) {}

    super.didChangeDependencies();
    await getData();
  }

  getData() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvier = Provider.of<CompanyData>(context);

    if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
      await Provider.of<SiteData>(context, listen: false)
          .getSitesByCompanyId(
              comProvier.com.id, userProvider.user.userToken, context)
          .then((value) async {
        print("GOt Sites");
      });
    }
    if (Provider.of<ShiftsData>(context, listen: false).shiftsList.isEmpty) {
      await Provider.of<ShiftsData>(context, listen: false)
          .getAllCompanyShifts(
              comProvier.com.id, userProvider.user.userToken, context)
          .then((value) async {
        print("got Shifts");
      });
    }
    await fillList();
  }

  fillList() async {
    await Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(
        Provider.of<SiteData>(context, listen: false).sitesList[siteId].id,
        false);
  }

  bool isLoading = false;
  int getSiteName(String siteName) {
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
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
                            future:
                                Provider.of<SiteData>(context).futureListener,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
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
                              return FutureBuilder(
                                  future: shiftsData.futureListener,
                                  builder: (context, snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return Container(
                                          color: Colors.white,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.white,
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(Colors.orange),
                                            ),
                                          ),
                                        );
                                      case ConnectionState.done:
                                        return Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                              child: SiteDropdown(
                                                edit: true,
                                                list: Provider.of<SiteData>(
                                                        context,
                                                        listen: true)
                                                    .sitesList,
                                                colour: Colors.white,
                                                icon: Icons.location_on,
                                                borderColor: Colors.black,
                                                hint: "الموقع",
                                                hintColor: Colors.black,
                                                onChange: (value) async {
                                                  // print()

                                                  _onRefresh();
                                                  siteId = getSiteName(value);
                                                  Provider.of<SiteData>(context,
                                                          listen: false)
                                                      .setCurrentSiteName(
                                                          value);
                                                  print(
                                                      "site name from monawbat $value");

                                                  Provider.of<ShiftsData>(
                                                          context,
                                                          listen: false)
                                                      .findMatchingShifts(
                                                          Provider.of<SiteData>(
                                                                  context,
                                                                  listen: false)
                                                              .sitesList[siteId]
                                                              .id,
                                                          false);
                                                },
                                                selectedvalue:
                                                    Provider.of<SiteData>(
                                                            context)
                                                        .sitesList[siteId]
                                                        .name,
                                                textColor: Colors.orange,
                                              ),
                                            ),
                                            Expanded(
                                                child: shiftsData
                                                            .shiftsBySite[0]
                                                            .shiftStartTime !=
                                                        -1
                                                    ? SmartRefresher(
                                                        onRefresh: _onRefresh,
                                                        controller:
                                                            refreshController,
                                                        enablePullDown: true,
                                                        header:
                                                            WaterDropMaterialHeader(
                                                          color: Colors.white,
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
                                                            : ListView.builder(
                                                                itemCount:
                                                                    shiftsData
                                                                        .shiftsBySite
                                                                        .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  return ShiftTile(
                                                                    siteName: shiftsData
                                                                        .shiftsBySite[
                                                                            index]
                                                                        .shiftName,
                                                                    siteIndex:
                                                                        siteId,
                                                                    index:
                                                                        index,
                                                                    shift: shiftsData
                                                                            .shiftsBySite[
                                                                        index],
                                                                    onTapDelete:
                                                                        () {
                                                                      var token = Provider.of<UserData>(
                                                                              context,
                                                                              listen: false)
                                                                          .user
                                                                          .userToken;
                                                                      return showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return RoundedAlert(
                                                                                onPressed: () async {
                                                                                  showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) {
                                                                                        return RoundedLoadingIndicator();
                                                                                      });
                                                                                  var msg = await shiftsData.deleteShift(shiftsData.shiftsBySite[index].shiftId, token, index, context);

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
                                                                                content: "هل تريد إزالة${shiftsData.shiftsBySite[index].shiftName} ؟");
                                                                          });
                                                                    },
                                                                    onTapEdit:
                                                                        () {
                                                                      print(
                                                                          "aaaaaaaaa :${shiftsData.shiftsBySite[index].shiftId}");
                                                                      Navigator.of(
                                                                              context)
                                                                          .push(
                                                                        new MaterialPageRoute(
                                                                          builder: (context) => AddShiftScreen(
                                                                              shiftsData.shiftsBySite[index],
                                                                              index,
                                                                              true,
                                                                              siteId),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                }),
                                                      )
                                                    : Center(
                                                        child: Container(
                                                          height: 20,
                                                          child: AutoSizeText(
                                                            "لا يوجد مناوبات بهذا الموقع\nبرجاء اضافة مناوبة",
                                                            maxLines: 1,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                height: 2,
                                                                fontSize: ScreenUtil()
                                                                    .setSp(16,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      )),
                                          ],
                                        );
                                      default:
                                        return Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(Colors.orange),
                                          ),
                                        );
                                    }
                                  });
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: FloatingActionButton(
              tooltip: "اضافة مناوبة",
              splashColor: Colors.white,
              elevation: 5,
              backgroundColor: Colors.orange[600],
              child: Icon(
                Icons.alarm_add_sharp,
                color: Colors.black,
                size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddShiftScreen(Shift(), 0, false, siteId)),
                );
              },
            )),
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
  @override
  void initState() {
    // TODO: implement initStat
    super.initState();
  }

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
                                  height: 20,
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
                              siteProv.setDropDownShift(widget.index);
                              siteProv.setSiteValue(widget.siteName);
                              siteProv.fillCurrentShiftID(
                                  Provider.of<ShiftsData>(context,
                                          listen: false)
                                      .shiftsBySite[widget.index]
                                      .shiftId);
                              siteProv.setDropDownShift(widget.index + 1);

                              siteProv.fillCurrentShiftID(
                                  Provider.of<ShiftsData>(context,
                                          listen: false)
                                      .shiftsBySite[widget.index]
                                      .shiftId);
                              print(siteProv.sitesList[widget.siteIndex].name);
                              print("finding matching shifts");
                              shiftProv.findMatchingShifts(
                                  siteProv.sitesList[widget.siteIndex].id,
                                  true);
                              // var index = getSiteName(siteProv.currentSiteName);

                              // print(siteProv.sitesList[index].name);
                              // shiftProv.findMatchingShifts(siteProv.sitesList[0].name, ddallshiftsBool)
                              Navigator.of(context).push(
                                new MaterialPageRoute(
                                  builder: (context) => UsersScreen(
                                    widget.siteIndex + 1,
                                    true,
                                  ),
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
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
  }

  showShiftDetails() {
    String end = amPmChanger(widget.shift.shiftEndTime);
    String start = amPmChanger(widget.shift.shiftStartTime);

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
                      height: 350.h,
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
                                        text: Provider.of<SiteData>(context)
                                            .sitesList[widget.siteIndex]
                                            .name,
                                      ),
                                      SizedBox(
                                        height: 10.0.h,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: dateDataField(
                                                controller:
                                                    TextEditingController(
                                                        text: start),
                                                icon: Icons.alarm,
                                                labelText: "من"),
                                          ),
                                          SizedBox(
                                            width: 5.0.w,
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: dateDataField(
                                                controller:
                                                    TextEditingController(
                                                        text: end),
                                                icon: Icons.alarm,
                                                labelText: "الى"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Padding(
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
