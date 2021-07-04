import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/MainCompanySettings.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/ReallocateUsers.dart';

import 'package:qr_users/constants.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';

import 'UsersScreen.dart';

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
bool checkBoxVal = false;

TimeOfDay intToTimeOfDay(int time) {
  int hours = (time ~/ 100);
  int min = time - (hours * 100);
  return TimeOfDay(hour: hours, minute: min);
}

String date;
AudioCache player = AudioCache();

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
    if (instance != null) {
      instance.stop();
    }
    levelClock = 300;
    timeOutController.text = "12:00AM";
    date = apiFormatter.format(DateTime.now());
    isSAved = false;
    selectedDateString = DateTime.now().toString();
    var now = DateTime.now();

    selectedDate = DateTime(now.year, now.month, now.day);
    fromPicked = (intToTimeOfDay(0));
    toPicked = (intToTimeOfDay(0));
    animateController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(milliseconds: 200),
    );
  }

  void playLoopedMusic() async {
    player = AudioCache(prefix: "");
    instance = await player.loop("clock.mp3");
    // await instance.setVolume(0.5); you can even set the volume
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AnimationController animateController;
  @override
  Widget build(BuildContext context) {
    var userType = Provider.of<UserData>(context, listen: false).user.userType;
    return Scaffold(
      body: Column(
        children: [
          Header(nav: false),
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
                                          text: "7000 جنية مصرى"),
                                    ),
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
                                        icon: Icons.location_on,
                                        text: Provider.of<SiteData>(context,
                                                listen: true)
                                            .sitesList[widget.siteIndex]
                                            .name,
                                      ),
                                    ),
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
                                          .format(DateTime.now())
                                          .toString())
                                    ],
                                  ),
                                ),
                                Divider(),
                                isSAved == false
                                    ? AssignTaskToUser(
                                        taskName: "اعطاء أذن لهذا المستخدم",
                                        iconData: FontAwesomeIcons.stopwatch,
                                        function: () => showPermessionDialog())
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 3),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(radioVal1 == 1
                                                ? "تأخير عن الحضور"
                                                : "انصراف مبكر"),
                                            Row(
                                              children: [
                                                Text(toPicked
                                                    .format(context)
                                                    .replaceAll(" ", "")),
                                                SizedBox(
                                                  width: 1,
                                                ),
                                                Text(","),
                                                Text(
                                                  selectedDate
                                                      .toString()
                                                      .substring(0, 10),
                                                  textDirection:
                                                      ui.TextDirection.ltr,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                InkWell(
                                                  onTap: () =>
                                                      showPermessionDialog(),
                                                  child: Icon(
                                                    FontAwesomeIcons.stopwatch,
                                                    color: Colors.orange,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                Divider(),
                                AssignTaskToUser(
                                  taskName: "تسجيل اجازات و مأموريات",
                                  iconData: FontAwesomeIcons.calendarCheck,
                                  function: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OutsideVacation(widget.user),
                                      )),
                                ),
                                Divider(),
                                AssignTaskToUser(
                                  function: () => widget.onResetMac(),
                                  iconData: Icons.repeat,
                                  taskName: "اعادة ضبط المستخدم",
                                ),
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
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
                                            duration:
                                                Duration(milliseconds: 800),
                                            controller: (controller) =>
                                                animateController = controller,
                                            manualTrigger: true,
                                            child: Checkbox(
                                              checkColor: Colors.white,
                                              activeColor: Colors.orange,
                                              value: checkBoxVal,
                                              onChanged: (value) {
                                                if (value == true) {
                                                  animateController.repeat();
                                                }
                                                setState(() {
                                                  print(
                                                      animateController.value);
                                                  checkBoxVal = value;
                                                });
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(),
                                AssignTaskToUser(
                                    taskName: "جدولة المناوبات",
                                    iconData: Icons.table_view,
                                    function: () async {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return RoundedLoadingIndicator();
                                          });
                                      var userProvider = Provider.of<UserData>(
                                          context,
                                          listen: false);
                                      var comProvider =
                                          Provider.of<CompanyData>(context,
                                              listen: false);
                                      await Provider.of<DaysOffData>(context,
                                              listen: false)
                                          .getDaysOff(
                                              comProvider.com.id,
                                              userProvider.user.userToken,
                                              context);
                                      for (int i = 0; i < 7; i++) {
                                        await Provider.of<DaysOffData>(context,
                                                listen: false)
                                            .setSiteAndShift(
                                                i,
                                                getShiftName(),
                                                Provider.of<SiteData>(context,
                                                        listen: false)
                                                    .sitesList[widget.siteIndex]
                                                    .name);
                                      }
                                      Navigator.pop(context);

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReAllocateUsers(widget.user),
                                          ));
                                    }),
                                Divider(),
                                AssignTaskToUser(
                                    taskName: " إرسال اثبات حضور",
                                    iconData: FontAwesomeIcons.checkCircle,
                                    function: () {
                                      return showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          _controller = AnimationController(
                                              vsync: this,
                                              duration: Duration(
                                                  seconds:
                                                      300) // gameData.levelClock is a user entered number elsewhere in the applciation
                                              );

                                          _controller.forward();

                                          return Stack(
                                            children: [
                                              Dialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)), //this right here
                                                  child: Directionality(
                                                      textDirection:
                                                          ui.TextDirection.rtl,
                                                      child: Container(
                                                        height: 250,
                                                        width: double.infinity,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height: 50.h,
                                                              ),
                                                              InkWell(
                                                                onTap: () {},
                                                                child: Text(
                                                                  "اثبات حضور",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .orange,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                              Divider(),
                                                              Text(
                                                                  "برجاء اثبات حضورك قبل انتهاء الوقت المحدد"),
                                                              SizedBox(
                                                                height: 20.h,
                                                              ),
                                                              RoundedButton(
                                                                  title:
                                                                      "اثبات",
                                                                  onPressed:
                                                                      () {
                                                                    Fluttertoast.showToast(
                                                                        msg:
                                                                            "تم اثبات الحضور بنجاح",
                                                                        backgroundColor:
                                                                            Colors
                                                                                .green,
                                                                        gravity:
                                                                            ToastGravity.CENTER);

                                                                    Navigator.pop(
                                                                        context);
                                                                  }),
                                                              Spacer(),
                                                              // Countdown(
                                                              //   function: () {
                                                              //     Navigator.pop(
                                                              //         context);
                                                              //   },
                                                              //   animation:
                                                              //       StepTween(
                                                              //     begin:
                                                              //         levelClock, // THIS IS A USER ENTERED NUMBER
                                                              //     end: 0,
                                                              //   ).animate(
                                                              //           _controller),
                                                              // ),
                                                            ],
                                                          ),
                                                        ),
                                                      ))),
                                              Positioned(
                                                  right: 125.w,
                                                  top: 180.h,
                                                  child: Container(
                                                    width: 150.w,
                                                    height: 150.h,
                                                    padding: EdgeInsets.all(20),
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              60),
                                                      child: Lottie.network(
                                                          "https://assets5.lottiefiles.com/packages/lf20_ktrj1k3o.json",
                                                          fit: BoxFit.fill),
                                                    ),
                                                  ))
                                            ],
                                          );
                                        },
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                                child:
                                    RounderButton("تعديل", widget.onTapEdit)),
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

  String plusSignPhone(String phoneNum) {
    int len = phoneNum.length;
    if (phoneNum[0] == "+") {
      return " ${phoneNum.substring(1, len)}+";
    } else {
      return "$phoneNum+";
    }
  }

  showPermessionDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, sets) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0)), //this right here
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 500.h,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: SmallDirectoriesHeader(
                                Lottie.asset("resources/schedule.json",
                                    repeat: false),
                                "اضافة اذن",
                              ),
                            ),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("تأخير عن الحضور"),
                                        Radio(
                                          activeColor: Colors.orange,
                                          value: 1,
                                          groupValue: radioVal1,
                                          onChanged: (value) {
                                            print(value);
                                            sets(() {
                                              radioVal1 = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("انصراف مبكر"),
                                        Radio(
                                          activeColor: Colors.orange,
                                          value: 2,
                                          groupValue: radioVal1,
                                          onChanged: (value) {
                                            print(value);
                                            sets(() {
                                              radioVal1 = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: Card(
                                elevation: 5,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "تاريخ الأذن",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
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
                                textDirection: ui.TextDirection.rtl,
                                child: Container(
                                  child: Theme(
                                    data: clockTheme,
                                    child: DateTimePicker(
                                      initialValue: selectedDateString,

                                      onChanged: (value) {
                                        print(date);
                                        print(value);
                                        if (value != date) {
                                          date = value;
                                          selectedDateString = date;

                                          sets(() {
                                            selectedDate = DateTime.parse(
                                                selectedDateString);
                                          });
                                          print(selectedDate);
                                        }

                                        print(value);
                                      },
                                      type: DateTimePickerType.date,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(DateTime.now().year,
                                          DateTime.december, 31),
                                      //controller: _endTimeController,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(14,
                                              allowFontScalingSelf: true),
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),

                                      decoration:
                                          kTextFieldDecorationTime.copyWith(
                                              hintStyle: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                              hintText: 'اليوم',
                                              prefixIcon: Icon(
                                                Icons.access_time,
                                                color: Colors.orange,
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
                              textDirection: ui.TextDirection.rtl,
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
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Directionality(
                              textDirection: ui.TextDirection.rtl,
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
                                            var to = await showTimePicker(
                                              context: context,
                                              initialTime: toPicked,
                                              builder: (BuildContext context,
                                                  Widget child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context)
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
                                                .replaceAll(" ", ""));
                                            if (to != null) {
                                              toPicked = to;
                                              sets(() {
                                                timeOutController.text =
                                                    "${toPicked.format(context).replaceAll(" ", "")}";
                                              });
                                            }
                                          },
                                          child: Directionality(
                                            textDirection: ui.TextDirection.rtl,
                                            child: Container(
                                              child: IgnorePointer(
                                                child: TextFormField(
                                                  enabled: false,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  controller: timeOutController,
                                                  decoration:
                                                      kTextFieldDecorationFromTO
                                                          .copyWith(
                                                              hintText: 'الوقت',
                                                              prefixIcon: Icon(
                                                                Icons.alarm,
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
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            RoundedButton(
                              onPressed: () {
                                print("bool $isSAved");
                                print(toPicked);
                                print(selectedDate);
                                print(isSAved);
                                if (toPicked != null && selectedDate != null) {
                                  Fluttertoast.showToast(
                                          msg: isSAved == false
                                              ? "تم تسجيل الأذن بنجاح"
                                              : "تم تعديل الأذن بنجاح",
                                          backgroundColor: Colors.green)
                                      .then((value) {
                                    setState(() {
                                      isSAved = true;
                                    });
                                  });
                                  Navigator.pop(context);
                                } else {
                                  Fluttertoast.showToast(
                                      gravity: ToastGravity.CENTER,
                                      toastLength: Toast.LENGTH_LONG,
                                      msg:
                                          "خطأ فى اضافة الأذن برجاء استكمال البيانات",
                                      backgroundColor: Colors.red);
                                }
                              },
                              title: "حفظ",
                            )
                          ],
                        ),
                      ),
                    ),
                  ));
            },
          );
        });
  }
}

class AssignTaskToUser extends StatelessWidget {
  final String taskName;
  final IconData iconData;
  final Function function;
  AssignTaskToUser({
    this.iconData,
    this.function,
    this.taskName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: InkWell(
        onTap: function,
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(taskName),
              Container(
                width: 25.w,
                height: 35.h,
                child: Icon(
                  iconData,
                  color: Colors.orange,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
