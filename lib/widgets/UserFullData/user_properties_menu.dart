import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/SiteAdminOutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/UserFullData/assignTaskToUser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserPropertiesMenu extends StatefulWidget {
  final Member user;
  UserPropertiesMenu({this.user});

  @override
  _UserPropertiesMenuState createState() => _UserPropertiesMenuState();
}

class _UserPropertiesMenuState extends State<UserPropertiesMenu> {
  @override
  Widget build(BuildContext context) {
    var userDataProvider = Provider.of<UserData>(context, listen: false).user;
    return ZoomIn(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: userDataProvider.userType != 2 ? 95.0.w : 20.0.w,
            vertical: userDataProvider.userType != 2 ? 90.0.h : 20.h,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: Container(
            height: userDataProvider.userType != 2 ? 200.h : 150.h,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AssignTaskToUser(
                        taskName: "??????",
                        iconData: FontAwesomeIcons.clock,
                        function: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => userDataProvider
                                              .userType !=
                                          2
                                      ? OutsideVacation(widget.user, 3, [
                                          getTranslated(
                                              context, "?????????? ???? ????????????"),
                                          getTranslated(context, "???????????? ????????")
                                        ], [])
                                      : SiteAdminOutsideVacation(
                                          widget.user, 3, [
                                          getTranslated(
                                              context, "?????????? ???? ????????????"),
                                          getTranslated(context, "???????????? ????????")
                                        ], [
                                          getTranslated(context, "??????????"),
                                          getTranslated(context, "??????????"),
                                          getTranslated(context, "???????? ????????????")
                                        ])),
                            )),
                    Divider(),
                    AssignTaskToUser(
                        taskName: "??????????",
                        iconData: FontAwesomeIcons.clock,
                        function: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => userDataProvider
                                              .userType !=
                                          2
                                      ? OutsideVacation(widget.user, 1, [
                                          getTranslated(
                                              context, "?????????? ???? ????????????"),
                                          getTranslated(context, "???????????? ????????")
                                        ], [
                                          getTranslated(context, "??????????"),
                                          getTranslated(context, "??????????"),
                                          getTranslated(context, "???????? ????????????")
                                        ])
                                      : SiteAdminOutsideVacation(
                                          widget.user, 1, [
                                          getTranslated(
                                              context, "?????????? ???? ????????????"),
                                          getTranslated(context, "???????????? ????????")
                                        ], [
                                          getTranslated(context, "??????????"),
                                          getTranslated(context, "??????????"),
                                          getTranslated(context, "???????? ????????????")
                                        ])),
                            )),
                    Divider(),
                    if (userDataProvider.userType != 2) ...[
                      AssignTaskToUser(
                          taskName: "??????????????",
                          iconData: FontAwesomeIcons.car,
                          function: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OutsideVacation(widget.user, 2, [
                                          getTranslated(
                                              context, "?????????? ???? ????????????"),
                                          getTranslated(context, "???????????? ????????"),
                                        ], [
                                          getTranslated(context, "??????????"),
                                          getTranslated(context, "??????????"),
                                          getTranslated(context, "???????? ????????????")
                                        ])),
                              )),
                      Divider(),
                      AssignTaskToUser(
                          taskName: "?????????? ????????",
                          iconData: FontAwesomeIcons.checkCircle,
                          function: () async {
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
                                  HuaweiServices _huawei = HuaweiServices();
                                  if (widget.user.osType == 3) {
                                    _huawei.huaweiPostNotification(
                                        widget.user.fcmToken,
                                        "?????????? ????????",
                                        "?????????? ?????????? ?????????? ????????",
                                        "attend");
                                    Fluttertoast.showToast(
                                        msg: "???? ?????????????? ??????????",
                                        backgroundColor: Colors.green,
                                        gravity: ToastGravity.CENTER);
                                  } else
                                    sendFcmMessage(
                                            topicName: "",
                                            userToken: widget.user.fcmToken,
                                            title: "?????????? ????????",
                                            category: "attend",
                                            message: "?????????? ?????????? ?????????? ????????")
                                        .then((value) {
                                      if (value) {
                                        Fluttertoast.showToast(
                                            msg: "???? ?????????????? ??????????",
                                            backgroundColor: Colors.green,
                                            gravity: ToastGravity.CENTER);
                                      } else {
                                        if (value) {
                                          Fluttertoast.showToast(
                                              msg: "?????? ???? ?????????????? ",
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER);
                                        }
                                      }
                                    });
                                  break;
                                case "limit exceed":
                                  Fluttertoast.showToast(
                                      msg:
                                          "?????? : ?????? ???????????? ?????????? ?????????????? ???? ???????? ????????????????",
                                      backgroundColor: Colors.red,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER);
                                  break;
                                case "fail shift":
                                  Fluttertoast.showToast(
                                      msg:
                                          "?????? : ???? ???????? ?????? ?????????? ???????? ???????? ?????????? ????????????????",
                                      backgroundColor: Colors.red,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER);
                                  break;

                                case "null":
                                  Fluttertoast.showToast(
                                      msg:
                                          "?????? ???? ?????????????? \n ???? ?????? ?????????? ???????????? ???????? ???????????????? ???? ?????? ",
                                      backgroundColor: Colors.red,
                                      gravity: ToastGravity.CENTER);
                                  break;
                                case "fail present":
                                  Fluttertoast.showToast(
                                      msg: "???? ?????? ?????????? ???????? ?????? ????????????????",
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
                          }),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
