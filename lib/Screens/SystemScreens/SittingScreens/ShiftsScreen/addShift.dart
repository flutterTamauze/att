import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/constants.dart';
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
    // TODO: implement initState
    super.initState();
    fillTextField();
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController _title = TextEditingController();

  TextEditingController _timeInController = TextEditingController();
  TextEditingController _timeOutController = TextEditingController();

  TimeOfDay fromPicked;
  TimeOfDay toPicked;

  TimeOfDay from24String;
  TimeOfDay to24String;

  String startString;
  String endString;

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
        backgroundColor: Colors.white,
        body: Container(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Header(nav: false),
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
                                      ? "إضافة منوابة"
                                      : "تعديل المنوابة"),
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
                                    // Container(
                                    //   width: double.infinity,
                                    //   height: 50,
                                    //   child: Row(
                                    //     children: [
                                    //       Expanded(
                                    //         flex: 1,
                                    //         child: Directionality(
                                    //           textDirection:
                                    //               ui.TextDirection.rtl,
                                    //           child: Theme(
                                    //             data: clockTheme,
                                    //             child: DateTimePicker(
                                    //               style: TextStyle(
                                    //                   color: Colors.black),
                                    //               enabled: edit,
                                    //               type: DateTimePickerType.time,
                                    //               controller:
                                    //                   _endTimeController,
                                    //               decoration:
                                    //                   kTextFieldDecorationTime
                                    //                       .copyWith(
                                    //                           hintText: 'إلى',
                                    //                           prefixIcon: Icon(
                                    //                             Icons.alarm,
                                    //                             color: Colors
                                    //                                 .orange,
                                    //                           )),
                                    //               validator: (val) {
                                    //                 if (val.length == 0) {
                                    //                   return 'مطلوب';
                                    //                 }
                                    //                 return null;
                                    //               },
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       SizedBox(
                                    //         width: 5,
                                    //       ),
                                    //       Expanded(
                                    //         flex: 1,
                                    //         child: Directionality(
                                    //           textDirection:
                                    //               ui.TextDirection.rtl,
                                    //           child: Theme(
                                    //             data: clockTheme,
                                    //             child: DateTimePicker(
                                    //               onChanged: (value) {
                                    //                 print(_startTimeController
                                    //                     .text);
                                    //               },
                                    //               style: TextStyle(
                                    //                   color: Colors.black),
                                    //               enabled: edit,
                                    //               type: DateTimePickerType.time,
                                    //               controller:
                                    //                   _startTimeController,
                                    //               decoration:
                                    //                   kTextFieldDecorationTime
                                    //                       .copyWith(
                                    //                           hintText: 'من',
                                    //                           prefixIcon: Icon(
                                    //                             Icons.alarm,
                                    //                             color: Colors
                                    //                                 .orange,
                                    //                           )),
                                    //               validator: (val) {
                                    //                 if (val.length == 0) {
                                    //                   return 'مطلوب';
                                    //                 }
                                    //                 return null;
                                    //               },
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //   height: 10.0,
                                    // ),
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
                                                              context: context,
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
                                                                  child: child,
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

                                                            if (from != null) {
                                                              fromPicked = from;
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
                                                                          Icons
                                                                              .alarm,
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
                                                                              false),
                                                                  child: child,
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
                                                                          Icons
                                                                              .alarm,
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
                                      height: 10.0.h,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: RoundedButton(
                                onPressed: () async {
                                  print("d$fromPicked");

                                  // var startInt = int.parse(
                                  //     "${fromPicked.hour}${fromPicked.minute}");
                                  // var endInt = int.parse(
                                  //     "${fromPicked.hour}${fromPicked.minute}");

                                  // var startInt = int.parse(fromPicked
                                  //     .format(context)
                                  //     .split(" ")[0]
                                  //     .replaceAll(":", ""));
                                  //
                                  // var endInt = int.parse(toPicked
                                  //     .format(context)
                                  //     .split(" ")[0]
                                  //     .replaceAll(":", ""));
                                  DateTime now = DateTime.now();
                                  TimeOfDay t = fromPicked;
                                  TimeOfDay tt = toPicked;
                                  final noww = new DateTime.now();

                                  DateTime dateFrom = DateTime(now.year,
                                      now.month, now.day, t.hour, t.minute);

                                  DateTime dateTo = DateTime(now.year,
                                      now.month, now.day, tt.hour, tt.minute);

                                  var startInt = int.parse(DateFormat("HH:mm")
                                      .format(dateFrom)
                                      .replaceAll(":", ""));
                                  startString =
                                      DateFormat("HH:mm").format(dateFrom);

                                  endString =
                                      DateFormat("HH:mm").format(dateTo);

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
                                          builder: (context) =>
                                              SingleChildScrollView(
                                            child: Container(
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
                                                            builder:
                                                                (BuildContext
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
            shiftName: _title.text,
            shiftId: widget.shift.shiftId,
            siteID: Provider.of<SiteData>(context, listen: false)
                .sitesList[siteId]
                .id,
            shiftStartTime: int.parse(startString.replaceAll(":", "")),
            shiftEndTime: int.parse(endString.replaceAll(":", ""))),
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
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedLoadingIndicator();
        });

    print(
        "${_title.text} + $siteId , ${int.parse(startString.replaceAll(":", ""))} + ${int.parse(endString.replaceAll(":", ""))}");
    var user = Provider.of<UserData>(context, listen: false).user;

    var msg = await Provider.of<ShiftsData>(context, listen: false).addShift(
        Shift(
            shiftName: _title.text,
            siteID: Provider.of<SiteData>(context, listen: false)
                .sitesList[siteId]
                .id,
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
