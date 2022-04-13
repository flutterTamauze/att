import 'dart:developer';

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
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';

import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/RadioButtonWidget.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:qr_users/widgets/UserFullData/floating_button_missions.dart';
import 'package:qr_users/widgets/UserFullData/user_floating_button_permVacations.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import '../../../../Core/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

class OutsideVacation extends StatefulWidget {
  final Member member;
  int radioValue;
  final List<String> permessionTitles;
  final List<String> holidayTitles;
  OutsideVacation(
      this.member, this.radioValue, this.permessionTitles, this.holidayTitles);
  @override
  _OutsideVacationState createState() => _OutsideVacationState();
}

var selectedAction = "عارضة";
var selectedMission;
var sleectedMember;
String selectedReason;
String selectedPermession;
DateTime toDate;
String toText;
String fromText;
DateTime fromDate;
DateTime yesterday, tomorrow, _today;
TextEditingController timeOutController = TextEditingController();
String dateToString = "";
String dateFromString = "";
String newString = "";
List<String> missions;
TimeOfDay toPicked;
String dateDifference;
List<DateTime> picked = [];
String formattedTime;
String _selectedDateString;
Future userHoliday;
Future userPermession;
Future userMission;
TextEditingController externalMissionController = TextEditingController();

class _OutsideVacationState extends State<OutsideVacation> {
  bool isPicked = false;

  TextEditingController _dateController = TextEditingController();

  List<DateTime> picked = [];

  TextEditingController _nameController = TextEditingController();
  @override
  void didChangeDependencies() {
    missions = [
      getTranslated(context, "داخلية"),
      getTranslated(context, "خارجية")
    ];
    super.didChangeDependencies();
  }

  @override
  void initState() {
    final UserHolidaysData _userHolidayData =
        Provider.of<UserHolidaysData>(context, listen: false);
    final UserPermessionsData _userPermessionData =
        Provider.of<UserPermessionsData>(context, listen: false);
    Provider.of<SiteData>(context, listen: false).setSiteValue("كل المواقع");
    _userPermessionData.isLoading = false;
    _userHolidayData.loadingHolidaysDetails = false;

    _userHolidayData.isLoading = false;
    _userPermessionData.permessionDetailLoading = false;
    isPicked = false;
    Provider.of<MissionsData>(context, listen: false).isLoading = false;
    // userMission = getSingleUserMission();
    _userHolidayData.singleUserHoliday.clear();
    Provider.of<UserPermessionsData>(context, listen: false)
        .singleUserPermessions
        .clear();
    Provider.of<MissionsData>(context, listen: false)
        .singleUserMissionsList
        .clear();
    selectedMission =
        Provider.of<PermissionHan>(context, listen: false).isEnglishLocale()
            ? "Internal"
            : "داخلية";
    selectedReason = widget.holidayTitles.first;
    selectedPermession = widget.permessionTitles.first;
    final now = DateTime.now();
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
    fromDate = now;
    _selectedDateString = now.toString();
    yesterday = DateTime(now.year + 2, DateTime.december, 31);
    _today = now;

    super.initState();
  }

