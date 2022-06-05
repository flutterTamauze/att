import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/SiteAdminOutsideVacation.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/UserFullData/assignTaskToUser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserPropertiesMenu extends StatefulWidget {
  final Member user;
  const UserPropertiesMenu({this.user});

  @override
  _UserPropertiesMenuState createState() => _UserPropertiesMenuState();
}

class _UserPropertiesMenuState extends State<UserPropertiesMenu> {
  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserData>(context, listen: false).user;
    return ZoomIn(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: userDataProvider.userType != 2 ? 95.0.w : 20.0.w,
            vertical: userDataProvider.userType != 2 ? 90.0.h : 20.h,
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: Container(
            height: userDataProvider.userType != 2 ? 180.h : 130.h,
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
                                  builder: (context) => userDataProvider
                                              .userType !=
                                          2
                                      ? OutsideVacation(widget.user, 3, [
                                          getTranslated(
                                              context, "تأخير عن الحضور"),
                                          getTranslated(context, "انصراف مبكر")
                                        ], [
                                          getTranslated(context, "عارضة"),
                                          getTranslated(context, "مرضى"),
                                          getTranslated(context, "رصيد اجازات")
                                        ])
                                      : SiteAdminOutsideVacation(
                                          widget.user, 3, [
                                          getTranslated(
                                              context, "تأخير عن الحضور"),
                                          getTranslated(context, "انصراف مبكر")
                                        ], [
                                          getTranslated(context, "عارضة"),
                                          getTranslated(context, "مرضى"),
                                          getTranslated(context, "رصيد اجازات")
                                        ])),
                            )),
                    const Divider(),
                    AssignTaskToUser(
                        taskName: "اجازة",
                        iconData: FontAwesomeIcons.clock,
                        function: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => userDataProvider
                                              .userType !=
                                          2
                                      ? OutsideVacation(widget.user, 1, [
                                          getTranslated(
                                              context, "تأخير عن الحضور"),
                                          getTranslated(context, "انصراف مبكر")
                                        ], [
                                          getTranslated(context, "عارضة"),
                                          getTranslated(context, "مرضى"),
                                          getTranslated(context, "رصيد اجازات")
                                        ])
                                      : SiteAdminOutsideVacation(
                                          widget.user, 1, [
                                          getTranslated(
                                              context, "تأخير عن الحضور"),
                                          getTranslated(context, "انصراف مبكر")
                                        ], [
                                          getTranslated(context, "عارضة"),
                                          getTranslated(context, "مرضى"),
                                          getTranslated(context, "رصيد اجازات")
                                        ])),
                            )),
                    const Divider(),
                    if (userDataProvider.userType != 2) ...[
                      AssignTaskToUser(
                          taskName: "مأمورية",
                          iconData: FontAwesomeIcons.car,
                          function: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OutsideVacation(widget.user, 2, [
                                          getTranslated(
                                              context, "تأخير عن الحضور"),
                                          getTranslated(context, "انصراف مبكر"),
                                        ], [
                                          getTranslated(context, "عارضة"),
                                          getTranslated(context, "مرضى"),
                                          getTranslated(context, "رصيد اجازات")
                                        ])),
                              )),
                      const Divider(),
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
