import 'dart:async';

// import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftSchedule/ShiftSchedule.dart';

import 'package:qr_users/constants.dart';
import 'package:qr_users/services/AttendProof/attend_proof.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';

import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/UserFullData/assignTaskToUser.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'package:qr_users/widgets/roundedButton.dart';

class UserFullDataScreen extends StatefulWidget {
  @override
  _UserFullDataScreenState createState() => _UserFullDataScreenState();

  UserFullDataScreen(
      {this.user,
      this.onResetMac,
      this.onTapDelete,
      this.onTapEdit,
      this.siteIndex});
  final Member user;
  final int siteIndex;
  final Function onTapEdit;
  final Function onTapDelete;
  final Function onResetMac;
}

bool isSAved = false;
bool allowToAttendBox = false;
bool noShowInReport = false;
TimeOfDay intToTimeOfDay(int time) {
  int hours = (time ~/ 100);
  int min = time - (hours * 100);
  return TimeOfDay(hour: hours, minute: min);
}

String date;
AudioCache player = AudioCache();
AttendProof attendObj = AttendProof();
AudioPlayer instance;
TextEditingController timeInController = TextEditingController();
TextEditingController timeOutController = TextEditingController();
String selectedDateString;
var radioVal1 = 1;
DateTime selectedDate;
final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
TimeOfDay fromPicked;
TimeOfDay toPicked;

AnimationController _controller;
int levelClock = 300;

