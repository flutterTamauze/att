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
import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
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
                        await Provider.of<UserHolidaysData>(context,
                                listen: false)
                            .getHolidayDetailsByID(
                                int.parse(widget.orderNum),
                                Provider.of<UserData>(context, listen: false)
                                    .user
                                    .userToken);
                      }
                      print(widget.holidayType);
                    },
                    initiallyExpanded: widget.isAdmin,
                    trailing: Container(
                      width: 80.w,
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
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
                    title: Text(
                      widget.orderNum,
                    ),
                    children: [
                      SlideInDown(
                        child: Provider.of<UserHolidaysData>(
                          context,
                        ).loadingHolidaysDetails
                            ? LoadingIndicator()
                            : Card(
                                elevation: 5,
                                child: Container(
                                  width: 350.w,
                                  margin: EdgeInsets.all(15),
                                  padding: EdgeInsets.only(
                                    top: 10,
                                  ),
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
                                              ? Text(
                                                  " ?????? ?????????????? : ?????? ${widget.vacationDaysCount[0].toString().substring(0, 11)}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              : Text(
                                                  "?????? ?????????????? : ???? ${widget.vacationDaysCount[0].toString().substring(0, 11)} ?????? ${widget.vacationDaysCount[1].toString().substring(0, 11)}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                          Divider(),
                                          Text(
                                            "?????? ?????????????? : ${getVacationType(widget.holidayType)} ",
                                            style: TextStyle(
                                              fontSize:
                                                  setResponsiveFontSize(14),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          widget.comments == ""
                                              ? Container()
                                              : Divider(),
                                          widget.comments != null
                                              ? widget.comments == ""
                                                  ? Container()
                                                  : Text(
                                                      "???????????? ?????????? : ${widget.comments}",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize:
                                                            setResponsiveFontSize(
                                                                14),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    )
                                              : Container(),
                                          widget.comments != null
                                              ? Divider()
                                              : Container(),
                                          widget.status != 3
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    widget.status == 2
                                                        ? widget.adminComment !=
                                                                ""
                                                            ? Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            10.h),
                                                                child: Text(
                                                                  "?????? ?????????? : ${widget.adminComment}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .red,
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
                                                                    width:
                                                                        230.w,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "?????????? ???????????? : ${widget.adminComment}",
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
                                                                  )
                                                            : Container(),
                                                  ],
                                                )
                                              : Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  padding: EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Text(
                                                    '???? ?????????? ?????????? ?????????? ???????????? ????????',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey[700],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                          widget.status == 1
                                              ? Divider()
                                              : Container(),
                                          widget.status == 1
                                              ? Container(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10.h),
                                                  // child: Text(
                                                  //   " ?????????? ???????????????? : ${widget.approveDate.substring(0, 11)}",
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
                                        String msg =
                                            await Provider.of<UserHolidaysData>(
                                                    context,
                                                    listen: false)
                                                .deleteUserHoliday(
                                                    int.parse(widget.orderNum),
                                                    Provider.of<UserData>(
                                                            context,
                                                            listen: false)
                                                        .user
                                                        .userToken,
                                                    widget.index);

                                        if (msg ==
                                            "Success : Holiday Deleted!") {
                                          Fluttertoast.showToast(
                                              msg: "???? ?????????? ??????????",
                                              backgroundColor: Colors.green);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "?????? ???? ??????????",
                                              backgroundColor: Colors.red);
                                        }
                                      },
                                      content: "???? ???????? ?????? ??????????",
                                      onCancel: () {},
                                      title: "?????? ??????????",
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
