import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/DailyReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import '../../constants.dart';

class UserVacationRequest extends StatefulWidget {
  UserVacationRequest();
  @override
  _UserVacationRequestState createState() => _UserVacationRequestState();
}

TextEditingController titileController = TextEditingController();
String selectedAction = "عارضة";
String selectedPermession = "تأخير عن الحضور";
var sleectedMember;
var toDate;
var fromDate;
DateTime yesterday;
TextEditingController _dateController = TextEditingController();
String dateToString = "";
String dateFromString = "";
List<String> actions = ["مرضى", "عارضة", "رصيد الاجازات", "حالة وفاة"];
List<String> permessionTitles = ["تأخير عن الحضور", "انصراف مبكر"];
TimeOfDay toPicked;
String dateDifference;

class _UserVacationRequestState extends State<UserVacationRequest> {
  @override
  void initState() {
    var now = DateTime.now();
    titileController.text = "";
    fromDate = DateTime(now.year, now.month, now.day);
    toDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    yesterday = DateTime(now.year, DateTime.december, 30);
    toPicked = (intToTimeOfDay(0));
    super.initState();
  }

  var radioVal2 = 1;
  @override
  void dispose() {
    super.dispose();
  }

  var selectedVal = "كل المواقع";
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Header(
                    nav: false,
                  ),
                  Expanded(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RadioButtonWidg(
                                  radioVal2: radioVal2,
                                  radioVal: 3,
                                  title: "أذن",
                                  onchannge: (value) {
                                    setState(() {
                                      radioVal2 = value;
                                    });
                                  },
                                ),
                                RadioButtonWidg(
                                  radioVal2: radioVal2,
                                  radioVal: 1,
                                  title: "اجازة",
                                  onchannge: (value) {
                                    setState(() {
                                      radioVal2 = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          radioVal2 == 1
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
                                                final List<DateTime> picked =
                                                    await DateRagePicker
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
                                                            lastDate:
                                                                yesterday);
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
                                                  String fromText =
                                                      " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                  String toText =
                                                      " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
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
                                                  fontWeight: FontWeight.w300),
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
                                                items: actions.map((String x) {
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
                                                    selectedAction = value;
                                                  });
                                                },
                                                value: selectedAction,
                                              )),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DetialsTextField(),
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
                                                        "تاريخ الأذن",
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
                                                      firstDate: DateTime.now(),
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
                                                        radioVal1 == 1
                                                            ? "اذن حتى الساعة"
                                                            : "اذن من الساعة",
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
                                                            print(toPicked
                                                                .format(context)
                                                                .replaceAll(
                                                                    " ", ""));
                                                            if (to != null) {
                                                              toPicked = to;
                                                              setState(() {
                                                                timeOutController
                                                                        .text =
                                                                    "${toPicked.format(context).replaceAll(" ", "")}";
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
                                                                              'الوقت',
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
                                            DetialsTextField()
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          RoundedButton(title: "حفظ الطلب", onPressed: () {})
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class DetialsTextField extends StatelessWidget {
  const DetialsTextField({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: TextField(
          controller: titileController,
          cursorColor: Colors.orange,
          maxLines: null,
          decoration: InputDecoration(
            errorStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Colors.orange),
            ),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 4)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey, width: 0)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey, width: 0)),
            hintStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            hintText: "قم بأدخال التفاصيل هنا",
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
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
    Key key,
    @required this.radioVal2,
  }) : super(key: key);

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
            print(value);
            onchannge(value);
          },
        ),
        Text(title),
      ],
    );
  }
}
