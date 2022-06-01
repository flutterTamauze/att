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
import 'package:qr_users/MLmodule/widgets/ShiftsTile/shift_tile.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/site_shifts_all.dart';
import 'package:qr_users/services/ShiftsData.dart';

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
  Future siteAdminShifts;
  @override
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    fillList();

    refreshController.refreshCompleted();
  }

  void didChangeDependencies() async {
    isLoading = false;
    print(Provider.of<ShiftsData>(context, listen: false).shiftsList.length);
    if (Provider.of<ShiftsData>(context, listen: false).shiftsList.isEmpty) {
      fillList();
    }

    super.didChangeDependencies();
  }

  fillList() async {
    siteAdminShifts = Provider.of<ShiftsData>(context, listen: false)
        .getShifts(
            Provider.of<UserData>(context, listen: false).user.userSiteId,
            Provider.of<UserData>(context, listen: false).user.userToken,
            context,
            2,
            Provider.of<UserData>(context, listen: false).user.userSiteId)
        .then((value) async => await Provider.of<ShiftsData>(context,
                listen: false)
            .findMatchingShifts(
                Provider.of<UserData>(context, listen: false).user.userSiteId,
                false));
  }

  bool isLoading = false;

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
                    Header(
                      nav: false,
                      onTab: () {},
                      goUserMenu: false,
                      goUserHomeFromMenu: false,
                    ),

                    ///Title
                    SmallDirectoriesHeader(
                      Lottie.asset("resources/shiftLottie.json", repeat: false),
                      getTranslated(context, "دليل المناوبات"),
                    ),

                    FutureBuilder(
                        future: siteAdminShifts,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Expanded(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ColorManager.primary,
                                ),
                              ),
                            );
                          }
                          return Expanded(
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
                                              header:
                                                  const WaterDropMaterialHeader(
                                                color: Colors.white,
                                                backgroundColor: Colors.orange,
                                              ),
                                              child: isLoading
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.white,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.orange),
                                                      ),
                                                    )
                                                  : ListView.builder(
                                                      itemCount: value
                                                          .shiftsList.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return ShiftTile(
                                                          siteName: value
                                                              .shiftsList[index]
                                                              .shiftName,
                                                          shifts: Shifts(
                                                              shiftName: value
                                                                  .shiftsList[
                                                                      index]
                                                                  .shiftName,
                                                              shiftEntime: value
                                                                  .shiftsList[
                                                                      index]
                                                                  .shiftEndTime
                                                                  .toString(),
                                                              shiftStTime: value
                                                                  .shiftsList[
                                                                      index]
                                                                  .shiftStartTime
                                                                  .toString(),
                                                              shiftId: value
                                                                  .shiftsList[
                                                                      index]
                                                                  .shiftId),
                                                          siteIndex: siteId,
                                                          index: index,
                                                          shift:
                                                              value.shiftsList[
                                                                  index],
                                                          onTapDelete: () {
                                                            final token =
                                                                Provider.of<UserData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .user
                                                                    .userToken;
                                                            return showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return RoundedAlert(
                                                                      onPressed:
                                                                          () async {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return RoundedLoadingIndicator();
                                                                            });
                                                                        final msg = await shiftsData.deleteShift(
                                                                            value.shiftsList[index].shiftId,
                                                                            token,
                                                                            index,
                                                                            context);

                                                                        if (msg ==
                                                                            "Success") {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Fluttertoast.showToast(
                                                                              msg: getTranslated(context, "تم الحذف بنجاح"),
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              timeInSecForIosWeb: 1,
                                                                              backgroundColor: Colors.green,
                                                                              gravity: ToastGravity.CENTER,
                                                                              textColor: Colors.white,
                                                                              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                        } else if (msg ==
                                                                            "hasData") {
                                                                          Fluttertoast.showToast(
                                                                              msg: getTranslated(context, "خطأ في الحذف: هذه المناوبة تحتوي على مستخدمين. برجاء حذف المستخدمين اولا"),
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              gravity: ToastGravity.CENTER,
                                                                              timeInSecForIosWeb: 1,
                                                                              backgroundColor: Colors.red,
                                                                              textColor: Colors.black,
                                                                              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                        } else if (msg ==
                                                                            "failed") {
                                                                          Fluttertoast.showToast(
                                                                              msg: getTranslated(context, "خطأ في الحذف"),
                                                                              gravity: ToastGravity.CENTER,
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              timeInSecForIosWeb: 1,
                                                                              backgroundColor: Colors.red,
                                                                              textColor: Colors.black,
                                                                              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
                                                                        } else if (msg ==
                                                                            "noInternet") {
                                                                          Fluttertoast.showToast(
                                                                              msg: getTranslated(context, "خطأ في الحذف : لا يوجد اتصال بالانترنت"),
                                                                              gravity: ToastGravity.CENTER,
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              timeInSecForIosWeb: 1,
                                                                              backgroundColor: Colors.red,
                                                                              textColor: Colors.black,
                                                                              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
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
                                                            Navigator.of(
                                                                    context)
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
                                                      fontSize: ScreenUtil().setSp(
                                                          16,
                                                          allowFontScalingSelf:
                                                              true),
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ),
                                            ));
                                },
                              ),
                            ],
                          ));
                        })
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
