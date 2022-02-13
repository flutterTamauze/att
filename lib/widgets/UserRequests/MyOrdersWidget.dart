import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';

import '../roundedAlert.dart';

class ExpandedOrderTile extends StatefulWidget {
  final String response, orderNum, adminComment;
  final IconData iconData;
  final String comments;
  final int holidayType;
  final int status;
  final int index;
  final List<DateTime> vacationDaysCount;
  final String date, createdDate, approveDate;
  bool isAdmin = false;
  ExpandedOrderTile({
    this.comments,
    this.orderNum,
    this.vacationDaysCount,
    this.holidayType,
    this.isAdmin,
    this.iconData,
    this.adminComment,
    this.response,
    this.status,
    this.index,
    this.date,
    this.createdDate,
    this.approveDate,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedOrderTileState createState() => _ExpandedOrderTileState();
}

class _ExpandedOrderTileState extends State<ExpandedOrderTile> {
  bool checkDeleteAllowed() {
    if (DateTime.now().isBefore(widget.vacationDaysCount[0]) &&
        widget.status == 3) {
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
                    await Provider.of<UserHolidaysData>(context, listen: false)
                        .getHolidayDetailsByID(
                            int.parse(widget.orderNum),
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
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AutoSizeText(
                            widget.createdDate.substring(0, 11),
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
                        color: widget.status == 2
                            ? Colors.red
                            : widget.status == 3
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ],
                  ),
                ),
                title: AutoSizeText(
                  widget.orderNum,
                ),
                children: [
                  SlideInDown(
                    child: Provider.of<UserHolidaysData>(
                      context,
                    ).loadingHolidaysDetails
                        ? Container()
                        : Card(
                            elevation: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      widget.vacationDaysCount[1].isBefore(
                                              widget.vacationDaysCount[0])
                                          ? AutoSizeText(
                                              " ${getTranslated(context, "مدة الأجازة")} : يوم ${widget.vacationDaysCount[0].toString().substring(0, 11)}",
                                              style: TextStyle(
                                                fontSize:
                                                    setResponsiveFontSize(14),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          : AutoSizeText(
                                              "${getTranslated(context, "مدة الأجازة")} : ${getTranslated(context, "من")} ${widget.vacationDaysCount[0].toString().substring(0, 11)} ${getTranslated(context, "إلى")} ${widget.vacationDaysCount[1].toString().substring(0, 11)}",
                                              style: TextStyle(
                                                fontSize:
                                                    setResponsiveFontSize(14),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                      const Divider(),
                                      AutoSizeText(
                                        "${getTranslated(context, "نوع الأجازة ")}: ${getTranslated(context, getVacationType(widget.holidayType))} ",
                                        style: TextStyle(
                                          fontSize: setResponsiveFontSize(14),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      widget.comments == ""
                                          ? Container()
                                          : const Divider(),
                                      widget.comments != null
                                          ? widget.comments == ""
                                              ? Container()
                                              : AutoSizeText(
                                                  "${getTranslated(context, "تفاصيل الطلب")} : ${widget.comments}",
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize:
                                                        setResponsiveFontSize(
                                                            15),
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                          : Container(),
                                      widget.comments != null
                                          ? const Divider()
                                          : Container(),
                                      widget.status != 3
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                widget.status == 2
                                                    ? widget.adminComment != ""
                                                        ? Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        10.h),
                                                            child: AutoSizeText(
                                                              "${getTranslated(context, "سبب الرفض")} : ${widget.adminComment}",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    setResponsiveFontSize(
                                                                        14),
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          )
                                                        : Container()
                                                    : widget.status == 1
                                                        ? widget.adminComment ==
                                                                    "" ||
                                                                widget.adminComment ==
                                                                    null
                                                            ? Container()
                                                            : Container(
                                                                width: 230.w,
                                                                child:
                                                                    AutoSizeText(
                                                                  "${getTranslated(context, "تعليق الأدمن")} : ${widget.adminComment}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  style:
                                                                      TextStyle(
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
                                                              )
                                                        : Container(),
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
                                                      setResponsiveFontSize(15),
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                      widget.status == 1
                                          ? const Divider()
                                          : Container(),
                                      widget.status == 1
                                          ? Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 10.h),
                                              // child: Text(
                                              //   " تاريخ الموافقة : ${widget.approveDate.substring(0, 11)}",
                                              //   textAlign: TextAlign.right,
                                              //   style: TextStyle(
                                              //     fontSize: 14,
                                              //     color: Colors.red,
                                              //     fontWeight: FontWeight.bold,
                                              //   ),
                                              // ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                  widget.status == 1 || widget.status == 2
                                      ? Lottie.asset(
                                          widget.status == 1
                                              ? "resources/accepted.json"
                                              : "resources/refused.json",
                                          width:
                                              widget.status == 1 ? 80.w : 60.w,
                                          height:
                                              widget.status == 1 ? 100 : 60.h,
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
                              return RoundedAlert(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final String msg =
                                      await Provider.of<UserHolidaysData>(
                                              context,
                                              listen: false)
                                          .deleteUserHoliday(
                                              int.parse(widget.orderNum),
                                              Provider.of<UserData>(context,
                                                      listen: false)
                                                  .user
                                                  .userToken,
                                              widget.index);

                                  if (msg == "Success : Holiday Deleted!") {
                                    Fluttertoast.showToast(
                                        msg: getTranslated(
                                            navigatorKey
                                                .currentState.overlay.context,
                                            "تم الحذف بنجاح"),
                                        backgroundColor: Colors.green);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: getTranslated(
                                            context, "خطأ في الحذف"),
                                        backgroundColor: Colors.red);
                                  }
                                },
                                content:
                                    getTranslated(context, "هل تريد حذف الطلب"),
                                onCancel: () {},
                                title: getTranslated(context, "حذف الطلب"),
                              );
                            });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.red)),
                        child: Icon(
                          FontAwesomeIcons.times,
                          color: Colors.red,
                          size: setResponsiveFontSize(15),
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
    );
  }
}
