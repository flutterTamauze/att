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
  Future getAllPermessions;
  TextEditingController _nameController = TextEditingController();
  DisplayPermessions(this._nameController, this.getAllPermessions);
  @override
  _DisplayPermessionsState createState() => _DisplayPermessionsState();
}

class _DisplayPermessionsState extends State<DisplayPermessions> {
  AutoCompleteTextField searchTextField;

  GlobalKey<AutoCompleteTextFieldState<Member>> key = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var permessionProv =
        Provider.of<UserPermessionsData>(context, listen: false);

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
                    future: widget.getAllPermessions,
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
