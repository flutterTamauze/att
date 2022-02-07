import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/AdminPanel/Widgets/userImageExpanstionTile.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/UserFullData/user_floating_button_permVacations.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

class ExpandedPendingVacation extends StatefulWidget {
  final Function onAccept, onRefused;
  final List<DateTime> vacationDaysCount;

  final bool isAdmin;
  final UserHolidays userHolidays;
  const ExpandedPendingVacation({
    this.onAccept,
    this.onRefused,
    this.vacationDaysCount,
    this.isAdmin,
    this.userHolidays,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedPendingVacationState createState() =>
      _ExpandedPendingVacationState();
}

class _ExpandedPendingVacationState extends State<ExpandedPendingVacation> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          accentColor: Colors.orange, unselectedWidgetColor: Colors.black),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          child: ExpansionTile(
            leading:
                LeadingExpanstionImage(image: widget.userHolidays.userImage),
            onExpansionChanged: (value) async {
              if (value) {
                showDialog(
                  context: context,
                  builder: (context) => RoundedLoadingIndicator(),
                );
                await Provider.of<UserHolidaysData>(context, listen: false)
                    .getPendingHolidayDetailsByID(
                        (widget.userHolidays.holidayNumber),
                        Provider.of<UserData>(context, listen: false)
                            .user
                            .userToken);
                Navigator.pop(context);
              }
            },
            trailing: Container(
              width: 80.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AutoSizeText(
                    widget.userHolidays.createdOnDate
                        .toString()
                        .substring(0, 11),
                    style: TextStyle(fontSize: setResponsiveFontSize(14)),
                  ),
                  widget.isAdmin
                      ? Container()
                      : const FaIcon(
                          FontAwesomeIcons.hourglass,
                          color: Colors.orange,
                          size: 15,
                        ),
                  Expanded(child: Container()),
                  Container(width: 3, color: Colors.orange),
                ],
              ),
            ),
            title: AutoSizeText(
              widget.userHolidays.userName,
              style: TextStyle(fontSize: setResponsiveFontSize(15)),
            ),
            children: [
              Stack(
                children: [
                  Provider.of<UserHolidaysData>(context).loadingHolidaysDetails
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
                                  widget.vacationDaysCount[1]
                                          .isBefore(widget.vacationDaysCount[0])
                                      ? AutoSizeText(
                                          " ${getTranslated(context, "مدة الأجازة ")}: ${getTranslated(context, "من")} ${widget.vacationDaysCount[0].toString().substring(0, 11)}",
                                          style: TextStyle(
                                            fontSize: setResponsiveFontSize(14),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      : AutoSizeText(
                                          " ${getTranslated(context, "مدة الأجازة ")}: ${getTranslated(context, "من")} ${widget.vacationDaysCount[0].toString().substring(0, 11)} ${getTranslated(context, "إلى")} ${widget.vacationDaysCount[1].toString().substring(0, 11)}",
                                          style: TextStyle(
                                            fontSize: setResponsiveFontSize(14),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                  const Divider(),
                                  AutoSizeText(
                                    "${getTranslated(context, "نوع الأجازة")}: ${widget.userHolidays.holidayType == 1 ? getTranslated(context, "عارضة") : widget.userHolidays.holidayType == 3 ? getTranslated(context, "مرضية") : getTranslated(context, "رصيد اجازات")} ",
                                    style: TextStyle(
                                      fontSize: setResponsiveFontSize(14),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  widget.userHolidays.holidayDescription == ""
                                      ? Container()
                                      : const Divider(),
                                  widget.userHolidays.holidayDescription != null
                                      ? widget.userHolidays
                                                  .holidayDescription ==
                                              ""
                                          ? Container()
                                          : AutoSizeText(
                                              "${getTranslated(context, "تفاصيل الطلب ")}: ${widget.userHolidays.holidayDescription}",
                                              style: TextStyle(
                                                fontSize:
                                                    setResponsiveFontSize(14),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                      : Container(),
                                  widget.userHolidays.holidayDescription != null
                                      ? const Divider()
                                      : Container(),
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
                  Provider.of<UserHolidaysData>(context).loadingHolidaysDetails
                      ? Container()
                      : !Provider.of<PermissionHan>(context, listen: false)
                              .isEnglishLocale()
                          ? Positioned(
                              bottom: 15.h,
                              left: 10.w,
                              child: FadeInVacPermFloatingButton(
                                  radioVal2: 0,
                                  comingFromAdminPanel: true,
                                  memberId: widget.userHolidays.userName))
                          : Positioned(
                              bottom: 15.h,
                              right: 10.w,
                              child: FadeInVacPermFloatingButton(
                                  radioVal2: 0,
                                  comingFromAdminPanel: true,
                                  memberId: widget.userHolidays.userName))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
