import 'dart:io';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Sites_data.dart';

import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/UserReport/UserReportDataTable.dart';
import 'package:qr_users/widgets/UserReport/UserReportDataTableEnd.dart';
import 'package:qr_users/widgets/UserReport/UserReportTableHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NormalUserReport extends StatefulWidget {
  final String name;
  final int siteId;
  // getUserReportUnits
  NormalUserReport({this.name, this.siteId});

  @override
  _NormalUserReportState createState() => _NormalUserReportState();
}

class _NormalUserReportState extends State<NormalUserReport> {
  TextEditingController _dateController = TextEditingController();

  TextEditingController _nameController = TextEditingController();
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Member>> key = new GlobalKey();

  DateTime toDate;
  DateTime fromDate;

  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');

  String dateToString = "";
  String dateFromString = "";

  String selectedId = "";
  Site siteData;
  DateTime yesterday;
  void didChangeDependencies() {
    final String fromText =
        " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
    final String toText =
        " ${getTranslated(context, "إلى")} ${DateFormat('yMMMd').format(toDate).toString()}";

    _dateController.text = "$fromText $toText";
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final int legalDay =
        Provider.of<CompanyData>(context, listen: false).com.legalComDate;
    fromDate = DateTime(now.year, now.month,
        Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    toDate = DateTime(now.year, now.month, now.day - 1);
    yesterday = DateTime(now.year, now.month, now.day - 1);
    if (toDate.isBefore(fromDate)) {
      fromDate = DateTime(now.year, now.month - 1,
          Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    }
    final comProv = Provider.of<CompanyData>(context, listen: false);
    if (fromDate.isBefore(comProv.com.createdOn)) {
      fromDate = comProv.com.createdOn;
    }
    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    final String fromText =
        " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    final String toText =
        " إلى ${DateFormat('yMMMd').format(toDate).toString()}";

    _dateController.text = "$fromText $toText";

    // getMembersData();
    Provider.of<ReportsData>(context, listen: false).userAttendanceReport =
        new UserAttendanceReport(
            userAttendListUnits: [],
            totalAbsentDay: 0,
            totalLateDay: 0,
            totalLateDuration: "",
            totalLateDeduction: -1,
            isDayOff: 0,
            totalDeduction: 0,
            totalDeductionAbsent: 0,
            totalOfficialVacation: 0);
    selectedId = Provider.of<UserData>(context, listen: false).user.id;
    Provider.of<ReportsData>(context, listen: false).getUserReportUnits(
        Provider.of<UserData>(context, listen: false).user.userToken,
        selectedId,
        dateFromString,
        dateToString,
        context);
  }

  int siteId = 0;
  int siteIdIndex = 0;
  final focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    return Consumer<ReportsData>(
      builder: (context, reportsData, child) {
        return WillPopScope(
          onWillPop: onWillPop,
          child: GestureDetector(
            onTap: () {
              _nameController.text == ""
                  ? FocusScope.of(context).unfocus()
                  : SystemChannels.textInput.invokeMethod('TextInput.hide');
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
                        Header(
                          goUserHomeFromMenu: false,
                          nav: false,
                          goUserMenu: false,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SmallDirectoriesHeader(
                              Lottie.asset("resources/report.json",
                                  repeat: false),
                              getTranslated(context, "تقرير الحضور"),
                            ),
                          ],
                        ),
                        Expanded(
                          child: FutureBuilder(
                              future: Provider.of<ReportsData>(context,
                                      listen: true)
                                  .futureListener,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: Platform.isIOS
                                            ? const CupertinoActivityIndicator(
                                                radius: 20,
                                              )
                                            : const CircularProgressIndicator(
                                                backgroundColor: Colors.white,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.orange),
                                              ),
                                      ),
                                    );
                                  case ConnectionState.done:
                                    return Column(
                                      children: [
                                        Container(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Theme(
                                              data: clockTheme1,
                                              child: Builder(
                                                builder: (context) {
                                                  return InkWell(
                                                      onTap: () async {
                                                        final List<DateTime>
                                                            picked =
                                                            await DateRagePicker.showDatePicker(
                                                                context:
                                                                    context,
                                                                initialFirstDate:
                                                                    fromDate,
                                                                initialLastDate:
                                                                    toDate,
                                                                firstDate:
                                                                    new DateTime(
                                                                        2021),
                                                                lastDate:
                                                                    yesterday);
                                                        var newString = "";
                                                        setState(() {
                                                          fromDate =
                                                              picked.first;
                                                          toDate = picked.last;
                                                          // selectedDuration = kCalcDateDifferance(
                                                          //     fromDate.toString(), toDate.toString());
                                                          // selectedDuration += 1;
                                                          final String
                                                              fromText =
                                                              " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                          final String toText =
                                                              " ${getTranslated(context, "إلى")} ${DateFormat('yMMMd').format(toDate).toString()}";
                                                          newString =
                                                              "$fromText $toText";
                                                        });

                                                        if (_dateController
                                                                .text !=
                                                            newString) {
                                                          _dateController.text =
                                                              newString;

                                                          dateFromString =
                                                              apiFormatter
                                                                  .format(
                                                                      fromDate);
                                                          dateToString =
                                                              apiFormatter
                                                                  .format(
                                                                      toDate);

                                                          await Provider.of<
                                                                      ReportsData>(
                                                                  context,
                                                                  listen: false)
                                                              .getUserReportUnits(
                                                                  Provider.of<UserData>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .user
                                                                      .userToken,
                                                                  selectedId,
                                                                  dateFromString,
                                                                  dateToString,
                                                                  context);
                                                        }
                                                      },
                                                      child: Directionality(
                                                        textDirection: ui
                                                            .TextDirection.rtl,
                                                        child: Container(
                                                          width: 330.w,
                                                          child: IgnorePointer(
                                                            child:
                                                                TextFormField(
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              controller:
                                                                  _dateController,
                                                              decoration: kTextFieldDecorationFromTO
                                                                  .copyWith(
                                                                      hintText: getTranslated(
                                                                          context,
                                                                          "المدة من / إلى"),
                                                                      prefixIcon:
                                                                          const Icon(
                                                                        Icons
                                                                            .calendar_today_rounded,
                                                                        color: Colors
                                                                            .orange,
                                                                      )),
                                                            ),
                                                          ),
                                                        ),
                                                      ));
                                                },
                                              ),
                                            ),
                                          ],
                                        )),
                                        Expanded(
                                          child: FutureBuilder(
                                              future: Provider.of<ReportsData>(
                                                      context)
                                                  .futureListener,
                                              builder: (context, snapshot) {
                                                switch (
                                                    snapshot.connectionState) {
                                                  case ConnectionState.waiting:
                                                    return Container(
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: Platform.isIOS
                                                            ? const CupertinoActivityIndicator()
                                                            : const CircularProgressIndicator(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                valueColor:
                                                                    const AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Colors
                                                                            .orange),
                                                              ),
                                                      ),
                                                    );
                                                  case ConnectionState.done:
                                                    return reportsData
                                                                .userAttendanceReport
                                                                .isDayOff !=
                                                            1
                                                        ? reportsData
                                                                    .userAttendanceReport
                                                                    .userAttendListUnits
                                                                    .length !=
                                                                0
                                                            ? Container(
                                                                color: Colors
                                                                    .white,
                                                                child:
                                                                    Directionality(
                                                                        textDirection: ui
                                                                            .TextDirection
                                                                            .rtl,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Divider(
                                                                              thickness: 1,
                                                                              color: ColorManager.primary,
                                                                            ),
                                                                            UserReportTableHeader(),
                                                                            Divider(
                                                                              thickness: 1,
                                                                              color: ColorManager.primary,
                                                                            ),
                                                                            Expanded(
                                                                                child: Container(
                                                                                    child: snapshot.data == "user created after period"
                                                                                        ? Container(
                                                                                            child: Center(
                                                                                              child: AutoSizeText(getTranslated(context, "المستخدم لم يكن مقيدا فى هذة الفترة"), style: boldStyle),
                                                                                            ),
                                                                                          )
                                                                                        : ListView.builder(
                                                                                            itemCount: reportsData.userAttendanceReport.userAttendListUnits.length,
                                                                                            itemBuilder: (BuildContext context, int index) {
                                                                                              return UserReportDataTableRow(reportsData.userAttendanceReport.userAttendListUnits[index]);
                                                                                            }))),
                                                                            UserReprotDataTableEnd(reportsData.userAttendanceReport)
                                                                          ],
                                                                        )),
                                                              )
                                                            : Row(
                                                                children: [
                                                                  Expanded(
                                                                      child:
                                                                          Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            20,
                                                                        child:
                                                                            AutoSizeText(
                                                                          getTranslated(
                                                                              context,
                                                                              "لا يوجد تسجيلات بهذا المستخدم"),
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              boldStyle,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )),
                                                                ],
                                                              )
                                                        : Row(
                                                            children: [
                                                              Expanded(
                                                                  child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    height: 20,
                                                                    child:
                                                                        AutoSizeText(
                                                                      getTranslated(
                                                                        context,
                                                                        "لا يوجد تسجيلات: يوم اجازة",
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize: ScreenUtil().setSp(
                                                                              16,
                                                                              allowFontScalingSelf:
                                                                                  true),
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                            ],
                                                          );
                                                  default:
                                                    return const Center(
                                                      child:
                                                          const CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.white,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.orange),
                                                      ),
                                                    );
                                                }
                                              }),
                                        )
                                      ],
                                    );
                                  default:
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                            widget.name != ""
                                ? Navigator.pop(context)
                                : Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NavScreenTwo(2)),
                                    (Route<dynamic> route) => false);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> onWillPop() {
    widget.name != ""
        ? Navigator.pop(context)
        : Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => NavScreenTwo(2)),
            (Route<dynamic> route) => false);
    return Future.value(false);
  }
}
