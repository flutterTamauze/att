import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/widgets/MissionsDisplay/DataTableMissionsHeader.dart';
import 'package:qr_users/MLmodule/widgets/MissionsDisplay/missions_summary_table_end.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/widgets/CompanyMissions/DataTableMissionRow.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayHeader.dart';
import 'dart:ui' as ui;

import 'data_table_mission_row_single_user.dart';

class FadeInMissionsFAbutton extends StatelessWidget {
  const FadeInMissionsFAbutton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: StatefulBuilder(
        builder: (context, setstate) {
          return Container(
            width: 50.w,
            height: 50.h,
            child: FloatingActionButton(
              elevation: 4,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    var userMissionsList = Provider.of<MissionsData>(
                      context,
                    ).singleUserMissionsList;
                    return FlipInY(
                      child: Dialog(
                        child: Container(
                          height: userMissionsList.isEmpty ? 100.h : 500.h,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                "مأموريات المستخدم",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Divider(),
                              SizedBox(
                                height: 10.h,
                              ),
                              userMissionsList.isEmpty
                                  ? Container()
                                  : DataTableholidayHeader(),
                              userMissionsList.isEmpty
                                  ? Container()
                                  : Divider(
                                      thickness: 1,
                                      color: Colors.orange[600],
                                    ),
                              Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Expanded(
                                    child: FutureBuilder(
                                        future: userMission,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child: Expanded(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              ),
                                            );
                                          } else {
                                            return userMissionsList.isEmpty
                                                ? Center(
                                                    child: Text(
                                                    "لا يوجد مأموريات لهذا المستخدم",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ))
                                                : ListView.builder(
                                                    itemCount:
                                                        userMissionsList.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Column(
                                                        children: [
                                                          DataTableMissionRow(
                                                              userMissionsList[
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
                              userMissionsList.isEmpty
                                  ? Container()
                                  : Divider(
                                      thickness: 1,
                                      color: Colors.orange[600],
                                    ),
                              userMissionsList.isEmpty
                                  ? Container()
                                  : MissionsSummaryTableEnd()
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
          );
        },
      ),
    );
  }
}
