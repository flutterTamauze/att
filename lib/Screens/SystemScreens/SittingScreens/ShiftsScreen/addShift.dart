import 'dart:io';
import 'dart:ui' as ui;

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';

import 'package:qr_users/constants.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
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
  bool intializeFromControllers = true;
  bool intializeToControllers = true;
  TextEditingController _timeInController = TextEditingController(); //sat
  TextEditingController _timeOutController = TextEditingController();
  TimeOfDay fromPicked;
  TimeOfDay toPicked;
  TextEditingController sunTimeInController = TextEditingController(); //sun
  TextEditingController sunTimeOutController = TextEditingController();
  TimeOfDay sunFromT;
  TimeOfDay sunToT;
  TextEditingController monTimeInController = TextEditingController();
  TextEditingController monTimeOutController = TextEditingController();
  TimeOfDay monFromT;
  TimeOfDay monToT;
  TextEditingController tuesTimeInController = TextEditingController();
  TextEditingController tuesTimeOutController = TextEditingController();
  TimeOfDay tuesFromT;
  TimeOfDay tuesToT;
  TextEditingController wedTimeInController = TextEditingController();
  TextEditingController wedTimeOutController = TextEditingController();
  TimeOfDay wedFromT;
  TimeOfDay wedToT;
  TextEditingController thuTimeInController = TextEditingController();
  TextEditingController thuTimeOutController = TextEditingController();
  TimeOfDay thuFromT;
  TimeOfDay thuToT;
  TextEditingController friTimeInController = TextEditingController();
  TextEditingController friTimeOutController = TextEditingController();
  TimeOfDay friFromT;
  TimeOfDay friToT;
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
    intializeToControllers = true;
    intializeFromControllers = true;
    if (widget.isEdit) {
      edit = true;
      siteId = getSiteListIndex(widget.shift.siteID);

      _timeInController.text = amPmChanger(widget.shift.shiftStartTime);
      _timeOutController.text = amPmChanger(widget.shift.shiftEndTime);

      fromPicked = (intToTimeOfDay(widget.shift.shiftStartTime));
      toPicked = (intToTimeOfDay(widget.shift.shiftEndTime));
      sunFromT = (intToTimeOfDay(widget.shift.sunShiftstTime));
      sunToT = (intToTimeOfDay(widget.shift.sunShiftenTime));
      monFromT = (intToTimeOfDay(widget.shift.monShiftstTime));
      monToT = (intToTimeOfDay(widget.shift.mondayShiftenTime));
      tuesFromT = (intToTimeOfDay(widget.shift.thursdayShiftstTime));
      tuesToT = (intToTimeOfDay(widget.shift.tuesdayShiftenTime));
      wedFromT = (intToTimeOfDay(widget.shift.wednesDayShiftstTime));
      wedToT = (intToTimeOfDay(widget.shift.wednesDayShiftenTime));
      thuFromT = (intToTimeOfDay(widget.shift.thursdayShiftstTime));
      thuToT = (intToTimeOfDay(widget.shift.thursdayShiftenTime));
      friFromT = (intToTimeOfDay(widget.shift.fridayShiftstTime));
      friToT = (intToTimeOfDay(widget.shift.fridayShiftenTime));

      _timeInController.text = amPmChanger(widget.shift.shiftStartTime);
      _timeOutController.text = amPmChanger(widget.shift.shiftEndTime);
      sunTimeInController.text = amPmChanger(widget.shift.sunShiftstTime);
      sunTimeOutController.text = amPmChanger(widget.shift.sunShiftenTime);
      monTimeInController.text = amPmChanger(widget.shift.monShiftstTime);
      monTimeOutController.text = amPmChanger(widget.shift.mondayShiftenTime);
      tuesTimeInController.text = amPmChanger(widget.shift.tuesdayShiftstTime);
      tuesTimeOutController.text = amPmChanger(widget.shift.tuesdayShiftenTime);
      wedTimeInController.text = amPmChanger(widget.shift.wednesDayShiftstTime);

      wedTimeOutController.text =
          amPmChanger(widget.shift.wednesDayShiftenTime);
      thuTimeInController.text = amPmChanger(widget.shift.thursdayShiftstTime);
      thuTimeOutController.text = amPmChanger(widget.shift.thursdayShiftenTime);
      friTimeInController.text = amPmChanger(widget.shift.fridayShiftstTime);
      friTimeOutController.text = amPmChanger(widget.shift.fridayShiftenTime);
      thuTimeOutController.text = amPmChanger(widget.shift.thursdayShiftenTime);
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
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);

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
              print(monFromT);
              print(monToT);
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
                            SizedBox(
                              height: 30.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.0.w),
                              child: Form(
                                key: _formKey,
                                child: Container(
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
                                                                if (!widget
                                                                        .isEdit &&
                                                                    intializeFromControllers !=
                                                                        false) {
                                                                  sunFromT =
                                                                      fromPicked;
                                                                  sunTimeInController
                                                                          .text =
                                                                      "${fromPicked.format(context).replaceAll(" ", "")}";
                                                                  monFromT =
                                                                      fromPicked;
                                                                  monTimeInController
                                                                          .text =
                                                                      "${fromPicked.format(context).replaceAll(" ", "")}";
                                                                  tuesFromT =
                                                                      fromPicked;
                                                                  tuesTimeInController
                                                                          .text =
                                                                      "${fromPicked.format(context).replaceAll(" ", "")}";
                                                                  wedFromT =
                                                                      fromPicked;
                                                                  wedTimeInController
                                                                          .text =
                                                                      "${fromPicked.format(context).replaceAll(" ", "")}";
                                                                  thuFromT =
                                                                      fromPicked;
                                                                  thuTimeInController
                                                                          .text =
                                                                      "${fromPicked.format(context).replaceAll(" ", "")}";
                                                                  friFromT =
                                                                      fromPicked;
                                                                  friTimeInController
                                                                          .text =
                                                                      "${fromPicked.format(context).replaceAll(" ", "")}";
                                                                }

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
                                                                  intializeFromControllers =
                                                                      false;
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
                                                                if (!widget
                                                                        .isEdit &&
                                                                    intializeToControllers !=
                                                                        false) {
                                                                  sunToT =
                                                                      toPicked;
                                                                  sunTimeOutController
                                                                          .text =
                                                                      "${toPicked.format(context).replaceAll(" ", "")}";
                                                                  monToT =
                                                                      toPicked;
                                                                  monTimeOutController
                                                                          .text =
                                                                      "${toPicked.format(context).replaceAll(" ", "")}";
                                                                  tuesToT =
                                                                      toPicked;
                                                                  tuesTimeOutController
                                                                          .text =
                                                                      "${toPicked.format(context).replaceAll(" ", "")}";
                                                                  wedToT =
                                                                      toPicked;
                                                                  wedTimeOutController
                                                                          .text =
                                                                      "${toPicked.format(context).replaceAll(" ", "")}";
                                                                  thuToT =
                                                                      toPicked;
                                                                  thuTimeOutController
                                                                          .text =
                                                                      "${toPicked.format(context).replaceAll(" ", "")}";
                                                                  friToT =
                                                                      toPicked;
                                                                  friTimeOutController
                                                                          .text =
                                                                      "${toPicked.format(context).replaceAll(" ", "")}";
                                                                }
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
                                                                  intializeToControllers =
                                                                      false;
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
                                          ? FutureBuilder(
                                              future: Provider.of<DaysOffData>(
                                                      context,
                                                      listen: false)
                                                  .getDaysOff(
                                                      comProvider.com.id,
                                                      userProvider
                                                          .user.userToken,
                                                      context),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            backgroundColor:
                                                                Colors.orange),
                                                  );
                                                }
                                                var daysOff =
                                                    Provider.of<DaysOffData>(
                                                            context,
                                                            listen: false)
                                                        .weak;
                                                return Column(
                                                  children: [
                                                    AdvancedShiftPicker(
                                                      enableText:
                                                          daysOff[0].isDayOff,
                                                      weekDay: "السبت",
                                                      fromPickedWeek:
                                                          fromPicked,
                                                      timeInController:
                                                          _timeInController,
                                                      timeOutController:
                                                          _timeOutController,
                                                      toPickedWeek: toPicked,
                                                    ),
                                                    AdvancedShiftPicker(
                                                      enableText:
                                                          daysOff[1].isDayOff,
                                                      weekDay: "الأحد",
                                                      fromPickedWeek: sunFromT,
                                                      timeInController:
                                                          sunTimeInController,
                                                      timeOutController:
                                                          sunTimeOutController,
                                                      toPickedWeek: sunToT,
                                                      callBackfunFrom:
                                                          (TimeOfDay v) {
                                                        sunFromT = v;
                                                      },
                                                      callBackfunTo:
                                                          (TimeOfDay v) {
                                                        sunToT = v;
                                                      },
                                                    ),
                                                    AdvancedShiftPicker(
                                                      enableText:
                                                          daysOff[2].isDayOff,
                                                      weekDay: "الأتنين",
                                                      fromPickedWeek: monFromT,
                                                      timeInController:
                                                          monTimeInController,
                                                      timeOutController:
                                                          monTimeOutController,
                                                      toPickedWeek: monToT,
                                                      callBackfunFrom:
                                                          (TimeOfDay v) {
                                                        monFromT = v;
                                                      },
                                                      callBackfunTo:
                                                          (TimeOfDay v) {
                                                        monToT = v;
                                                      },
                                                    ),
                                                    AdvancedShiftPicker(
                                                      enableText:
                                                          daysOff[3].isDayOff,
                                                      weekDay: "الثلاثاء",
                                                      fromPickedWeek: tuesFromT,
                                                      timeInController:
                                                          tuesTimeInController,
                                                      timeOutController:
                                                          tuesTimeOutController,
                                                      toPickedWeek: tuesToT,
                                                      callBackfunFrom:
                                                          (TimeOfDay v) {
                                                        tuesFromT = v;
                                                      },
                                                      callBackfunTo:
                                                          (TimeOfDay v) {
                                                        tuesToT = v;
                                                      },
                                                    ),
                                                    AdvancedShiftPicker(
                                                      enableText:
                                                          daysOff[4].isDayOff,
                                                      weekDay: "الأربعاء",
                                                      fromPickedWeek: wedFromT,
                                                      timeInController:
                                                          wedTimeInController,
                                                      timeOutController:
                                                          wedTimeOutController,
                                                      toPickedWeek: wedToT,
                                                      callBackfunFrom:
                                                          (TimeOfDay v) {
                                                        wedFromT = v;
                                                      },
                                                      callBackfunTo:
                                                          (TimeOfDay v) {
                                                        wedToT = v;
                                                      },
                                                    ),
                                                    AdvancedShiftPicker(
                                                      enableText:
                                                          daysOff[5].isDayOff,
                                                      weekDay: "الخميس",
                                                      fromPickedWeek: thuFromT,
                                                      timeInController:
                                                          thuTimeInController,
                                                      timeOutController:
                                                          thuTimeOutController,
                                                      toPickedWeek: thuToT,
                                                      callBackfunFrom:
                                                          (TimeOfDay v) {
                                                        thuFromT = v;
                                                      },
                                                      callBackfunTo:
                                                          (TimeOfDay v) {
                                                        thuToT = v;
                                                      },
                                                    ),
                                                    AdvancedShiftPicker(
                                                      enableText:
                                                          daysOff[6].isDayOff,
                                                      weekDay: "الجمعة",
                                                      fromPickedWeek: friFromT,
                                                      timeInController:
                                                          friTimeInController,
                                                      timeOutController:
                                                          friTimeOutController,
                                                      toPickedWeek: friToT,
                                                      callBackfunFrom:
                                                          (TimeOfDay v) {
                                                        friFromT = v;
                                                      },
                                                      callBackfunTo:
                                                          (TimeOfDay v) {
                                                        friToT = v;
                                                      },
                                                    ),
                                                  ],
                                                );
                                              })
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
                                  DateTime now = DateTime.now();
                                  TimeOfDay t = fromPicked;
                                  TimeOfDay tt = toPicked;
                                  TimeOfDay sunT = sunFromT;
                                  TimeOfDay sunTT = sunToT;
                                  TimeOfDay monT = monFromT;
                                  TimeOfDay monTT = monToT;
                                  TimeOfDay tuesT = tuesFromT;
                                  TimeOfDay tuesTT = tuesToT;
                                  TimeOfDay wedT = wedFromT;
                                  TimeOfDay wedTT = wedToT;
                                  TimeOfDay thurT = thuFromT;
                                  TimeOfDay thurTT = thuToT;
                                  TimeOfDay friT = friFromT;
                                  TimeOfDay friTT = friToT;

                                  DateTime dateFrom = DateTime(now.year,
                                      now.month, now.day, t.hour, t.minute);

                                  DateTime dateTo = DateTime(now.year,
                                      now.month, now.day, tt.hour, tt.minute);
                                  sunFrom = DateTime(now.year, now.month,
                                      now.day, sunT.hour, sunT.minute);
                                  monFrom = DateTime(now.year, now.month,
                                      now.day, monT.hour, monT.minute);
                                  tuesFrom = DateTime(now.year, now.month,
                                      now.day, tuesT.hour, tuesT.minute);
                                  wedFrom = DateTime(now.year, now.month,
                                      now.day, wedT.hour, wedT.minute);
                                  friFrom = DateTime(now.year, now.month,
                                      now.day, friT.hour, friT.minute);
                                  thuFrom = DateTime(now.year, now.month,
                                      now.day, thurT.hour, thurT.minute);
                                  friFrom = DateTime(now.year, now.month,
                                      now.day, friT.hour, friT.minute);
                                  sunTo = DateTime(now.year, now.month, now.day,
                                      sunTT.hour, sunTT.minute);
                                  monTo = DateTime(now.year, now.month, now.day,
                                      monTT.hour, monTT.minute);
                                  tuesTo = DateTime(now.year, now.month,
                                      now.day, tuesTT.hour, tuesTT.minute);
                                  wedTo = DateTime(now.year, now.month, now.day,
                                      wedTT.hour, wedTT.minute);
                                  thuTo = DateTime(now.year, now.month, now.day,
                                      thurTT.hour, thurTT.minute);
                                  friTo = DateTime(now.year, now.month, now.day,
                                      friTT.hour, friTT.minute);

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

                                  // var startStart =
                                  //     ((startInt - kBeforeStartShift) + 2400) %
                                  //         2400;
                                  // var startEnd =
                                  //     (startInt + kAfterStartShift) % 2400;
                                  // var endStart = endInt;
                                  // var endEnd = (endInt + kAfterEndShift) % 2400;

                                  if (!widget.isEdit) {
                                    if (_formKey.currentState.validate()) {
                                      if (startInt > endInt) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return RoundedAlert(
                                              onPressed: () async {
                                                addShiftFun();
                                              },
                                              title: "اضافة مناوبة",
                                              content:
                                                  " برجاء العلم ان مواعيد المناوية من $startString \n إلي $endString",
                                            );
                                          },
                                        );
                                      } else {
                                        addShiftFun();
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
                                                                await editShiftFun();
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
                                                        editShiftFun();
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

  editShiftFun() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedLoadingIndicator();
        });
    var user = Provider.of<UserData>(context, listen: false).user;
    print(Provider.of<SiteData>(context, listen: false).sitesList[siteId].id);

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
              msg: "تم تعديل المناوبة بنجاح",
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

  addShiftFun() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedLoadingIndicator();
        });

    var user = Provider.of<UserData>(context, listen: false).user;

    print(_monFrom);
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
          msg: "تمت إضافة المناوبة بنجاح",
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

