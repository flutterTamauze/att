import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';

import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';

import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';

import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import '../../constants.dart';

class UserVacationRequest extends StatefulWidget {
  int radioVal;
  UserVacationRequest(this.radioVal);
  @override
  _UserVacationRequestState createState() => _UserVacationRequestState();
}

TextEditingController commentController = TextEditingController();
String selectedReason = "عارضة";
String selectedPermession = "تأخير عن الحضور";
TextEditingController timeOutController = TextEditingController();
var sleectedMember;
var toDate;
var fromDate;
String toText;
String fromText;
DateTime yesterday;
TextEditingController _dateController = TextEditingController();
String dateToString = "";
String dateFromString = "";
List<String> actions = ["عارضة", "مرضية", "رصيد اجازات"];
List<String> permessionTitles = ["تأخير عن الحضور", "انصراف مبكر"];
TimeOfDay toPicked;
String dateDifference;
List<DateTime> picked = [];

class _UserVacationRequestState extends State<UserVacationRequest> {
  @override
  void initState() {
    picked = null;
    timeOutController.text = "";
    toPicked = (intToTimeOfDay(0));
    selectedDateString = null;
    dateDifference = null;
    _dateController.text = "";
    var now = DateTime.now();
    commentController.text = "";
    fromDate = DateTime(now.year, now.month, now.day);
    toDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    yesterday = DateTime(now.year, DateTime.december, 30);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String formattedTime;
  var selectedVal = "كل المواقع";
  @override
  Widget build(BuildContext context) {
    var userdata = Provider.of<UserData>(context, listen: false).user;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: ListView(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Header(
                      goUserHomeFromMenu: false,
                      nav: false,
                      goUserMenu: false,
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          children: [
                            Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SmallDirectoriesHeader(
                                    Lottie.asset("resources/calender.json",
                                        repeat: false),
                                    "طلب اجازة / اذن",
                                  ),
                                ],
                              ),
                            ),
                            VacationCardHeader(
                              header: "نوع الطلب",
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RadioButtonWidg(
                                    radioVal2: widget.radioVal,
                                    radioVal: 3,
                                    title: "أذن",
                                    onchannge: (value) {
                                      setState(() {
                                        widget.radioVal = value;
                                      });
                                    },
                                  ),
                                  RadioButtonWidg(
                                    radioVal2: widget.radioVal,
                                    radioVal: 1,
                                    title: "اجازة",
                                    onchannge: (value) {
                                      setState(() {
                                        widget.radioVal = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            widget.radioVal == 1
                                ? Column(
                                    children: [
                                      VacationCardHeader(
                                        header: "مدة الأجازة",
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
                                                              DateTime(
                                                                  DateTime.now()
                                                                      .year,
                                                                  DateTime.now()
                                                                      .month,
                                                                  DateTime.now()
                                                                      .day),
                                                          initialLastDate:
                                                              toDate,
                                                          firstDate: DateTime(
                                                              DateTime.now()
                                                                  .year,
                                                              DateTime.now()
                                                                  .month,
                                                              DateTime.now()
                                                                  .day),
                                                          lastDate: yesterday);
                                                  var newString = "";
                                                  setState(() {
                                                    fromDate = picked.first;
                                                    toDate = picked.last;
                                                    dateDifference = (toDate
                                                                .difference(
                                                                    fromDate)
                                                                .inDays +
                                                            1)
                                                        .toString();
                                                    fromText =
                                                        " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                    toText =
                                                        " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
                                                    newString =
                                                        "$fromText $toText";
                                                  });

                                                  if (_dateController.text !=
                                                      newString) {
                                                    _dateController.text =
                                                        newString;

                                                    dateFromString =
                                                        apiFormatter
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
                                                                FontWeight
                                                                    .w500),
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        controller:
                                                            _dateController,
                                                        decoration:
                                                            kTextFieldDecorationFromTO
                                                                .copyWith(
                                                                    hintText:
                                                                        'المدة من / إلى',
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
                                          ? Container(
                                              padding: EdgeInsets.all(5),
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                "تم اختيار $dateDifference يوم ",
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
                                        header: "نوع الأجازة",
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 5.w),
                                        child: Directionality(
                                          textDirection: ui.TextDirection.rtl,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                alignment: Alignment.topRight,
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border:
                                                        Border.all(width: 1)),
                                                width: 150.w,
                                                height: 40.h,
                                                child:
                                                    DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                  elevation: 2,
                                                  isExpanded: true,
                                                  items:
                                                      actions.map((String x) {
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
                                                      selectedReason = value;
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
                                                  "نوع الأذن",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                        const EdgeInsets.all(
                                                            8.0),
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
                                                        items: permessionTitles
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
                                                        value:
                                                            selectedPermession,
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
                                                          "تاريخ الأذن",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                            selectedDateString,

                                                        onChanged: (value) {
                                                          print(date);
                                                          print(value);
                                                          if (value != date) {
                                                            date = value;
                                                            selectedDateString =
                                                                date;

                                                            setState(() {
                                                              selectedDate =
                                                                  DateTime.parse(
                                                                      selectedDateString);
                                                            });
                                                            print(selectedDate);
                                                          }

                                                          print(value);
                                                        },
                                                        type: DateTimePickerType
                                                            .date,
                                                        firstDate:
                                                            DateTime.now(),
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
                                                                FontWeight
                                                                    .w400),

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
                                                                        'اليوم',
                                                                    prefixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .access_time,
                                                                      color: Colors
                                                                          .orange,
                                                                    )),
                                                        validator: (val) {
                                                          if (val.length == 0) {
                                                            return 'مطلوب';
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
                                                                  "تأخير عن الحضور"
                                                              ? "اذن حتى الساعة"
                                                              : "اذن من الساعة",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                                context:
                                                                    context,
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
                                                                    child:
                                                                        child,
                                                                  );
                                                                },
                                                              );

                                                              if (to != null) {
                                                                final now =
                                                                    new DateTime
                                                                        .now();
                                                                final dt = DateTime(
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
                                                            child:
                                                                Directionality(
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
                                                                            FontWeight.w400),
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .next,
                                                                    controller:
                                                                        timeOutController,
                                                                    decoration: kTextFieldDecorationFromTO
                                                                        .copyWith(
                                                                            hintText:
                                                                                'الوقت',
                                                                            prefixIcon:
                                                                                Icon(
                                                                              Icons.alarm,
                                                                              color: Colors.orange,
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
                                              DetialsTextField(
                                                  commentController)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            Provider.of<UserPermessionsData>(context)
                                        .isLoading ||
                                    Provider.of<UserHolidaysData>(context)
                                        .isLoading
                                ? CircularProgressIndicator(
                                    backgroundColor: Colors.orange)
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RoundedButton(
                                        title: "حفظ الطلب",
                                        onPressed: () async {
                                          if (widget.radioVal == 1) //اجازة
                                          {
                                            if (picked != null) {
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
                                                          fromDate: picked[0],
                                                          toDate: picked
                                                                      .length ==
                                                                  2
                                                              ? picked[1]
                                                              : DateTime.now(),
                                                          holidayType:
                                                              selectedReason ==
                                                                      "عارضة"
                                                                  ? 1
                                                                  : selectedReason ==
                                                                          "مرضية"
                                                                      ? 2
                                                                      : 3,
                                                          holidayStatus: 3),
                                                      userdata.userToken,
                                                      userdata.id)
                                                  .then((value) {
                                                if (value ==
                                                    "Success : Holiday Created!") {
                                                  return showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      sendFcmMessage(
                                                        topicName:
                                                            "attendChilango",
                                                        title:
                                                            "تم طلب الأجازة بنجاح",
                                                        category: "vacation",
                                                        message:
                                                            "تم طلب اجازة من قبل المستخدم ${Provider.of<UserData>(context, listen: false).user.name}",
                                                      );

                                                      return StackedNotificaitonAlert(
                                                        repeatAnimation: false,
                                                        popWidget: true,
                                                        notificationTitle:
                                                            "تم تقديم طلب الأجازة بنجاح ",
                                                        notificationContent:
                                                            "برجاء متابعة الطلب ",
                                                        roundedButtonTitle:
                                                            "متابعة",
                                                        lottieAsset:
                                                            "resources/success.json",
                                                        showToast: false,
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "لقد تم تقديم طلب من قبل",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red);
                                                }
                                              });
                                            } else {
                                              Fluttertoast.showToast(
                                                  gravity: ToastGravity.CENTER,
                                                  backgroundColor: Colors.red,
                                                  msg: "قم بأدخال مدة الأجازة");
                                            }
                                          } else //اذن
                                          {
                                            if (selectedDateString != null &&
                                                timeOutController.text != "") {
                                              print(selectedDate);
                                              print(timeOutController.text);
                                              String msg = await Provider.of<
                                                          UserPermessionsData>(
                                                      context,
                                                      listen: false)
                                                  .addUserPermession(
                                                      UserPermessions(
                                                          date: selectedDate,
                                                          duration:
                                                              formattedTime,
                                                          permessionType:
                                                              selectedPermession ==
                                                                      "تأخير عن الحضور"
                                                                  ? 1
                                                                  : 2,
                                                          permessionDescription:
                                                              commentController
                                                                          .text ==
                                                                      ""
                                                                  ? "لا يوجد تعليق"
                                                                  : commentController
                                                                      .text,
                                                          user: userdata.name),
                                                      Provider.of<UserData>(
                                                              context,
                                                              listen: false)
                                                          .user
                                                          .userToken,
                                                      userdata.id);
                                              if (msg == "success") {
                                                return showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    sendFcmMessage(
                                                      topicName:
                                                          "attendChilango",
                                                      title: "تم طلب اذن بنجاح",
                                                      category: "permession",
                                                      message:
                                                          "تم طلب اذن من قبل المستخدم ${Provider.of<UserData>(context, listen: false).user.name}",
                                                    );

                                                    return StackedNotificaitonAlert(
                                                      repeatAnimation: false,
                                                      popWidget: true,
                                                      notificationTitle:
                                                          "تم تقديم طلب الأذن بنجاح ",
                                                      notificationContent:
                                                          "برجاء متابعة الطلب ",
                                                      roundedButtonTitle:
                                                          "متابعة",
                                                      lottieAsset:
                                                          "resources/success.json",
                                                      showToast: false,
                                                    );
                                                  },
                                                );
                                              } else if (msg ==
                                                  'already exist') {
                                                Fluttertoast.showToast(
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor: Colors.red,
                                                    msg:
                                                        "لقد تم تقديم طلب من قبل");
                                              } else if (msg == "failed") {
                                                errorToast();
                                              }
                                            } else {
                                              Fluttertoast.showToast(
                                                  gravity: ToastGravity.CENTER,
                                                  backgroundColor: Colors.red,
                                                  msg:
                                                      "قم بأدخال البيانات المطلوبة");
                                            }
                                          }
                                        }),
                                  )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class RadioButtonWidg extends StatelessWidget {
  final Function onchannge;
  final int radioVal;
  final String title;
  const RadioButtonWidg({
    this.onchannge,
    this.radioVal,
    this.title,
    @required this.radioVal2,
  });

  final int radioVal2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Radio(
          activeColor: Colors.orange,
          value: radioVal,
          groupValue: radioVal2,
          onChanged: (value) {
            onchannge(value);
          },
        ),
        Text(title),
      ],
    );
  }
}
