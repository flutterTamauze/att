import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/Screens/SystemScreens/ReportScreens/DailyReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';

import 'package:qr_users/constants.dart';

import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/VacationData.dart';

import 'package:qr_users/services/report_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';

import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OfficialVacation extends StatefulWidget {
  @override
  _OfficialVacationState createState() => _OfficialVacationState();
}

class _OfficialVacationState extends State<OfficialVacation> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Vacation>> key = new GlobalKey();

  DateTime toDate;
  DateTime fromDate;

  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');

  String dateToString = "";
  String dateFromString = "";

  String selectedId = "";
  Site siteData;
  DateTime yesterday;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var now = DateTime.now();

    toDate = DateTime(now.year, now.month, now.day);
    fromDate = DateTime(toDate.year, DateTime.january, 1);

    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    String fromText = " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    String toText = " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
    print(toDate.toString());
    print(fromDate.toString());
    _dateController.text = "$fromText $toText";
  }

  @override
  Widget build(BuildContext context) {
    var vactionProv = Provider.of<VacationData>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          child: Column(children: [
            Header(
              nav: false,
            ),
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmallDirectoriesHeader(
                    Lottie.asset("resources/calender.json", repeat: false),
                    "العطلات الرسمية",
                  ),
                ],
              ),
            ),
            Theme(
              data: clockTheme1,
              child: Builder(
                builder: (context) {
                  return InkWell(
                      onTap: () async {
                        final List<DateTime> picked =
                            await DateRagePicker.showDatePicker(
                                context: context,
                                initialFirstDate: fromDate,
                                initialLastDate: toDate,
                                firstDate: new DateTime(2021),
                                lastDate: toDate);
                        var newString = "";
                        setState(() {
                          fromDate = picked.first;
                          toDate = picked.last;
                          // selectedDuration = kCalcDateDifferance(
                          //     fromDate.toString(), toDate.toString());
                          // selectedDuration += 1;
                          String fromText =
                              " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                          String toText =
                              " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
                          newString = "$fromText $toText";
                        });

                        if (_dateController.text != newString) {
                          _dateController.text = newString;

                          dateFromString = apiFormatter.format(fromDate);
                          dateToString = apiFormatter.format(toDate);

                          if (_nameController.text != "" ||
                              Provider.of<UserData>(context, listen: false)
                                      .user
                                      .userType ==
                                  2) {
                            var userToken =
                                Provider.of<UserData>(context, listen: false)
                                    .user
                                    .userToken;

                            await Provider.of<ReportsData>(context,
                                    listen: false)
                                .getUserReportUnits(userToken, selectedId,
                                    dateFromString, dateToString, context);
                          }
                        }
                      },
                      child: Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Container(
                          width: 330.w,
                          child: IgnorePointer(
                            child: TextFormField(
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                              textInputAction: TextInputAction.next,
                              controller: _dateController,
                              decoration: kTextFieldDecorationFromTO.copyWith(
                                  hintText: 'المدة من / إلى',
                                  prefixIcon: Icon(
                                    Icons.calendar_today_rounded,
                                    color: Colors.orange,
                                  )),
                            ),
                          ),
                        ),
                      ));
                },
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              width: 330.w,
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: searchTextField = AutoCompleteTextField<Vacation>(
                  key: key,
                  clearOnSubmit: false,
                  controller: _nameController,
                  suggestions: Provider.of<VacationData>(context).vactionList,
                  style: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(16, allowFontScalingSelf: true),
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                  decoration: kTextFieldDecorationFromTO.copyWith(
                      hintStyle: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500),
                      hintText: 'اسم العطلة',
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.orange,
                      )),
                  itemFilter: (item, query) {
                    return item.vacationName
                        .toLowerCase()
                        .contains(query.toLowerCase());
                  },
                  itemSorter: (a, b) {
                    return a.vacationName.compareTo(b.vacationName);
                  },
                  itemSubmitted: (item) async {
                    var index = vactionProv.vactionList.indexOf(item);
                    if (_nameController.text != item.vacationName) {
                      setState(() {
                        searchTextField.textField.controller.text =
                            item.vacationName;
                        vactionProv.setCopy(index);
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
                                item.vacationName,
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
              height: 10.h,
            ),
            Expanded(
                child: Container(
              color: Colors.white,
              child: Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Column(
                    children: [
                      DataTableVacationHeader(),
                      Expanded(
                          child: Container(
                        child: ListView.builder(
                            itemCount: _nameController.text == ""
                                ? vactionProv.vactionList.length
                                : vactionProv.copyVacationList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return DataTableVacationRow(
                                  _nameController.text == ""
                                      ? vactionProv.vactionList[index]
                                      : vactionProv.copyVacationList[index]);
                            }),
                      )),
                    ],
                  )),
            ))
          ]),
        ),
      ),
    );
  }
}
