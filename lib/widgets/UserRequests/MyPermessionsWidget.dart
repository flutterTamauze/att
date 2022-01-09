import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserShifts.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';

import '../roundedAlert.dart';

class ExpandedPermessionsTile extends StatefulWidget {
  final String desc, orderNum, adminComment, duration, vacationReason;
  final IconData iconData;
  final int status, currentIndex;
  bool isAdmin = false;
  final int permessionType;
  final DateTime date, createdOn, approvedDate;

  ExpandedPermessionsTile({
    this.orderNum,
    this.permessionType,
    this.vacationReason,
    this.isAdmin,
    this.currentIndex,
    this.duration,
    this.iconData,
    this.adminComment,
    this.desc,
    this.status,
    this.date,
    this.createdOn,
    this.approvedDate,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedOrderTileState createState() => _ExpandedOrderTileState();
}

class _ExpandedOrderTileState extends State<ExpandedPermessionsTile> {
  bool checkDeleteAllowed() {
    if (DateTime.now().isBefore(widget.date) && widget.status == 3) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
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
                        print(widget.orderNum);
                        await Provider.of<UserPermessionsData>(context,
                                listen: false)
                            .getPermessionDetailsByID(
                                int.parse(widget.orderNum),
                                Provider.of<UserData>(context, listen: false)
                                    .user
                                    .userToken);
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
                              Text(
                                widget.createdOn.toString().substring(0, 11),
                              ),
                              FaIcon(
                                widget.status == 3
                                    ? FontAwesomeIcons.hourglass
                                    : widget.status == 1
                                        ? FontAwesomeIcons.check
                                        : FontAwesomeIcons.times,
                                color: widget.status == 3
                                    ? Colors.orange
                                    : widget.status == 1
                                        ? Colors.green
                                        : Colors.red,
                                size: 15,
                              )
                            ],
                          ),
                          Container(
                            width: 3,
                            color: widget.status == 3
                                ? Colors.orange
                                : widget.status == 1
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      widget.orderNum,
                    ),
                    children: [
                      SlideInDown(
                        child:
                            Provider.of<UserPermessionsData>(context)
                                    .permessionDetailLoading
                                ? LoadingIndicator()
                                : Card(
                                    elevation: 5,
                                    child: Container(
                                      width: 330.w,
                                      margin: EdgeInsets.all(15),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AutoSizeText(
                                                "${getTranslated(context, "نوع الأذن")} : ${widget.permessionType == 1 ? getTranslated(context, "تأخير عن الحضور") : getTranslated(context, "انصراف مبكر")} ",
                                                style: TextStyle(
                                                  fontSize:
                                                      setResponsiveFontSize(14),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              widget.desc == ""
                                                  ? Container()
                                                  : Divider(),
                                              if (widget.desc != null) ...[
                                                widget.desc == ""
                                                    ? Container()
                                                    : AutoSizeText(
                                                        "${getTranslated(context, "تفاصيل الطلب")}: ${widget.desc}",
                                                        style: TextStyle(
                                                          fontSize:
                                                              setResponsiveFontSize(
                                                                  14),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                widget.desc == ""
                                                    ? Container()
                                                    : Divider()
                                              ],
                                              AutoSizeText(
                                                  "${getTranslated(context, "تاريخ الأذن")}  : ${widget.date.toString().substring(0, 11)}"),
                                              Divider(),
                                              AutoSizeText(widget
                                                          .permessionType ==
                                                      1
                                                  ? "${getTranslated(context, "اذن حتى الساعة")}  : ${amPmChanger(int.parse(widget.duration))}"
                                                  : "${getTranslated(context, "اذن من الساعة")} : ${amPmChanger(int.parse(widget.duration))}"),
                                              widget.desc != null
                                                  ? Divider()
                                                  : Container(),
                                              widget.status != 3
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        widget.status == 2
                                                            ? widget.adminComment ==
                                                                        "" ||
                                                                    widget.adminComment ==
                                                                        null
                                                                ? Container()
                                                                : Container(
                                                                    padding: EdgeInsets.only(
                                                                        bottom:
                                                                            10.h),
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${getTranslated(context, "سبب الرفض ")}: ${widget.adminComment}",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            setResponsiveFontSize(14),
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  )
                                                            : widget.adminComment ==
                                                                        null ||
                                                                    widget.adminComment ==
                                                                        ""
                                                                ? Container()
                                                                : Container(
                                                                    width:
                                                                        230.w,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${getTranslated(context, "تعليق الأدمن")} : ${widget.adminComment}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            setResponsiveFontSize(13),
                                                                        color: Colors
                                                                            .green,
                                                                        height:
                                                                            1.3,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                        widget.adminComment ==
                                                                    null ||
                                                                widget.adminComment ==
                                                                    ""
                                                            ? Container()
                                                            : Divider()
                                                      ],
                                                    )
                                                  : Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      padding: EdgeInsets.only(
                                                          bottom: 5),
                                                      child: AutoSizeText(
                                                        getTranslated(context,
                                                            'تم ارسال الطلب برجاء انتظار الرد'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              setResponsiveFontSize(
                                                                  15),
                                                          color:
                                                              Colors.grey[700],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                          Expanded(child: Container()),
                                          widget.status == 1 ||
                                                  widget.status == 2
                                              ? Lottie.asset(
                                                  widget.status == 1
                                                      ? "resources/accepted.json"
                                                      : "resources/refused.json",
                                                  width: widget.status == 1
                                                      ? 100.w
                                                      : 60.w,
                                                  height: widget.status == 1
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
                        child: InkWell(
                          onTap: () {
                            return showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: RoundedAlert(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        final String msg = await Provider.of<
                                                    UserPermessionsData>(
                                                context,
                                                listen: false)
                                            .deleteUserPermession(
                                                int.parse(widget.orderNum),
                                                Provider.of<UserData>(context,
                                                        listen: false)
                                                    .user
                                                    .userToken,
                                                widget.currentIndex);

                                        if (msg ==
                                            "Success : Permission Deleted!") {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(
                                                  context, "تم الحذف بنجاح"),
                                              backgroundColor: Colors.green);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(
                                                  context, "خطأ في الحذف"),
                                              backgroundColor: Colors.red);
                                        }
                                      },
                                      content: getTranslated(
                                        context,
                                        "هل تريد حذف الطلب",
                                      ),
                                      onCancel: () {},
                                      title:
                                          getTranslated(context, "حذف الطلب"),
                                    ),
                                  );
                                });
                          },
                          child: Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 2, color: Colors.red)),
                            child: Icon(
                              FontAwesomeIcons.times,
                              color: Colors.red,
                              size: 15,
                            ),
                          ),
                        ),
                        top: 0,
                        right: 0,
                      )
                    : Container()
              ],
            ),
          ),
        ));
  }
}