  var selectedVal = "كل المواقع";
  @override
  Widget build(BuildContext context) {
    final SiteData prov = Provider.of<SiteData>(context, listen: false);
    final List<Site> list =
        Provider.of<SiteShiftsData>(context, listen: true).sites;
    final SiteShiftsData shiftsData =
        Provider.of<SiteShiftsData>(context, listen: false);
    final sitesData = Provider.of<SiteData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return GestureDetector(
        onTap: () {
          _nameController.text == ""
              ? FocusScope.of(context).unfocus()
              : SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          // floatingActionButton: widget.radioValue == 2
          //     ? FadeInMissionsFAbutton(
          //         memberId: widget.member.id,
          //       )
          //     :
          floatingActionButton: widget.radioValue != 2
              ? FadeInVacPermFloatingButton(
                  radioVal2: widget.radioValue,
                  comingFromAdminPanel: false,
                  memberId: widget.member.id,
                )
              : Container(),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SmallDirectoriesHeader(
                                Lottie.asset("resources/calender.json",
                                    repeat: false),
                                getTranslated(context, "الأجازات و المأموريات"),
                              ),
                            ],
                          ),
                          VacationCardHeader(
                            header:
                                "${getTranslated(context, "تسجيل طلب للمستخدم:")} ${widget.member.name}",
                          ),
                          VacationCardHeader(
                            header: getTranslated(context, "نوع الطلب"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RadioButtonWidg(
                                  radioVal2: widget.radioValue,
                                  radioVal: 3,
                                  title: getTranslated(context, "أذن"),
                                  onchannge: (value) {
                                    setState(() {
                                      _today = DateTime.now();
                                      widget.radioValue = value;
                                    });
                                  },
                                ),
                                RadioButtonWidg(
                                  radioVal2: widget.radioValue,
                                  radioVal: 1,
                                  title: getTranslated(context, "اجازة"),
                                  onchannge: (value) {
                                    setState(() {
                                      fromDate = widget.radioValue == 3
                                          ? DateTime.now()
                                          : tomorrow;
                                      widget.radioValue = value;
                                    });
                                  },
                                ),
                                RadioButtonWidg(
                                  radioVal: 2,
                                  radioVal2: widget.radioValue,
                                  title: getTranslated(
                                    context,
                                    "مأمورية",
                                  ),
                                  onchannge: (value) {
                                    // getSingleUserMission();
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
                                                                : tomorrow,
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
                                                      " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                  toText =
                                                      "  ${getTranslated(context, "إلى")} ${DateFormat('yMMMd').format(toDate).toString()}";
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
                                              child: Container(
                                                // width: 330,
                                                width: 365.w,
                                                child: IgnorePointer(
                                                  child: TextFormField(
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    controller: _dateController,
                                                    decoration:
                                                        kTextFieldDecorationFromTO
                                                            .copyWith(
                                                                hintText:
                                                                    getTranslated(
                                                                        context,
                                                                        "المدة من / الى"),
                                                                prefixIcon:
                                                                    const Icon(
                                                                  Icons
                                                                      .calendar_today_rounded,
                                                                  color: Colors
                                                                      .orange,
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
                                        ? fromText == ""
                                            ? Container()
                                            : Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  "${getTranslated(context, "تم اختيار")} $dateDifference ${getTranslated(context, "يوم")} ",
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ))
                                        : Container(),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    VacationCardHeader(
                                      header:
                                          getTranslated(context, "نوع الأجازة"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 5.w),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(width: 1)),
                                          height: 40.h,
                                          child: DropdownButtonHideUnderline(
                                              child: DropdownButton(
                                            elevation: 2,
                                            isExpanded: true,
                                            items: widget.holidayTitles
                                                .map((String x) {
                                              return DropdownMenuItem<String>(
                                                  value: x,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10),
                                                    child: AutoSizeText(
                                                      x,
                                                      style: const TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ));
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedReason = value;
                                                if (value !=
                                                    getTranslated(
                                                        context, "عارضة")) {
                                                  _dateController.text = "";
                                                  newString = "";
                                                  tomorrow = DateTime(
                                                      DateTime.now().year,
                                                      DateTime.now().month,
                                                      DateTime.now().day + 1);
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
                                    DetialsTextField(commentController),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Provider.of<UserPermessionsData>(context)
                                                .isLoading ||
                                            Provider.of<UserHolidaysData>(
                                                    context)
                                                .isLoading
                                        ? const CircularProgressIndicator(
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
                                                                picked.length ==
                                                                        2
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
                                                            // createdOnDate:
                                                            //     DateTime.now(),
                                                            holidayStatus: 3),
                                                        Provider.of<UserData>(
                                                                context,
                                                                listen: false)
                                                            .user
                                                            .userToken,
                                                        widget.member.id)
                                                    .then((value) {
                                                  if (value ==
                                                      Holiday.Success) {
                                                    Fluttertoast.showToast(
                                                            msg: getTranslated(
                                                                context,
                                                                "تم الإضافة بنجاح"),
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            backgroundColor:
                                                                Colors.green)
                                                        .whenComplete(() =>
                                                            Navigator.pop(
                                                                context));

                                                    sendFcmMessage(
                                                      topicName: "",
                                                      title: "أجازة",
                                                      category: "vacation",
                                                      userToken: widget
                                                          .member.fcmToken,
                                                      message:
                                                          "تم وضع اجازة لك ",
                                                    );
                                                  } else if (value ==
                                                      Holiday
                                                          .External_Mission_InThis_Period) {
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "لا يمكن وضع الأجازة : يوجد مأمورية خارجية"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red);
                                                  } else if (value ==
                                                      Holiday
                                                          .Holiday_Approved_InThis_Period) {
                                                    Fluttertoast.showToast(
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        msg: getTranslated(
                                                            context,
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
                                                        msg: getTranslated(
                                                          context,
                                                          "لا يمكن وضع الاجازة : يوجد مأمورية داخلية",
                                                        ),
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
                                                        msg: getTranslated(
                                                            context,
                                                            "لا يمكن طلب الاجازة : يوجد طلب اذن"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        backgroundColor:
                                                            Colors.red);
                                                  } else if (value ==
                                                      Holiday
                                                          .Another_Holiday_NOT_APPROVED) {
                                                    Fluttertoast.showToast(
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        msg: getTranslated(
                                                            context,
                                                            "يوجد اجازة لم يتم الموافقة عليها فى هذه الفترة"),
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
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor: Colors.red,
                                                    msg: getTranslated(context,
                                                        "قم بأدخال مدة الأجازة"));
                                              }
                                            },
                                            title:
                                                getTranslated(context, "حفظ"),
                                          )
                                  ],
                                )
                              : widget.radioValue == 2
                                  ? Column(
                                      children: [
                                        VacationCardHeader(
                                          header: getTranslated(
                                              context, "نوع المأمورية"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(width: 1)),
                                            height: 40.h,
                                            child: DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                              elevation: 2,
                                              isExpanded: true,
                                              items: missions.map((String x) {
                                                return DropdownMenuItem<String>(
                                                    value: x,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                      child: AutoSizeText(
                                                        x,
                                                        style: const TextStyle(
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
                                                  selectedMission = value;
                                                });
                                              },
                                              value: selectedMission,
                                            )),
                                          ),
                                        ),
                                        selectedMission ==
                                                getTranslated(context, "داخلية")
                                            ? SitesAndMissionsWidg(
                                                prov: prov,
                                                selectedVal: selectedVal,
                                                list: list,
                                                onchannge: (value) {
                                                  setState(() {
                                                    selectedVal = value;
                                                  });
                                                },
                                              )
                                            : Container(),
                                        VacationCardHeader(
                                          header: getTranslated(
                                              context, "مدة المأمورية"),
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
                                                                fromDate,
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
                                                      isPicked = true;
                                                      final String fromText =
                                                          " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                      final String toText =
                                                          " ${getTranslated(context, "إلى")}  ${DateFormat('yMMMd').format(toDate).toString()}";
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
                                                      dateToString =
                                                          apiFormatter
                                                              .format(toDate);
                                                    }
                                                  },
                                                  child: Container(
                                                    // width: 330,
                                                    width: 365.w,
                                                    child: IgnorePointer(
                                                      child: TextFormField(
                                                        style: const TextStyle(
                                                            color: Colors.black,
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
                                                                hintText:
                                                                    getTranslated(
                                                                        context,
                                                                        'المدة من / إلى'),
                                                                prefixIcon:
                                                                    const Icon(
                                                                  Icons
                                                                      .calendar_today_rounded,
                                                                  color: Colors
                                                                      .orange,
                                                                )),
                                                      ),
                                                    ),
                                                  ));
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        DetialsTextField(
                                            externalMissionController),
                                        Provider.of<UserHolidaysData>(context)
                                                    .isLoading ||
                                                Provider.of<MissionsData>(
                                                        context)
                                                    .isLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              )
                                            : RoundedButton(
                                                onPressed: () async {
                                                  if (selectedMission ==
                                                      getTranslated(
                                                          context, "خارجية")) {
                                                    if (isPicked == false) {
                                                      Fluttertoast.showToast(
                                                          msg: getTranslated(
                                                              context,
                                                              "برجاء ادخال المدة"),
                                                          backgroundColor:
                                                              Colors.red);
                                                    } else {
                                                      Provider.of<UserHolidaysData>(
                                                              context,
                                                              listen: false)
                                                          .addExternalMission(
                                                              fromDate,
                                                              toDate,
                                                              context,
                                                              widget.member.id,
                                                              externalMissionController
                                                                  .text,
                                                              widget.member
                                                                  .fcmToken);
                                                    }
                                                  } //داخلية
                                                  else {
                                                    Provider.of<MissionsData>(
                                                            context,
                                                            listen: false)
                                                        .addInternalMission(
                                                            context,
                                                            picked,
                                                            externalMissionController
                                                                .text,
                                                            fromDate,
                                                            toDate,
                                                            widget.member.id,
                                                            widget.member
                                                                .fcmToken,
                                                            widget
                                                                .member.osType,
                                                            shiftsData
                                                                .siteShiftList[
                                                                    sitesData
                                                                        .dropDownSitesIndex]
                                                                .siteName,
                                                            shiftsData
                                                                .shifts[sitesData
                                                                    .dropDownShiftIndex]
                                                                .shiftName);
                                                  }
                                                },
                                                title: getTranslated(
                                                    context, "حفظ"),
                                              )
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
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          setResponsiveFontSize(
                                                              11)),
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
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border:
                                                          Border.all(width: 1)),
                                                  height: 40.h,
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                          child: DropdownButton(
                                                    elevation: 2,
                                                    isExpanded: true,
                                                    items: widget
                                                        .permessionTitles
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
                                              const Divider(),
                                              Card(
                                                elevation: 5,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      AutoSizeText(
                                                        getTranslated(context,
                                                            "تاريخ الأذن"),
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
                                                padding:
                                                    const EdgeInsets.all(5),
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
                                                          DateTime.now().year +
                                                              2,
                                                          DateTime.december,
                                                          31),
                                                      //controller: _endTimeController,
                                                      style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(14,
                                                                  allowFontScalingSelf:
                                                                      true),
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400),

                                                      decoration: kTextFieldDecorationTime
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
                                                                      'اليوم'),
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
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      AutoSizeText(
                                                        selectedPermession ==
                                                                getTranslated(
                                                                    context,
                                                                    "تأخير عن الحضور")
                                                            ? getTranslated(
                                                                context,
                                                                "اذن حتى الساعة")
                                                            : getTranslated(
                                                                context,
                                                                "اذن من الساعة",
                                                              ),
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13),
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
                                                          child: Container(
                                                            child:
                                                                IgnorePointer(
                                                              child:
                                                                  TextFormField(
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
                                                                            'الوقت'),
                                                                        prefixIcon:
                                                                            const Icon(
                                                                          Icons
                                                                              .alarm,
                                                                          color:
                                                                              Colors.orange,
                                                                        )),
                                                              ),
                                                            ),
                                                          ));
                                                    },
                                                  ),
                                                )),
                                              ),
                                              DetialsTextField(
                                                  commentController)
                                            ],
                                          ),
                                        ),
                                        Provider.of<UserPermessionsData>(
                                                        context)
                                                    .isLoading ||
                                                Provider.of<UserHolidaysData>(
                                                        context)
                                                    .isLoading
                                            ? const CircularProgressIndicator(
                                                backgroundColor: Colors.orange)
                                            : RoundedButton(
                                                onPressed: () async {
                                                  if (_selectedDateString !=
                                                          null &&
                                                      timeOutController.text !=
                                                          "") {
                                                    final String msg = await Provider.of<UserPermessionsData>(context, listen: false)
                                                        .addUserPermession(
                                                            UserPermessions(
                                                                // createdOn:
                                                                //     DateTime.now(),
                                                                date: DateTime.parse(
                                                                    _selectedDateString),
                                                                duration: formattedTime
                                                                    .replaceAll(
                                                                        ":", ""),
                                                                permessionType:
                                                                    selectedPermession == getTranslated(context, "تأخير عن الحضور")
                                                                        ? 1
                                                                        : 2,
                                                                permessionDescription: commentController.text == ""
                                                                    ? getTranslated(
                                                                        context, "لا يوجد تعليق")
                                                                    : commentController
                                                                        .text,
                                                                user: widget
                                                                    .member
                                                                    .name),
                                                            Provider.of<UserData>(
                                                                    context,
                                                                    listen: false)
                                                                .user
                                                                .userToken,
                                                            widget.member.id);
                                                    if (msg == "success") {
                                                      Fluttertoast.showToast(
                                                              msg: getTranslated(
                                                                  context,
                                                                  "تم الإضافة بنجاح"),
                                                              backgroundColor:
                                                                  Colors.green,
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER)
                                                          .whenComplete(() =>
                                                              Navigator.pop(
                                                                  context));
                                                      {
                                                        sendFcmMessage(
                                                          topicName: "",
                                                          userToken: widget
                                                              .member.fcmToken,
                                                          title: "اذن",
                                                          category:
                                                              "permession",
                                                          message:
                                                              "تم وضع اذن لك",
                                                        );
                                                      }
                                                    } else if (msg ==
                                                        "external mission") {
                                                      debugPrint(
                                                          "external found");
                                                      Fluttertoast.showToast(
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          backgroundColor:
                                                              Colors.red,
                                                          msg: getTranslated(
                                                              context,
                                                              "يوجد مأمورية خارجية فى هذا اليوم"));
                                                    } else if (msg ==
                                                        'already exist') {
                                                      Fluttertoast.showToast(
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          backgroundColor:
                                                              Colors.red,
                                                          msg: getTranslated(
                                                              context,
                                                              "لقد تم تقديم طلب من قبل"));
                                                    } else if (msg ==
                                                        "failed") {
                                                      errorToast(context);
                                                    } else if (msg ==
                                                        "dublicate permession") {
                                                      Fluttertoast.showToast(
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          backgroundColor:
                                                              Colors.red,
                                                          msg: getTranslated(
                                                              context,
                                                              "يوجد اذن فى هذا اليوم"));
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        backgroundColor:
                                                            Colors.red,
                                                        msg: getTranslated(
                                                            context,
                                                            "قم بأدخال البيانات المطلوبة"));
                                                  }
                                                },
                                                title: getTranslated(
                                                    context, "حفظ"),
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
  const SitesAndMissionsWidg({
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
    int holder;
    return Column(
      children: [
        VacationCardHeader(
            header: getTranslated(
          context,
          "الموقع و المناوبة للمأمورية",
        )),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 60.h,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          Consumer<SiteShiftsData>(
                            builder: (context, value, child) {
                              return IgnorePointer(
                                ignoring: widget.prov.siteValue == "كل المواقع"
                                    ? true
                                    : false,
                                child: DropdownButton(
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    elevation: 5,
                                    items: value.shifts
                                        .map(
                                          (value) => DropdownMenuItem(
                                              child: Container(
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
                                      if (widget.selectedVal != "كل المواقع") {
                                        final List<String> x = [];

                                        value.shifts.forEach((element) {
                                          x.add(element.shiftName);
                                        });
                                        setState(() {
                                          debugPrint("on changed $v");
                                          holder = x.indexOf(v);

                                          Provider.of<SiteData>(context,
                                                  listen: false)
                                              .setDropDownShift(holder);
                                        });
                                      }
                                    },
                                    hint: AutoSizeText(
                                        getTranslated(context, "كل المناوبات")),
                                    value: widget.prov.siteValue == "كل المواقع"
                                        ? null
                                        : value
                                            .shifts[Provider.of<SiteData>(
                                                    context,
                                                    listen: true)
                                                .dropDownShiftIndex]
                                            .shiftName

                                    // value
                                    ),
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.alarm,
                  color: Colors.orange[600],
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          Consumer<ShiftsData>(
                            builder: (context, value, child) {
                              return DropdownButton(
                                isExpanded: true,
                                underline: const SizedBox(),
                                elevation: 5,
                                items: widget.list
                                    .map((value) => DropdownMenuItem(
                                          child: Container(
                                            height: 20,
                                            child: AutoSizeText(
                                              value.name,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: ScreenUtil().setSp(
                                                      12,
                                                      allowFontScalingSelf:
                                                          true),
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          value: value.name,
                                        ))
                                    .toList(),
                                onChanged: (v) async {
                                  widget.prov.setDropDownShift(0);
                                  Provider.of<SiteShiftsData>(context,
                                          listen: false)
                                      .getShiftsList(v, false);
                                  if (v != "كل المواقع") {
                                    widget.prov.setDropDownIndex(widget
                                            .prov.dropDownSitesStrings
                                            .indexOf(v) -
                                        1);
                                  } else {
                                    widget.prov.setDropDownIndex(0);
                                  }

                                  widget.prov.fillCurrentShiftID(widget
                                      .list[widget.prov.dropDownSitesIndex + 1]
                                      .id);

                                  widget.prov.setSiteValue(v);
                                  widget.onchannge(v);
                                },
                                value: widget.selectedVal,
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
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
  const VacationCardHeader({
    this.header,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            AutoSizeText(
              header,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: setResponsiveFontSize(13)),
            ),
          ],
        ),
      ),
    );
  }
}
