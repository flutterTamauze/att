import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/widgets/HolidaysDisplay/holiday_summary_table_end.dart';
import 'package:qr_users/MLmodule/widgets/PermessionsDisplay/DataTablePermessionHeader.dart';
import 'package:qr_users/MLmodule/widgets/PermessionsDisplay/permessions_summary_table_end.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/DataTablePermessionRow.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayHeader.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayRow.dart';

class FadeInVacPermFloatingButton extends StatelessWidget {
  const FadeInVacPermFloatingButton(
      {Key key, @required this.radioVal2, this.memberId})
      : super(key: key);

  final int radioVal2;
  final String memberId;

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: Container(
        width: 50.w,
        height: 50.h,
        child: FloatingActionButton(
          elevation: 4,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                List<UserHolidays> provList =
                    Provider.of<UserHolidaysData>(context, listen: true)
                        .singleUserHoliday;
                var permessionsList = Provider.of<UserPermessionsData>(
                  context,
                ).singleUserPermessions;
                return FlipInY(
                  child: Dialog(
                    child: Container(
                      height: radioVal2 == 1
                          ? provList.isEmpty
                              ? 100.h
                              : 500.h
                          : permessionsList.isEmpty
                              ? 100.h
                              : 500.h,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            radioVal2 == 1
                                ? "اجازات المستخدم"
                                : "اذونات المستخدم",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          Divider(),
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
                              ? Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Expanded(
                                      child: FutureBuilder(
                                          future: userHoliday,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              );
                                            } else {
                                              return provList.isEmpty
                                                  ? Center(
                                                      child: Text(
                                                      "لا يوجد اجازات لهذا المستخدم",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ))
                                                  : ListView.builder(
                                                      itemCount:
                                                          provList.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Column(
                                                          children: [
                                                            DataTableHolidayRow(
                                                                provList[
                                                                    index]),
                                                            Divider(
                                                              thickness: 1,
                                                            )
                                                          ],
                                                        );
                                                      });
                                            }
                                          })),
                                )
                              : Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Expanded(
                                      child: FutureBuilder(
                                          future: userPermession,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              );
                                            } else {
                                              return permessionsList.isEmpty
                                                  ? Center(
                                                      child: Text(
                                                      "لا يوجد اذنات لهذا المستخدم",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ))
                                                  : ListView.builder(
                                                      itemCount: permessionsList
                                                          .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Column(
                                                          children: [
                                                            DataTablePermessionRow(
                                                                permessionsList[
                                                                    index]),
                                                            Divider(
                                                              thickness: 1,
                                                            )
                                                          ],
                                                        );
                                                      });
                                            }
                                          })),
                                ),
                          radioVal2 == 1
                              ? provList.isEmpty
                                  ? Container()
                                  : Divider(
                                      thickness: 1,
                                      color: Colors.orange[600],
                                    )
                              : permessionsList.isEmpty
                                  ? Container()
                                  : Divider(color: Colors.orange[600]),
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
                  ),
                );
              },
            );
          },
          backgroundColor: Colors.orange[600],
          child: Icon(
            FontAwesomeIcons.info,
            color: Colors.black,
            size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
          ),
        ),
      ),
    );
  }
}
