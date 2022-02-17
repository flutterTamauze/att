import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserShifts.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/UserRequests/DeletePermessionWidget.dart';

import '../roundedAlert.dart';

class ExpandedPermessionsTile extends StatefulWidget {
  final IconData iconData;
  final int currentIndex;
  final bool isAdmin;

  final UserPermessions userPermessions;
  const ExpandedPermessionsTile({
    this.isAdmin,
    this.currentIndex,
    this.iconData,
    this.userPermessions,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedOrderTileState createState() => _ExpandedOrderTileState();
}

class _ExpandedOrderTileState extends State<ExpandedPermessionsTile> {
  bool checkDeleteAllowed() {
    if (DateTime.now().isBefore(widget.userPermessions.date) &&
        widget.userPermessions.permessionStatus == 3) {
      return true;
    }
    return false;
  }

  bool adminResponseIsNull() {
    if (widget.userPermessions.adminResponse == null ||
        widget.userPermessions.adminResponse == "") {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          accentColor: Colors.orange, unselectedWidgetColor: Colors.black),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Stack(
          children: [
            Container(
              child: ExpansionTile(
                onExpansionChanged: (value) async {
                  if (value) {
                    showDialog(
                      context: context,
                      builder: (context) => RoundedLoadingIndicator(),
                    );
                    await Provider.of<UserPermessionsData>(context,
                            listen: false)
                        .getPermessionDetailsByID(
                            int.parse(
                                widget.userPermessions.permessionId.toString()),
                            Provider.of<UserData>(context, listen: false)
                                .user
                                .userToken);
                    Navigator.pop(context);
                  }
                },
                initiallyExpanded: widget.isAdmin,
                trailing: Container(
                  width: 80.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AutoSizeText(
                            widget.userPermessions.createdOn
                                .toString()
                                .substring(0, 11),
                          ),
                          FaIcon(
                            widget.userPermessions.permessionStatus == 3
                                ? FontAwesomeIcons.hourglass
                                : widget.userPermessions.permessionStatus == 1
                                    ? FontAwesomeIcons.check
                                    : FontAwesomeIcons.times,
                            color: widget.userPermessions.permessionStatus == 3
                                ? Colors.orange
                                : widget.userPermessions.permessionStatus == 1
                                    ? Colors.green
                                    : Colors.red,
                            size: 15,
                          )
                        ],
                      ),
                      Container(
                        width: 3,
                        color: widget.userPermessions.permessionStatus == 3
                            ? Colors.orange
                            : widget.userPermessions.permessionStatus == 1
                                ? Colors.green
                                : Colors.red,
                      ),
                    ],
                  ),
                ),
                title: AutoSizeText(
                    widget.userPermessions.permessionId.toString()),
                children: [
                  SlideInDown(
                    child: Provider.of<UserPermessionsData>(context)
                            .permessionDetailLoading
                        ? Container()
                        : Card(
                            elevation: 5,
                            child: Container(
                              width: 330.w,
                              margin: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        "${getTranslated(context, "نوع الأذن")} : ${widget.userPermessions.permessionType == 1 ? getTranslated(context, "تأخير عن الحضور") : getTranslated(context, "انصراف مبكر")} ",
                                        style: TextStyle(
                                          fontSize: setResponsiveFontSize(13),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      widget.userPermessions
                                                  .permessionDescription ==
                                              ""
                                          ? Container()
                                          : const Divider(),
                                      if (widget.userPermessions
                                              .permessionDescription !=
                                          null) ...[
                                        widget.userPermessions
                                                    .permessionDescription ==
                                                ""
                                            ? Container()
                                            : AutoSizeText(
                                                "${getTranslated(context, "تفاصيل الطلب")}: ${widget.userPermessions.permessionDescription}",
                                                style: TextStyle(
                                                  fontSize:
                                                      setResponsiveFontSize(13),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                        widget.userPermessions
                                                    .permessionDescription ==
                                                ""
                                            ? Container()
                                            : const Divider()
                                      ],
                                      AutoSizeText(
                                        "${getTranslated(context, "تاريخ الأذن")}  : ${widget.userPermessions.date.toString().substring(0, 11)}",
                                        style: TextStyle(
                                            fontSize:
                                                setResponsiveFontSize(13)),
                                      ),
                                      const Divider(),
                                      AutoSizeText(
                                        widget.userPermessions.permessionType ==
                                                1
                                            ? "${getTranslated(context, "اذن حتى الساعة")}  : ${amPmChanger(int.parse(widget.userPermessions.duration.replaceAll(":", "")))}"
                                            : "${getTranslated(context, "اذن من الساعة")} : ${amPmChanger(int.parse(widget.userPermessions.duration.replaceAll(":", "")))}",
                                        style: TextStyle(
                                            fontSize:
                                                setResponsiveFontSize(13)),
                                      ),
                                      widget.userPermessions
                                                  .permessionDescription !=
                                              null
                                          ? const Divider()
                                          : Container(),
                                      widget.userPermessions.permessionStatus !=
                                              3
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                widget.userPermessions
                                                            .permessionStatus ==
                                                        2
                                                    ? widget.userPermessions
                                                                    .adminResponse ==
                                                                "" ||
                                                            widget.userPermessions
                                                                    .adminResponse ==
                                                                null
                                                        ? Container()
                                                        : Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        10.h),
                                                            child: AutoSizeText(
                                                              "${getTranslated(context, "سبب الرفض ")}: ${widget.userPermessions.adminResponse}",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    setResponsiveFontSize(
                                                                        13),
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          )
                                                    : adminResponseIsNull()
                                                        ? Container()
                                                        : Container(
                                                            width: 230.w,
                                                            child: AutoSizeText(
                                                              "${getTranslated(context, "تعليق الأدمن")} : ${widget.userPermessions.adminResponse}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    setResponsiveFontSize(
                                                                        13),
                                                                color: Colors
                                                                    .green,
                                                                height: 1.3,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                adminResponseIsNull()
                                                    ? Container()
                                                    : const Divider()
                                              ],
                                            )
                                          : Container(
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: AutoSizeText(
                                                getTranslated(context,
                                                    'تم ارسال الطلب برجاء انتظار الرد'),
                                                style: TextStyle(
                                                  fontSize:
                                                      setResponsiveFontSize(13),
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  widget.userPermessions.permessionStatus ==
                                              1 ||
                                          widget.userPermessions
                                                  .permessionStatus ==
                                              2
                                      ? Lottie.asset(
                                          widget.userPermessions
                                                      .permessionStatus ==
                                                  1
                                              ? "resources/accepted.json"
                                              : "resources/refused.json",
                                          width: widget.userPermessions
                                                      .permessionStatus ==
                                                  1
                                              ? 100.w
                                              : 60.w,
                                          height: widget.userPermessions
                                                      .permessionStatus ==
                                                  1
                                              ? 100
                                              : 60.h,
                                          repeat: false)
                                      : Container()
                                ],
                              ),
                            ),
                          ),
                  )
                ],
              ),
            ),
            checkDeleteAllowed()
                ? Positioned(
                    child: RemovePermession(
                      permId: widget.userPermessions.permessionId,
                      index: widget.currentIndex,
                    ),
                    top: 0,
                    right: 0,
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
