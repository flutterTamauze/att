import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';

import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';

import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';

import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Core/constants.dart';

class UserVacationRequest extends StatefulWidget {
  int radioVal;
  final List<String> permesionTitles;
  final List<String> holidayTitles;
  UserVacationRequest(this.radioVal, this.permesionTitles, this.holidayTitles);
  @override
  _UserVacationRequestState createState() => _UserVacationRequestState();
}

TextEditingController commentController = TextEditingController();
String selectedReason;
String selectedPermession;
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

TimeOfDay toPicked;
String dateDifference;
List<DateTime> picked = [];
DateTime _today, _tomorow;

class _UserVacationRequestState extends State<UserVacationRequest> {
  @override
  void initState() {
    selectedPermession = widget.permesionTitles.first;
    selectedReason = widget.holidayTitles.first;
    picked = null;
    _today = DateTime.now();
    _tomorow = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    Provider.of<UserPermessionsData>(context, listen: false).isLoading = false;
    Provider.of<UserHolidaysData>(context, listen: false).isLoading = false;
    timeOutController.text = "";
    toPicked = (intToTimeOfDay(0));
    selectedDateString = null;
    dateDifference = null;
    _dateController.text = "";
    final now = DateTime.now();
    commentController.text = "";
    fromDate = DateTime(now.year, now.month, now.day);
    toDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    yesterday = DateTime(now.year + 2, DateTime.december, 31);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String formattedTime;
  var selectedVal = "كل المواقع";
  var newString = "";
  @override
  Widget build(BuildContext context) {
    final userdata = Provider.of<UserData>(context, listen: false).user;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: Container(
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
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SmallDirectoriesHeader(
                                Lottie.asset("resources/calender.json",
                                    repeat: false),
                                getTranslated(context, "طلب اذن / اجازة"),
                              ),
                            ],
                          ),
                          VacationCardHeader(
                            header: getTranslated(context, "نوع الطلب"),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RadioButtonWidg(
                                  radioVal2: widget.radioVal,
                                  radioVal: 3,
                                  title: getTranslated(context, "أذن"),
                                  onchannge: (value) {
                                    setState(() {
                                      widget.radioVal = value;
                                    });
                                  },
                                ),
                                RadioButtonWidg(
                                  radioVal2: widget.radioVal,
                                  radioVal: 1,
                                  title: getTranslated(context, "اجازة"),
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
                                      header:
                                          getTranslated(context, "نوع الأجازة"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 5.w),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(width: 1)),
                                          width: 600.w,
                                          height: 40.h,
                                          child: DropdownButtonHideUnderline(
                                              child: DropdownButton(
                                            elevation: 2,
                                            isExpanded: true,
                                            items: widget.holidayTitles
                                                .map((String x) {
                                              return DropdownMenuItem<String>(
                                                  value: x,
                                                  child: AutoSizeText(
                                                    x,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: ColorManager
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ));
                                            }).toList(),
                                            onChanged: (String value) {
                                              setState(() {
                                                selectedReason = value;
                                                if (value != "عارضة") {
                                                  _dateController.text = "";
                                                  newString = "";
                                                  _tomorow = DateTime(
                                                      DateTime.now().year,
                                                      DateTime.now().month,
                                                      DateTime.now().day + 1);
                                                  _today = DateTime.now();
                                                  toDate = _tomorow;
                                                }
                                              });
                                            },
                                            value: selectedReason,
                                          )),
                                        ),
                                      ),
                                    ),
                                    VacationCardHeader(
                                      header:
                                          getTranslated(context, "مدة الأجازة"),
                                    ),
                                    const SizedBox(
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
                                                                    getTranslated(
                                                                        context,
                                                                        "عارضة")
                                                                ? _today
                                                                : _tomorow,
                                                        initialLastDate: toDate,
                                                        firstDate: DateTime(
                                                            DateTime.now().year,
                                                            DateTime.now()
                                                                .month,
                                                            selectedReason ==
                                                                    getTranslated(
                                                                        context,
                                                                        "عارضة")
                                                                ? DateTime.now()
                                                                    .day
                                                                : DateTime.now()
                                                                        .day +
                                                                    1),
                                                        lastDate: yesterday);

                                                setState(() {
                                                  _today = picked.first;
                                                  _tomorow = picked.first;
                                                  fromDate = picked.first;
                                                  toDate = picked.last;
                                                  dateDifference = (toDate
                                                              .difference(
                                                                  fromDate)
                                                              .inDays +
                                                          1)
                                                      .toString();
                                                  fromText =
                                                      " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                  toText =
                                                      " ${getTranslated(context, "إلى")}  ${DateFormat('yMMMd').format(toDate).toString()}";
                                                  newString =
                                                      "$fromText $toText";
                                                });
                                                print(picked.length);
                                                print(fromDate);
                                                print(toDate);
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
                                              child: Container(
                                                // width: 330,
                                                width: 365.w,
                                                child: IgnorePointer(
                                                  child: TextFormField(
                                                    style: TextStyle(
                                                        color: ColorManager
                                                            .accentColor,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    controller: _dateController,
                                                    decoration: kTextFieldDecorationFromTO
                                                        .copyWith(
                                                            hintStyle: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                fontSize:
                                                                    setResponsiveFontSize(
                                                                        14),
                                                                color: Colors
                                                                    .black),
                                                            hintText: getTranslated(
                                                                context,
                                                                'المدة من / إلى'),
                                                            prefixIcon:
                                                                const Icon(
                                                              Icons
                                                                  .calendar_today_rounded,
                                                              color:
                                                                  Colors.orange,
                                                            )),
                                                  ),
                                                ),
                                              ));
                                        },
                                      ),
                                    )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    dateDifference != null
                                        ? Container(
                                            padding: const EdgeInsets.all(5),
                                            alignment: Alignment.centerRight,
                                            child: AutoSizeText(
                                              "${getTranslated(context, "تم اختيار")} $dateDifference ${getTranslated(context, "يوم")} ",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w300),
                                            ))
                                        : Container(),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    DetialsTextField(
                                      commentController,
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Card(
                                      elevation: 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            AutoSizeText(
                                              getTranslated(
                                                  context, "نوع الأذن"),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11),
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            alignment:
                                                Provider.of<PermissionHan>(
                                                            context,
                                                            listen: false)
                                                        .isEnglishLocale()
                                                    ? Alignment.centerLeft
                                                    : Alignment.centerRight,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border:
                                                        Border.all(width: 1)),
                                                width: 600.w,
                                                height: 40.h,
                                                child:
                                                    DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                  elevation: 2,
                                                  isExpanded: true,
                                                  items: widget.permesionTitles
                                                      .map((String x) {
                                                    return DropdownMenuItem<
                                                            String>(
                                                        value: x,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: AutoSizeText(
                                                            x,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: const TextStyle(
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
                                          const Divider(),
                                          Card(
                                            elevation: 5,
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  AutoSizeText(
                                                    getTranslated(
                                                        context, "تاريخ الأذن"),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            setResponsiveFontSize(
                                                                13)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            child: Container(
                                              child: Theme(
                                                data: clockTheme,
                                                child: DateTimePicker(
                                                  initialValue:
                                                      selectedDateString,

                                                  onChanged: (value) {
                                                    date = value;

                                                    setState(() {
                                                      selectedDateString = date;
                                                      selectedDate =
                                                          DateTime.parse(
                                                              selectedDateString);
                                                    });
                                                  },
                                                  initialDate:
                                                      widget.radioVal == 3
                                                          ? _today
                                                          : _tomorow,
                                                  type: DateTimePickerType.date,
                                                  firstDate:
                                                      widget.radioVal == 3
                                                          ? _today
                                                          : _tomorow,
                                                  lastDate: DateTime(
                                                      DateTime.now().year + 2,
                                                      DateTime.december,
                                                      31),
                                                  //controller: _endTimeController,
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil().setSp(
                                                          14,
                                                          allowFontScalingSelf:
                                                              true),
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400),

                                                  decoration:
                                                      kTextFieldDecorationTime
                                                          .copyWith(
                                                              hintStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              hintText:
                                                                  getTranslated(
                                                                      context,
                                                                      "اليوم"),
                                                              prefixIcon:
                                                                  const Icon(
                                                                Icons
                                                                    .access_time,
                                                                color: Colors
                                                                    .orange,
                                                              )),
                                                  validator: (val) {
                                                    if (val.length == 0) {
                                                      return getTranslated(
                                                          context, "مطلوب");
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Card(
                                            elevation: 5,
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  AutoSizeText(
                                                    selectedPermession ==
                                                            getTranslated(
                                                                context,
                                                                "تأخير عن الحضور")
                                                        ? getTranslated(context,
                                                            "اذن حتى الساعة")
                                                        : getTranslated(context,
                                                            "اذن من الساعة"),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            setResponsiveFontSize(
                                                                13)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 50.h,
                                            child: Container(
                                                child: Theme(
                                              data: clockTheme,
                                              child: Builder(
                                                builder: (context) {
                                                  return InkWell(
                                                      onTap: () async {
                                                        final to =
                                                            await showTimePicker(
                                                          context: context,
                                                          initialTime: toPicked,
                                                          builder: (BuildContext
                                                                  context,
                                                              Widget child) {
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
                                                          final dt = DateTime(
                                                              now.year,
                                                              now.month,
                                                              now.day,
                                                              to.hour,
                                                              to.minute);

                                                          formattedTime =
                                                              DateFormat.Hm()
                                                                  .format(dt);

                                                          toPicked = to;
                                                          setState(() {
                                                            timeOutController
                                                                    .text =
                                                                "${toPicked.format(context).replaceAll(" ", " ")}";
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        child: IgnorePointer(
                                                          child: TextFormField(
                                                            enabled: false,
                                                            style: const TextStyle(
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
                                                                    hintText: getTranslated(
                                                                        context,
                                                                        "الوقت"),
                                                                    prefixIcon:
                                                                        const Icon(
                                                                      Icons
                                                                          .alarm,
                                                                      color: Colors
                                                                          .orange,
                                                                    )),
                                                          ),
                                                        ),
                                                      ));
                                                },
                                              ),
                                            )),
                                          ),
                                          DetialsTextField(
                                            commentController,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          Provider.of<UserPermessionsData>(context).isLoading ||
                                  Provider.of<UserHolidaysData>(context)
                                      .isLoading
                              ? const CircularProgressIndicator(
                                  backgroundColor: Colors.orange)
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RoundedButton(
                                      title:
                                          getTranslated(context, "حفظ الطلب"),
                                      onPressed: () async {
                                        if (widget.radioVal == 1) //اجازة
                                        {
                                          if (picked != null) {
//4-2-2021
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
                                                        holidayType: selectedReason ==
                                                                getTranslated(
                                                                    context,
                                                                    "عارضة")
                                                            ? 1
                                                            : selectedReason ==
                                                                    getTranslated(
                                                                        context,
                                                                        "مرضية")
                                                                ? 2
                                                                : 3,
                                                        holidayStatus: 3),
                                                    userdata.userToken,
                                                    userdata.id)
                                                .then((value) {
                                              if (value == Holiday.Success) {
                                                return showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    sendFcmMessage(
                                                      topicName:
                                                          "attend${Provider.of<CompanyData>(context, listen: false).com.id}",
                                                      title: "طلب أجازة",
                                                      category:
                                                          "vacationRequest",
                                                      message:
                                                          "تم طلب اجازة من قبل المستخدم ${Provider.of<UserData>(context, listen: false).user.name}",
                                                    );

                                                    return StackedNotificaitonAlert(
                                                      repeatAnimation: false,
                                                      popWidget: true,
                                                      isAdmin: false,
                                                      isFromBackground: false,
                                                      notificationTitle:
                                                          getTranslated(context,
                                                              "تم تقديم طلب الأجازة بنجاح"),
                                                      notificationContent:
                                                          getTranslated(context,
                                                              "برجاء متابعة الطلب"),
                                                      roundedButtonTitle:
                                                          getTranslated(context,
                                                              "متابعة"),
                                                      lottieAsset:
                                                          "resources/success.json",
                                                      showToast: false,
                                                    );
                                                  },
                                                );
                                              } else if (value ==
                                                  Holiday
                                                      .Internal_Mission_InThis_Period) {
                                                {
                                                  Fluttertoast.showToast(
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      msg: getTranslated(
                                                          context,
                                                          "لا يمكن طلب الاجازة : يوجد مأمورية خارجية"),
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red);
                                                }
                                              } else if (value ==
                                                  Holiday
                                                      .Another_Holiday_NOT_APPROVED) {
                                                Fluttertoast.showToast(
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    msg: getTranslated(context,
                                                        "يوجد اجازة لم يتم الموافقة عليها فى هذه الفترة"),
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor:
                                                        Colors.red);
                                              } else if (value ==
                                                  Holiday
                                                      .Holiday_Approved_InThis_Period) {
                                                Fluttertoast.showToast(
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    msg: getTranslated(context,
                                                        "يوجد اجازة تم الموافقة عليها فى هذه الفترة"),
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor:
                                                        Colors.red);
                                              } else if (value ==
                                                  Holiday
                                                      .Internal_Mission_InThis_Period) {
                                                Fluttertoast.showToast(
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    msg: getTranslated(context,
                                                        "لا يمكن طلب الاجازة : يوجد مأمورية داخلية"),
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor:
                                                        Colors.red);
                                              } else if (value ==
                                                  Holiday
                                                      .Permession_InThis_Period) {
                                                Fluttertoast.showToast(
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    msg: getTranslated(context,
                                                        "لا يمكن طلب الاجازة : يوجد طلب اذن"),
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor:
                                                        Colors.red);
                                              } else {
                                                errorToast(context);
                                              }
                                            });
                                          } else {
                                            Fluttertoast.showToast(
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.red,
                                                msg: getTranslated(context,
                                                    "قم بأدخال مدة الأجازة"));
                                          }
                                        } else //اذن
                                        {
                                          if (selectedDateString != null &&
                                              timeOutController.text != "") {
                                            print(selectedDate);
                                            print(timeOutController.text);
                                            final String msg = await Provider.of<UserPermessionsData>(
                                                    context,
                                                    listen: false)
                                                .addUserPermession(
                                                    UserPermessions(
                                                        // createdOn: DateTime.now(),
                                                        date: selectedDate,
                                                        duration: formattedTime
                                                            .replaceAll(
                                                                ":", ""),
                                                        permessionType:
                                                            selectedPermession == getTranslated(context, "تأخير عن الحضور")
                                                                ? 1
                                                                : 2,
                                                        permessionDescription:
                                                            commentController.text == ""
                                                                ? getTranslated(
                                                                    context,
                                                                    "لا يوجد تعليق")
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
                                                        "attend${Provider.of<CompanyData>(context, listen: false).com.id}",
                                                    title: getTranslated(
                                                        context, "طلب اذن"),
                                                    category:
                                                        "permessionRequest",
                                                    message:
                                                        "${getTranslated(context, "تم طلب اذن من قبل المستخدم ")}${Provider.of<UserData>(context, listen: false).user.name}",
                                                  );

                                                  return StackedNotificaitonAlert(
                                                    repeatAnimation: false,
                                                    isFromBackground: false,
                                                    popWidget: true,
                                                    isAdmin: false,
                                                    notificationTitle:
                                                        getTranslated(context,
                                                            "تم تقديم طلب الأذن بنجاح"),
                                                    notificationContent:
                                                        getTranslated(context,
                                                            "برجاء متابعة الطلب"),
                                                    roundedButtonTitle:
                                                        getTranslated(
                                                            context, "متابعة"),
                                                    lottieAsset:
                                                        "resources/success.json",
                                                    showToast: false,
                                                  );
                                                },
                                              );
                                            } else if (msg == 'already exist') {
                                              Fluttertoast.showToast(
                                                  gravity: ToastGravity.CENTER,
                                                  backgroundColor: Colors.red,
                                                  msg: getTranslated(context,
                                                      "لقد تم تقديم طلب من قبل"));
                                            } else if (msg ==
                                                "dublicate permession") {
                                              Fluttertoast.showToast(
                                                  gravity: ToastGravity.CENTER,
                                                  backgroundColor: Colors.red,
                                                  msg: getTranslated(context,
                                                      "يوجد اذن اخر فى هذا اليوم"));
                                            } else if (msg ==
                                                "external mission") {
                                              Fluttertoast.showToast(
                                                  gravity: ToastGravity.CENTER,
                                                  backgroundColor: Colors.red,
                                                  msg: getTranslated(context,
                                                      "يوجد مأمورية خارجية فى هذا اليوم"));
                                            } else if (msg == "holiday") {
                                              Fluttertoast.showToast(
                                                  gravity: ToastGravity.CENTER,
                                                  backgroundColor: Colors.red,
                                                  msg: getTranslated(context,
                                                      "يوجد اجازة فى هذا اليوم"));
                                            } else if (msg ==
                                                "holiday was not approved") {
                                              Fluttertoast.showToast(
                                                  gravity: ToastGravity.CENTER,
                                                  backgroundColor: Colors.red,
                                                  msg: getTranslated(context,
                                                      "يوجد اجازة لم يتم الموافقة عليها"));
                                            } else if (msg == "failed") {
                                              errorToast(context);
                                            }
                                          } else {
                                            print(selectedDateString);
                                            print(timeOutController.text);
                                            Fluttertoast.showToast(
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.red,
                                                msg: getTranslated(context,
                                                    "قم بأدخال البيانات المطلوبة"));
                                          }
                                        }
                                      }),
                                )
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
        AutoSizeText(title),
      ],
    );
  }
}
