import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'dart:ui' as ui;
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import '../SettingsScreen.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'AttendanceSettings.dart';
import 'OfficialVacations.dart';
import 'OutsideVacation.dart';

class CompanySettings extends StatefulWidget {
  @override
  _CompanySettingsState createState() => _CompanySettingsState();
}

int selectedDuration;
var toDate;
var fromDate;
var selectedNo = attendNumbers.first;
var selectedLeave = leaveNumbers.first;
DateTime yesterday;
TextEditingController controller = TextEditingController();
final _formKey = GlobalKey<FormState>();
List<String> attendNumbers = ["ساعة", "ساعتين", "٣ ساعات"];
List<String> leaveNumbers = [
  "ساعة",
  "ساعتين",
  "٣ ساعات",
  "٤ ساعات",
  "٥ ساعات",
  "٦ ساعات"
];
// int _cameraFace = FlutterMobileVision.CAMERA_FRONT;
// bool _autoFocusFace = true;
// bool _torchFace = false;
// bool _multipleFace = true;
// bool _showTextFace = true;
// Size _previewFace;
// List<Face> _faces = [];

class _CompanySettingsState extends State<CompanySettings> {
  @override
  void initState() {
    // TODO: implement initState
    var now = DateTime.now();
    // FlutterMobileVision.start().then((previewSizes) => setState(() {
    //       _previewFace = previewSizes[_cameraFace].first;
    //     }));
    fromDate = DateTime(now.year, now.month, now.day - 1);
    toDate = DateTime(now.year, now.month, now.day - 1);
    yesterday = DateTime(now.year, now.month, now.day - 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);
    Future getDaysOff() async {
      await Provider.of<DaysOffData>(context, listen: false)
          .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
    }

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Header(nav: false),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: SmallDirectoriesHeader(
                Lottie.asset("resources/settings1.json", repeat: false),
                "اعدادات الشركة",
              ),
            ),
          ),
          ServiceTile(
              title: "العطلات الأسبوعية",
              subTitle: "ادارة العطلات الأسبوعية",
              icon: FontAwesomeIcons.calendarWeek,
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                await getDaysOff();
                Navigator.pop(context);
                showVacationsDetails();
              }),
          ServiceTile(
              title: "العطلات الرسمية",
              subTitle: "ادارة العطلات الرسمية",
              icon: Icons.calendar_today_rounded,
              onTap: () async {
                print("going t vacation");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfficialVacation(),
                    ));
              }),
          // ServiceTile(
          //     title: "اعدادات الخصومات",
          //     subTitle: "ادارة الخصومات",
          //     icon: Icons.money_off_csred_outlined,
          //     onTap: () async {}),

          ServiceTile(
              title: "اعدادات الحضور و الأنصراف",
              subTitle: "ادارة الحضور و الأنصراف",
              icon: FontAwesomeIcons.usersCog,
              onTap: () {
                showAttendanceSettings();
              }),

          // ServiceTile(
          //     title: "test only",
          //     subTitle: "testonly",
          //     icon: FontAwesomeIcons.usersCog,
          //     onTap: () async {
          //       print("d");

          //       // try {
          //       //   await FlutterMobileVision.face(
          //       //     autoFocus: _autoFocusFace,
          //       //     multiple: _multipleFace,
          //       //     flash: _torchFace,
          //       //     showText: _showTextFace,
          //       //     preview: _previewFace,
          //       //     camera: _cameraFace,
          //       //     fps: 15.0,
          //       //   );
          //       // } catch (e) {
          //       //   print(e);
          //       // }
          //     }),
          // // ServiceTile(
          // //     title: "تسجيل إذن",
          // //     subTitle: "ادارة الأذونات",
          // //     icon: FontAwesomeIcons.calendarCheck,
          // //     onTap: () async {
          // //       Navigator.push(
          // //           context,
          // //           MaterialPageRoute(
          // //             builder: (context) => SchedulePermession(),
          // //           ));
          // //     }),
        ],
      ),
    );
  }

  showAttendanceSettings() async {
    return showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(onTap: () {
            if (!_formKey.currentState.validate()) {
              return;
            } else {}
            FocusScope.of(context).unfocus();
          }, child: StatefulBuilder(
            builder: (context, sets) {
              return Form(
                key: _formKey,
                child: Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0)), //this right here
                    child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Container(
                        height: 300.h,
                        width: double.infinity,
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "اعدادات الحضور و الأنصراف",
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(19, allowFontScalingSelf: true),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        height: 50.h,
                                        child: Text(
                                          "سماحية التأخير",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScreenUtil().setSp(15,
                                                allowFontScalingSelf: true),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 120.w,
                                        height: 40.h,
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          onEditingComplete: () {
                                            print("finsh");
                                          },
                                          textAlignVertical:
                                              TextAlignVertical.bottom,
                                          textAlign: TextAlign.center,
                                          cursorColor: Colors.orange,
                                          style: TextStyle(
                                            color: Colors.orange,
                                          ),
                                          controller: controller,
                                          validator: (value) {
                                            if (!RegExp(
                                                    r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$')
                                                .hasMatch(value)) {
                                              return "برجاء ادخال رقم";
                                            } else if (value.isEmpty) {
                                              return 'برجاء تحديد المدة';
                                            } else if (int.parse(value) > 30 ||
                                                int.parse(value) < 0) {
                                              return 'برجاء ادخال مدة من  0 إلى 30';
                                            }
                                          },
                                          decoration: InputDecoration(
                                              errorMaxLines: 2,
                                              errorStyle: TextStyle(
                                                  fontSize: ScreenUtil().setSp(
                                                      14,
                                                      allowFontScalingSelf:
                                                          true)),
                                              hintText: "0-30 دقيقة",
                                              disabledBorder: const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.0),
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10))),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.0),
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10))),
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.0),
                                                  borderRadius: BorderRadius.all(Radius.circular(10)))),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("سماحية تسجيل الحضور"),
                                Directionality(
                                  textDirection: ui.TextDirection.rtl,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      alignment: Alignment.topRight,
                                      padding: EdgeInsets.only(right: 10.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 0.0, color: Colors.grey),
                                      ),
                                      width: 120.w,
                                      height: 40.h,
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                        elevation: 2,
                                        isExpanded: true,
                                        items: attendNumbers.map((String x) {
                                          return DropdownMenuItem<String>(
                                              value: x,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  x,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      color: Colors.orange,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ));
                                        }).toList(),
                                        onChanged: (value) {
                                          sets(() {
                                            selectedNo = value;
                                          });
                                        },
                                        value: selectedNo,
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("سماحية تسجيل الأنصراف"),
                                Directionality(
                                  textDirection: ui.TextDirection.rtl,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      alignment: Alignment.topRight,
                                      padding: EdgeInsets.only(right: 10.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 0.0, color: Colors.grey),
                                      ),
                                      width: 120.w,
                                      height: 40.h,
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                        elevation: 2,
                                        isExpanded: true,
                                        items: leaveNumbers.map((String x) {
                                          return DropdownMenuItem<String>(
                                              value: x,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  x,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      color: Colors.orange,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ));
                                        }).toList(),
                                        onChanged: (value) {
                                          sets(() {
                                            selectedLeave = value;
                                          });
                                        },
                                        value: selectedLeave,
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Center(
                                child: RoundedButton(
                                    title: "حفظ",
                                    onPressed: () {
                                      if (!_formKey.currentState.validate()) {
                                        return;
                                      } else {
                                        Navigator.pop(context);
                                        Fluttertoast.showToast(
                                            msg: "تم الحفظ بنجاح",
                                            backgroundColor: Colors.green);
                                      }
                                    }))
                          ],
                        ),
                      ),
                    )),
              );
            },
          ));
        });
  }

  showVacationsDetails() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: Stack(
                  children: [
                    Container(
                      height: 460.h,
                      width: double.infinity,
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          DirectoriesHeader(
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40.0),
                              child: Lottie.asset("resources/shifts.json",
                                  repeat: false),
                            ),
                            "ايام الاجازات للشركة",
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: ListView.builder(
                                    itemCount: Provider.of<DaysOffData>(context,
                                            listen: true)
                                        .weak
                                        .length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      print(index);
                                      return CustomRow(
                                          model: Provider.of<DaysOffData>(
                                                  context,
                                                  listen: true)
                                              .weak[index],
                                          onTap: () {
                                            int i = 0;
                                            if (Provider.of<DaysOffData>(
                                                        context,
                                                        listen: false)
                                                    .weak[index]
                                                    .isDayOff ==
                                                true) {
                                              Provider.of<DaysOffData>(context,
                                                      listen: false)
                                                  .toggleDayOff(index);
                                            } else {
                                              Provider.of<DaysOffData>(context,
                                                      listen: false)
                                                  .weak
                                                  .forEach((element) {
                                                if (element.isDayOff == true) {
                                                  i++;
                                                }
                                              });

                                              if (i < 2) {
                                                Provider.of<DaysOffData>(
                                                        context,
                                                        listen: false)
                                                    .toggleDayOn(index);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "لا يمكن اخيار اكثر من يومين",
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.black,
                                                    fontSize: ScreenUtil().setSp(
                                                        16,
                                                        allowFontScalingSelf:
                                                            true));
                                              }
                                            }
                                          });
                                    })),
                          ),
                          Container(
                            width: 100.w,
                            child: RounderButton("حفظ", () async {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return RoundedLoadingIndicator();
                                  });

                              var userProvider =
                                  Provider.of<UserData>(context, listen: false);
                              var comProvider = Provider.of<CompanyData>(
                                  context,
                                  listen: false);
                              var msg = await Provider.of<DaysOffData>(context,
                                      listen: false)
                                  .editDaysOffApi(comProvider.com.id,
                                      userProvider.user.userToken, context);
                              if (msg == "Success") {
                                Fluttertoast.showToast(
                                    msg: "تم التعديل بنجاح",
                                    gravity: ToastGravity.CENTER,
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: ScreenUtil()
                                        .setSp(16, allowFontScalingSelf: true));
                                Navigator.pop(context);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "خطا في التعديل",
                                    gravity: ToastGravity.CENTER,
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.black,
                                    fontSize: ScreenUtil()
                                        .setSp(16, allowFontScalingSelf: true));
                              }
                              Navigator.pop(context);
                            }),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      left: 5.0.w,
                      top: 5.0.h,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.orange,
                            size: ScreenUtil()
                                .setSp(25, allowFontScalingSelf: true),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }
}