class _UserFullDataScreenState extends State<UserFullDataScreen>
    with TickerProviderStateMixin {
  void initState() {
    super.initState();
    // if (instance != null) {
    //   instance.stop();
    // }
    levelClock = 300;

    timeOutController.text = "12:00AM";
    date = apiFormatter.format(DateTime.now());
    isSAved = false;
    selectedDateString = DateTime.now().toString();
    var now = DateTime.now();

    selectedDate = DateTime(now.year, now.month, now.day);
    fromPicked = (intToTimeOfDay(0));
    toPicked = (intToTimeOfDay(0));
    animateControllerOne = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(milliseconds: 200),
    );
    animateControllerTwo = AnimationController(
        vsync: this, // the SingleTickerProviderStateMixin
        duration: Duration(milliseconds: 200));
  }

  void playLoopedMusic() async {
    // player = AudioCache(prefix: "");
    // instance = await player.loop("clock.mp3");
    // await instance.setVolume(0.5); you can even set the volume
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  AnimationController animateControllerOne;
  AnimationController animateControllerTwo;
  @override
  Widget build(BuildContext context) {
    var userType = Provider.of<UserData>(context, listen: false).user.userType;

    return Scaffold(
      endDrawer: NotificationItem(),
      body: Column(
        children: [
          Header(
            nav: false,
            goUserMenu: false,
            goUserHomeFromMenu: false,
          ),
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: Color(0xffFF7E00),
                          ),
                        ),
                        child: Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                  '$baseURL/${widget.user.userImageURL}',
                                ),
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2, color: Color(0xffFF7E00))),
                        ),
                      ),
                      Container(
                        height: 20,
                        child: AutoSizeText(
                          widget.user.name,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: ScreenUtil()
                                  .setSp(14, allowFontScalingSelf: true),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                UserDataField(
                                  icon: Icons.email,
                                  text: widget.user.email,
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: UserDataField(
                                        icon: Icons.title,
                                        text: widget.user.jobTitle,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    userType == 4
                                        ? Expanded(
                                            flex: 1,
                                            child: UserDataField(
                                              icon: Icons.person,
                                              text: widget.user.normalizedName,
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: UserDataField(
                                          icon: Icons.phone,
                                          text: plusSignPhone(
                                                  widget.user.phoneNumber)
                                              .replaceAll(
                                                  new RegExp(r"\s+\b|\b\s"),
                                                  "")),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: UserDataField(
                                          icon: FontAwesomeIcons.moneyBill,
                                          text:
                                              "${widget.user.salary} جنية مصرى"),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  children: [
                                    userType != 2
                                        ? Expanded(
                                            flex: 1,
                                            child: UserDataField(
                                              icon: Icons.location_on,
                                              text: Provider.of<SiteData>(
                                                      context,
                                                      listen: true)
                                                  .sitesList[widget.siteIndex]
                                                  .name,
                                            ),
                                          )
                                        : Container(),
                                    Expanded(
                                      flex: 1,
                                      child: UserDataField(
                                          icon: Icons.query_builder,
                                          text: getShiftName()),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "تاريخ التعيين",
                                      ),
                                      Text(DateFormat('yMMMd')
                                          .format(widget.user.hiredDate)
                                          .toString())
                                    ],
                                  ),
                                ),
                                userType == 4 ? Divider() : Container(),
                                userType != 2
                                    ? AssignTaskToUser(
                                        taskName:
                                            "تسجيل  مأموريات / اذونات / اجازات",
                                        iconData:
                                            FontAwesomeIcons.calendarCheck,
                                        function: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OutsideVacation(widget.user),
                                            )),
                                      )
                                    : Container(),
                                Divider(),
                                userType == 4
                                    ? AssignTaskToUser(
                                        function: () => widget.onResetMac(),
                                        iconData: Icons.repeat,
                                        taskName: "اعادة ضبط هاتف المستخدم",
                                      )
                                    : Container(),
                                userType == 4 ? Divider() : Container(),
                                userType == 4
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 3),
                                        child: Container(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "السماح للمستخدم بالتسجيل بالبطاقة",
                                              ),
                                              Container(
                                                width: 20.w,
                                                height: 20.h,
                                                child: Pulse(
                                                  duration: Duration(
                                                      milliseconds: 800),
                                                  controller: (controller) =>
                                                      animateControllerOne =
                                                          controller,
                                                  manualTrigger: true,
                                                  child: Checkbox(
                                                    checkColor: Colors.white,
                                                    activeColor: Colors.orange,
                                                    value: widget
                                                        .user.isAllowedToAttend,
                                                    onChanged: (value) {
                                                      if (value == true) {
                                                        animateControllerOne
                                                            .repeat();
                                                      }
                                                      setState(() {
                                                        allowToAttendBox =
                                                            value;
                                                      });
                                                      widget.user
                                                              .isAllowedToAttend =
                                                          value;
                                                      Provider.of<MemberData>(
                                                              context,
                                                              listen: false)
                                                          .allowMemberAttendByCard(
                                                              widget.user.id,
                                                              value,
                                                              Provider.of<UserData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .user
                                                                  .userToken);
                                                    },
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userType == 4 ? Divider() : Container(),
                                userType == 4
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 3),
                                        child: Container(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "عدم الظهور في التقرير",
                                              ),
                                              Container(
                                                width: 20.w,
                                                height: 20.h,
                                                child: Pulse(
                                                  duration: Duration(
                                                      milliseconds: 800),
                                                  controller: (controller) =>
                                                      animateControllerTwo =
                                                          controller,
                                                  manualTrigger: true,
                                                  child: Checkbox(
                                                    checkColor: Colors.white,
                                                    activeColor: Colors.orange,
                                                    value: widget
                                                        .user.excludeFromReport,
                                                    onChanged: (value) {
                                                      if (value == true) {
                                                        animateControllerTwo
                                                            .repeat();
                                                      }
                                                      setState(() {
                                                        noShowInReport = value;
                                                      });
                                                      widget.user
                                                              .excludeFromReport =
                                                          value;
                                                      Provider.of<MemberData>(
                                                              context,
                                                              listen: false)
                                                          .exludeUserFromReport(
                                                              widget.user.id,
                                                              value,
                                                              Provider.of<UserData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .user
                                                                  .userToken);
                                                    },
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                userType == 4 ? Divider() : Container(),
                                userType == 4 || userType == 2
                                    ? AssignTaskToUser(
                                        taskName: "جدولة المناوبات",
                                        iconData: Icons.table_view,
                                        function: () async {
                                          // showDialog(
                                          //     context: context,
                                          //     builder: (BuildContext context) {
                                          //       return RoundedLoadingIndicator();
                                          //     });
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ShiftScheduleScreen(
                                                  member: widget.user,
                                                  siteIndex: widget.siteIndex,
                                                ),
                                              ));
                                        })
                                    : Container(),
                                userType == 4 ? Divider() : Container(),
                                userType != 2
                                    ? AssignTaskToUser(
                                        taskName: " إرسال اثبات حضور",
                                        iconData: FontAwesomeIcons.checkCircle,
                                        function: () async {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return RoundedLoadingIndicator();
                                              });
                                          await attendObj
                                              .sendAttendProof(
                                                  Provider.of<UserData>(context,
                                                          listen: false)
                                                      .user
                                                      .userToken,
                                                  widget.user.id,
                                                  widget.user.fcmToken)
                                              .then((value) {
                                            print("VAlue $value");
                                            switch (value) {
                                              case "fail shift":
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "خطأ فى الأرسال : لم تبدأ المناوبة بعد",
                                                    backgroundColor: Colors.red,
                                                    gravity:
                                                        ToastGravity.CENTER);
                                                break;
                                              case "null":
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "خطأ فى الأرسال \n لم يتم تسجيل الدخول بهذا المستخدم من قبل ",
                                                    backgroundColor: Colors.red,
                                                    gravity:
                                                        ToastGravity.CENTER);
                                                break;
                                              case "fail present":
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "لم يتم تسجيل حضور هذا المتسخدم",
                                                    backgroundColor: Colors.red,
                                                    gravity:
                                                        ToastGravity.CENTER);
                                                break;
                                              case "fail":
                                                errorToast();
                                                break;
                                              default:
                                                sendFcmMessage(
                                                        topicName: "",
                                                        userToken: widget
                                                            .user.fcmToken,
                                                        title: "اثبات حضور",
                                                        category: "attend",
                                                        message:
                                                            "برجاء اثبات حضورك الأن")
                                                    .then((value) {
                                                  if (value) {
                                                    Fluttertoast.showToast(
                                                        msg: "تم الأرسال بنجاح",
                                                        backgroundColor:
                                                            Colors.green,
                                                        gravity: ToastGravity
                                                            .CENTER);
                                                  } else {
                                                    if (value) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "خطأ فى الأرسال ",
                                                          backgroundColor:
                                                              Colors.red,
                                                          gravity: ToastGravity
                                                              .CENTER);
                                                    }
                                                  }
                                                });
                                            }
                                          }).then((value) =>
                                                  Navigator.pop(context));
                                        })
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      userType == 4
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: RounderButton(
                                          "تعديل", widget.onTapEdit)),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  Provider.of<UserData>(context, listen: false)
                                              .user
                                              .id ==
                                          widget.user.id
                                      ? Container()
                                      : Expanded(
                                          child: RounderButton(
                                              "حذف", widget.onTapDelete))
                                ],
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getShiftName() {
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (list[i].shiftId == widget.user.shiftId) {
        return list[i].shiftName;
      }
    }
    return "";
  }
}

String plusSignPhone(String phoneNum) {
  int len = phoneNum.length;
  if (phoneNum[0] == "+") {
    return " ${phoneNum.substring(1, len)}+";
  } else {
    return "$phoneNum+";
  }
}
