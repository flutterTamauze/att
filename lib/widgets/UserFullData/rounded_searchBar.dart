import 'dart:io';
import 'dart:ui' as ui;

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/AddUserScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/Settings/settings.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/Shared/shimmer_builder.dart';
import 'package:qr_users/widgets/UserFullData/assignTaskToUser.dart';
import 'package:qr_users/widgets/UserFullData/member_tile.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/UserFullData/user_properties_menu.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:shimmer/shimmer.dart';

class RoundedSearchBar extends StatelessWidget {
  final Function searchFun;
  final Function dropdownFun;

  bool iscomingFromShifts = false;
  final String dropdownValue;
  final List<Site> list;
  final textController;

  RoundedSearchBar(
      {this.searchFun,
      this.dropdownFun,
      this.dropdownValue,
      this.iscomingFromShifts,
      this.list,
      this.textController});
  String plusSignPhone(String phoneNum) {
    int len = phoneNum.length;
    return "+ ${phoneNum.substring(0, len - 1)}";
  }

  Widget build(BuildContext context) {
    var prov = Provider.of<SiteData>(context, listen: false);

    return GestureDetector(
      onTap: () => print(prov.dropDownSitesIndex),
      child: Container(
        child: Column(
          children: [
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                  height: 44.0.h,
                  child: Center(
                    child: TextField(
                      controller: textController,
                      onChanged: searchFun,
                      style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true)),
                      decoration: kTextFieldDecorationWhite.copyWith(
                        hintText: 'اسم المستخدم',
                        hintStyle: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.grey,
                        ),
                        fillColor: Color(0xFFE9E9E9),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  )),
            ),
            SizedBox(
              height: 10,
            ),
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
                                child: Consumer<ShiftsData>(
                                  builder: (context, value, child) {
                                    return IgnorePointer(
                                      ignoring: prov.siteValue == "كل المواقع"
                                          ? true
                                          : false,
                                      child: DropdownButton(
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          elevation: 5,
                                          items: value.shiftsBySite
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
                                          onChanged: (v) async {
                                            int holder;
                                            if (prov.siteValue !=
                                                "كل المواقع") {
                                              List<String> x = [];
                                              prov.fillCurrentShiftID(value
                                                  .shiftsBySite[0].shiftId);
                                              value.shiftsBySite
                                                  .forEach((element) {
                                                x.add(element.shiftName);
                                              });

                                              print("on changed $v");
                                              holder = x.indexOf(v);
                                              prov.fillCurrentShiftIndex(
                                                  holder - 1);
                                              print("holder $holder");
                                              prov.setDropDownShift(holder);
                                              print(
                                                  "dropdown site index ${holder}");

                                              prov.fillCurrentShiftID(value
                                                  .shiftsBySite[holder]
                                                  .shiftId);
                                              if (prov.currentShiftID != -100) {
                                                print('i will not go there');
                                                List<Member> finalTest = [];

                                                Provider.of<MemberData>(context,
                                                        listen: false)
                                                    .copyMemberList
                                                    .forEach((element) {
                                                  if (element.shiftId ==
                                                      prov.currentShiftID) {
                                                    print(
                                                        "element id :${element.shiftId}");

                                                    finalTest.add(element);
                                                  }
                                                  Provider.of<MemberData>(
                                                          context,
                                                          listen: false)
                                                      .setMmemberList(
                                                          finalTest);
                                                });
                                              } else {
                                                List<Member> fakeList = [];
                                                fakeList =
                                                    Provider.of<MemberData>(
                                                            context,
                                                            listen: false)
                                                        .copyMemberList;
                                                Provider.of<MemberData>(context,
                                                        listen: false)
                                                    .setMmemberList(fakeList);
                                              }
                                            }
                                          },
                                          hint: Text("كل المناوبات"),
                                          value: prov.siteValue == "كل المواقع"
                                              ? null
                                              : value
                                                  .shiftsBySite[
                                                      prov.dropDownShiftIndex]
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
                                      items: list
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
                                        prov.setDropDownShift(0);
                                        dropdownFun(v);
                                        if (v != "كل المواقع") {
                                          prov.setDropDownIndex(prov
                                                  .dropDownSitesStrings
                                                  .indexOf(v) -
                                              1);
                                        } else {
                                          prov.setDropDownIndex(0);
                                        }

                                        await Provider.of<ShiftsData>(context,
                                                listen: false)
                                            .findMatchingShifts(
                                                Provider.of<SiteData>(context,
                                                        listen: false)
                                                    .sitesList[
                                                        prov.dropDownSitesIndex]
                                                    .id,
                                                true);

                                        prov.fillCurrentShiftID(
                                            list[prov.dropDownSitesIndex + 1]
                                                .id);

                                        prov.setSiteValue(v);
                                        print(prov.dropDownSitesStrings);
                                      },
                                      value: dropdownValue,
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
          ],
        ),
      ),
    );
  }
}
