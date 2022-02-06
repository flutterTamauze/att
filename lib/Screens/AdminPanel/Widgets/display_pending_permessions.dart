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
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/UserFullData/user_floating_button_permVacations.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

class ExpandedPendingPermessions extends StatefulWidget {
  final String desc, userName, adminComment, duration, userId;
  final int id, index;
  Function onAccept;
  Function onRefused;
  bool isAdmin = false;
  final int permessionType;
  final String date, createdOn;

  ExpandedPendingPermessions({
    this.userName,
    this.permessionType,
    this.id,
    this.onRefused,
    this.onAccept,
    this.isAdmin,
    this.duration,
    this.adminComment,
    this.desc,
    this.date,
    this.userId,
    this.index,
    this.createdOn,
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
              width: 80.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: AutoSizeText(
                            widget.createdOn.substring(0, 11),
                          ),
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
                widget.userName,
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
                                    "${getTranslated(context, "نوع الأذن")}: ${widget.permessionType == 1 ? getTranslated(context, "تأخير عن الحضور") : getTranslated(context, "انصراف مبكر")} ",
                                    style: TextStyle(
                                      fontSize: setResponsiveFontSize(14),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  widget.desc == ""
                                      ? Container()
                                      : const Divider(),
                                  widget.desc != null
                                      ? widget.desc == ""
                                          ? Container()
                                          : AutoSizeText(
                                              "${getTranslated(context, "تفاصيل الطلب ")} : ${widget.desc}",
                                              style: TextStyle(
                                                fontSize:
                                                    setResponsiveFontSize(14),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                      : Container(),
                                  widget.desc != null
                                      ? widget.desc == ""
                                          ? Container()
                                          : const Divider()
                                      : Container(),
                                  AutoSizeText(
                                      "${getTranslated(context, "تاريخ الأذن ")}: ${widget.date.substring(0, 11)}"),
                                  const Divider(),
                                  AutoSizeText(widget.permessionType == 1
                                      ? "${getTranslated(context, "اذن حتى الساعة")}: ${amPmChanger(int.parse(widget.duration))}"
                                      : "${getTranslated(context, "اذن من الساعة")}: ${amPmChanger(int.parse(widget.duration))}"),
                                  widget.desc != null
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
                                  memberId: widget.userId))
                          : Positioned(
                              bottom: 15.h,
                              right: 10.w,
                              child: FadeInVacPermFloatingButton(
                                  radioVal2: 0,
                                  comingFromAdminPanel: true,
                                  memberId: widget.userId))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
