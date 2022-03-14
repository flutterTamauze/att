import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserShifts.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/UserFullData/user_floating_button_permVacations.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

class ExpandedPendingPermessions extends StatefulWidget {
  final StringConversionSinkMixin adminComment;
  final int id, index;
  Function onAccept;
  Function onRefused;
  bool isAdmin = false;

  final UserPermessions userPermessions;

  ExpandedPendingPermessions({
    this.id,
    this.onRefused,
    this.onAccept,
    this.isAdmin,
    this.userPermessions,
    this.adminComment,
    this.index,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedPendingPermessionsState createState() =>
      _ExpandedPendingPermessionsState();
}

class _ExpandedPendingPermessionsState
    extends State<ExpandedPendingPermessions> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          accentColor: Colors.orange, unselectedWidgetColor: Colors.black),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          child: ExpansionTile(
            onExpansionChanged: (value) async {
              if (value) {
                showDialog(
                  context: context,
                  builder: (context) => RoundedLoadingIndicator(),
                );
                await Provider.of<UserPermessionsData>(context, listen: false)
                    .getPendingPermessionDetailsByID(
                        (widget.id),
                        Provider.of<UserData>(context, listen: false)
                            .user
                            .userToken);
                Navigator.pop(context);
              }
            },
            trailing: Container(
              width: 100.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 90,
                              child: AutoSizeText(
                                "  ${widget.userPermessions.permessionType == 1 ? getTranslated(context, "تأخير عن الحضور") : getTranslated(context, "انصراف مبكر")}",
                                style: boldStyle.copyWith(
                                    fontSize: setResponsiveFontSize(10)),
                                textAlign: locator
                                        .locator<PermissionHan>()
                                        .isEnglishLocale()
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Container(
                              child: AutoSizeText(
                                widget.userPermessions.date
                                    .toString()
                                    .substring(0, 11),
                                style: TextStyle(
                                    fontSize: setResponsiveFontSize(11)),
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            AutoSizeText(
                              "  ${amPmChanger(int.parse(widget.userPermessions.duration.replaceAll(":", "")))}",
                              style: TextStyle(
                                  fontSize: setResponsiveFontSize(11)),
                            ),
                          ],
                        ),
                      ),
                      widget.isAdmin
                          ? Container()
                          : const FaIcon(
                              FontAwesomeIcons.hourglass,
                              color: Colors.orange,
                              size: 15,
                            )
                    ],
                  ),
                  Container(width: 3, color: Colors.orange),
                ],
              ),
            ),
            title: Container(
              child: AutoSizeText(
                widget.userPermessions.user,
                style: TextStyle(fontSize: setResponsiveFontSize(15)),
              ),
            ),
            children: [
              Stack(
                children: [
                  Provider.of<UserPermessionsData>(context)
                          .permessionDetailLoading
                      ? Container()
                      : SlideInDown(
                          child: Card(
                            elevation: 5,
                            child: Container(
                              width: 300.w,
                              margin: const EdgeInsets.all(15),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    "${getTranslated(context, "نوع الأذن")}: ${widget.userPermessions.permessionType == 1 ? getTranslated(context, "تأخير عن الحضور") : getTranslated(context, "انصراف مبكر")} ",
                                    style: TextStyle(
                                      fontSize: setResponsiveFontSize(15),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  widget.userPermessions
                                              .permessionDescription ==
                                          ""
                                      ? Container()
                                      : const Divider(),
                                  widget.userPermessions
                                              .permessionDescription !=
                                          null
                                      ? widget.userPermessions
                                                  .permessionDescription ==
                                              ""
                                          ? Container()
                                          : AutoSizeText(
                                              "${getTranslated(context, "تفاصيل الطلب ")} : ${widget.userPermessions.permessionDescription}",
                                              style: TextStyle(
                                                fontSize:
                                                    setResponsiveFontSize(15),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                      : Container(),
                                  widget.userPermessions
                                              .permessionDescription !=
                                          null
                                      ? widget.userPermessions
                                                  .permessionDescription ==
                                              ""
                                          ? Container()
                                          : const Divider()
                                      : Container(),
                                  AutoSizeText(
                                      "${getTranslated(context, "تاريخ الأذن ")}: ${widget.userPermessions.date.toString().substring(0, 11)}"),
                                  const Divider(),
                                  AutoSizeText(widget
                                              .userPermessions.permessionType ==
                                          1
                                      ? "${getTranslated(context, "اذن حتى الساعة")}: ${amPmChanger(int.parse(widget.userPermessions.duration.replaceAll(":", "")))}"
                                      : "${getTranslated(context, "اذن من الساعة")}: ${amPmChanger(int.parse(widget.userPermessions.duration.replaceAll(":", "")))}"),
                                  const Divider(),
                                  AutoSizeText(
                                    "${getTranslated(context, "تاريخ إنشاء الطلب")}: ${widget.userPermessions.createdOn.toString().substring(0, 11)}",
                                    style: TextStyle(
                                      fontSize: setResponsiveFontSize(15),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    children: [
                                      // Text(
                                      //   "قرارك",
                                      //   style: TextStyle(
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () => widget.onAccept(),
                                            child: const FaIcon(
                                              FontAwesomeIcons.check,
                                              color: Colors.green,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          InkWell(
                                            onTap: () => widget.onRefused(),
                                            child: const FaIcon(
                                              FontAwesomeIcons.times,
                                              color: Colors.red,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                  Provider.of<UserPermessionsData>(context)
                          .permessionDetailLoading
                      ? Container()
                      : !Provider.of<PermissionHan>(context, listen: false)
                              .isEnglishLocale()
                          ? Positioned(
                              bottom: 15.h,
                              left: 10.w,
                              child: FadeInVacPermFloatingButton(
                                  radioVal2: 0,
                                  comingFromAdminPanel: true,
                                  memberId: widget.userPermessions.userID))
                          : Positioned(
                              bottom: 15.h,
                              right: 10.w,
                              child: FadeInVacPermFloatingButton(
                                  radioVal2: 0,
                                  comingFromAdminPanel: true,
                                  memberId: widget.userPermessions.userID))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
