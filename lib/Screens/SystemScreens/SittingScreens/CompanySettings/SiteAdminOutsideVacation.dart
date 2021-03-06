import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';

import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import '../../../../Core/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

class SiteAdminOutsideVacation extends StatefulWidget {
  final Member member;
  int radioValue;
  final List<String> permessionTitles;
  final List<String> holidayTitles;
  SiteAdminOutsideVacation(
      this.member, this.radioValue, this.permessionTitles, this.holidayTitles);
  @override
  _SiteAdminOutsideVacationState createState() =>
      _SiteAdminOutsideVacationState();
}

var sleectedMember;
DateTime toDate;
String toText;
String fromText;
DateTime fromDate;
DateTime yesterday, tomorrow, _today;
TextEditingController timeOutController = TextEditingController();
String dateToString = "";
String dateFromString = "";
String newString = "";
List<String> missions = ["????????????", "????????????"];
TimeOfDay toPicked;
String dateDifference;
List<DateTime> picked = [];
String formattedTime;
String _selectedDateString;
Future userHoliday;
Future userPermession;
Future userMission;
TextEditingController externalMissionController = TextEditingController();

class _SiteAdminOutsideVacationState extends State<SiteAdminOutsideVacation> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool isPicked = false;

  TextEditingController _dateController = TextEditingController();

  List<DateTime> picked = [];

  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    isPicked = false;

    var now = DateTime.now();
    fromText = "";
    toText = "";

    commentController.text = "";
    timeOutController.text = "";
    externalMissionController.text = "";
    toPicked = (intToTimeOfDay(0));
    toDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    tomorrow = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    fromDate = tomorrow;
    _selectedDateString = tomorrow.toString();
    yesterday = DateTime(now.year, DateTime.december, 30);
    _today = DateTime.now();
    sleectedMember =
        Provider.of<MemberData>(context, listen: false).membersList[0].name;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return GestureDetector(
        onTap: () {
          print(externalMissionController.text);
          _nameController.text == ""
              ? FocusScope.of(context).unfocus()
              : SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Header(
                  nav: false,
                  goUserMenu: false,
                  goUserHomeFromMenu: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SmallDirectoriesHeader(
                                  Lottie.asset("resources/calender.json",
                                      repeat: false),
                                  "???????????????? ?? ????????????????????",
                                ),
                              ],
                            ),
                          ),
                          VacationCardHeader(
                            header:
                                "?????????? ?????? ???????????????? : ${widget.member.name}",
                          ),
                          VacationCardHeader(
                            header: "?????? ??????????",
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RadioButtonWidg(
                                  radioVal2: widget.radioValue,
                                  radioVal: 3,
                                  title: "??????",
                                  onchannge: (value) {
                                    setState(() {
                                      widget.radioValue = value;
                                    });
                                  },
                                ),
                                RadioButtonWidg(
                                  radioVal2: widget.radioValue,
                                  radioVal: 1,
                                  title: "??????????",
                                  onchannge: (value) {
                                    setState(() {
                                      widget.radioValue = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          widget.radioValue == 1
                              ? Column(
                                  children: [
                                    VacationCardHeader(
                                      header: "?????? ??????????????",
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                        child: Theme(
                                      data: clockTheme1,
                                      child: Builder(
                                        builder: (context) {
                                          return InkWell(
                                              onTap: () async {
                                                picked = await DateRagePicker
                                                    .showDatePicker(
                                                        context: context,
                                                        initialFirstDate:
                                                            selectedReason ==
                                                                    "??????????"
                                                                ? _today
                                                                : tomorrow,
                                                        initialLastDate: toDate,
                                                        firstDate: DateTime(
                                                            DateTime.now().year,
                                                            DateTime.now()
                                                                .month,
                                                            selectedReason ==
                                                                    "??????????"
                                                                ? DateTime.now()
                                                                    .day
                                                                : DateTime.now()
                                                                        .day +
                                                                    1),
                                                        lastDate: yesterday);

                                                setState(() {
                                                  _today = picked.first;
                                                  tomorrow = picked.first;
                                                  fromDate = picked.first;
                                                  toDate = picked.last;
                                                  dateDifference = (toDate
                                                              .difference(
                                                                  fromDate)
                                                              .inDays +
                                                          1)
                                                      .toString();
                                                  fromText =
                                                      " ???? ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                  toText =
                                                      " ?????? ${DateFormat('yMMMd').format(toDate).toString()}";
                                                  newString =
                                                      "$fromText $toText";
                                                });

                                                if (_dateController.text !=
                                                    newString) {
                                                  _dateController.text =
                                                      newString;

                                                  dateFromString = apiFormatter
                                                      .format(fromDate);
                                                  dateToString = apiFormatter
                                                      .format(toDate);
                                                }
                                              },
                                              child: Directionality(
                                                textDirection:
                                                    ui.TextDirection.rtl,
                                                child: Container(
                                                  // width: 330,
                                                  width: 365.w,
                                                  child: IgnorePointer(
                                                    child: TextFormField(
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      controller:
                                                          _dateController,
                                                      decoration:
                                                          kTextFieldDecorationFromTO
                                                              .copyWith(
                                                                  hintText:
                                                                      '?????????? ???? / ??????',
                                                                  prefixIcon:
                                                                      Icon(
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
                                    )),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    dateDifference != null
                                        ? fromText == ""
                                            ? Container()
                                            : Container(
                                                padding: EdgeInsets.all(5),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  "???? ???????????? $dateDifference ?????? ",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ))
                                        : Container(),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    VacationCardHeader(
                                      header: "?????? ??????????????",
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 5.w),
                                      child: Directionality(
                                        textDirection: ui.TextDirection.rtl,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              alignment: Alignment.topRight,
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(width: 1)),
                                              width: 150.w,
                                              height: 40.h,
                                              child:
                                                  DropdownButtonHideUnderline(
                                                      child: DropdownButton(
                                                elevation: 2,
                                                isExpanded: true,
                                                items: widget.holidayTitles
                                                    .map((String x) {
                                                  return DropdownMenuItem<
                                                          String>(
                                                      value: x,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          x,
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.orange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ));
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedReason = value;
                                                    if (value != "??????????") {
                                                      _dateController.text = "";
                                                      newString = "";
                                                      tomorrow = DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          DateTime.now().day +
                                                              1);
                                                      _today = DateTime.now();
                                                      toDate = tomorrow;
                                                    }
                                                  });
                                                },
                                                value: selectedReason,
                                              )),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DetialsTextField(commentController),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Provider.of<UserPermessionsData>(context)
                                                .isLoading ||
                                            Provider.of<UserHolidaysData>(
                                                    context)
                                                .isLoading
                                        ? CircularProgressIndicator(
                                            backgroundColor: Colors.orange)
                                        : RoundedButton(
                                            onPressed: () async {
                                              if (picked != null &&
                                                  picked.isNotEmpty) {
                                                final DateTime now =
                                                    DateTime.now();
                                                final DateFormat format =
                                                    DateFormat(
                                                        'dd-M-yyyy'); //4-2-2021
                                                final String formatted =
                                                    format.format(now);
                                                Provider.of<UserHolidaysData>(
                                                        context,
                                                        listen: false)
                                                    .addHoliday(
                                                        UserHolidays(
                                                            holidayDescription:
                                                                commentController
                                                                    .text,
                                                            fromDate: fromDate,
                                                            toDate:
                                                                picked.length == 2
                                                                    ? toDate
                                                                    : fromDate,
                                                            holidayType:
                                                                selectedReason ==
                                                                        "??????????"
                                                                    ? 1
                                                                    : selectedReason ==
                                                                            "??????????"
                                                                        ? 2
                                                                        : 3,
                                                            createdOnDate:
                                                                DateTime.now(),
                                                            holidayStatus: 3),
                                                        Provider.of<UserData>(
                                                                context,
                                                                listen: false)
                                                            .user
                                                            .userToken,
                                                        widget.member.id)
                                                    .then((value) {
                                                  if (value ==
                                                      "Success : Holiday Created!") {
                                                    Fluttertoast.showToast(
                                                            msg:
                                                                "???? ?????? ?????????????? ??????????",
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            backgroundColor:
                                                                Colors.green)
                                                        .whenComplete(() =>
                                                            Navigator.pop(
                                                                context));
                                                    HuaweiServices _huawei =
                                                        HuaweiServices();
                                                    if (widget.member.osType ==
                                                        3) {
                                                      _huawei
                                                          .huaweiPostNotification(
                                                              widget.member
                                                                  .fcmToken,
                                                              "??????????",
                                                              "???? ?????? ?????????? ???? ",
                                                              "vacation");
                                                    } else {
                                                      sendFcmMessage(
                                                        topicName: "",
                                                        title: "??????????",
                                                        category: "vacation",
                                                        userToken: widget
                                                            .member.fcmToken,
                                                        message:
                                                            "???? ?????? ?????????? ???? ",
                                                      );
                                                    }
                                                  } else if (value ==
                                                      "Failed : There are external mission in this period!") {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "???? ???????? ?????? ?????????????? : ???????? ?????????????? ????????????",
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red);
                                                  } else if (value ==
                                                      "Failed : There are an holiday approved in this period!") {
                                                    Fluttertoast.showToast(
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        msg:
                                                            "???????? ?????????? ???? ???????????????? ?????????? ???? ?????? ????????????",
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        backgroundColor:
                                                            Colors.red);
                                                  } else if (value ==
                                                      "Failed : There are an internal Mission in this period!") {
                                                    Fluttertoast.showToast(
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        msg:
                                                            "???? ???????? ?????? ?????????????? : ???????? ?????????????? ????????????",
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        backgroundColor:
                                                            Colors.red);
                                                  } else if (value ==
                                                      "Failed : There are an permission in this period!") {
                                                    Fluttertoast.showToast(
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        msg:
                                                            "???? ???????? ?????? ?????????????? : ???????? ?????? ??????",
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        backgroundColor:
                                                            Colors.red);
                                                  } else {
                                                    errorToast();
                                                  }
                                                });
                                              } else {
                                                Fluttertoast.showToast(
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor: Colors.red,
                                                    msg:
                                                        "???? ???????????? ?????? ??????????????");
                                              }
                                            },
                                            title: "??????",
                                          )
                                  ],
                                )
                              : Column(
                                  children: [
                                    Directionality(
                                      textDirection: ui.TextDirection.rtl,
                                      child: Card(
                                        elevation: 5,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              AutoSizeText(
                                                "?????? ??????????",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11),
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Directionality(
                                        textDirection: ui.TextDirection.rtl,
                                        child: Column(
                                          children: [
                                            Directionality(
                                              textDirection:
                                                  ui.TextDirection.rtl,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    alignment:
                                                        Alignment.topRight,
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            width: 1)),
                                                    width: 200.w,
                                                    height: 40.h,
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton(
                                                      elevation: 2,
                                                      isExpanded: true,
                                                      items: widget
                                                          .permessionTitles
                                                          .map((String x) {
                                                        return DropdownMenuItem<
                                                                String>(
                                                            value: x,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                x,
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .orange,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ));
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedPermession =
                                                              value;
                                                        });
                                                      },
                                                      value: selectedPermession,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(),
                                            Directionality(
                                              textDirection:
                                                  ui.TextDirection.rtl,
                                              child: Card(
                                                elevation: 5,
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "?????????? ??????????",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              child: Directionality(
                                                textDirection:
                                                    ui.TextDirection.rtl,
                                                child: Container(
                                                  child: Theme(
                                                    data: clockTheme,
                                                    child: DateTimePicker(
                                                      initialValue:
                                                          _selectedDateString,

                                                      onChanged: (value) {
                                                        date = value;

                                                        setState(() {
                                                          _selectedDateString =
                                                              date;
                                                          selectedDate =
                                                              DateTime.parse(
                                                                  _selectedDateString);
                                                        });
                                                      },
                                                      type: DateTimePickerType
                                                          .date,
                                                      initialDate: _today,
                                                      firstDate: _today,
                                                      lastDate: DateTime(
                                                          DateTime.now().year,
                                                          DateTime.december,
                                                          31),
                                                      //controller: _endTimeController,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(14,
                                                                  allowFontScalingSelf:
                                                                      true),
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400),

                                                      decoration:
                                                          kTextFieldDecorationTime
                                                              .copyWith(
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  hintText:
                                                                      '??????????',
                                                                  prefixIcon:
                                                                      Icon(
                                                                    Icons
                                                                        .access_time,
                                                                    color: Colors
                                                                        .orange,
                                                                  )),
                                                      validator: (val) {
                                                        if (val.length == 0) {
                                                          return '??????????';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Directionality(
                                              textDirection:
                                                  ui.TextDirection.rtl,
                                              child: Card(
                                                elevation: 5,
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        selectedPermession ==
                                                                "?????????? ???? ????????????"
                                                            ? "?????? ?????? ????????????"
                                                            : "?????? ???? ????????????",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Directionality(
                                              textDirection:
                                                  ui.TextDirection.rtl,
                                              child: Container(
                                                width: double.infinity,
                                                height: 50.h,
                                                child: Container(
                                                    child: Theme(
                                                  data: clockTheme,
                                                  child: Builder(
                                                    builder: (context) {
                                                      return InkWell(
                                                          onTap: () async {
                                                            var to =
                                                                await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  toPicked,
                                                              builder: (BuildContext
                                                                      context,
                                                                  Widget
                                                                      child) {
                                                                return MediaQuery(
                                                                  data: MediaQuery.of(
                                                                          context)
                                                                      .copyWith(
                                                                    alwaysUse24HourFormat:
                                                                        false,
                                                                  ),
                                                                  child: child,
                                                                );
                                                              },
                                                            );

                                                            if (to != null) {
                                                              final now =
                                                                  new DateTime
                                                                      .now();
                                                              final dt =
                                                                  DateTime(
                                                                      now.year,
                                                                      now.month,
                                                                      now.day,
                                                                      to.hour,
                                                                      to.minute);

                                                              formattedTime =
                                                                  DateFormat
                                                                          .Hm()
                                                                      .format(
                                                                          dt);

                                                              toPicked = to;
                                                              setState(() {
                                                                timeOutController
                                                                        .text =
                                                                    "${toPicked.format(context).replaceAll(" ", " ")}";
                                                              });
                                                            }
                                                          },
                                                          child: Directionality(
                                                            textDirection: ui
                                                                .TextDirection
                                                                .rtl,
                                                            child: Container(
                                                              child:
                                                                  IgnorePointer(
                                                                child:
                                                                    TextFormField(
                                                                  enabled:
                                                                      false,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                  textInputAction:
                                                                      TextInputAction
                                                                          .next,
                                                                  controller:
                                                                      timeOutController,
                                                                  decoration: kTextFieldDecorationFromTO
                                                                      .copyWith(
                                                                          hintText:
                                                                              '??????????',
                                                                          prefixIcon:
                                                                              Icon(
                                                                            Icons.alarm,
                                                                            color:
                                                                                Colors.orange,
                                                                          )),
                                                                ),
                                                              ),
                                                            ),
                                                          ));
                                                    },
                                                  ),
                                                )),
                                              ),
                                            ),
                                            DetialsTextField(commentController)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Provider.of<UserPermessionsData>(context)
                                                .isLoading ||
                                            Provider.of<UserHolidaysData>(
                                                    context)
                                                .isLoading
                                        ? CircularProgressIndicator(
                                            backgroundColor: Colors.orange)
                                        : RoundedButton(
                                            onPressed: () async {
                                              if (_selectedDateString != null &&
                                                  timeOutController.text !=
                                                      "") {
                                                String msg = await Provider.of<UserPermessionsData>(context, listen: false).addUserPermession(
                                                    UserPermessions(
                                                        createdOn:
                                                            DateTime.now(),
                                                        date: DateTime.parse(
                                                            _selectedDateString),
                                                        duration: formattedTime
                                                            .replaceAll(
                                                                ":", ""),
                                                        permessionType:
                                                            selectedPermession ==
                                                                    "?????????? ???? ????????????"
                                                                ? 1
                                                                : 2,
                                                        permessionDescription:
                                                            commentController.text == ""
                                                                ? "???? ???????? ??????????"
                                                                : commentController
                                                                    .text,
                                                        user:
                                                            widget.member.name),
                                                    Provider.of<UserData>(context,
                                                            listen: false)
                                                        .user
                                                        .userToken,
                                                    widget.member.id);
                                                if (msg == "success") {
                                                  Fluttertoast.showToast(
                                                          msg:
                                                              "???? ?????? ?????????? ??????????",
                                                          backgroundColor:
                                                              Colors.green,
                                                          gravity: ToastGravity
                                                              .CENTER)
                                                      .whenComplete(() =>
                                                          Navigator.pop(
                                                              context));
                                                  HuaweiServices _huawei =
                                                      HuaweiServices();
                                                  if (widget.member.osType ==
                                                      3) {
                                                    _huawei
                                                        .huaweiPostNotification(
                                                            widget.member
                                                                .fcmToken,
                                                            "??????",
                                                            "???? ?????? ?????????? ???? ",
                                                            "permession");
                                                  } else {
                                                    sendFcmMessage(
                                                      topicName: "",
                                                      userToken: widget
                                                          .member.fcmToken,
                                                      title: "??????",
                                                      category: "permession",
                                                      message: "???? ?????? ?????? ????",
                                                    );
                                                  }
                                                } else if (msg ==
                                                    "external mission") {
                                                  print("external found");
                                                  Fluttertoast.showToast(
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      msg:
                                                          "???????? ?????????????? ???????????? ???? ?????? ??????????");
                                                } else if (msg ==
                                                    'already exist') {
                                                  Fluttertoast.showToast(
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      msg:
                                                          "?????? ???? ?????????? ?????? ???? ??????");
                                                } else if (msg == "failed") {
                                                  errorToast();
                                                } else if (msg ==
                                                    "dublicate permession") {
                                                  Fluttertoast.showToast(
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      msg:
                                                          "???????? ?????? ???? ?????? ??????????");
                                                }
                                              } else {
                                                print(selectedDateString);
                                                print(timeOutController.text);
                                                Fluttertoast.showToast(
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor: Colors.red,
                                                    msg:
                                                        "???? ???????????? ???????????????? ????????????????");
                                              }
                                            },
                                            title: "??????",
                                          )
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class SitesAndMissionsWidg extends StatefulWidget {
  final Function onchannge;
  SitesAndMissionsWidg({
    this.onchannge,
    Key key,
    @required this.prov,
    @required this.selectedVal,
    @required this.list,
  }) : super(key: key);

  final SiteData prov;
  final String selectedVal;
  final List<Site> list;

  @override
  _SitesAndMissionsWidgState createState() => _SitesAndMissionsWidgState();
}

class _SitesAndMissionsWidgState extends State<SitesAndMissionsWidg> {
  @override
  Widget build(BuildContext context) {
    int shiftId;
    int holder;
    return Column(
      children: [
        VacationCardHeader(
          header: "???????????? ?? ???????????????? ??????????????????",
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 60.h,
          child: Container(
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: Consumer<SiteShiftsData>(
                              builder: (context, value, child) {
                                return IgnorePointer(
                                  ignoring:
                                      widget.prov.siteValue == "???? ??????????????"
                                          ? true
                                          : false,
                                  child: DropdownButton(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      elevation: 5,
                                      items: value.shifts
                                          .map(
                                            (value) => DropdownMenuItem(
                                                child: Container(
                                                    alignment:
                                                        Alignment.topRight,
                                                    height: 20.h,
                                                    child: AutoSizeText(
                                                      value.shiftName,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: ScreenUtil()
                                                              .setSp(12,
                                                                  allowFontScalingSelf:
                                                                      true),
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    )),
                                                value: value.shiftName),
                                          )
                                          .toList(),
                                      onChanged: (v) async {
                                        if (widget.selectedVal !=
                                            "???? ??????????????") {
                                          List<String> x = [];

                                          value.shifts.forEach((element) {
                                            x.add(element.shiftName);
                                          });

                                          print("on changed $v");
                                          holder = x.indexOf(v);

                                          widget.prov.setDropDownShift(holder);
                                          shiftId =
                                              value.shifts[holder].shiftId;
                                        }
                                      },
                                      hint: Text("???? ??????????????????"),
                                      value:
                                          widget.prov.siteValue == "???? ??????????????"
                                              ? null
                                              : value
                                                  .shifts[widget
                                                      .prov.dropDownShiftIndex]
                                                  .shiftName

                                      // value
                                      ),
                                );
                              },
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.alarm,
                  color: ColorManager.primary,
                ),
                SizedBox(
                  width: 20,
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: Consumer<ShiftsData>(
                              builder: (context, value, child) {
                                return DropdownButton(
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  elevation: 5,
                                  items: widget.list
                                      .map((value) => DropdownMenuItem(
                                            child: Container(
                                              alignment: Alignment.topRight,
                                              height: 20,
                                              child: AutoSizeText(
                                                value.name,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: ScreenUtil().setSp(
                                                        12,
                                                        allowFontScalingSelf:
                                                            true),
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                            value: value.name,
                                          ))
                                      .toList(),
                                  onChanged: (v) async {
                                    print(v);
                                    widget.prov.setDropDownShift(0);
                                    Provider.of<SiteShiftsData>(context,
                                            listen: false)
                                        .getShiftsList(v, false);
                                    if (v != "???? ??????????????") {
                                      widget.prov.setDropDownIndex(widget
                                              .prov.dropDownSitesStrings
                                              .indexOf(v) -
                                          1);
                                    } else {
                                      widget.prov.setDropDownIndex(0);
                                    }
                                    // await Provider.of<ShiftsData>(context,
                                    //         listen: false)
                                    //     .findMatchingShifts(
                                    //         Provider.of<SiteData>(context,
                                    //                 listen: false)
                                    //             .sitesList[widget
                                    //                 .prov.dropDownSitesIndex]
                                    //             .id,
                                    //         false);

                                    widget.prov.fillCurrentShiftID(widget
                                        .list[
                                            widget.prov.dropDownSitesIndex + 1]
                                        .id);

                                    widget.prov.setSiteValue(v);
                                    widget.onchannge(v);
                                    print(widget.prov.dropDownSitesStrings);
                                  },
                                  value: widget.selectedVal,
                                );
                              },
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.location_on,
                  color: ColorManager.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VacationCardHeader extends StatelessWidget {
  final String header;
  VacationCardHeader({
    this.header,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Text(
                header,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
