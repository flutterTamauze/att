import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftSchedule/ReallocateUsers.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';

import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/UserFullData/assignTaskToUser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserProperties extends StatefulWidget {
  final Member user;
  final int siteIndex;
  UserProperties({this.user, this.siteIndex});

  @override
  _UserPropertiesState createState() => _UserPropertiesState();
}

class _UserPropertiesState extends State<UserProperties> {
  int getsiteIDbyShiftId(int shiftId) {
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    List<Shift> currentSite =
        list.where((element) => element.shiftId == shiftId).toList();
    print(currentSite[0].siteID);
    return currentSite[0].siteID;
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

  int getShiftid(String shiftName) {
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;

    List<Shift> currentShift =
        list.where((element) => element.shiftName == shiftName).toList();

    return currentShift[0].shiftId;
  }

  int getsiteIDbyName(String siteName) {
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    List<Site> currentSite =
        list.where((element) => element.name == siteName).toList();
    return currentSite[0].id;
  }

  shiftScheduling() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);
    String shiftName = getShiftName();

    await Provider.of<DaysOffData>(context, listen: false)
        .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
    for (int i = 0; i < 7; i++) {
      await Provider.of<DaysOffData>(context, listen: false).setSiteAndShift(
          i,
          Provider.of<SiteData>(context, listen: false)
              .sitesList[widget.siteIndex]
              .name,
          shiftName,
          getShiftid(shiftName),
          getsiteIDbyShiftId(widget.user.shiftId));
    }
    Navigator.pop(context);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReAllocateUsers(
            widget.user,
            false,
            0,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var userDataProvider = Provider.of<UserData>(context, listen: false).user;
    var memberData = Provider.of<MemberData>(context, listen: false);
    return ZoomIn(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          // decoration: BoxDecoration(
          //     border: Border.all(width: 2, color: Colors.orange[600])),
          padding: EdgeInsets.all(10),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  userDataProvider.userType != 2
                      ? AssignTaskToUser(
                          taskName: "تسجيل  مأموريات / اذونات / اجازات",
                          iconData: FontAwesomeIcons.calendarCheck,
                          function: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OutsideVacation(widget.user, 2)),
                              ))
                      : Container(),
                  Divider(),
                  userDataProvider.userType == 4
                      ? AssignTaskToUser(
                          function: () {
                            return showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return RoundedAlert(
                                      onPressed: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return RoundedLoadingIndicator();
                                            });
                                        var token = Provider.of<UserData>(
                                                context,
                                                listen: false)
                                            .user
                                            .userToken;
                                        if (await memberData.resetMemberMac(
                                                widget.user.id,
                                                token,
                                                context) ==
                                            "Success") {
                                          Navigator.pop(context);
                                          Fluttertoast.showToast(
                                            msg: "تم اعادة الضبط بنجاح",
                                            gravity: ToastGravity.CENTER,
                                            toastLength: Toast.LENGTH_SHORT,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "خطأ في اعادة الضبط",
                                            gravity: ToastGravity.CENTER,
                                            toastLength: Toast.LENGTH_SHORT,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: 16.0,
                                          );
                                        }
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      title: 'إعادة ضبط بيانات مستخدم',
                                      content:
                                          "هل تريد اعادة ضبط بيانات هاتف المستخدم؟");
                                });
                          },
                          iconData: Icons.repeat,
                          taskName: "اعادة ضبط هاتف المستخدم",
                        )
                      : Container(),
                  userDataProvider.userType == 4 ? Divider() : Container(),
                  userDataProvider.userType == 4
                      ? Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "السماح للمستخدم بالتسجيل بالبطاقة",
                                ),
                                Container(
                                  width: 20.w,
                                  height: 20.h,
                                  child: Pulse(
                                    duration: Duration(milliseconds: 800),
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Colors.orange,
                                      value: widget.user.isAllowedToAttend,
                                      onChanged: (value) {
                                        if (value == true) {}
                                        setState(() {
                                          allowToAttendBox = value;
                                        });
                                        widget.user.isAllowedToAttend = value;
                                        Provider.of<MemberData>(context,
                                                listen: false)
                                            .allowMemberAttendByCard(
                                                widget.user.id,
                                                value,
                                                Provider.of<UserData>(context,
                                                        listen: false)
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
                  userDataProvider.userType == 4 ? Divider() : Container(),
                  userDataProvider.userType == 4
                      ? Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "عدم الظهور في التقرير",
                                ),
                                Container(
                                  width: 20.w,
                                  height: 20.h,
                                  child: Pulse(
                                    duration: Duration(milliseconds: 800),
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Colors.orange,
                                      value: widget.user.excludeFromReport,
                                      onChanged: (value) {
                                        if (value == true) {}
                                        setState(() {
                                          noShowInReport = value;
                                        });
                                        widget.user.excludeFromReport = value;
                                        Provider.of<MemberData>(context,
                                                listen: false)
                                            .exludeUserFromReport(
                                                widget.user.id,
                                                value,
                                                Provider.of<UserData>(context,
                                                        listen: false)
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
                  userDataProvider.userType == 4 ? Divider() : Container(),
                  userDataProvider.userType == 4 ||
                          userDataProvider.userType == 2
                      ? AssignTaskToUser(
                          taskName: "جدولة المناوبات",
                          iconData: Icons.table_view,
                          function: () async {
                            var userProv =
                                Provider.of<UserData>(context, listen: false)
                                    .user;

                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return RoundedLoadingIndicator();
                                });
                            var userProvider =
                                Provider.of<UserData>(context, listen: false);

                            var comProvider = Provider.of<CompanyData>(context,
                                listen: false);

                            await Provider.of<DaysOffData>(context,
                                    listen: false)
                                .getDaysOff(comProvider.com.id,
                                    userProvider.user.userToken, context);
                            var isEdit = await Provider.of<ShiftsData>(context,
                                    listen: false)
                                .getFirstAvailableSchedule(
                                    userProv.userToken, widget.user.id);
                            if (userProv.userType == 2 && isEdit == false) {
                              Fluttertoast.showToast(
                                      msg: "لا يوجد جدولة لهذا المستخدم",
                                      backgroundColor: Colors.red,
                                      gravity: ToastGravity.CENTER)
                                  .then((value) => Navigator.pop(context));
                            } else {
                              print(isEdit);
                              print("ana d5lt");
                              if (isEdit == false) {
                                await Provider.of<SiteData>(context,
                                        listen: false)
                                    .setDropDownShift(0);
                                await Provider.of<SiteData>(context,
                                        listen: false)
                                    .setDropDownIndex(0);
                                await Provider.of<ShiftsData>(context,
                                        listen: false)
                                    .findMatchingShifts(
                                        Provider.of<SiteData>(context,
                                                listen: false)
                                            .sitesList[Provider.of<SiteData>(
                                                    context,
                                                    listen: false)
                                                .dropDownSitesIndex]
                                            .id,
                                        false);
                                shiftScheduling();
                                Navigator.pop(context);
                              } else {
                                var scheduleList = Provider.of<ShiftsData>(
                                        context,
                                        listen: false)
                                    .firstAvailableSchedule;
                                Navigator.pop(context);

                                Provider.of<ShiftsData>(context, listen: false)
                                    .sitesSchedules = [
                                  scheduleList.satShift.siteName,
                                  scheduleList.sunShift.siteName,
                                  scheduleList.monShift.siteName,
                                  scheduleList.tuesShift.siteName,
                                  scheduleList.wednShift.siteName,
                                  scheduleList.thurShift.siteName,
                                  scheduleList.friShift.siteName
                                ];
                                Provider.of<ShiftsData>(context, listen: false)
                                    .shiftSchedules = [
                                  scheduleList.satShift.shiftName,
                                  scheduleList.sunShift.shiftName,
                                  scheduleList.monShift.shiftName,
                                  scheduleList.tuesShift.shiftName,
                                  scheduleList.wednShift.shiftName,
                                  scheduleList.thurShift.shiftName,
                                  scheduleList.friShift.shiftName
                                ];
                                for (int i = 0; i < 7; i++) {
                                  await Provider.of<DaysOffData>(context, listen: false)
                                      .setSiteAndShift(
                                          i,
                                          Provider.of<ShiftsData>(context, listen: false)
                                              .sitesSchedules[i],
                                          Provider.of<ShiftsData>(context,
                                                  listen: false)
                                              .shiftSchedules[i],
                                          userDataProvider.userType == 2
                                              ? userProv.userShiftId
                                              : getShiftid(
                                                  Provider.of<ShiftsData>(context,
                                                          listen: false)
                                                      .shiftSchedules[i]),
                                          userDataProvider.userType == 2
                                              ? userProv.userSiteId
                                              : getsiteIDbyName(
                                                  Provider.of<ShiftsData>(context,
                                                          listen: false)
                                                      .sitesSchedules[i]));
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReAllocateUsers(
                                              widget.user,
                                              isEdit,
                                              0,
                                            )));
                              }
                            }
                          })
                      : Container(),
                  Divider(),
                  AssignTaskToUser(
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
                                Provider.of<UserData>(context, listen: false)
                                    .user
                                    .userToken,
                                widget.user.id,
                                widget.user.fcmToken)
                            .then((value) {
                          print("VAlue $value");
                          switch (value) {
                            case "success":
                              HuaweiServices _huawei = HuaweiServices();
                              if (widget.user.osType == 3) {
                                _huawei.huaweiPostNotification(
                                    widget.user.fcmToken,
                                    "اثبات حضور",
                                    "برجاء اثبات حضورك الأن",
                                    "attend");
                                Fluttertoast.showToast(
                                    msg: "تم الأرسال بنجاح",
                                    backgroundColor: Colors.green,
                                    gravity: ToastGravity.CENTER);
                              } else
                                sendFcmMessage(
                                        topicName: "",
                                        userToken: widget.user.fcmToken,
                                        title: "اثبات حضور",
                                        category: "attend",
                                        message: "برجاء اثبات حضورك الأن")
                                    .then((value) {
                                  if (value) {
                                    Fluttertoast.showToast(
                                        msg: "تم الأرسال بنجاح",
                                        backgroundColor: Colors.green,
                                        gravity: ToastGravity.CENTER);
                                  } else {
                                    if (value) {
                                      Fluttertoast.showToast(
                                          msg: "خطأ فى الأرسال ",
                                          backgroundColor: Colors.red,
                                          gravity: ToastGravity.CENTER);
                                    }
                                  }
                                });
                              break;

                            case "fail shift":
                              Fluttertoast.showToast(
                                  msg:
                                      "خطأ : لا يمكن طلب اثبات حضور خارج توقيت المناوبة",
                                  backgroundColor: Colors.red,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER);
                              break;
                            case "null":
                              Fluttertoast.showToast(
                                  msg:
                                      "خطأ فى الأرسال \n لم يتم تسجيل الدخول بهذا المستخدم من قبل ",
                                  backgroundColor: Colors.red,
                                  gravity: ToastGravity.CENTER);
                              break;
                            case "fail present":
                              Fluttertoast.showToast(
                                  msg: "لم يتم تسجيل حضور هذا المتسخدم",
                                  backgroundColor: Colors.red,
                                  gravity: ToastGravity.CENTER);
                              break;
                            case "fail":
                              errorToast();
                              break;
                            default:
                              errorToast();
                          }
                        }).then((value) => Navigator.pop(context));
                      })
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