class AdvancedShiftPicker extends StatefulWidget {
  String weekDay;

  bool enableText;
  Function callBackfunFrom, callBackfunTo;
  TextEditingController timeInController, timeOutController;
  TimeOfDay fromPickedWeek, toPickedWeek;
  AdvancedShiftPicker(
      {this.fromPickedWeek,
      this.callBackfunFrom,
      this.timeInController,
      this.timeOutController,
      this.enableText,
      this.callBackfunTo,
      this.toPickedWeek,
      this.weekDay});
  @override
  _AdvancedShiftPickerState createState() => _AdvancedShiftPickerState();
}

class _AdvancedShiftPickerState extends State<AdvancedShiftPicker> {
  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 50.h,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.weekDay,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        child: Theme(
                      data: clockTheme,
                      child: Builder(
                        builder: (context) {
                          return InkWell(
                              onTap: () async {
                                if (!widget.enableText) {
                                  var from = await showTimePicker(
                                    context: context,
                                    initialTime: widget.fromPickedWeek,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  MaterialLocalizations localizations =
                                      MaterialLocalizations.of(context);
                                  String formattedTime =
                                      localizations.formatTimeOfDay(from,
                                          alwaysUse24HourFormat: false);

                                  if (from != null) {
                                    widget.fromPickedWeek = from;
                                    widget.callBackfunFrom(from);
                                    setState(() {
                                      if (Platform.isIOS) {
                                        widget.timeInController.text =
                                            formattedTime;
                                      } else {
                                        widget.timeInController.text =
                                            "${widget.fromPickedWeek.format(context).replaceAll(" ", "")}";
                                      }
                                    });
                                  }
                                }
                              },
                              child: Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Container(
                                  child: IgnorePointer(
                                    child: TextFormField(
                                      enabled: !widget.enableText,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                      textInputAction: TextInputAction.next,
                                      controller: widget.timeInController,
                                      decoration:
                                          kTextFieldDecorationFromTO.copyWith(
                                              hintText: 'من',
                                              prefixIcon: Icon(
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
                  SizedBox(
                    width: 5.w,
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        child: Theme(
                      data: clockTheme,
                      child: Builder(
                        builder: (context) {
                          return InkWell(
                              onTap: () async {
                                if (!widget.enableText) {
                                  var to = await showTimePicker(
                                    context: context,
                                    initialTime: widget.toPickedWeek,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  MaterialLocalizations localizations =
                                      MaterialLocalizations.of(context);
                                  String formattedTime2 =
                                      localizations.formatTimeOfDay(to,
                                          alwaysUse24HourFormat: false);
                                  if (to != null) {
                                    widget.toPickedWeek = to;
                                    widget.callBackfunTo(to);
                                    setState(() {
                                      if (Platform.isIOS) {
                                        widget.timeOutController.text =
                                            formattedTime2;
                                      } else {
                                        widget.timeOutController.text =
                                            "${widget.toPickedWeek.format(context).replaceAll(" ", "")}";
                                      }
                                    });
                                  }
                                }
                              },
                              child: Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Container(
                                  child: IgnorePointer(
                                    child: TextFormField(
                                      enabled: !widget.enableText,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                      textInputAction: TextInputAction.next,
                                      controller: widget.timeOutController,
                                      decoration:
                                          kTextFieldDecorationFromTO.copyWith(
                                              hintText: 'الى',
                                              prefixIcon: Icon(
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
                ],
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Divider(
              thickness: 1,
            ),
            SizedBox(
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}
