import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Reports/Services/Attend_Proof_Model.dart';
import 'package:qr_users/services/Reports/Widgets/attendProov.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/Reports/DailyReport/dailyReportTableHeader.dart';
import 'package:qr_users/widgets/Reports/displayReportButton.dart';
import 'package:qr_users/widgets/Shared/HandleNetwork_ServerDown/handleState.dart';

import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/Shared/Single_day_datePicker.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';

import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

class AttendProofReport extends StatefulWidget {
  @override
  _AttendProofReportState createState() => _AttendProofReportState();
}

class _AttendProofReportState extends State<AttendProofReport> {
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  String date;
  String selectedDateString;
  DateTime selectedDate;
  DateTime today;
  int siteIndex = 0;
  String currentSiteName = "";
  bool showTable = false;
  int siteID;
  void initState() {
    super.initState();
    siteID = Provider.of<SiteShiftsData>(context, listen: false)
        .siteShiftList[0]
        .siteId;
    date = apiFormatter.format(DateTime.now());
    // getReportData(date);
    selectedDateString = DateTime.now().toString();
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    selectedDate = DateTime(now.year, now.month, now.day);
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    debugPrint("starrt refresh");
    await getReportData(date, siteID);
    debugPrint("refresh");

    refreshController.refreshCompleted();
  }

  getReportData(date, siteId) async {
    final userProvider = Provider.of<UserData>(context, listen: false);

    await Provider.of<ReportsData>(context, listen: false)
        .getDailyAttendProofReport(
      userProvider.user.userToken,
      siteId,
      date,
      context,
    );
  }

  // int calculateDateDifference(DateTime date) {
  //   DateTime now = DateTime.now();
  //   return DateTime(date.year, date.month, date.day)
  //       .difference(DateTime(now.year, now.month, now.day))
  //       .inDays;
  // }

