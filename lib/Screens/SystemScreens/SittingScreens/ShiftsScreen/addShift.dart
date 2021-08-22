import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/widgets/AdvancedShiftSettings/adv_shift_settings.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/CameraPickerScreen.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AddShiftScreen extends StatefulWidget {
  final Shift shift;
  final int id;
  final isEdit;
  final siteId;
  AddShiftScreen(this.shift, this.id, this.isEdit, this.siteId);

  @override
  _AddShiftScreenState createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen> {
  bool edit = true;

  @override
  void initState() {
    super.initState();
    fillTextField();
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController _title = TextEditingController();

  TextEditingController _timeInController = TextEditingController();
  TextEditingController _timeOutController = TextEditingController();

  TimeOfDay fromPicked;
  TimeOfDay toPicked;
  bool checkedBox = false;
  TimeOfDay from24String;
  TimeOfDay to24String;
  DateTime sunFrom,
      sunTo,
      monFrom,
      monTo,
      tuesFrom,
      tuesTo,
      wedFrom,
      wedTo,
      thuFrom,
      thuTo,
      friFrom,
      friTo;
  String startString; //sat
  String endString;
  String _sunFrom,
      _sunTo,
      _monFrom,
      _monTo,
      _tuesFrom,
      _tuesTo,
      _wedFrom,
      _wedTo,
      _thuFrom,
      _thuTo,
      _friFrom,
      _friTo;
  int siteId = 0;

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

  TimeOfDay intToTimeOfDay(int time) {
    int hours = (time ~/ 100);
    int min = time - (hours * 100);
    return TimeOfDay(hour: hours, minute: min);
  }

  fillTextField() {
    if (widget.isEdit) {
      edit = true;
      siteId = getSiteListIndex(widget.shift.siteID);

      _timeInController.text = amPmChanger(widget.shift.shiftStartTime);
      _timeOutController.text = amPmChanger(widget.shift.shiftEndTime);

      fromPicked = (intToTimeOfDay(widget.shift.shiftStartTime));
      toPicked = (intToTimeOfDay(widget.shift.shiftEndTime));

      _title.text = widget.shift.shiftName.toString();
    } else {
      _timeInController.text = "";
      _timeOutController.text = "";

      fromPicked = (intToTimeOfDay(0));
      toPicked = (intToTimeOfDay(0));

      siteId = widget.siteId;
    }
  }

  Future<TimeOfDay> inputTimeSelect(TimeOfDay initTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );
  }

  String getTimeToString(int time) {
    print(time);
    double hoursDouble = time / 100.0;
    int h = hoursDouble.toInt();
    print(h);
    double minDouble = time.toDouble() % 100;
    int m = minDouble.toInt();
    print(m);
    NumberFormat formatter = new NumberFormat("00");
    return "${formatter.format(h)}:${formatter.format(m)}";
  }

  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        endDrawer: NotificationItem(),
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GestureDetector(
            onTap: () {
              print(startString);
              print(_timeInController.text);
              print(_timeOutController.text);
            },
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Header(
                      nav: false,
                      goUserHomeFromMenu: false,
                      goUserMenu: false,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: SmallDirectoriesHeader(
                                  Lottie.asset("resources/shiftLottie.json",
                                      repeat: false),
                                  (!widget.isEdit)
                                      ? "إضافة مناوبة"
                                      : "تعديل المناوبة"),
                            ),
                            // DirectoriesHeader(
                            //     ClipRRect(
                            //       borderRadius: BorderRadius.circular(60.0),
                            //       child: Lottie.asset("resources/shifts.json",
                            //           repeat: false),
                            //     ),
                            //     (!widget.isEdit)
                            //         ? "إضافة منوابة"
                            //         : "تعديل المنوابة"),
                            SizedBox(
                              height: 30.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.0.w),
                              child: Form(
                                key: _formKey,
                                child: Container(
                                  height: checkedBox
                                      ? MediaQuery.of(context).size.height
                                      : 300.h,
                                  width: checkedBox
                                      ? MediaQuery.of(context).size.width
                                      : 400.w,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      IgnorePointer(
                                        ignoring: !edit,
                                        child: SiteDropdown(
                                          edit: edit,
                                          list: Provider.of<SiteData>(context)
                                              .sitesList,
                                          colour: Colors.white,
                                          icon: Icons.location_on,
                                          borderColor: Colors.black,
                                          hint: "الموقع",
                                          hintColor: Colors.black,
                                          onChange: (vlaue) {
                                            // print()
                                            siteId = getSiteId(vlaue);
                                            print(vlaue);
                                          },
                                          selectedvalue:
                                              Provider.of<SiteData>(context)
                                                  .sitesList[siteId]
                                                  .name,
                                          textColor: Colors.orange,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0.h,
                                      ),
                                      TextFormField(
                                        enabled: edit,
                                        onFieldSubmitted: (_) {},
                                        textInputAction: TextInputAction.next,
                                        textAlign: TextAlign.right,
                                        validator: (text) {
                                          if (text.length == 0) {
                                            return 'مطلوب';
                                          }
                                          return null;
                                        },
                                        controller: _title,
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                                hintText: 'اسم المناوبة',
                                                suffixIcon: Icon(
                                                  Icons.title,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Directionality(
                                        textDirection: ui.TextDirection.rtl,
                                        child: Container(
                                          width: double.infinity,
                                          height: 50.h,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                    child: Theme(
                                                  data: clockTheme,
                                                  child: Builder(
                                                    builder: (context) {
                                                      return InkWell(
                                                          onTap: () async {
                                                            if (edit) {
                                                              var from =
                                                                  await showTimePicker(
                                                                context:
                                                                    context,
                                                                initialTime:
                                                                    fromPicked,
                                                                builder: (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child) {
                                                                  return MediaQuery(
                                                                    data: MediaQuery.of(
                                                                            context)
                                                                        .copyWith(
                                                                            alwaysUse24HourFormat:
                                                                                false),
                                                                    child:
                                                                        child,
                                                                  );
                                                                },
                                                              );
                                                              MaterialLocalizations
                                                                  localizations =
                                                                  MaterialLocalizations
                                                                      .of(context);
                                                              String
                                                                  formattedTime =
                                                                  localizations
                                                                      .formatTimeOfDay(
                                                                          from,
                                                                          alwaysUse24HourFormat:
                                                                              false);

                                                              if (from !=
                                                                  null) {
                                                                fromPicked =
                                                                    from;
                                                                setState(() {
                                                                  if (Platform
                                                                      .isIOS) {
                                                                    _timeInController
                                                                            .text =
                                                                        formattedTime;
                                                                  } else {
                                                                    _timeInController
                                                                            .text =
                                                                        "${fromPicked.format(context).replaceAll(" ", "")}";
                                                                  }
                                                                });
                                                              }
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
                                                                  enabled: edit,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                  textInputAction:
                                                                      TextInputAction
                                                                          .next,
                                                                  controller:
                                                                      _timeInController,
                                                                  decoration: kTextFieldDecorationFromTO
                                                                      .copyWith(
                                                                          hintText:
                                                                              'من',
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
                                              SizedBox(
                                                width: 5.w,
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                    child: Theme(
                                                  data: clockTheme,
                                                  child: Builder(
                                                    builder: (context) {
                                                      return InkWell(
                                                          onTap: () async {
                                                            if (edit) {
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
                                                                                false),
                                                                    child:
                                                                        child,
                                                                  );
                                                                },
                                                              );
                                                              MaterialLocalizations
                                                                  localizations =
                                                                  MaterialLocalizations
                                                                      .of(context);
                                                              String
                                                                  formattedTime2 =
                                                                  localizations
                                                                      .formatTimeOfDay(
                                                                          to,
                                                                          alwaysUse24HourFormat:
                                                                              false);
                                                              if (to != null) {
                                                                toPicked = to;
                                                                setState(() {
                                                                  if (Platform
                                                                      .isIOS) {
                                                                    _timeOutController
                                                                            .text =
                                                                        formattedTime2;
                                                                  } else {
                                                                    _timeOutController
                                                                            .text =
                                                                        "${toPicked.format(context).replaceAll(" ", "")}";
                                                                  }
                                                                });
                                                              }
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
                                                                  enabled: edit,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                  textInputAction:
                                                                      TextInputAction
                                                                          .next,
                                                                  controller:
                                                                      _timeOutController,
                                                                  decoration: kTextFieldDecorationFromTO
                                                                      .copyWith(
                                                                          hintText:
                                                                              'الى',
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
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Checkbox(
                                                activeColor: Colors.orange[700],
                                                value: checkedBox,
                                                onChanged: ((_timeInController
                                                                .text ==
                                                            "") ||
                                                        (_timeOutController
                                                                .text ==
                                                            ""))
                                                    ? null
                                                    : (value) {
                                                        setState(() {
                                                          checkedBox = value;
                                                        });
                                                      }),
                                            Text("اعدادات متقدمة")
                                          ],
                                        ),
                                      ),
                                      checkedBox
                                          ? AdvancedShiftSettings(
                                              from: fromPicked,
                                              to: toPicked,
                                              isEdit: widget.isEdit,
                                              edit: edit,
                                              shift: widget.shift,
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: RoundedButton(
                                onPressed: () async {
                                  var dayssOff = Provider.of<DaysOffData>(
                                          context,
                                          listen: false)
                                      .advancedShift;
                                  DateTime now = DateTime.now();
                                  TimeOfDay t = fromPicked;
                                  TimeOfDay tt = toPicked;

                                  DateTime dateFrom = DateTime(now.year,
                                      now.month, now.day, t.hour, t.minute);

                                  DateTime dateTo = DateTime(now.year,
                                      now.month, now.day, tt.hour, tt.minute);
                                  if (checkedBox) {
                                    sunFrom = dayssOff[1].fromDate == null
                                        ? dateFrom
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[1].fromDate.hour,
                                            dayssOff[1].fromDate.minute);
                                    sunTo = dayssOff[1].fromDate == null
                                        ? dateTo
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[1].toDate.hour,
                                            dayssOff[1].toDate.minute);
                                    monFrom = dayssOff[2].fromDate == null
                                        ? dateFrom
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[2].fromDate.hour,
                                            dayssOff[2].fromDate.minute);
                                    monTo = dayssOff[2].fromDate == null
                                        ? dateTo
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[2].toDate.hour,
                                            dayssOff[2].toDate.minute);
                                    tuesFrom = dayssOff[3].fromDate == null
                                        ? dateFrom
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[3].fromDate.hour,
                                            dayssOff[3].fromDate.minute);
                                    tuesTo = dayssOff[3].fromDate == null
                                        ? dateTo
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[3].toDate.hour,
                                            dayssOff[3].toDate.minute);

                                    wedFrom = dayssOff[4].fromDate == null
                                        ? dateFrom
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[4].fromDate.hour,
                                            dayssOff[4].fromDate.minute);
                                    wedTo = dayssOff[4].fromDate == null
                                        ? dateTo
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[4].toDate.hour,
                                            dayssOff[4].toDate.minute);
                                    thuFrom = dayssOff[5].fromDate == null
                                        ? dateFrom
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[5].fromDate.hour,
                                            dayssOff[5].fromDate.minute);
                                    thuTo = dayssOff[5].fromDate == null
                                        ? dateTo
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[5].toDate.hour,
                                            dayssOff[5].toDate.minute);
                                    friFrom = dayssOff[6].fromDate == null
                                        ? dateFrom
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[6].fromDate.hour,
                                            dayssOff[6].fromDate.minute);
                                    friTo = dayssOff[6].fromDate == null
                                        ? dateTo
                                        : DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            dayssOff[6].toDate.hour,
                                            dayssOff[6].toDate.minute);
                                  } else {
                                    sunFrom = dateFrom;
                                    monFrom = dateFrom;
                                    tuesFrom = dateFrom;
                                    thuFrom = dateFrom;
                                    wedFrom = dateFrom;
                                    friFrom = dateFrom;
                                    sunTo = dateTo;
                                    monTo = dateTo;
                                    tuesTo = dateTo;
                                    thuTo = dateTo;
                                    wedTo = dateTo;
                                    friTo = dateTo;
                                  }

                                  var startInt = int.parse(DateFormat("HH:mm")
                                      .format(dateFrom)
                                      .replaceAll(":", ""));
                                  startString =
                                      DateFormat("HH:mm").format(dateFrom);

                                  endString =
                                      DateFormat("HH:mm").format(dateTo);

                                  _sunFrom =
                                      DateFormat("HH:mm").format(sunFrom);
                                  _sunTo = DateFormat("HH:mm").format(sunTo);
                                  _monFrom =
                                      DateFormat("HH:mm").format(monFrom);
                                  _monTo = DateFormat("HH:mm").format(monTo);
                                  _thuFrom =
                                      DateFormat("HH:mm").format(thuFrom);
                                  _thuTo = DateFormat("HH:mm").format(thuTo);
                                  _wedFrom =
                                      DateFormat("HH:mm").format(wedFrom);
                                  _wedTo = DateFormat("HH:mm").format(wedTo);
                                  _friFrom =
                                      DateFormat("HH:mm").format(friFrom);
                                  _friTo = DateFormat("HH:mm").format(friTo);
                                  _tuesFrom =
                                      DateFormat("HH:mm").format(tuesFrom);
                                  _tuesTo = DateFormat("HH:mm").format(tuesTo);
                                  var endInt = int.parse(DateFormat("HH:mm")
                                      .format(dateTo)
                                      .replaceAll(":", ""));

                                  var startStart =
                                      ((startInt - kBeforeStartShift) + 2400) %
                                          2400;
                                  var startEnd =
                                      (startInt + kAfterStartShift) % 2400;
                                  var endStart = endInt;
                                  var endEnd = (endInt + kAfterEndShift) % 2400;

                                  print(
                                      "$startStart   $startEnd    $endStart   $endEnd");
                                  if (!widget.isEdit) {
                                    if (_formKey.currentState.validate()) {
                                      if (startInt > endInt) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return RoundedAlert(
                                              onPressed: () async {
                                                addShiftFun(startStart,
                                                    startEnd, endStart, endEnd);
                                              },
                                              title: "اضافة مناوبة",
                                              content:
                                                  " برجاء العلم ان مواعيد المناوية من $startString \n إلي $endString",
                                            );
                                          },
                                        );
                                      } else {
                                        addShiftFun(startStart, startEnd,
                                            endStart, endEnd);
                                      }
                                    }
                                  } else {
                                    if (edit) {
                                      if (_formKey.currentState.validate()) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) => Container(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                              ),
                                              height: 200.h,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  RoundedButton(
                                                    onPressed: () async {
                                                      if (startInt > endInt) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return RoundedAlert(
                                                              onPressed:
                                                                  () async {
                                                                await editShiftFun(
                                                                    startStart,
                                                                    startEnd,
                                                                    endStart,
                                                                    endEnd);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              title:
                                                                  "تعديل مناوبة",
                                                              content:
                                                                  " برجاء العلم ان مواعيد المناوبة من $startString \n إلي $endString",
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        editShiftFun(
                                                            startStart,
                                                            startEnd,
                                                            endStart,
                                                            endEnd);
                                                      }
                                                    },
                                                    title: "حفظ ؟",
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        edit = true;
                                      });
                                    }
                                  }
                                },
                                title: (!widget.isEdit)
                                    ? "إضافة"
                                    : edit
                                        ? "حفظ"
                                        : "تعديل",
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
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
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    ShiftsScreen(widget.siteId, -1)),
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
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  editShiftFun(int sS, int sE, int eS, int eE) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedLoadingIndicator();
        });
    var user = Provider.of<UserData>(context, listen: false).user;
    print(Provider.of<SiteData>(context, listen: false).sitesList[siteId].id);
    print("aaaaaaaaa :${widget.shift.shiftId}");

    var msg = await Provider.of<ShiftsData>(context, listen: false).editShift(
        Shift(
          fridayShiftenTime: int.parse(_friTo.replaceAll(":", "")),
          fridayShiftstTime: int.parse(_friFrom.replaceAll(":", "")),
          monShiftstTime: int.parse(_monFrom.replaceAll(":", "")),
          mondayShiftenTime: int.parse(_monTo.replaceAll(":", "")),
          sunShiftenTime: int.parse(_sunTo.replaceAll(":", "")),
          sunShiftstTime: int.parse(_sunFrom.replaceAll(":", "")),
          thursdayShiftenTime: int.parse(_thuTo.replaceAll(":", "")),
          thursdayShiftstTime: int.parse(_thuFrom.replaceAll(":", "")),
          tuesdayShiftenTime: int.parse(_tuesTo.replaceAll(":", "")),
          tuesdayShiftstTime: int.parse(_tuesFrom.replaceAll(":", "")),
          wednesDayShiftenTime: int.parse(_wedTo.replaceAll(":", "")),
          wednesDayShiftstTime: int.parse(_wedFrom.replaceAll(":", "")),
          shiftStartTime: int.parse(startString.replaceAll(":", "")),
          shiftEndTime: int.parse(endString.replaceAll(":", "")),
          shiftName: _title.text,
          shiftId: widget.shift.shiftId,
          siteID: Provider.of<SiteData>(context, listen: false)
              .sitesList[siteId]
              .id,
        ),
        widget.id,
        user.userToken,
        context);

    if (msg == "Success") {
      setState(() {
        edit = false;
      });
      Fluttertoast.showToast(
              msg:
                  "تم تعديل المناوبة بنجاح\n مواعيد الحضور من ${amPmChanger(sS)} إلي ${amPmChanger(sE)} \n مواعيد الانصراف من ${amPmChanger(eS)} إلى ${amPmChanger(eE)}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true))
          .then((value) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ShiftsScreen(0, -1)),
              (Route<dynamic> route) => false));
    } else if (msg == "exists") {
      Fluttertoast.showToast(
          msg: "خطأ في اضافة المناوبة: اسم المناوبة مستخدم مسبقا لنفس الموقع",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.black,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
    } else if (msg == "failed") {
      Fluttertoast.showToast(
          msg: "خطأ في تعديل المناوبة",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
    } else if (msg == "noInternet") {
      Fluttertoast.showToast(
          msg: "خطأ في تعديل المناوبة:لايوجد اتصال بالانترنت",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER,
          textColor: Colors.black,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
    } else {
      Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER,
          textColor: Colors.black,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
    }
    Navigator.pop(context);
    Navigator.pop(context);
  }

  addShiftFun(int sS, int sE, int eS, int eE) async {
    var dayssOff =
        Provider.of<DaysOffData>(context, listen: false).advancedShift;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedLoadingIndicator();
        });

    var user = Provider.of<UserData>(context, listen: false).user;

    var msg = await Provider.of<ShiftsData>(context, listen: false).addShift(
        Shift(
            shiftName: _title.text,
            siteID: Provider.of<SiteData>(context, listen: false)
                .sitesList[siteId]
                .id,
            fridayShiftenTime: int.parse(_friTo.replaceAll(":", "")),
            fridayShiftstTime: int.parse(_friFrom.replaceAll(":", "")),
            monShiftstTime: int.parse(_monFrom.replaceAll(":", "")),
            mondayShiftenTime: int.parse(_monTo.replaceAll(":", "")),
            sunShiftenTime: int.parse(_sunTo.replaceAll(":", "")),
            sunShiftstTime: int.parse(_sunFrom.replaceAll(":", "")),
            thursdayShiftenTime: int.parse(_thuTo.replaceAll(":", "")),
            thursdayShiftstTime: int.parse(_thuFrom.replaceAll(":", "")),
            tuesdayShiftenTime: int.parse(_tuesTo.replaceAll(":", "")),
            tuesdayShiftstTime: int.parse(_tuesFrom.replaceAll(":", "")),
            wednesDayShiftenTime: int.parse(_wedTo.replaceAll(":", "")),
            wednesDayShiftstTime: int.parse(_wedFrom.replaceAll(":", "")),
            shiftStartTime: int.parse(startString.replaceAll(":", "")),
            shiftEndTime: int.parse(endString.replaceAll(":", ""))),
        user.userToken,
        context);
    Navigator.pop(context);

    if (msg == "Success") {
      Fluttertoast.showToast(
          msg:
              "تمت إضافة المناوبة بنجاح\n مواعيد الحضور من ${getTimeToString(sS)} إلي ${getTimeToString(sE)} \n مواعيد الانصراف من ${getTimeToString(eS)} إلى ${getTimeToString(eE)}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ShiftsScreen(siteId, -1)),
          (Route<dynamic> route) => false);
    } else if (msg == "exists") {
      Fluttertoast.showToast(
          msg: "خطأ في اضافة المناوبة: اسم المناوبة مستخدم مسبقا لنفس الموقع",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.black,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
    } else if (msg == "failed") {
      Fluttertoast.showToast(
          msg: "خطأ في اضافة المناوبة",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.black,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
    } else if (msg == "noInternet") {
      Fluttertoast.showToast(
          msg: "خطأ في اضافة المناوبة:لايوجد اتصال بالانترنت",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.black,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
    } else {
      Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.black,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
    }
  }

  int getSiteId(String siteName) {
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
  }

  int getSiteListIndex(int siteId) {
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteId == list[i].id) {
        return i;
      }
    }
    return -1;
  }

  Future<bool> onWillPop() {
    print("back");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => ShiftsScreen(widget.siteId, -1)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class LocationTile extends StatelessWidget {
  final String title;

  final Function onTapLocation;
  final Function onTapEdit;
  final Function onTapDelete;
  LocationTile(
      {this.title, this.onTapEdit, this.onTapDelete, this.onTapLocation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: double.infinity,
              height: 60.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircularIconButton(
                        icon: Icons.delete,
                        onTap: onTapDelete,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      CircularIconButton(
                        icon: Icons.edit,
                        onTap: onTapEdit,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      CircularIconButton(
                        icon: Icons.location_on,
                        onTap: onTapLocation,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        child: AutoSizeText(
                          title,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.location_on,
                        size:
                            ScreenUtil().setSp(40, allowFontScalingSelf: true),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
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
            size: ScreenUtil().setSp(25, allowFontScalingSelf: true),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
