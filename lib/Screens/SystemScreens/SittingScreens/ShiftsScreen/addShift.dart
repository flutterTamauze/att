import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';

import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
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
  final siteIndex;

  const AddShiftScreen(
      this.shift, this.id, this.isEdit, this.siteId, this.siteIndex);

  @override
  _AddShiftScreenState createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen> {
  bool edit = true;
  bool loadDaysOff = false;
  @override
  void initState() {
    super.initState();

    siteName = Provider.of<SiteShiftsData>(context, listen: false)
        .siteShiftList[widget.siteId ?? 0]
        .siteName;
    fillTextField();
  }

  final _formKey = GlobalKey<FormState>();
  String siteName;
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
    final int min = intTime - (hours * 100);

    final ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours != 0 ? hours : 12; //

    final String hoursStr = hours < 10
        ? '0$hours'
        : hours.toString(); // the hour '0' should be '12'
    final String minStr = min < 10 ? '0$min' : min.toString();

    final strTime = '$hoursStr:$minStr$ampm';

    return strTime;
  }

  TimeOfDay intToTimeOfDay(int time) {
    final int hours = (time ~/ 100);
    final int min = time - (hours * 100);
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
      tuesFromT = (intToTimeOfDay(widget.shift.tuesdayShiftstTime));
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
      friFromT = (intToTimeOfDay(0));
      friToT = (intToTimeOfDay(0));
      sunFromT = (intToTimeOfDay(0));
      sunToT = (intToTimeOfDay(0));
      monFromT = (intToTimeOfDay(0));
      monToT = (intToTimeOfDay(0));
      tuesFromT = (intToTimeOfDay(0));
      tuesToT = (intToTimeOfDay(0));
      thuFromT = (intToTimeOfDay(0));
      thuToT = (intToTimeOfDay(0));
      wedFromT = (intToTimeOfDay(0));
      wedToT = (intToTimeOfDay(0));

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
    final double hoursDouble = time / 100.0;
    final int h = hoursDouble.toInt();
    final double minDouble = time.toDouble() % 100;
    final int m = minDouble.toInt();
    final NumberFormat formatter = new NumberFormat("00");
    return "${formatter.format(h)}:${formatter.format(m)}";
  }

  bool compareShiftTime(TimeOfDay startTime, TimeOfDay endTime) {
    final int startNumber = (startTime.hour * 60) + startTime.minute;
    final int endNumber = (endTime.hour * 60) + endTime.minute;
    final int difference = (endNumber - startNumber).abs();
    log(difference.toString());
    if (difference >= 180)
      return true;
    else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return WillPopScope(
      onWillPop: onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          endDrawer: NotificationItem(),
          backgroundColor: Colors.white,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
                            SmallDirectoriesHeader(
                                Lottie.asset("resources/shiftLottie.json",
                                    repeat: false),
                                (!widget.isEdit)
                                    ? getTranslated(context, "إضافة مناوبة")
                                    : getTranslated(context, "تعديل المناوبة")),
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
                                          height: 40,
                                          list: Provider.of<SiteShiftsData>(
                                                  context)
                                              .siteShiftList,
                                          colour: Colors.white,
                                          icon: Icons.location_on,
                                          borderColor: Colors.black,
                                          hint: "الموقع",
                                          hintColor: Colors.black,
                                          onChange: (vlaue) {
                                            // debugPrint()
                                            siteId = getSiteId(vlaue);
                                          },
                                          selectedvalue: siteName,
                                          textColor: Colors.orange,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0.h,
                                      ),
                                      TextFormField(
                                        onFieldSubmitted: (_) {},
                                        textInputAction: TextInputAction.next,
                                        validator: (text) {
                                          if (text.length == 0) {
                                            return getTranslated(
                                                context, "مطلوب");
                                          } else if (text.length > 25) {
                                            return getTranslated(context,
                                                "يجب ان لا يزيد اسم المناوبة عن 25 حرف");
                                          }
                                          return null;
                                        },
                                        controller: _title,
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                                hintText: getTranslated(
                                                    context, 'اسم المناوبة'),
                                                suffixIcon: const Icon(
                                                  Icons.title,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      widget.isEdit
                                          ? Container()
                                          : Container(
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
                                                                  final from =
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
                                                                        data: MediaQuery.of(context).copyWith(
                                                                            alwaysUse24HourFormat:
                                                                                false),
                                                                        child:
                                                                            child,
                                                                      );
                                                                    },
                                                                  );
                                                                  final MaterialLocalizations
                                                                      localizations =
                                                                      MaterialLocalizations.of(
                                                                          context);
                                                                  final String
                                                                      formattedTime =
                                                                      localizations.formatTimeOfDay(
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

                                                                    setState(
                                                                        () {
                                                                      if (Platform
                                                                          .isIOS) {
                                                                        _timeInController.text =
                                                                            formattedTime;
                                                                      } else {
                                                                        _timeInController.text =
                                                                            "${fromPicked.format(context).replaceAll(" ", "")}";
                                                                      }
                                                                      intializeFromControllers =
                                                                          false;
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                child:
                                                                    IgnorePointer(
                                                                  child:
                                                                      TextFormField(
                                                                    enabled:
                                                                        edit,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .next,
                                                                    controller:
                                                                        _timeInController,
                                                                    decoration: kTextFieldDecorationFromTO
                                                                        .copyWith(
                                                                            hintText: getTranslated(context,
                                                                                'من'),
                                                                            prefixIcon:
                                                                                const Icon(
                                                                              Icons.alarm,
                                                                              color: Colors.orange,
                                                                            )),
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
                                                                  final to =
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
                                                                        data: MediaQuery.of(context).copyWith(
                                                                            alwaysUse24HourFormat:
                                                                                false),
                                                                        child:
                                                                            child,
                                                                      );
                                                                    },
                                                                  );
                                                                  final MaterialLocalizations
                                                                      localizations =
                                                                      MaterialLocalizations.of(
                                                                          context);
                                                                  final String
                                                                      formattedTime2 =
                                                                      localizations.formatTimeOfDay(
                                                                          to,
                                                                          alwaysUse24HourFormat:
                                                                              false);
                                                                  if (to !=
                                                                      null) {
                                                                    toPicked =
                                                                        to;
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
                                                                    setState(
                                                                        () {
                                                                      if (Platform
                                                                          .isIOS) {
                                                                        _timeOutController.text =
                                                                            formattedTime2;
                                                                      } else {
                                                                        _timeOutController.text =
                                                                            "${toPicked.format(context).replaceAll(" ", "")}";
                                                                      }
                                                                      intializeToControllers =
                                                                          false;
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                child:
                                                                    IgnorePointer(
                                                                  child:
                                                                      TextFormField(
                                                                    enabled:
                                                                        edit,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .next,
                                                                    controller:
                                                                        _timeOutController,
                                                                    decoration: kTextFieldDecorationFromTO
                                                                        .copyWith(
                                                                            hintText: getTranslated(context,
                                                                                "إلى"),
                                                                            prefixIcon:
                                                                                const Icon(
                                                                              Icons.alarm,
                                                                              color: Colors.orange,
                                                                            )),
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
                                        height: 10.0.h,
                                      ),
                                      Column(
                                        children: [
                                          AdvancedShiftPicker(
                                            callBackfunFrom: (TimeOfDay v) {
                                              fromPicked = v;
                                            },
                                            callBackfunTo: (TimeOfDay v) {
                                              toPicked = v;
                                            },
                                            weekDay:
                                                getTranslated(context, "السبت"),
                                            fromPickedWeek: fromPicked,
                                            timeInController: _timeInController,
                                            timeOutController:
                                                _timeOutController,
                                            isShiftsScreen: true,
                                            toPickedWeek: toPicked,
                                          ),
                                          AdvancedShiftPicker(
                                            isShiftsScreen: true,
                                            weekDay:
                                                getTranslated(context, "الأحد"),
                                            fromPickedWeek: sunFromT,
                                            timeInController:
                                                sunTimeInController,
                                            timeOutController:
                                                sunTimeOutController,
                                            toPickedWeek: sunToT,
                                            callBackfunFrom: (TimeOfDay v) {
                                              sunFromT = v;
                                            },
                                            callBackfunTo: (TimeOfDay v) {
                                              sunToT = v;
                                            },
                                          ),
                                          AdvancedShiftPicker(
                                            weekDay: getTranslated(
                                                context, "الأثنين"),
                                            isShiftsScreen: true,
                                            fromPickedWeek: monFromT,
                                            timeInController:
                                                monTimeInController,
                                            timeOutController:
                                                monTimeOutController,
                                            toPickedWeek: monToT,
                                            callBackfunFrom: (TimeOfDay v) {
                                              monFromT = v;
                                            },
                                            callBackfunTo: (TimeOfDay v) {
                                              monToT = v;
                                            },
                                          ),
                                          AdvancedShiftPicker(
                                            isShiftsScreen: true,
                                            weekDay: getTranslated(
                                                context, "الثلاثاء"),
                                            fromPickedWeek: tuesFromT,
                                            timeInController:
                                                tuesTimeInController,
                                            timeOutController:
                                                tuesTimeOutController,
                                            toPickedWeek: tuesToT,
                                            callBackfunFrom: (TimeOfDay v) {
                                              tuesFromT = v;
                                            },
                                            callBackfunTo: (TimeOfDay v) {
                                              tuesToT = v;
                                            },
                                          ),
                                          AdvancedShiftPicker(
                                            weekDay: getTranslated(
                                                context, "الأربعاء"),
                                            isShiftsScreen: true,
                                            fromPickedWeek: wedFromT,
                                            timeInController:
                                                wedTimeInController,
                                            timeOutController:
                                                wedTimeOutController,
                                            toPickedWeek: wedToT,
                                            callBackfunFrom: (TimeOfDay v) {
                                              wedFromT = v;
                                            },
                                            callBackfunTo: (TimeOfDay v) {
                                              wedToT = v;
                                            },
                                          ),
                                          AdvancedShiftPicker(
                                            weekDay: getTranslated(
                                                context, "الخميس"),
                                            isShiftsScreen: true,
                                            fromPickedWeek: thuFromT,
                                            timeInController:
                                                thuTimeInController,
                                            timeOutController:
                                                thuTimeOutController,
                                            toPickedWeek: thuToT,
                                            callBackfunFrom: (TimeOfDay v) {
                                              thuFromT = v;
                                            },
                                            callBackfunTo: (TimeOfDay v) {
                                              thuToT = v;
                                            },
                                          ),
                                          AdvancedShiftPicker(
                                            weekDay: getTranslated(
                                                context, "الجمعة"),
                                            isShiftsScreen: true,
                                            fromPickedWeek: friFromT,
                                            timeInController:
                                                friTimeInController,
                                            timeOutController:
                                                friTimeOutController,
                                            toPickedWeek: friToT,
                                            callBackfunFrom: (TimeOfDay v) {
                                              friFromT = v;
                                            },
                                            callBackfunTo: (TimeOfDay v) {
                                              friToT = v;
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: RoundedButton(
                                onPressed: () async {
                                  final DateTime now = DateTime.now();
                                  final TimeOfDay t = fromPicked;
                                  final TimeOfDay tt = toPicked;
                                  final TimeOfDay sunT = sunFromT;
                                  final TimeOfDay sunTT = sunToT;
                                  final TimeOfDay monT = monFromT;
                                  final TimeOfDay monTT = monToT;
                                  final TimeOfDay tuesT = tuesFromT;
                                  final TimeOfDay tuesTT = tuesToT;
                                  final TimeOfDay wedT = wedFromT;
                                  final TimeOfDay wedTT = wedToT;
                                  final TimeOfDay thurT = thuFromT;
                                  final TimeOfDay thurTT = thuToT;
                                  final TimeOfDay friT = friFromT;
                                  final TimeOfDay friTT = friToT;

                                  final DateTime dateFrom = DateTime(now.year,
                                      now.month, now.day, t.hour, t.minute);

                                  final DateTime dateTo = DateTime(now.year,
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

                                  final startInt = int.parse(DateFormat("HH:mm")
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
                                  final endInt = int.parse(DateFormat("HH:mm")
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
                                              title: getTranslated(
                                                context,
                                                "إضافة مناوبة",
                                              ),
                                              content:
                                                  " ${getTranslated(context, "برجاء العلم ان مواعيد المناوبة من")} $startString \n ${getTranslated(context, "إلي")} $endString",
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
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return RoundedAlert(
                                                onPressed: () async {
                                                  {
                                                    editShiftFun();
                                                  }
                                                },
                                                title: getTranslated(
                                                    context, 'حفظ التعديل'),
                                                content: getTranslated(context,
                                                    "هل تريد حفظ التعديل ؟"));
                                          },
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
                                    ? getTranslated(context, "إضافة")
                                    : edit
                                        ? getTranslated(context, "حفظ")
                                        : getTranslated(context, "تعديل"),
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
                        Navigator.of(context)
                            .pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ShiftsScreen(0, -1, siteId)),
                                (Route<dynamic> route) => false)
                            .then((value) => Provider.of<SiteShiftsData>(
                                    context,
                                    listen: false)
                                .getShiftsList(siteName, false));
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
    final user = Provider.of<UserData>(context, listen: false).user;
    final bool mondayCheck = compareShiftTime(monFromT, monToT),
        sundayCheck = compareShiftTime(sunFromT, sunToT),
        tuesCheck = compareShiftTime(tuesFromT, tuesToT),
        wednCheck = compareShiftTime(wedFromT, wedToT),
        thursCheck = compareShiftTime(thuFromT, thuToT),
        friCheck = compareShiftTime(friFromT, friToT);

    if (!mondayCheck ||
        !sundayCheck ||
        !tuesCheck ||
        !thursCheck ||
        !wednCheck ||
        !friCheck) {
      Fluttertoast.showToast(
          msg: getTranslated(context,
              "خطأ : الوقت المحدد بين بداية و نهاية المناوبة\n يجب ان يكون اكبر من اربع ساعات"),
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG);
      Navigator.pop(context);
    } else {
      print("site $siteId");
      final msg =
          await Provider.of<ShiftsData>(context, listen: false).editShift(
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
                siteID: widget.shift.siteID,
              ),
              widget.id,
              user.userToken,
              context,
              widget.siteIndex);

      if (msg == "Success") {
        Provider.of<SiteShiftsData>(context, listen: false).getShiftsList(
            Provider.of<SiteShiftsData>(context, listen: false)
                .siteShiftList[widget.siteIndex]
                .siteName,
            false);
        setState(() {
          edit = false;
        });
        Fluttertoast.showToast(
                msg: getTranslated(
                  context,
                  "تم التعديل بنجاح",
                ),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true))
            .then((value) => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        ShiftsScreen(widget.siteIndex, -1, siteId)),
                (Route<dynamic> route) => false));
        Provider.of<SiteShiftsData>(context, listen: false)
            .getShiftsList(siteName, false);
      } else if (msg == "exists") {
        displayErrorToast(
            context,
            getTranslated(context,
                "خطأ في اضافة المناوبة: اسم المناوبة مستخدم مسبقا لنفس الموقع"));
      } else if (msg == "failed") {
        displayErrorToast(
            context, getTranslated(context, "خطأ في تعديل المناوبة"));
      } else if (msg == "noInternet") {
        displayErrorToast(
            context, "خطأ في تعديل المناوبة:لايوجد اتصال بالانترنت");
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
  }

  addShiftFun() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedLoadingIndicator();
        });

    final user = Provider.of<UserData>(context, listen: false).user;
    final bool mondayCheck = compareShiftTime(monFromT, monToT),
        sundayCheck = compareShiftTime(sunFromT, sunToT),
        tuesCheck = compareShiftTime(tuesFromT, tuesToT),
        wednCheck = compareShiftTime(wedFromT, wedToT),
        thursCheck = compareShiftTime(thuFromT, thuToT),
        friCheck = compareShiftTime(friFromT, friToT);

    var msg;
    if (!mondayCheck ||
        !sundayCheck ||
        !tuesCheck ||
        !thursCheck ||
        !wednCheck ||
        !friCheck) {
      Fluttertoast.showToast(
          msg: getTranslated(context,
              "خطأ : الوقت المحدد بين بداية و نهاية المناوبة\n يجب ان يكون اكبر من اربع ساعات"),
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG);
      Navigator.pop(context);
    } else {
      msg = await Provider.of<ShiftsData>(context, listen: false).addShift(
          Shift(
              shiftName: _title.text,
              siteID: Provider.of<SiteShiftsData>(context, listen: false)
                  .siteShiftList[siteId]
                  .siteId,
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
          context,
          widget.siteIndex);
      // Navigator.pop(context);
      log("MESSAGE IS $msg");
      if (msg == "Success") {
        Fluttertoast.showToast(
                msg: getTranslated(context, "تمت إضافة المناوبة بنجاح"),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true))
            .then((value) => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => ShiftsScreen(siteId, -1, siteId)),
                (Route<dynamic> route) => false));
      } else if (msg == "exists") {
        displayErrorToast(
            context,
            getTranslated(context,
                "خطأ في اضافة المناوبة: اسم المناوبة مستخدم مسبقا لنفس الموقع"));
      } else if (msg == "failed") {
        displayErrorToast(context, getTranslated(context, "حدث خطأ ما"));
      } else if (msg == "noInternet") {
        displayErrorToast(
            context,
            getTranslated(
                context, "خطأ في اضافة المناوبة : لايوجد اتصال بالانترنت"));
      } else {
        displayErrorToast(context, msg);
      }
    }
  }

  int getSiteId(String siteName) {
    final list = Provider.of<SiteData>(context, listen: false).sitesList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
  }

  int getSiteListIndex(int siteId) {
    print("list index $siteId");
    final list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteId == list[i].siteId) {
        return i;
      }
    }
    return -1;
  }

  Future<bool> onWillPop() {
    debugPrint("back");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => ShiftsScreen(widget.siteId, -1, siteId)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final onTap;

  const CircularIconButton({this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
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
  bool isShiftsScreen;
  Function callBackfunFrom, callBackfunTo;
  TextEditingController timeInController, timeOutController;
  TimeOfDay fromPickedWeek, toPickedWeek;
  AdvancedShiftPicker(
      {this.fromPickedWeek,
      this.callBackfunFrom,
      this.timeInController,
      this.timeOutController,
      this.callBackfunTo,
      this.toPickedWeek,
      this.weekDay,
      this.isShiftsScreen});
  @override
  _AdvancedShiftPickerState createState() => _AdvancedShiftPickerState();
}

class _AdvancedShiftPickerState extends State<AdvancedShiftPicker> {
  bool compareShiftTime(TimeOfDay startTime, TimeOfDay endTime) {
    final int startNumber = (startTime.hour * 60) + startTime.minute;
    final int endNumber = (endTime.hour * 60) + endTime.minute;
    final int difference = (endNumber - startNumber).abs();
    log(difference.toString());
    if (difference >= 240)
      return true;
    else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50.h,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  widget.weekDay,
                  style: TextStyle(
                      fontSize: setResponsiveFontSize(13),
                      fontWeight: FontWeight.bold),
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
                            var from;
                            if (widget.isShiftsScreen) {
                              from = await showTimePicker(
                                context: context,
                                initialTime: widget.fromPickedWeek,
                                builder: (BuildContext context, Widget child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: false),
                                    child: child,
                                  );
                                },
                              );
                              final MaterialLocalizations localizations =
                                  MaterialLocalizations.of(context);
                              final String formattedTime =
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
                          child: Container(
                            child: IgnorePointer(
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: setResponsiveFontSize(14),
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                                textInputAction: TextInputAction.next,
                                controller: widget.timeInController,
                                decoration: kTextFieldDecorationFromTO.copyWith(
                                    hintText: getTranslated(context, 'من'),
                                    prefixIcon: const Icon(
                                      Icons.alarm,
                                      color: Colors.orange,
                                    )),
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
                            var to;

                            if (widget.isShiftsScreen) {
                              to = await showTimePicker(
                                context: context,
                                initialTime: widget.toPickedWeek,
                                builder: (BuildContext context, Widget child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: false),
                                    child: child,
                                  );
                                },
                              );
                              final MaterialLocalizations localizations =
                                  MaterialLocalizations.of(context);
                              final String formattedTime2 =
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
                          child: Container(
                            child: IgnorePointer(
                              child: TextFormField(
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: setResponsiveFontSize(14),
                                    fontWeight: FontWeight.w500),
                                textInputAction: TextInputAction.next,
                                controller: widget.timeOutController,
                                decoration: kTextFieldDecorationFromTO.copyWith(
                                    hintText: getTranslated(context, 'إلى'),
                                    prefixIcon: const Icon(
                                      Icons.alarm,
                                      color: Colors.orange,
                                    )),
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
        widget.isShiftsScreen
            ? widget.fromPickedWeek == intToTimeOfDay(0) &&
                    widget.toPickedWeek == intToTimeOfDay(0)
                ? Container()
                : !compareShiftTime(widget.fromPickedWeek, widget.toPickedWeek)
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: () {},
                            child: AutoSizeText(
                              getTranslated(
                                  context, "يجب ان لا تقل المدة عن 4 ساعات"),
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      )
                    : Container()
            : Container(),
        const SizedBox(
          height: 2,
        ),
        const Divider(
          thickness: 1,
        ),
        const SizedBox(
          height: 2,
        ),
      ],
    );
  }
}
