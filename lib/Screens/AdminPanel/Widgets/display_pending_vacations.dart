import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/UserFullData/user_floating_button_permVacations.dart';

class ExpandedPendingVacation extends StatefulWidget {
  final String response, userName, adminComment, userId;
  final String comments;
  final int holidayType, holidayId;
  final Function onAccept, onRefused;
  final List<DateTime> vacationDaysCount;
  final String date, createdOn;
  final bool isAdmin;
  ExpandedPendingVacation({
    this.comments,
    this.userName,
    this.onAccept,
    this.holidayId,
    this.onRefused,
    this.vacationDaysCount,
    this.holidayType,
    this.isAdmin,
    this.adminComment,
    this.response,
    this.date,
    this.createdOn,
    this.userId,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedPendingVacationState createState() =>
      _ExpandedPendingVacationState();
}

class _ExpandedPendingVacationState extends State<ExpandedPendingVacation> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
          data: Theme.of(context).copyWith(
              accentColor: Colors.orange, unselectedWidgetColor: Colors.black),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              child: ExpansionTile(
                onExpansionChanged: (value) async {
                  if (value) {
                    await Provider.of<UserHolidaysData>(context, listen: false)
                        .getPendingHolidayDetailsByID(
                            (widget.holidayId),
                            Provider.of<UserData>(context, listen: false)
                                .user
                                .userToken);
                  }
                },
                trailing: Container(
                  width: 80.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            widget.createdOn.substring(0, 11),
                          ),
                          widget.isAdmin
                              ? Container()
                              : FaIcon(
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
                title: Text(
                  widget.userName,
                ),
                children: [
                  Stack(
                    children: [
                      SlideInDown(
                        child: Provider.of<UserHolidaysData>(context)
                                .loadingHolidaysDetails
                            ? LoadingIndicator()
                            : Card(
                                elevation: 5,
                                child: Container(
                                  width: 300.w,
                                  margin: EdgeInsets.all(15),
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
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
                                        "?????? ?????????????? : ${widget.holidayType == 1 ? "??????????" : widget.holidayType == 3 ? "??????????" : "???????? ????????????"} ",
                                        style: TextStyle(
                                          fontSize: 14,
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
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                          : Container(),
                                      widget.comments != null
                                          ? Divider()
                                          : Container(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        children: [
                                          // Text(
                                          //   "??????????",
                                          //   style: TextStyle(
                                          //       fontWeight: FontWeight.bold),
                                          // ),
                                          Divider(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () => widget.onAccept(),
                                                child: FaIcon(
                                                  FontAwesomeIcons.check,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20.w,
                                              ),
                                              InkWell(
                                                onTap: () => widget.onRefused(),
                                                child: FaIcon(
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
                      Provider.of<UserHolidaysData>(context)
                              .loadingHolidaysDetails
                          ? Container()
                          : Positioned(
                              bottom: 15.h,
                              left: 10.w,
                              child: FadeInVacPermFloatingButton(
                                  radioVal2: 1,
                                  comingFromAdminPanel: true,
                                  memberId: widget.userId))
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
