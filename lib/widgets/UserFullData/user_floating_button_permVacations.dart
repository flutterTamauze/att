import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/MLmodule/widgets/HolidaysDisplay/holiday_summary_table_end.dart';
import 'package:qr_users/MLmodule/widgets/PermessionsDisplay/DataTablePermessionHeader.dart';
import 'package:qr_users/MLmodule/widgets/PermessionsDisplay/permessions_summary_table_end.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/DataTablePermessionRow.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayHeader.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayRow.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

class FadeInVacPermFloatingButton extends StatelessWidget {
  const FadeInVacPermFloatingButton(
      {Key key,
      @required this.radioVal2,
      this.memberId,
      @required this.comingFromAdminPanel})
      : super(key: key);

  final int radioVal2;
  final String memberId;
  final bool comingFromAdminPanel;

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: Container(
        width: comingFromAdminPanel ? 35.w : 50.w,
        height: comingFromAdminPanel ? 35.h : 50.h,
        child: FloatingActionButton(
          elevation: 4,
          onPressed: () async {
            if (comingFromAdminPanel) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return RoundedLoadingIndicator();
                  });
              if (radioVal2 == 1) {
                await Provider.of<UserHolidaysData>(context, listen: false)
                    .getSingleUserHoliday(
                        memberId,
                        Provider.of<UserData>(context, listen: false)
                            .user
                            .userToken);
              } else {
                await Provider.of<UserPermessionsData>(context, listen: false)
                    .getSingleUserPermession(
                        memberId,
                        Provider.of<UserData>(context, listen: false)
                            .user
                            .userToken);
              }

              Navigator.pop(navigatorKey.currentState.overlay.context);
            } else //Coming from user details
            {
              if (radioVal2 == 3) {
                if (Provider.of<UserPermessionsData>(context, listen: false)
                    .singleUserPermessions
                    .isEmpty) {
                  Provider.of<UserPermessionsData>(context, listen: false)
                      .getSingleUserPermession(
                          memberId,
                          Provider.of<UserData>(context, listen: false)
                              .user
                              .userToken);
                }
              } else if (radioVal2 == 1) {
                if (Provider.of<UserHolidaysData>(context, listen: false)
                    .singleUserHoliday
                    .isEmpty) {
                  Provider.of<UserHolidaysData>(context, listen: false)
                      .getSingleUserHoliday(
                          memberId,
                          Provider.of<UserData>(context, listen: false)
                              .user
                              .userToken);
                }
              }
            }

            showDialog(
              context: navigatorKey.currentState.overlay.context,
              builder: (context) {
                final List<UserHolidays> provList =
                    Provider.of<UserHolidaysData>(context, listen: true)
                        .singleUserHoliday;
                final permessionsList = Provider.of<UserPermessionsData>(
                  context,
                ).singleUserPermessions;
                return FlipInY(
                  child: Dialog(
                    child: Stack(
                      children: [
                        Container(
                          height: radioVal2 == 1
                              ? provList.isEmpty
                                  ? 100.h
                                  : 500.h
                              : permessionsList.isEmpty
                                  ? 100.h
                                  : 500.h,
                          padding: const EdgeInsets.all(10),
                          child: Provider.of<UserPermessionsData>(
                                    context,
                                  ).permessionDetailLoading ||
                                  Provider.of<UserHolidaysData>(
                                    context,
                                  ).loadingHolidaysDetails
                              ? const LoadingIndicator()
                              : Column(
                                  children: [
                                    AutoSizeText(
                                      radioVal2 == 1
                                          ? getTranslated(
                                              context, "اجازات المستخدم")
                                          : getTranslated(
                                              context, "اذونات المستخدم"),
                                      style: TextStyle(
                                          fontSize: setResponsiveFontSize(20),
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const Divider(),
                                    radioVal2 == 1
                                        ? provList.isEmpty
                                            ? Container()
                                            : DataTableholidayHeader()
                                        : permessionsList.isEmpty
                                            ? Container()
                                            : DataTablePermessionHeader(),
                                    radioVal2 == 1
                                        ? provList.isNotEmpty
                                            ? Divider(
                                                thickness: 1,
                                                color: Colors.orange[600],
                                              )
                                            : Container()
                                        : permessionsList.isNotEmpty
                                            ? Divider(
                                                thickness: 1,
                                                color: Colors.orange[600],
                                              )
                                            : Container(),
                                    radioVal2 == 1
                                        ? Expanded(
                                            child: FutureBuilder(
                                                future: userHoliday,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.orange,
                                                      ),
                                                    );
                                                  } else {
                                                    return provList.isEmpty
                                                        ? Center(
                                                            child: AutoSizeText(
                                                            getTranslated(
                                                                context,
                                                                "لا يوجد اجازات لهذا المستخدم"),
                                                            style: boldStyle,
                                                          ))
                                                        : ListView.builder(
                                                            itemCount:
                                                                provList.length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              return Column(
                                                                children: [
                                                                  DataTableHolidayRow(
                                                                      provList[
                                                                          index]),
                                                                  const Divider(
                                                                    thickness:
                                                                        1,
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                  }
                                                }))
                                        : Expanded(
                                            child: FutureBuilder(
                                                future: userPermession,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.orange,
                                                      ),
                                                    );
                                                  } else {
                                                    return permessionsList
                                                            .isEmpty
                                                        ? Center(
                                                            child: AutoSizeText(
                                                            getTranslated(
                                                                context,
                                                                "لا يوجد اذونات لهذا المستخدم"),
                                                            style: boldStyle,
                                                          ))
                                                        : ListView.builder(
                                                            itemCount:
                                                                permessionsList
                                                                    .length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              return Column(
                                                                children: [
                                                                  DataTablePermessionRow(
                                                                      permessionsList[
                                                                          index]),
                                                                  const Divider(
                                                                    thickness:
                                                                        1,
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                  }
                                                })),
                                    radioVal2 == 1
                                        ? provList.isEmpty
                                            ? Container()
                                            : Divider(
                                                thickness: 1,
                                                color: Colors.orange[600],
                                              )
                                        : permessionsList.isEmpty
                                            ? Container()
                                            : Divider(
                                                color: Colors.orange[600]),
                                    radioVal2 == 1
                                        ? provList.isEmpty
                                            ? Container()
                                            : HolidaySummaryTableEnd()
                                        : permessionsList.isEmpty
                                            ? Container()
                                            : PermessionsSummaryTableEnd()
                                  ],
                                ),
                        ),
                        Positioned(
                            top: 0,
                            left: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: FaIcon(
                                  FontAwesomeIcons.times,
                                  color: Colors.orange[600],
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                );
              },
            );
          },
          backgroundColor: Colors.orange[600],
          child: Icon(
            FontAwesomeIcons.info,
            color: Colors.black,
            size: ScreenUtil().setSp(comingFromAdminPanel ? 15 : 30,
                allowFontScalingSelf: true),
          ),
        ),
      ),
    );
  }
}
