import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/SiteAdminOutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftSchedule/ReallocateUsers.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/site_shifts_all.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';

import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/UserFullData/assignTaskToUser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../main.dart';

class UserProperties extends StatefulWidget {
  final Member user;
  final int siteIndex;
  UserProperties({
    this.user,
    this.siteIndex,
  });

  @override
  _UserPropertiesState createState() => _UserPropertiesState();
}

class _UserPropertiesState extends State<UserProperties> {
  int getsiteIDbyShiftId(int shiftId) {
    final list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    final List<Shift> currentSite =
        list.where((element) => element.shiftId == shiftId).toList();
    print(currentSite[0].siteID);
    return currentSite[0].siteID;
  }

  String getShiftName() {
    final list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (list[i].shiftId == widget.user.shiftId) {
        return list[i].shiftName;
      }
    }
    return "";
  }

//   int getShiftid(String shiftName) {
//     var list =
//         Provider.of<SiteShiftsData>(context, listen: false).allCompanyShifts;

//  for (int i=0;i<list.length;i++)
//  {
//    if (list[0].)
//  }

//   }

  int getsiteIDbyName(String siteName) {
    final list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    final List<SiteShiftsModel> currentSite =
        list.where((element) => element.siteName == siteName).toList();
    return currentSite[0].siteId;
  }

  shiftScheduling() async {
    final userProvider = Provider.of<UserData>(context, listen: false);
    final comProvider = Provider.of<CompanyData>(context, listen: false);
    // String shiftName = getShiftName();
    print("index");
    print(widget.siteIndex);
    await Provider.of<DaysOffData>(context, listen: false)
        .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
    for (int i = 0; i < 7; i++) {
      await Provider.of<DaysOffData>(context, listen: false).setSiteAndShift(
          //hngeb al data de mn al back kolha
          i,
          widget.user.siteName, //default site name
          widget.user.shiftName,
          widget.user.shiftId,
          widget.user.siteId);
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
    final userDataProvider = Provider.of<UserData>(context, listen: false).user;
    final memberData = Provider.of<MemberData>(context, listen: false);
    final DataConnectionChecker dataConnectionChecker = DataConnectionChecker();
    final NetworkInfoImp networkInfoImp = NetworkInfoImp(dataConnectionChecker);
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
                  AssignTaskToUser(
                      taskName: userDataProvider.userType != 2
                          ? "تسجيل  مأموريات / اذونات / اجازات"
                          : " تسجيل اذونات / اجازات",
                      iconData: FontAwesomeIcons.calendarCheck,
                      function: () async {
                        final bool isConnected =
                            await networkInfoImp.isConnected;
                        if (isConnected) {
                          userDataProvider.userType == 2
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SiteAdminOutsideVacation(
                                            widget.user, 3),
                                  ))
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OutsideVacation(widget.user, 2)),
                                );
                        } else {
                          return weakInternetConnection(
                            navigatorKey.currentState.overlay.context,
                          );
                        }
                      }),
                  Divider(),
                  userDataProvider.userType == 4
                      ? AssignTaskToUser(
                          function: () async {
                            final bool isConnected =
                                await networkInfoImp.isConnected;
                            if (isConnected) {
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
                                          final token = Provider.of<UserData>(
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
                            } else {
                              return weakInternetConnection(
                                navigatorKey.currentState.overlay.context,
                              );
                            }
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
                                AutoSizeText(
                                  "السماح للمستخدم بالتسجيل بالبطاقة",
                                  style: TextStyle(
                                      fontSize: setResponsiveFontSize(13)),
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
                                  style: TextStyle(
                                      fontSize: setResponsiveFontSize(13)),
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
                            final userProv =
                                Provider.of<UserData>(context, listen: false)
                                    .user;

                            final bool isConnected =
                                await networkInfoImp.isConnected;
                            if (isConnected) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return RoundedLoadingIndicator();
                                  });
                              final userProvider =
                                  Provider.of<UserData>(context, listen: false);

                              final comProvider = Provider.of<CompanyData>(
                                  context,
                                  listen: false);

                              await Provider.of<DaysOffData>(context,
                                      listen: false)
                                  .getDaysOff(comProvider.com.id,
                                      userProvider.user.userToken, context);
                              final isEdit = await Provider.of<ShiftsData>(
                                      context,
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
                                  Provider.of<SiteShiftsData>(context,
                                          listen: false)
                                      .getShiftsList(
                                          Provider.of<SiteShiftsData>(context,
                                                  listen: false)
                                              .siteShiftList[
                                                  Provider.of<SiteData>(context,
                                                          listen: false)
                                                      .dropDownSitesIndex]
                                              .siteName,
                                          false);

                                  shiftScheduling();
                                  Navigator.pop(context);
                                } else {
                                  final scheduleList = Provider.of<ShiftsData>(
                                          context,
                                          listen: false)
                                      .firstAvailableSchedule;
                                  Navigator.pop(context);

                                  Provider.of<ShiftsData>(context,
                                          listen: false)
                                      .sitesSchedules = [
                                    scheduleList.satShift.siteName,
                                    scheduleList.sunShift.siteName,
                                    scheduleList.monShift.siteName,
                                    scheduleList.tuesShift.siteName,
                                    scheduleList.wednShift.siteName,
                                    scheduleList.thurShift.siteName,
                                    scheduleList.friShift.siteName
                                  ];
                                  Provider.of<ShiftsData>(context,
                                          listen: false)
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
                                    await Provider.of<DaysOffData>(context,
                                            listen: false)
                                        .setSiteAndShift(
                                      i,
                                      Provider.of<ShiftsData>(context,
                                              listen: false)
                                          .sitesSchedules[i],
                                      Provider.of<ShiftsData>(context,
                                              listen: false)
                                          .shiftSchedules[i],
                                      userDataProvider.userType == 2
                                          ? userProv.userShiftId
                                          : i == 0
                                              ? scheduleList.satShift.shiftId
                                              : i == 1
                                                  ? scheduleList
                                                      .sunShift.shiftId
                                                  : i == 2
                                                      ? scheduleList
                                                          .monShift.shiftId
                                                      : i == 3
                                                          ? scheduleList
                                                              .tuesShift.shiftId
                                                          : i == 4
                                                              ? scheduleList
                                                                  .wednShift
                                                                  .shiftId
                                                              : i == 5
                                                                  ? scheduleList
                                                                      .thurShift
                                                                      .shiftId
                                                                  : i == 6
                                                                      ? scheduleList
                                                                          .friShift
                                                                          .shiftId
                                                                      : 0,
                                      userDataProvider.userType == 2
                                          ? userProv.userSiteId
                                          : i == 0
                                              ? scheduleList.satShift.siteId
                                              : i == 1
                                                  ? scheduleList.sunShift.siteId
                                                  : i == 2
                                                      ? scheduleList
                                                          .monShift.siteId
                                                      : i == 3
                                                          ? scheduleList
                                                              .tuesShift.siteId
                                                          : i == 4
                                                              ? scheduleList
                                                                  .wednShift
                                                                  .siteId
                                                              : i == 5
                                                                  ? scheduleList
                                                                      .thurShift
                                                                      .siteId
                                                                  : i == 6
                                                                      ? scheduleList
                                                                          .friShift
                                                                          .siteId
                                                                      : 0,
                                    );
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
                            } else {
                              return weakInternetConnection(
                                navigatorKey.currentState.overlay.context,
                              );
                            }
                          })
                      : Container(),
                  Divider(),
                  userDataProvider.userType != 2
                      ? AssignTaskToUser(
                          taskName: " إرسال اثبات حضور",
                          iconData: FontAwesomeIcons.checkCircle,
                          function: () async {
                            final bool isConnected =
                                await networkInfoImp.isConnected;
                            if (isConnected) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return RoundedLoadingIndicator();
                                  });

                              await attendObj
                                  .sendAttendProof(
                                      userDataProvider.userToken,
                                      widget.user.id,
                                      widget.user.fcmToken,
                                      userDataProvider.id)
                                  .then((value) {
                                print("VAlue $value");
                                switch (value) {
                                  case "success":
                                    final HuaweiServices _huawei =
                                        HuaweiServices();
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
                                  case "limit exceed":
                                    Fluttertoast.showToast(
                                        msg:
                                            "خطأ : لقد تجاوزت العدد المسموح بة لهذا المستخدم",
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
                            } else {
                              return weakInternetConnection(
                                navigatorKey.currentState.overlay.context,
                              );
                            }
                          })
                      : Container()
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
