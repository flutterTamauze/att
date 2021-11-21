import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/SiteAdminOutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/constants.dart';
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
                        taskName: "إذن",
                        iconData: FontAwesomeIcons.clock,
                        function: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      userDataProvider.userType != 2
                                          ? OutsideVacation(widget.user, 3)
                                          : SiteAdminOutsideVacation(
                                              widget.user, 3)),
                            )),
                    Divider(),
                    AssignTaskToUser(
                        taskName: "اجازة",
                        iconData: FontAwesomeIcons.clock,
                        function: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      userDataProvider.userType != 2
                                          ? OutsideVacation(widget.user, 1)
                                          : SiteAdminOutsideVacation(
                                              widget.user, 1)),
                            )),
                    Divider(),
                    if (userDataProvider.userType != 2) ...[
                      AssignTaskToUser(
                          taskName: "مأمورية",
                          iconData: FontAwesomeIcons.car,
                          function: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OutsideVacation(widget.user, 2)),
                              )),
                      Divider(),
                      AssignTaskToUser(
                          taskName: "اثبات حضور",
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
