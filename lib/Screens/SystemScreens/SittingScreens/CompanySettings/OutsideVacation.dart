import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';

import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:qr_users/widgets/UserRequests/UserOrdersListView.dart';
import 'package:qr_users/widgets/UserRequests/UserPermessionsListView.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import '../../../../constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

class OutsideVacation extends StatefulWidget {
  final Member member;
  OutsideVacation(this.member);
  @override
  _OutsideVacationState createState() => _OutsideVacationState();
}

var selectedAction = "عارضة";
var selectedMission = "داخلية";
var sleectedMember;
DateTime toDate;
String toText;
String fromText;
DateTime fromDate;
DateTime yesterday;
TextEditingController timeOutController = TextEditingController();
String dateToString = "";
String dateFromString = "";
List<String> actions = ["مرضى", "عارضة", "رصيد الاجازات", "حالة وفاة"];
List<String> missions = ["داخلية", "خارجية"];
TimeOfDay toPicked;
String dateDifference;
List<DateTime> picked = [];
String formattedTime;
String _selectedDateString;
Future userHoliday;
Future userPermession;

class _OutsideVacationState extends State<OutsideVacation> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  TextEditingController _dateController = TextEditingController();
  addExternalMission() async {
    if (fromText != "" && toText != "") {
      String msg = await Provider.of<UserHolidaysData>(context, listen: false)
          .addHoliday(
              UserHolidays(
                userId: widget.member.id,
                holidayType: 4,
                fromDate: fromDate,
                toDate: toDate,
              ),
              Provider.of<UserData>(context, listen: false).user.userToken,
              widget.member.id);
      print("assssssssss");
      if (msg == "Success : Holiday Created!") {
        Fluttertoast.showToast(
            msg: "تمت اضافة المأمورية بنجاح",
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER);
        await sendFcmMessage(
          category: "externalMission",
          message: "تم تسجيل مأمورية خارجية لك",
          userToken: widget.member.fcmToken,
          topicName: "",
          title: "تم تكليفك بمأمورية",
        ).then((value) => Navigator.pop(context));
      } else if (msg ==
          "Failed : Another Holiday not approved for this user!") {
        Fluttertoast.showToast(
            msg: "تم وضع مأمورية لهذا المستخدم من قبل",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(
            msg: "خطأ في اضافة المأمورية",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      }
    } else {
      Fluttertoast.showToast(
          msg: "برجاء ادخال المدة",
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER);
    }
  }

  List<DateTime> picked = [];
  addInternalMission() async {
    var prov = Provider.of<SiteData>(context, listen: false);
    if (prov.siteValue == "كل المواقع" || picked.isEmpty) {
      Fluttertoast.showToast(
          msg: "برجاء ادخال البيانات المطلوبة",
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER);
    } else {
      String msg = await Provider.of<MissionsData>(context, listen: false)
          .addUserMission(
        UserMissions(
            fromDate: fromDate,
            toDate: toDate,
            shiftId: Provider.of<ShiftsData>(context, listen: false)
                .shiftsBySite[prov.dropDownShiftIndex]
                .shiftId,
            userId: widget.member.id),
        Provider.of<UserData>(context, listen: false).user.userToken,
      );
      if (msg == "Success : InternalMission Created!") {
        Fluttertoast.showToast(
            msg: "تمت اضافة المأمورية بنجاح",
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER);
        print(widget.member.fcmToken);
        sendFcmMessage(
          category: "internalMission",
          message: "تم تسجيل مأمورية داخلية لك ",
          userToken: widget.member.fcmToken,
          topicName: "",
          title: "تم تكليفك بمأمورية",
        ).then((value) => Navigator.pop(context));
      } else if (msg ==
          "Failed : Another InternalMission not approved for this user!") {
        Fluttertoast.showToast(
            msg: "تم وضع مأمورية لهذا المستخدم من قبل",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(
            msg: "خطأ فى اضافة المأمورية",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      }
    }
  }

  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    // userHoliday = Provider.of<UserHolidaysData>(context, listen: false)
    //     .getSingleUserHoliday(widget.member.id,
    //         Provider.of<UserData>(context, listen: false).user.userToken);
    // userPermession = Provider.of<UserPermessionsData>(context, listen: false)
    //     .getSingleUserPermession(widget.member.id,
    //         Provider.of<UserData>(context, listen: false).user.userToken);
    Provider.of<UserHolidaysData>(context, listen: false).isLoading = false;
    var now = DateTime.now();
    fromText = "";
    toText = "";
    _selectedDateString = DateTime.now().toString();
    commentController.text = "";
    timeOutController.text = "";
    toPicked = (intToTimeOfDay(0));
    fromDate = DateTime(now.year, now.month, now.day);
    toDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    yesterday = DateTime(now.year, DateTime.december, 30);
    sleectedMember =
        Provider.of<MemberData>(context, listen: false).membersList[0].name;
    super.initState();
  }

  var radioVal2 = 2;
  @override
  void dispose() {
    super.dispose();
  }

  var selectedVal = "كل المواقع";
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<SiteData>(context, listen: false);
    var list = Provider.of<SiteData>(context, listen: true).dropDownSitesList;
    return GestureDetector(
        onTap: () {
          print(fromText);
          _nameController.text == ""
              ? FocusScope.of(context).unfocus()
              : SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: radioVal2 == 2
              ? Container()
              : FadeInDown(
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    child: FloatingActionButton(
                      elevation: 4,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            List<UserHolidays> provList =
                                Provider.of<UserHolidaysData>(context,
                                        listen: true)
                                    .singleUserHoliday;
                            var permessionsList =
                                Provider.of<UserPermessionsData>(
                              context,
                            ).singleUserPermessions;
                            return FlipInY(
                              child: Dialog(
                                child: Container(
                                  height: radioVal2 == 1
                                      ? provList.isEmpty
                                          ? 100.h
                                          : 500.h
                                      : permessionsList.isEmpty
                                          ? 100.h
                                          : 500.h,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text(
                                        radioVal2 == 1
                                            ? "اجازات المستخدم"
                                            : "اذونات المستخدم",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Divider(),
                                      radioVal2 == 1
                                          ? FutureBuilder(
                                              future: userHoliday,
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.orange,
                                                    ),
                                                  );
                                                } else {
                                                  return provList.isEmpty
                                                      ? Text(
                                                          "لا يوجد اجازات لهذا المستخدم",
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )
                                                      : Expanded(
                                                          child:
                                                              UserOrdersListView(
                                                            provList: provList,
                                                            memberId: widget
                                                                .member.id,
                                                          ),
                                                        );
                                                }
                                              })
                                          : FutureBuilder(
                                              future: userPermession,
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.orange,
                                                    ),
                                                  );
                                                } else {
                                                  return Expanded(
                                                    child: permessionsList
                                                            .isEmpty
                                                        ? Text(
                                                            "لا يوجد اذونات لهذا المستخدم",
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          )
                                                        : UserPermessionListView(
                                                            isFilter: false,
                                                            memberId: widget
                                                                .member.id,
                                                            permessionsList:
                                                                permessionsList),
                                                  );
                                                }
                                              })
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      backgroundColor: Colors.orange[600],
                      child: Icon(
                        FontAwesomeIcons.info,
                        color: Colors.black,
                        size:
                            ScreenUtil().setSp(30, allowFontScalingSelf: true),
                      ),
                    ),
                  ),
                ),
          endDrawer: NotificationItem(),
          body: SingleChildScrollView(
            child: Container(
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
                                  "تسجيل مأمورية",
                                ),
                              ],
                            ),
                          ),
                          VacationCardHeader(
                            header:
                                "تسجيل مأمورية للمستخدم : ${widget.member.name}",
                          ),
                          // Directionality(
                          //   textDirection: ui.TextDirection.rtl,
                          //   child: Container(
                          //     child: SearchableDropdown.single(
                          //       dialogBox: false,
                          //       menuConstraints:
                          //           BoxConstraints.tight(Size.fromHeight(400)),
                          //       items: Provider.of<MemberData>(context,
                          //               listen: false)
                          //           .membersList
                          //           .map(
                          //             (value) => DropdownMenuItem(
                          //                 child: Container(
                          //                     alignment: Alignment.topRight,
                          //                     height: 20,
                          //                     child: AutoSizeText(
                          //                       value.name,
                          //                       style: TextStyle(
                          //                           color: Colors.black,
                          //                           fontSize: ScreenUtil().setSp(12,
                          //                               allowFontScalingSelf: true),
                          //                           fontWeight: FontWeight.w700),
                          //                     )),
                          //                 value: value.name),
                          //           )
                          //           .toList(),
                          //       value: sleectedMember,
                          //       hint: "اسم المستخدم",
                          //       closeButton: "غلق",
                          //       onChanged: (value) {
                          //         setState(() {
                          //           sleectedMember = value;
                          //         });
                          //       },
                          //       isExpanded: true,
                          //     ),
                          //   ),
                          // ),
                          //COMMENTED TILL DISCUTION//
                          // VacationCardHeader(
                          //   header: "نوع الطلب",
                          // ),
                          // Padding(
                          //   padding: EdgeInsets.only(right: 20.w),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       RadioButtonWidg(
                          //         radioVal2: radioVal2,
                          //         radioVal: 3,
                          //         title: "أذن",
                          //         onchannge: (value) {
                          //           setState(() {
                          //             radioVal2 = value;
                          //           });
                          //         },
                          //       ),
                          //       RadioButtonWidg(
                          //         radioVal2: radioVal2,
                          //         radioVal: 1,
                          //         title: "اجازة",
                          //         onchannge: (value) {
                          //           setState(() {
                          //             radioVal2 = value;
                          //           });
                          //         },
                          //       ),
                          //       RadioButtonWidg(
                          //         radioVal: 2,
                          //         radioVal2: radioVal2,
                          //         title: "مأمورية",
                          //         onchannge: (value) {
                          //           setState(() {
                          //             radioVal2 = value;
                          //           });
                          //         },
                          //       ),
                          //     ],
                          //   ),
                          // ),
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
                                                        initialLastDate: toDate,
                                                        firstDate: DateTime(
                                                            DateTime.now().year,
                                                            DateTime.now()
                                                                .month,
                                                            DateTime.now().day),
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
                                        ? fromText == ""
                                            ? Container()
                                            : Container(
                                                padding: EdgeInsets.all(5),
                                                alignment:
                                                    Alignment.centerRight,
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
                                                            fromDate: picked[0],
                                                            toDate:
                                                                picked.length == 2
                                                                    ? picked[1]
                                                                    : DateTime
                                                                        .now(),
                                                            holidayType:
                                                                selectedReason ==
                                                                        "عارضة"
                                                                    ? 1
                                                                    : selectedReason ==
                                                                            "مرضية"
                                                                        ? 2
                                                                        : 3,
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
                                                    return showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        sendFcmMessage(
                                                          topicName: "",
                                                          title: "أجازة",
                                                          category: "vacation",
                                                          userToken: widget
                                                              .member.fcmToken,
                                                          message:
                                                              "تم وضع اجازة لك ",
                                                        );

                                                        return StackedNotificaitonAlert(
                                                          repeatAnimation:
                                                              false,
                                                          popWidget: true,
                                                          notificationTitle:
                                                              "تم وضع الطلب  بنجاح ",
                                                          notificationContent:
                                                              "برجاء متابعة الطلب ",
                                                          roundedButtonTitle:
                                                              "متابعة",
                                                          isAdmin: true,
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
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor: Colors.red,
                                                    msg:
                                                        "قم بأدخال مدة الأجازة");
                                              }
                                            },
                                            title: "حفظ",
                                          )
                                  ],
                                )
                              : radioVal2 == 2
                                  ? Column(
                                      children: [
                                        VacationCardHeader(
                                          header: "نوع المأمورية",
                                        ),
                                        Directionality(
                                          textDirection: ui.TextDirection.rtl,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                alignment: Alignment.topRight,
                                                padding: EdgeInsets.only(
                                                    right: 10.w),
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
                                                      missions.map((String x) {
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
                                                      selectedMission = value;
                                                    });
                                                  },
                                                  value: selectedMission,
                                                )),
                                              ),
                                            ),
                                          ),
                                        ),
                                        selectedMission == "داخلية"
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
                                          header: "مدة المأمورية",
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

                                                      fromText =
                                                          " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                      toText =
                                                          " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
                                                      newString =
                                                          "$fromText $toText";
                                                      if (_dateController
                                                              .text !=
                                                          newString) {
                                                        _dateController.text =
                                                            newString;

                                                        dateFromString =
                                                            apiFormatter.format(
                                                                fromDate);
                                                        dateToString =
                                                            apiFormatter
                                                                .format(toDate);
                                                      }
                                                    });
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
                                                              color:
                                                                  Colors.black,
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
                                          height: 20.h,
                                        ),
                                        Provider.of<UserHolidaysData>(context)
                                                    .isLoading ||
                                                Provider.of<MissionsData>(
                                                        context)
                                                    .isLoading
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              )
                                            : RoundedButton(
                                                onPressed: () async {
                                                  if (selectedMission ==
                                                      "خارجية") {
                                                    addExternalMission();
                                                  } //داخلية
                                                  else {
                                                    addInternalMission();
                                                  }
                                                },
                                                title: "حفظ",
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
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
                                                          items:
                                                              permessionTitles
                                                                  .map((String
                                                                      x) {
                                                            return DropdownMenuItem<
                                                                    String>(
                                                                value: x,
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
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
                                                                            FontWeight.w500),
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
                                                      padding:
                                                          EdgeInsets.all(10),
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
                                                          type:
                                                              DateTimePickerType
                                                                  .date,
                                                          firstDate:
                                                              DateTime.now(),
                                                          lastDate: DateTime(
                                                              DateTime.now()
                                                                  .year,
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
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),

                                                          decoration:
                                                              kTextFieldDecorationTime
                                                                  .copyWith(
                                                                      hintStyle:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w400,
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
                                                            if (val.length ==
                                                                0) {
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
                                                      padding:
                                                          EdgeInsets.all(10),
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

                                                                if (to !=
                                                                    null) {
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
                                                                child:
                                                                    Container(
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
                                                                      decoration: kTextFieldDecorationFromTO.copyWith(
                                                                          hintText: 'الوقت',
                                                                          prefixIcon: Icon(
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
                                                DetialsTextField(
                                                    commentController)
                                              ],
                                            ),
                                          ),
                                        ),
                                        Provider.of<UserPermessionsData>(
                                                        context)
                                                    .isLoading ||
                                                Provider.of<UserHolidaysData>(
                                                        context)
                                                    .isLoading
                                            ? CircularProgressIndicator(
                                                backgroundColor: Colors.orange)
                                            : RoundedButton(
                                                onPressed: () async {
                                                  if (_selectedDateString !=
                                                          null &&
                                                      timeOutController.text !=
                                                          "") {
                                                    print(_selectedDateString);
                                                    print(
                                                        timeOutController.text);
                                                    String msg = await Provider
                                                            .of<UserPermessionsData>(context,
                                                                listen: false)
                                                        .addUserPermession(
                                                            UserPermessions(
                                                                date:
                                                                    selectedDate,
                                                                duration:
                                                                    formattedTime,
                                                                permessionType:
                                                                    selectedPermession == "تأخير عن الحضور"
                                                                        ? 1
                                                                        : 2,
                                                                permessionDescription: commentController.text == ""
                                                                    ? "لا يوجد تعليق"
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
                                                      return showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          sendFcmMessage(
                                                            topicName: "",
                                                            userToken: widget
                                                                .member
                                                                .fcmToken,
                                                            title: "اذن",
                                                            category:
                                                                "permession",
                                                            message:
                                                                "تم وضع اذن لك",
                                                          );

                                                          return StackedNotificaitonAlert(
                                                            repeatAnimation:
                                                                false,
                                                            popWidget: true,
                                                            notificationTitle:
                                                                "تم وضع الطلب  بنجاح ",
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
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          backgroundColor:
                                                              Colors.red,
                                                          msg:
                                                              "لقد تم تقديم طلب من قبل");
                                                    } else if (msg ==
                                                        "failed") {
                                                      errorToast();
                                                    }
                                                  } else {
                                                    print(selectedDateString);
                                                    print(
                                                        timeOutController.text);
                                                    Fluttertoast.showToast(
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        backgroundColor:
                                                            Colors.red,
                                                        msg:
                                                            "قم بأدخال البيانات المطلوبة");
                                                  }
                                                },
                                                title: "حفظ",
                                              )
                                      ],
                                    ),
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
          header: "الموقع و المناوبة للمأمورية",
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
                            child: Consumer<ShiftsData>(
                              builder: (context, value, child) {
                                return IgnorePointer(
                                  ignoring:
                                      widget.prov.siteValue == "كل المواقع"
                                          ? true
                                          : false,
                                  child: DropdownButton(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      elevation: 5,
                                      items: value.shiftsBySite
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
                                            "كل المواقع") {
                                          List<String> x = [];

                                          value.shiftsBySite.forEach((element) {
                                            x.add(element.shiftName);
                                          });

                                          print("on changed $v");
                                          holder = x.indexOf(v);

                                          widget.prov.setDropDownShift(holder);
                                          shiftId =
                                              value.shiftsList[holder].shiftId;
                                        }
                                      },
                                      hint: Text("كل المناوبات"),
                                      value:
                                          widget.prov.siteValue == "كل المواقع"
                                              ? null
                                              : value
                                                  .shiftsBySite[widget
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
                  color: Colors.orange[600],
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

                                    if (v != "كل المواقع") {
                                      widget.prov.setDropDownIndex(widget
                                              .prov.dropDownSitesStrings
                                              .indexOf(v) -
                                          1);
                                    } else {
                                      widget.prov.setDropDownIndex(0);
                                    }
                                    await Provider.of<ShiftsData>(context,
                                            listen: false)
                                        .findMatchingShifts(
                                            Provider.of<SiteData>(context,
                                                    listen: false)
                                                .sitesList[widget
                                                    .prov.dropDownSitesIndex]
                                                .id,
                                            false);

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
                  color: Colors.orange[600],
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
