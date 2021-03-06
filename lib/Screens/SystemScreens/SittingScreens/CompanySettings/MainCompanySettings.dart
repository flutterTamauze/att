import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

import 'package:qr_users/Core/constants.dart';

import 'package:qr_users/services/CompanySettings/companySettings.dart';
import 'package:qr_users/services/DaysOff.dart';

import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'dart:ui' as ui;
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import '../SettingsScreen.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'OfficialVacations.dart';

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
List<String> attendNumbers = ["1", "2", "3"];
List<String> leaveNumbers = ["1", "2", "3", "4", "5", "6"];
CompanySettingsService companySettings = CompanySettingsService();

class _CompanySettingsState extends State<CompanySettings> {
  UserData userProvider;
  CompanyData comProvider;
  @override
  void initState() {
    var now = DateTime.now();
    userProvider = Provider.of<UserData>(context, listen: false);
    comProvider = Provider.of<CompanyData>(context, listen: false);
    fromDate = DateTime(now.year, now.month, now.day - 1);
    toDate = DateTime(now.year, now.month, now.day - 1);
    yesterday = DateTime(now.year, now.month, now.day - 1);
    super.initState();
  }

  Future getDaysOff() async {
    await Provider.of<DaysOffData>(context, listen: false)
        .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
  }

  Future getOfficialVacations() async {
    await Provider.of<VacationData>(context, listen: false)
        .getOfficialVacations(comProvider.com.id, userProvider.user.userToken);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      floatingActionButton: MultipleFloatingButtonsNoADD(),
      endDrawer: NotificationItem(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Header(
            nav: false,
            goUserHomeFromMenu: false,
            goUserMenu: false,
          ),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: SmallDirectoriesHeader(
                Lottie.asset("resources/settings1.json", repeat: false),
                "?????????????? ????????????",
              ),
            ),
          ),
          ServiceTile(
              title: "?????????????? ??????????????????",
              subTitle: "?????????? ?????????????? ??????????????????",
              icon: FontAwesomeIcons.calendarWeek,
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(child: RoundedLoadingIndicator());
                    });
                await getDaysOff();
                Navigator.pop(context);
                showVacationsDetails();
              }),
          ServiceTile(
              title: "?????????????? ??????????????",
              subTitle: "?????????? ?????????????? ??????????????",
              icon: Icons.calendar_today_rounded,
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                await getOfficialVacations();
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfficialVacation(),
                    ));
              }),
          userProvider.user.userType == 4
              ? ServiceTile(
                  title: "?????????????? ???????????? ?? ????????????????",
                  subTitle: "?????????? ???????????? ?? ????????????????",
                  icon: FontAwesomeIcons.usersCog,
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return RoundedLoadingIndicator();
                        });
                    await companySettings.getCompanySettingsTime(
                        comProvider.com.id, userProvider.user.userToken);

                    Navigator.pop(context);
                    controller.text = companySettings.lateAllowance.toString();
                    showAttendanceSettings(
                      companySettings.attendClearance.toString(),
                      companySettings.lateAllowance.toString(),
                      companySettings.leaveClearance.toString(),
                      companySettings.settingsID,
                      comProvider.com.id,
                    );
                  })
              : Container(),
        ],
      ),
    );
  }

  showAttendanceSettings(
    String attendClearance,
    String lateAlowance,
    String leaveClearance,
    int settingsID,
    int companyId,
  ) async {
    bool isLoading = false;
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
                              "?????????????? ???????????? ?? ????????????????",
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
                                          "???????????? ?????????????? (??????????)",
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
                                              return "?????????? ?????????? ??????";
                                            } else if (value.isEmpty) {
                                              return '?????????? ?????????? ??????????';
                                            } else if (int.parse(value) > 30 ||
                                                int.parse(value) < 0) {
                                              return '?????????? ?????????? ?????? ????  0 ?????? 30';
                                            }
                                          },
                                          decoration: InputDecoration(
                                              errorMaxLines: 2,
                                              errorStyle: TextStyle(
                                                  fontSize: ScreenUtil().setSp(
                                                      14,
                                                      allowFontScalingSelf:
                                                          true)),
                                              hintText: "0-30 ??????????",
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
                                Text("???????????? ?????????? ????????????"),
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
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "??????????",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      x,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                        }).toList(),
                                        onChanged: (value) {
                                          sets(() {
                                            attendClearance = value;
                                          });
                                        },
                                        value: attendClearance.toString(),
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
                                Text("???????????? ?????????? ????????????????"),
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
                                                child: Row(
                                                  children: [
                                                    Text("??????????",
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.orange,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      x,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                        }).toList(),
                                        onChanged: (value) {
                                          sets(() {
                                            leaveClearance = value;
                                          });
                                        },
                                        value: leaveClearance.toString(),
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Center(
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        backgroundColor: Colors.orange,
                                      )
                                    : RoundedButton(
                                        title: "??????",
                                        onPressed: () async {
                                          if (!_formKey.currentState
                                              .validate()) {
                                            return;
                                          } else {
                                            sets(() {
                                              isLoading = true;
                                            });
                                            await companySettings
                                                .updateCompanySettingsTime(
                                              settingsID,
                                              companyId,
                                              int.parse(controller.text),
                                              int.parse(attendClearance),
                                              int.parse(leaveClearance),
                                              Provider.of<UserData>(context,
                                                      listen: false)
                                                  .user
                                                  .userToken,
                                            )
                                                .then((value) {
                                              if (value) {
                                                successfulSaved();
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: "?????? ???? ??????????????",
                                                    backgroundColor:
                                                        Colors.red);
                                              }
                                            });
                                            sets(() {
                                              isLoading = false;
                                            });
                                            Navigator.pop(context);
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
                            "???????? ?????????????? ????????????",
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
                                                        "???? ???????? ?????????? ???????? ???? ??????????",
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
                            child: userProvider.user.userType == 4
                                ? RounderButton("??????", () async {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return RoundedLoadingIndicator();
                                        });

                                    var userProvider = Provider.of<UserData>(
                                        context,
                                        listen: false);
                                    var comProvider = Provider.of<CompanyData>(
                                        context,
                                        listen: false);
                                    var msg = await Provider.of<DaysOffData>(
                                            context,
                                            listen: false)
                                        .editDaysOffApi(
                                            comProvider.com.id,
                                            userProvider.user.userToken,
                                            context);
                                    if (msg == "Success") {
                                      Fluttertoast.showToast(
                                          msg: "???? ?????????????? ??????????",
                                          gravity: ToastGravity.CENTER,
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: ScreenUtil().setSp(16,
                                              allowFontScalingSelf: true));
                                      Navigator.pop(context);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "?????? ???? ??????????????",
                                          gravity: ToastGravity.CENTER,
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.black,
                                          fontSize: ScreenUtil().setSp(16,
                                              allowFontScalingSelf: true));
                                    }
                                    Navigator.pop(context);
                                  })
                                : Container(),
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
