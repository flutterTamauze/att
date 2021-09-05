import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';

import 'package:provider/provider.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/services/MemberData.dart';

import 'package:qr_users/services/UserHolidays/user_holidays.dart';

import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayHeader.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayRow.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import '../../../constants.dart';

class DisplayHolidays extends StatefulWidget {
  final TextEditingController _nameController;
  DisplayHolidays(this._nameController);
  @override
  _DisplayHolidaysState createState() => _DisplayHolidaysState();
}

class _DisplayHolidaysState extends State<DisplayHolidays> {
  GlobalKey<AutoCompleteTextFieldState<Member>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;

  Future getAllHolidays;

  @override
  void initState() {
    widget._nameController.text = "";
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);

    if (Provider.of<UserHolidaysData>(context, listen: false)
        .holidaysList
        .isEmpty) {
      getAllHolidays = Provider.of<UserHolidaysData>(context, listen: false)
          .getAllHolidays(userProvider.user.userToken, comProvider.com.id);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var holidayProv = Provider.of<UserHolidaysData>(context, listen: false);
    return Expanded(
      child: Column(
        children: [
          Container(
            child: VacationCardHeader(
              header: "عرض الأجازات",
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
                  List<int> indexes = [];
                  for (int i = 0; i < holidayProv.userNames.length; i++) {
                    if (holidayProv.userNames[i] == item.name) {
                      indexes.add(i);
                    }
                  }
                  if (widget._nameController.text != item.name) {
                    setState(() {
                      print(item.name);
                      searchTextField.textField.controller.text = item.name;

                      Provider.of<UserHolidaysData>(context, listen: false)
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
          Container(child: DataTableholidayHeader()),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Expanded(
                child: FutureBuilder(
                    future: getAllHolidays,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } else {
                        if (holidayProv.holidaysList.isEmpty) {
                          return Center(
                            child: Text(
                              "لا يوجد اجازات",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          );
                        }
                        return ListView.builder(
                            itemCount: widget._nameController.text == ""
                                ? holidayProv.holidaysList.length
                                : holidayProv.copyHolidaysList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  DataTableHolidayRow(
                                      widget._nameController.text == ""
                                          ? holidayProv.holidaysList[index]
                                          : holidayProv
                                              .copyHolidaysList[index]),
                                  Divider(
                                    thickness: 1,
                                  )
                                ],
                              );
                            });
                      }
                    })),
          ),
        ],
      ),
    );
  }
}
