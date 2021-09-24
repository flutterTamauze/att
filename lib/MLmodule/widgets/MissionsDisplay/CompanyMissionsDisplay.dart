import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';

import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/widgets/MissionsDisplay/DataTableMissionsHeader.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/services/MemberData.dart';

import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/CompanyMissions.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';

import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/CompanyMissions/DataTableMissionRow.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayHeader.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayRow.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import '../../../constants.dart';
import 'missions_summary_table_end.dart';

class DisplayCompanyMissions extends StatefulWidget {
  final TextEditingController _nameController;
  final Future _getMission;
  DisplayCompanyMissions(this._nameController, this._getMission);
  @override
  _DisplayHolidaysState createState() => _DisplayHolidaysState();
}

class _DisplayHolidaysState extends State<DisplayCompanyMissions> {
  GlobalKey<AutoCompleteTextFieldState<Member>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;

  Future getCompanyMissions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var comMissionProv = Provider.of<MissionsData>(context, listen: false);
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          widget._nameController.text == ""
              ? Container()
              : Divider(
                  thickness: 1,
                  color: Colors.orange[600],
                ),
          Container(
              child: widget._nameController.text == ""
                  ? Text(
                      "برجاء اختيار اسم المستخدم",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[600],
                          fontSize: 15),
                    )
                  : DataTableholidayHeader()),
          widget._nameController.text == ""
              ? Container()
              : Divider(
                  thickness: 1,
                  color: Colors.orange[600],
                ),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Expanded(
                child: FutureBuilder(
                    future: widget._getMission,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } else {
                        return widget._nameController.text == ""
                            ? Container()
                            : comMissionProv.singleUserMissionsList.isEmpty
                                ? Center(
                                    child: Text(
                                    "لا يوجد مأموريات لهذا المستخدم",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ))
                                : ListView.builder(
                                    itemCount: comMissionProv
                                        .singleUserMissionsList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          DataTableMissionRow(comMissionProv
                                              .singleUserMissionsList[index]),
                                          Divider(
                                            thickness: 1,
                                          )
                                        ],
                                      );
                                    });
                      }
                    })),
          ),
          widget._nameController.text == ""
              ? Container()
              : Divider(
                  thickness: 1,
                  color: Colors.orange[600],
                ),
          widget._nameController.text == ""
              ? Container()
              : MissionsSummaryTableEnd()
        ],
      ),
    );
  }
}
