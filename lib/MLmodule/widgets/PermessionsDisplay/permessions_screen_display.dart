import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';

import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/widgets/PermessionsDisplay/permessions_summary_table_end.dart';

import 'package:qr_users/Screens/SystemScreens/ReportScreens/DataTablePermessionRow.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/services/MemberData.dart';

import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import '../../../constants.dart';
import 'DataTablePermessionHeader.dart';

class DisplayPermessions extends StatefulWidget {
  TextEditingController _nameController = TextEditingController();
  DisplayPermessions(this._nameController);
  @override
  _DisplayPermessionsState createState() => _DisplayPermessionsState();
}

class _DisplayPermessionsState extends State<DisplayPermessions> {
  AutoCompleteTextField searchTextField;

  GlobalKey<AutoCompleteTextFieldState<Member>> key = new GlobalKey();

  Future getAllPermessions;

  @override
  void initState() {
    super.initState();
    widget._nameController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    var permessionProv =
        Provider.of<UserPermessionsData>(context, listen: false);

    return Expanded(
      child: Column(
        children: [
          Container(
            child: VacationCardHeader(
              header: "عرض الأذونات",
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
                  getAllPermessions =
                      Provider.of<UserPermessionsData>(context, listen: false)
                          .getSingleUserPermession(
                              item.id,
                              Provider.of<UserData>(context, listen: false)
                                  .user
                                  .userToken);
                  List<int> indexes = [];
                  for (int i = 0; i < permessionProv.userNames.length; i++) {
                    if (permessionProv.userNames[i] == item.name) {
                      indexes.add(i);
                    }
                  }
                  if (widget._nameController.text != item.name) {
                    setState(() {
                      print(item.name);
                      searchTextField.textField.controller.text = item.name;

                      Provider.of<UserPermessionsData>(context, listen: false)
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
                  : DataTablePermessionHeader()),
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
                    future: getAllPermessions,
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
                            : permessionProv.singleUserPermessions.isEmpty
                                ? Center(
                                    child: Text(
                                    "لا يوجد اذنات لهذا المستخدم",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ))
                                : ListView.builder(
                                    itemCount: permessionProv
                                        .singleUserPermessions.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          DataTablePermessionRow(permessionProv
                                              .singleUserPermessions[index]),
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
              : PermessionsSummaryTableEnd()
        ],
      ),
    );
  }
}
