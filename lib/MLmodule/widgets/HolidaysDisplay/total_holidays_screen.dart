import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/MLmodule/widgets/HolidaysDisplay/holiday_summary_table_end.dart';

import 'package:qr_users/services/MemberData/MemberData.dart';

import 'package:qr_users/services/UserHolidays/user_holidays.dart';

import 'package:qr_users/widgets/Holidays/DataTableHolidayHeader.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayRow.dart';

import 'dart:ui' as ui;

import '../../../Core/constants.dart';

class DisplayHolidays extends StatefulWidget {
  final TextEditingController _nameController;
  final Future getHoliday;
  DisplayHolidays(this._nameController, this.getHoliday);
  @override
  _DisplayHolidaysState createState() => _DisplayHolidaysState();
}

class _DisplayHolidaysState extends State<DisplayHolidays> {
  GlobalKey<AutoCompleteTextFieldState<Member>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;

  @override
  Widget build(BuildContext context) {
    final holidayProv = Provider.of<UserHolidaysData>(context, listen: false);

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
                  ? AutoSizeText(
                      "برجاء اختيار اسم المستخدم",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorManager.primary,
                          fontSize: setResponsiveFontSize(15)),
                    )
                  : DataTableholidayHeader()),
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
                    future: widget.getHoliday,
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
                            : holidayProv.singleUserHoliday.isNotEmpty
                                ? ListView.builder(
                                    itemCount:
                                        holidayProv.singleUserHoliday.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return holidayProv
                                                  .singleUserHoliday[index]
                                                  .holidayStatus ==
                                              1
                                          ? Column(
                                              children: [
                                                DataTableHolidayRow(holidayProv
                                                    .singleUserHoliday[index]),
                                                const Divider(
                                                  thickness: 1,
                                                )
                                              ],
                                            )
                                          : Container();
                                    })
                                : Center(
                                    child: Provider.of<MemberData>(context)
                                            .loadingSearch
                                        ? Container()
                                        : Provider.of<MemberData>(context)
                                                .userSearchMember
                                                .isEmpty
                                            ? AutoSizeText(
                                                "لا يوجد نتائج للبحث",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : AutoSizeText(
                                                "لا يوجد اجازات لهذا المستخدم",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ));
                        ;
                      }
                    })),
          ),
          widget._nameController.text == ""
              ? Container()
              : Divider(thickness: 1, color: ColorManager.primary),
          widget._nameController.text == ""
              ? Container()
              : HolidaySummaryTableEnd()
        ],
      ),
    );
  }
}