  final SlidableController slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    final comDate = Provider.of<CompanyData>(context, listen: false);
    final reprotData = Provider.of<ReportsData>(context, listen: true);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      floatingActionButton: MultipleFloatingButtonsNoADD(),
      endDrawer: NotificationItem(),
      backgroundColor: Colors.white,
      body: Consumer<ReportsData>(
        builder: (context, reportsData, child) {
          return Container(
            child: Stack(
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Header(
                    goUserHomeFromMenu: false,
                    nav: false,
                    goUserMenu: false,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.h),
                    child: SmallDirectoriesHeader(
                      Lottie.asset("resources/report.json", repeat: false),
                      getTranslated(context, "إثباتات الحضور"),
                    ),
                  ),
                  Container(
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: SiteDropdown(
                                  edit: true,
                                  list: Provider.of<SiteShiftsData>(context)
                                      .siteShiftList,
                                  colour: Colors.white,
                                  icon: Icons.location_on,
                                  borderColor: Colors.black,
                                  hint: getTranslated(context, "الموقع"),
                                  hintColor: Colors.black,
                                  height: 90,
                                  onChange: (value) async {
                                    siteIndex =
                                        getSiteIndexBySiteName(value, context);
                                    setState(() {
                                      showTable = false;
                                      siteID = Provider.of<SiteShiftsData>(
                                              context,
                                              listen: false)
                                          .siteShiftList[siteIndex]
                                          .siteId;
                                    });
                                  },
                                  selectedvalue:
                                      Provider.of<SiteShiftsData>(context)
                                          .siteShiftList[siteIndex]
                                          .siteName,
                                  textColor: ColorManager.primary),
                            ),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Container(
                                child: Theme(
                                    data: clockTheme,
                                    child: SingleDayDatePicker(
                                      firstDate: comDate.com.createdOn,
                                      lastDate: DateTime.now(),
                                      selectedDateString: selectedDateString,
                                      functionPicker: (value) {
                                        if (value != date) {
                                          date = value;
                                          selectedDateString = date;
                                          setState(() {
                                            selectedDate = DateTime.parse(
                                                selectedDateString);
                                            showTable = false;
                                          });
                                        }
                                      },
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showTable) ...[
                    FutureBuilder(
                        future: reportsData.futureListener,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Expanded(child: LoadingIndicator());
                            case ConnectionState.done:
                              return Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    orangeDivider,
                                    AttendProovTableHeader(),
                                    orangeDivider,
                                    Expanded(
                                      child: Container(
                                        color: Colors.white,
                                        child: reportsData
                                                    .attendProofList.length ==
                                                0
                                            ? CenterMessageText(
                                                message: getTranslated(context,
                                                    "لا يوجد إثباتات حضور فى هذا اليوم"))
                                            : reportsData.isLoading
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.orange,
                                                    ),
                                                  )
                                                : SmartRefresher(
                                                    onRefresh: _onRefresh,
                                                    controller:
                                                        refreshController,
                                                    enablePullDown: true,
                                                    header:
                                                        WaterDropMaterialHeader(
                                                            color: Colors.white,
                                                            backgroundColor:
                                                                ColorManager
                                                                    .primary),
                                                    child: ListView.builder(
                                                      physics:
                                                          const AlwaysScrollableScrollPhysics(),
                                                      itemCount: reportsData
                                                          .attendProofList
                                                          .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Slidable(
                                                          enabled: !reprotData
                                                              .attendProofList[
                                                                  index]
                                                              .isAttended,
                                                          actionExtentRatio:
                                                              0.10,
                                                          closeOnScroll: true,
                                                          controller:
                                                              slidableController,
                                                          actionPane:
                                                              const SlidableDrawerActionPane(),
                                                          secondaryActions: [
                                                            ZoomIn(
                                                              child: InkWell(
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(7),
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              10.h),
                                                                  decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Colors
                                                                          .white,
                                                                      border: Border.all(
                                                                          width:
                                                                              2,
                                                                          color:
                                                                              Colors.red)),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .delete,
                                                                    size: 18,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  return showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return reprotData.isLoading
                                                                            ? Center(
                                                                                child: CircularProgressIndicator(
                                                                                  backgroundColor: ColorManager.primary,
                                                                                ),
                                                                              )
                                                                            : RoundedAlert(
                                                                                onPressed: () async {
                                                                                  Navigator.pop(context);
                                                                                  final String msg = await Provider.of<ReportsData>(context, listen: false).deleteAttendProofFromReport(Provider.of<UserData>(context, listen: false).user.userToken, reportsData.attendProofList[index].id, index);
                                                                                  if (msg == "Success : AttendProof Deleted!") {
                                                                                    Fluttertoast.showToast(msg: getTranslated(navigatorKey.currentState.overlay.context, "تم الحذف بنجاح"), backgroundColor: Colors.green);
                                                                                  } else if (msg == "Fail : Proof created by another user") {
                                                                                    Fluttertoast.showToast(msg: getTranslated(navigatorKey.currentState.overlay.context, "لا يمكنك حذف طلب تسجيل حضور لم تقم بإنشاؤه"), backgroundColor: Colors.red, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
                                                                                  } else {
                                                                                    Fluttertoast.showToast(msg: getTranslated(navigatorKey.currentState.overlay.context, "خطأ في حذف الإثبات"), backgroundColor: Colors.red);
                                                                                  }
                                                                                },
                                                                                content: getTranslated(context, "هل تريد حذف الإثبات"),
                                                                                onCancel: () {},
                                                                                title: getTranslated(context, "حذف الإثبات"),
                                                                              );
                                                                      });
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                          child:
                                                              DisplayAttendProofList(
                                                            attendProofList:
                                                                reportsData
                                                                        .attendProofList[
                                                                    index],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            default:
                              return const Center(
                                  child: const LoadingIndicator());
                          }
                        }),
                  ] else ...[
                    Container(
                      width: 400.w,
                      height: 300.h,
                      child: Lottie.asset("resources/displayReport.json",
                          fit: BoxFit.fill),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Flexible(
                      flex: 1,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            getReportData(date, siteID);
                            setState(() {
                              showTable = true;
                            });
                          },
                          child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5),
                              width: 150.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2, color: ColorManager.primary),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const DisplayReportButton()),
                        ),
                      ),
                    )
                  ],
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
