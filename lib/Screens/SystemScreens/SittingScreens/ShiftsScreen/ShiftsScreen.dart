import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/MLmodule/widgets/ShiftsTile/shift_tile.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/api.dart';

import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import "package:qr_users/services/Sites_data.dart";
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

import '../../../../services/ShiftsData.dart';
import '../../../../services/Sites_data.dart';

class ShiftsScreen extends StatefulWidget {
  final siteId;
  final isFromSites;
  final siteIndex;

  const ShiftsScreen(this.siteId, this.isFromSites, this.siteIndex);

  @override
  _ShiftsScreenState createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  int siteId = 0;
  @override
  void initState() {
    // x
    super.initState();
    Provider.of<SiteData>(context, listen: false).pageIndex = 0;
    debugPrint("init state");
    siteId = widget.siteId;
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    debugPrint("refresh");
    // if failed,use refreshFailed()
    setState(() {
      isLoading = true;
    });
    await (Provider.of<SiteShiftsData>(context, listen: false)
        .getShiftsList(siteName, false));

    setState(() {
      isLoading = false;
    });

    refreshController.refreshCompleted();
  }

  String siteName;
  void didChangeDependencies() async {
    isLoading = false;
    debugPrint("start state");
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
        child: Scaffold(
            endDrawer: NotificationItem(),
            backgroundColor: Colors.white,
            body: Container(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Header(
                        nav: false,
                        goUserHomeFromMenu: true,
                      ),

                      ///Title
                      SmallDirectoriesHeader(
                          Lottie.asset("resources/shiftLottie.json",
                              repeat: false),
                          getTranslated(context, "دليل المناوبات")),

                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: SiteDropdown(
                                edit: true,
                                height: 40,
                                list: Provider.of<SiteShiftsData>(context,
                                        listen: false)
                                    .siteShiftList,
                                colour: Colors.white,
                                icon: Icons.location_on,
                                borderColor: Colors.black,
                                hint: "الموقع",
                                hintColor: Colors.black,
                                onChange: (value) async {
                                  // debugPrint()

                                  siteId = getSiteName(value);
                                  siteName = Provider.of<SiteShiftsData>(
                                          context,
                                          listen: false)
                                      .siteShiftList[siteId]
                                      .siteName;
                                  _onRefresh();
                                  Provider.of<SiteData>(context, listen: false)
                                      .setCurrentSiteName(value);

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
                                    child: value.dropDownShifts[0].shiftId == 0
                                        ? Center(
                                            child: Container(
                                              height: 50.h,
                                              child: AutoSizeText(
                                                getTranslated(context,
                                                    "لا يوجد مناوبات بهذا الموقع\nبرجاء اضافة مناوبة"),
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    height: 2,
                                                    fontSize: ScreenUtil().setSp(
                                                        17,
                                                        allowFontScalingSelf:
                                                            true),
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          )
                                        : SmartRefresher(
                                            onRefresh: _onRefresh,
                                            controller: refreshController,
                                            enablePullDown: true,
                                            header:
                                                const WaterDropMaterialHeader(
                                              color: Colors.white,
                                              backgroundColor: Colors.orange,
                                            ),
                                            child: ListView.builder(
                                                itemCount:
                                                    value.dropDownShifts.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return ShiftTile(
                                                    shifts: value
                                                        .dropDownShifts[index],
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
                                                                          .dropDownShifts[
                                                                              index]
                                                                          .shiftId,
                                                                      token,
                                                                      index,
                                                                      context);

                                                                  if (msg ==
                                                                      "Success") {
                                                                    Provider.of<SiteShiftsData>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .getShiftsList(
                                                                            Provider.of<SiteShiftsData>(context, listen: false).siteShiftList[widget.siteIndex].siteName,
                                                                            false);
                                                                    // Navigator.pop(context);
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
                                                                    "${getTranslated(context, "هل تريد إزالة")} ${value.dropDownShifts[index].shiftName} ؟");
                                                          });
                                                    },
                                                    onTapEdit: () async {
                                                      Shift currentShift;
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return RoundedLoadingIndicator();
                                                          });
                                                      currentShift =
                                                          await Provider.of<
                                                                      ShiftApi>(
                                                                  context,
                                                                  listen: false)
                                                              .getShiftByShiftId(
                                                        value
                                                            .dropDownShifts[
                                                                index]
                                                            .shiftId,
                                                      )
                                                            ..shiftId = value
                                                                .dropDownShifts[
                                                                    index]
                                                                .shiftId
                                                            ..siteID = value
                                                                .siteShiftList[
                                                                    siteId]
                                                                .siteId;

                                                      Navigator.pop(context);
                                                      print(widget.siteIndex);
                                                      Navigator.of(context)
                                                          .push(
                                                        new MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddShiftScreen(
                                                                  currentShift,
                                                                  index,
                                                                  true,
                                                                  siteId,
                                                                  widget
                                                                      .siteIndex),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }),
                                          ));
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
                                    builder: (context) =>
                                        const NavScreenTwo(3)),
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
                Provider.of<UserData>(context, listen: false).user.userType == 4
                    ? MultipleFloatingButtons(
                        mainTitle: getTranslated(context, "إضافة مناوبة"),
                        shiftName: "",
                        siteId: siteId,
                        comingFromShifts: false,
                        mainIconData: Icons.alarm_add_sharp)
                    : MultipleFloatingButtonsNoADD()),
      );
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
