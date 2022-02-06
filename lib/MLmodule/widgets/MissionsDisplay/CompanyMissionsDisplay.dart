import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/services/MemberData/MemberData.dart';

import 'package:qr_users/services/UserMissions/user_missions.dart';

import 'package:qr_users/widgets/CompanyMissions/DataTableMissionRow.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayHeader.dart';

import 'dart:ui' as ui;

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

  @override
  Widget build(BuildContext context) {
    final comMissionProv = Provider.of<MissionsData>(context, listen: false);
    return Expanded(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          widget._nameController.text == ""
              ? Container()
              : Divider(
                  thickness: 1,
                  color: ColorManager.primary,
                ),
          Container(
              child: widget._nameController.text == ""
                  ? Text(
                      getTranslated(context, "برجاء اختيار اسم المستخدم"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorManager.primary,
                        fontSize: setResponsiveFontSize(15),
                      ),
                    )
                  : DataTableMissionHeader()),
          widget._nameController.text == ""
              ? Container()
              : Divider(
                  thickness: 1,
                  color: ColorManager.primary,
                ),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Expanded(
                child: FutureBuilder(
                    future: widget._getMission,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } else {
                        return widget._nameController.text == ""
                            ? Container()
                            : comMissionProv.singleUserMissionsList.isNotEmpty
                                ? ListView.builder(
                                    itemCount: comMissionProv
                                        .singleUserMissionsList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          DataTableMissionRow(comMissionProv
                                              .singleUserMissionsList[index]),
                                          const Divider(
                                            thickness: 1,
                                          )
                                        ],
                                      );
                                    })
                                : Center(
                                    child: Provider.of<MemberData>(context)
                                            .loadingSearch
                                        ? Container()
                                        : Provider.of<MemberData>(context)
                                                .userSearchMember
                                                .isEmpty
                                            ? AutoSizeText(
                                                getTranslated(context,
                                                    "لا يوجد نتائج للبحث"),
                                                style: TextStyle(
                                                    fontSize:
                                                        setResponsiveFontSize(
                                                            15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : AutoSizeText(
                                                getTranslated(context,
                                                    "لا يوجد مأموريات لهذا المستخدم"),
                                                style: TextStyle(
                                                    fontSize:
                                                        setResponsiveFontSize(
                                                            14),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ));
                      }
                    })),
          ),
          widget._nameController.text == ""
              ? Container()
              : Divider(
                  thickness: 1,
                  color: ColorManager.primary,
                ),
          widget._nameController.text == ""
              ? Container()
              : MissionsSummaryTableEnd()
        ],
      ),
    );
  }
}
