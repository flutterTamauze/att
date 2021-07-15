import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/ShiftsData.dart';

import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import 'package:qr_users/widgets/roundedButton.dart';

class ReAllocateUsers extends StatefulWidget {
  final Member member;
  ReAllocateUsers(this.member);
  @override
  _ReAllocateUsersState createState() => _ReAllocateUsersState();
}

class _ReAllocateUsersState extends State<ReAllocateUsers> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // TODO: implement initState

    getDaysOff();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getDaysOff() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);
    await Provider.of<DaysOffData>(context, listen: false)
        .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
  }

  @override
  Widget build(BuildContext context) {
    var permessionProv =
        Provider.of<UserPermessionsData>(context, listen: false)
            .permessionsList;
    var selectedVal = "كل المواقع";
    var list = Provider.of<SiteData>(context, listen: true).dropDownSitesList;
    var daysofflist = Provider.of<DaysOffData>(context, listen: true);
    var prov = Provider.of<SiteData>(context, listen: false);

    return GestureDetector(
        onTap: () {
          for (int i = 0; i < daysofflist.reallocateUsers.length; i++) {
            print(daysofflist.reallocateUsers[i].shiftname);

            print(daysofflist.reallocateUsers[i].sitename);
          }
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Header(
                    nav: false,
                  ),
                  Expanded(
                    child: FutureBuilder(
                        future: Provider.of<DaysOffData>(context).future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              color: Colors.white,
                              child: Center(
                                child: Platform.isIOS
                                    ? CupertinoActivityIndicator(
                                        radius: 20,
                                      )
                                    : CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                      ),
                              ),
                            );
                          }

                          return Container(
                            child: Column(children: [
                              Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SmallDirectoriesHeader(
                                      Lottie.asset("resources/calender.json",
                                          repeat: false),
                                      "جدولة المناوبات",
                                    ),
                                  ],
                                ),
                              ),
                              VacationCardHeader(
                                header:
                                    "جدولة المناوبات للمستخدم : ${widget.member.name} ",
                              ),
                              Expanded(
                                  child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            daysofflist.reallocateUsers[index]
                                                    .isDayOff
                                                ? Card(
                                                    child: Container(
                                                      width: 200.w,
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Text("يوم عطلة",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 16),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                  )
                                                : Stack(
                                                    children: [
                                                      Card(
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          width: 200.w,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(daysofflist
                                                                  .reallocateUsers[
                                                                      index]
                                                                  .sitename),
                                                              Text(daysofflist
                                                                  .reallocateUsers[
                                                                      index]
                                                                  .shiftname)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                          child: InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return Dialog(child:
                                                                  StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                                  return Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10),
                                                                    height:
                                                                        200.h,
                                                                    width: double
                                                                        .infinity,
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Container(
                                                                            padding:
                                                                                EdgeInsets.all(20),
                                                                            child: Text(
                                                                              "اختر الموقع و المناوبة",
                                                                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                                                                              textAlign: TextAlign.center,
                                                                            )),
                                                                        Container(
                                                                          height:
                                                                              60.h,
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Row(
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
                                                                                                  ignoring: prov.siteValue == "كل المواقع" ? true : false,
                                                                                                  child: DropdownButton(
                                                                                                      isExpanded: true,
                                                                                                      underline: SizedBox(),
                                                                                                      elevation: 5,
                                                                                                      items: value.shiftsBySite
                                                                                                          .map(
                                                                                                            (value) => DropdownMenuItem(
                                                                                                                child: Container(
                                                                                                                    alignment: Alignment.topRight,
                                                                                                                    height: 20.h,
                                                                                                                    child: AutoSizeText(
                                                                                                                      value.shiftName,
                                                                                                                      style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.w700),
                                                                                                                    )),
                                                                                                                value: value.shiftName),
                                                                                                          )
                                                                                                          .toList(),
                                                                                                      onChanged: (v) async {
                                                                                                        int holder;
                                                                                                        if (selectedVal != "كل المواقع") {
                                                                                                          List<String> x = [];
                                                                                                          // prov.fillCurrentShiftID(value
                                                                                                          //     .shiftsBySite[0]
                                                                                                          //     .shiftId);
                                                                                                          value.shiftsBySite.forEach((element) {
                                                                                                            x.add(element.shiftName);
                                                                                                          });

                                                                                                          print("on changed $v");
                                                                                                          holder = x.indexOf(v);
                                                                                                          setState(() {
                                                                                                            prov.setDropDownShift(holder);
                                                                                                          });

                                                                                                          print("dropdown site index ${holder}");

                                                                                                          // prov.fillCurrentShiftID(value
                                                                                                          //     .shiftsBySite[holder]
                                                                                                          //     .shiftId);
                                                                                                        }
                                                                                                      },
                                                                                                      hint: Text("كل المناوبات"),
                                                                                                      value: prov.siteValue == "كل المواقع" ? null : value.shiftsBySite[prov.dropDownShiftIndex].shiftName

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
                                                                                                                style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.w700),
                                                                                                              ),
                                                                                                            ),
                                                                                                            value: value.name,
                                                                                                          ))
                                                                                                      .toList(),
                                                                                                  onChanged: (v) async {
                                                                                                    print(v);
                                                                                                    prov.setDropDownShift(0);
                                                                                                    // prov.setDropDownShift(
                                                                                                    //     0);
                                                                                                    // dropdownFun(v);
                                                                                                    // if (v !=
                                                                                                    //     "كل المواقع") {
                                                                                                    //   prov.setDropDownIndex(prov
                                                                                                    //           .dropDownSitesStrings
                                                                                                    //           .indexOf(
                                                                                                    //               v)
                                                                                                    //       1);
                                                                                                    // } else {
                                                                                                    //   prov.setDropDownIndex(
                                                                                                    //       0);
                                                                                                    // }
                                                                                                    if (v != "كل المواقع") {
                                                                                                      prov.setDropDownIndex(prov.dropDownSitesStrings.indexOf(v) - 1);
                                                                                                    } else {
                                                                                                      prov.setDropDownIndex(0);
                                                                                                    }
                                                                                                    await Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(Provider.of<SiteData>(context, listen: false).sitesList[prov.dropDownSitesIndex].id, false);

                                                                                                    prov.fillCurrentShiftID(list[prov.dropDownSitesIndex + 1].id);

                                                                                                    prov.setSiteValue(v);
                                                                                                    setState(() {
                                                                                                      selectedVal = v;
                                                                                                    });
                                                                                                    print(prov.dropDownSitesStrings);
                                                                                                  },
                                                                                                  value: selectedVal,
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
                                                                        Spacer(),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(bottom: 10),
                                                                          child: RoundedButton(
                                                                              title: "حفظ",
                                                                              onPressed: () async {
                                                                                await Provider.of<DaysOffData>(context, listen: false).setSiteAndShift(index, selectedVal, Provider.of<ShiftsData>(context, listen: false).shiftsBySite[prov.dropDownShiftIndex].shiftName);
                                                                                prov.setDropDownIndex(0);
                                                                                prov.setSiteValue("كل المواقع");

                                                                                Navigator.pop(context);
                                                                              }),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ));
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 20.w,
                                                          height: 20.h,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .orange,
                                                                  shape: BoxShape
                                                                      .circle),
                                                          child: Icon(
                                                            Icons.edit,
                                                            size: 15,
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(1),
                                                        ),
                                                      ))
                                                    ],
                                                  ),
                                            Text(
                                                daysofflist
                                                    .reallocateUsers[index]
                                                    .dayName,
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16)),
                                          ],
                                        ),
                                        Divider()
                                      ],
                                    ),
                                  );
                                },
                                itemCount: daysofflist.reallocateUsers.length,
                              ))
                            ]),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget showEditWidget() {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)), //this right here
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Container(
            height: 200.h,
            child: Text("d"),
          ),
        ));
  }
}
