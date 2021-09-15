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
  DisplayCompanyMissions(this._nameController);
  @override
  _DisplayHolidaysState createState() => _DisplayHolidaysState();
}

class _DisplayHolidaysState extends State<DisplayCompanyMissions> {
  GlobalKey<AutoCompleteTextFieldState<Member>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;

  Future getCompanyMissions;

  @override
  void initState() {
    widget._nameController.text = "";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var comMissionProv = Provider.of<MissionsData>(context, listen: false);
    return Expanded(
      child: Column(
        children: [
          Container(
            child: VacationCardHeader(
              header: "عرض المأموريات",
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            width: 330.w,
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: searchTextField = AutoCompleteTextField<Member>(
                key: key,
                clearOnSubmit: false,
                controller: widget._nameController,
                suggestions:
                    Provider.of<MemberData>(context, listen: true).membersList,
                style: TextStyle(
                    fontSize:
                        ScreenUtil().setSp(16, allowFontScalingSelf: true),
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
                decoration: kTextFieldDecorationFromTO.copyWith(
                    hintStyle: TextStyle(
                        fontSize:
                            ScreenUtil().setSp(16, allowFontScalingSelf: true),
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500),
                    hintText: 'اسم المستخدم',
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.orange,
                    )),
                itemFilter: (item, query) {
                  return item.name.toLowerCase().contains(query.toLowerCase());
                },
                itemSorter: (a, b) {
                  return a.name.compareTo(b.name);
                },
                itemSubmitted: (item) async {
                  var userProvider =
                      Provider.of<UserData>(context, listen: false);

                  getCompanyMissions =
                      Provider.of<MissionsData>(context, listen: false)
                          .getSingleUserMissions(
                              item.id, userProvider.user.userToken);
                  List<int> indexes = [];

                  print(comMissionProv.userNames.length);
                  for (int i = 0; i < comMissionProv.userNames.length; i++) {
                    if (comMissionProv.userNames[i] == item.name) {
                      indexes.add(i);
                    }
                  }
                  if (widget._nameController.text != item.name) {
                    setState(() {
                      print(item.name);
                      searchTextField.textField.controller.text = item.name;

                      Provider.of<MissionsData>(context, listen: false)
                          .setCopyByIndex(indexes);
                      // isVacationselected = true;
                    });
                  }
                },
                itemBuilder: (context, item) {
                  // ui for the autocompelete row
                  return Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                        bottom: 5,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 10.w,
                          ),
                          Container(
                            height: 20,
                            child: AutoSizeText(
                              item.name,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(16, allowFontScalingSelf: true),
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 5,
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
                    future: getCompanyMissions,
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
