import 'dart:developer';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';

import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';

import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

class RoundedSearchBar extends StatefulWidget {
  final Function searchFun;
  final Function dropdownFun;
  final Function resetTextFieldFun;
  bool iscomingFromShifts = false;
  final String dropdownValue;
  final List<Site> list;
  final TextEditingController textController;

  RoundedSearchBar(
      {this.searchFun,
      this.dropdownFun,
      this.dropdownValue,
      this.iscomingFromShifts,
      this.list,
      this.textController,
      this.resetTextFieldFun});

  @override
  _RoundedSearchBarState createState() => _RoundedSearchBarState();
}

class _RoundedSearchBarState extends State<RoundedSearchBar> {
  bool showSearchButton = true;
  String plusSignPhone(String phoneNum) {
    int len = phoneNum.length;
    return "+ ${phoneNum.substring(0, len - 1)}";
  }

  Widget build(BuildContext context) {
    var prov = Provider.of<SiteData>(context, listen: true);

    return GestureDetector(
      onTap: () => print("prov.dropDownSitesIndex"),
      child: Container(
        child: Column(
          children: [
            Container(
              child: Flexible(
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        child: Center(
                          child: Column(
                            children: [
                              Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Consumer<SiteShiftsData>(
                                  builder: (context, shiftData, child) {
                                    return IgnorePointer(
                                      ignoring: prov.siteValue == "???? ??????????????"
                                          ? true
                                          : false,
                                      child: DropdownButton(
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          elevation: 5,
                                          items: shiftData.shifts
                                              .map(
                                                (value) => DropdownMenuItem(
                                                    child: Container(
                                                        alignment:
                                                            Alignment.topRight,
                                                        height: 20.h,
                                                        child: AutoSizeText(
                                                          value.shiftName,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(12,
                                                                      allowFontScalingSelf:
                                                                          true),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        )),
                                                    value: value.shiftName),
                                              )
                                              .toList(),
                                          onChanged: (val) async {
                                            int holder;
                                            prov.setShiftValue(val);
                                            if (prov.siteValue !=
                                                "???? ??????????????") {
                                              List<String> x = [];

                                              shiftData.shifts
                                                  .forEach((element) {
                                                x.add(element.shiftName);
                                              });

                                              holder = x.indexOf(val);
                                              print(shiftData
                                                  .shifts[holder].shiftId);
                                              if (shiftData
                                                      .shifts[holder].shiftId ==
                                                  -100) {
                                                Provider.of<MemberData>(context,
                                                        listen: false)
                                                    .bySitePageIndex = 0;
                                                Provider.of<MemberData>(context,
                                                        listen: false)
                                                    .keepRetriving = true;
                                              }
                                              Provider.of<MemberData>(context,
                                                      listen: false)
                                                  .byShiftPageIndex = 0;
                                              Provider.of<MemberData>(context,
                                                      listen: false)
                                                  .keepRetriving = true;
                                              log("ad ${prov.dropDownSitesIndex.toString()}");
                                              Provider.of<MemberData>(context, listen: false).getAllCompanyMember(
                                                  shiftData.shifts[holder].shiftId ==
                                                          -100
                                                      ? Provider.of<SiteShiftsData>(
                                                              context,
                                                              listen: false)
                                                          .siteShiftList[prov
                                                              .dropDownSitesIndex]
                                                          .siteId
                                                      : -1,
                                                  Provider.of<CompanyData>(context,
                                                          listen: false)
                                                      .com
                                                      .id,
                                                  Provider.of<UserData>(context,
                                                          listen: false)
                                                      .user
                                                      .userToken,
                                                  context,
                                                  shiftData.shifts[holder]
                                                              .shiftId ==
                                                          -100
                                                      ? -1
                                                      : shiftData.shifts[holder]
                                                          .shiftId);
                                              prov.setDropDownShift(holder);
                                            }
                                          },
                                          hint: Provider.of<SiteShiftsData>(
                                                          context,
                                                          listen: false)
                                                      .shifts
                                                      .isEmpty &&
                                                  Provider.of<SiteData>(context)
                                                          .siteValue !=
                                                      "???? ??????????????"
                                              ? Text("???? ???????? ??????????????")
                                              : Text("???? ??????????????????"),
                                          value: prov.siteValue == "???? ??????????????"
                                              ? null
                                              : shiftData.shifts.isEmpty
                                                  ? null
                                                  : shiftData
                                                      .shifts[prov
                                                          .dropDownShiftIndex]
                                                      .shiftName

                                          // value
                                          ),
                                    );
                                  },
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.alarm,
                      color: Colors.orange[600],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        child: Center(
                          child: Column(
                            children: [
                              Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Consumer<ShiftsData>(
                                  builder: (context, value, child) {
                                    return DropdownButton(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      elevation: 5,
                                      items: widget.list
                                          .map((value) => DropdownMenuItem(
                                                child: Container(
                                                  alignment: Alignment.topRight,
                                                  height: 20,
                                                  child: AutoSizeText(
                                                    value.name,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: ScreenUtil()
                                                            .setSp(12,
                                                                allowFontScalingSelf:
                                                                    true),
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                                value: value.name,
                                              ))
                                          .toList(),
                                      onChanged: (v) async {
                                        Provider.of<SiteShiftsData>(context,
                                                listen: false)
                                            .getShiftsList(v, true);
                                        prov.setDropDownShift(0);

                                        widget.dropdownFun(v);
                                        if (v != "???? ??????????????") {
                                          prov.setDropDownIndex(prov
                                                  .dropDownSitesStrings
                                                  .indexOf(v) -
                                              1);

                                          print(v);
                                        } else {
                                          prov.setDropDownIndex(0);
                                        }

                                        prov.setSiteValue(v);
                                        print(prov.dropDownSitesStrings);
                                      },
                                      value: widget.dropdownValue,
                                    );
                                  },
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.location_on,
                      color: Colors.orange[600],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                          decoration: BoxDecoration(),
                          height: 44.0.h,
                          child: Stack(
                            overflow: Overflow.visible,
                            children: [
                              TextFormField(
                                onFieldSubmitted: (_) async {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    showSearchButton = false;
                                    widget
                                        .searchFun(widget.textController.text);
                                  });
                                },
                                onChanged: (String v) {
                                  print(v);
                                  if (v.isEmpty) {
                                    widget.resetTextFieldFun();
                                  }
                                  print(showSearchButton);
                                  if (showSearchButton == false) {
                                    setState(() {
                                      showSearchButton = true;
                                    });
                                  }
                                },
                                controller: widget.textController,
                                style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(16, allowFontScalingSelf: true)),
                                decoration:
                                    kTextFieldDecorationForSearch.copyWith(
                                        hintText: '?????? ????????????????',
                                        hintStyle: TextStyle(
                                          fontSize: ScreenUtil().setSp(16,
                                              allowFontScalingSelf: true),
                                        ),
                                        fillColor: Color(0xFFE9E9E9),
                                        contentPadding: EdgeInsets.only(
                                            left: 11,
                                            right: 13,
                                            top: 20,
                                            bottom: 14),
                                        errorStyle: TextStyle(
                                          fontSize: 13,
                                          height: 0.7,
                                        ),
                                        errorMaxLines: 4),
                              ),
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: Container(
                                  width: 1.3,
                                  height: 50,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                              )
                            ],
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.textController.text.length < 3) {
                            Fluttertoast.showToast(
                                msg: "?????? ???? ???? ?????? ?????????? ???? 3 ????????",
                                backgroundColor: Colors.red,
                                gravity: ToastGravity.CENTER);
                          } else {
                            setState(() {
                              showSearchButton = false;
                              widget.searchFun(widget.textController.text);
                            });
                          }
                        },
                        child: showSearchButton
                            ? Container(
                                height: 44.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xff4a4a4a), width: 1.0),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10)),
                                  color: Colors.orange[500],
                                ),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    showSearchButton = true;
                                  });
                                  widget.resetTextFieldFun();
                                },
                                child: Container(
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xff4a4a4a), width: 1.0),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)),
                                    color: Colors.orange[500],
                                  ),
                                  child: Icon(FontAwesomeIcons.times,
                                      color: Colors.white),
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
