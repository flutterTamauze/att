import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/MLmodule/widgets/MissionsDisplay/missions_summary_table_end.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/CompanyMissions/DataTableMissionRow.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayHeader.dart';
import 'dart:ui' as ui;

import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';

class FadeInMissionsFAbutton extends StatelessWidget {
  const FadeInMissionsFAbutton({
    this.memberId,
    Key key,
  }) : super(key: key);
  final String memberId;
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
              onPressed: () async {
                if (Provider.of<MissionsData>(context, listen: false)
                    .singleUserMissionsList
                    .isEmpty) {
                  userMission =
                      Provider.of<MissionsData>(context, listen: false)
                          .getSingleUserMissions(
                              memberId,
                              Provider.of<UserData>(context, listen: false)
                                  .user
                                  .userToken);
                }
                showDialog(
                  context: context,
                  builder: (context) {
                    var userMissionsList = Provider.of<MissionsData>(
                      context,
                    ).singleUserMissionsList;
                    return FlipInY(
                      child: Dialog(
                        child: Stack(
                          children: [
                            Container(
                              height: userMissionsList.isEmpty ? 100.h : 500.h,
                              padding: EdgeInsets.all(10),
                              child: Provider.of<MissionsData>(
                                context,
                              ).missionsLoading
                                  ? LoadingIndicator()
                                  : Column(
                                      children: [
                                        AutoSizeText(
                                          getTranslated(
                                              context, "مأموريات المستخدم"),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  setResponsiveFontSize(20)),
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
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.orange,
                                                        ),
                                                      );
                                                    } else {
                                                      return userMissionsList
                                                              .isEmpty
                                                          ? Center(
                                                              child:
                                                                  AutoSizeText(
                                                              getTranslated(
                                                                  context,
                                                                  "لا يوجد مأموريات لهذا المستخدم"),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      setResponsiveFontSize(
                                                                          15),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ))
                                                          : ListView.builder(
                                                              itemCount:
                                                                  userMissionsList
                                                                      .length,
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return Column(
                                                                  children: [
                                                                    DataTableMissionRow(
                                                                        userMissionsList[
                                                                            index]),
                                                                    Divider(
                                                                      thickness:
                                                                          1,
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
                size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
              ),
            ),
          );
        },
      ),
    );
  }
}
