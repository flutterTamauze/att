import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/CameraPickerScreen.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:qr_users/services/Sites_data.dart';

import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import 'package:qr_users/widgets/roundedButton.dart';

import '../../../../constants.dart';

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
    userProvider = Provider.of<UserData>(context, listen: false);
    _picked = null;
    _yesterday = DateTime(DateTime.now().year, DateTime.december, 30);
    _dateController.text = "";
    var now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, now.day);
    _toDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

    Provider.of<ShiftsData>(context, listen: false).isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var _yesterday;
  var _picked;
  var _toDate;
  UserData userProvider;
  var _fromDate;
  String _toText, _fromText;
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  TextEditingController _dateController = TextEditingController();

  int getShiftid(String shiftName) {
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (shiftName == list[i].shiftName) {
        return list[i].shiftId;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    var selectedVal = "كل المواقع";
    var list = Provider.of<SiteData>(context, listen: true).dropDownSitesList;
    var daysofflist = Provider.of<DaysOffData>(context, listen: true);
    var prov = Provider.of<SiteData>(context, listen: false);
    ShiftsData shiftProv = Provider.of<ShiftsData>(context, listen: true);
    return GestureDetector(
        onTap: () {
          print(daysofflist.reallocateUsers[1].shiftID.toString());

          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Header(
                    nav: false,
                    goUserMenu: false,
                    goUserHomeFromMenu: false,
                  ),
                  Expanded(
                    child: Container(
                      child: Column(children: [
                        Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            child: Theme(
                          data: clockTheme1,
                          child: Builder(
                            builder: (context) {
                              return InkWell(
                                  onTap: () async {
                                    _picked =
                                        await DateRagePicker.showDatePicker(
                                            context: context,
                                            initialFirstDate: DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day),
                                            initialLastDate: _toDate,
                                            firstDate: DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day),
                                            lastDate: _yesterday);
                                    var newString = "";
                                    setState(() {
                                      _fromDate = _picked.first;
                                      _toDate = _picked.last;

                                      _fromText =
                                          " من ${DateFormat('yMMMd').format(_fromDate).toString()}";
                                      _toText =
                                          " إلى ${DateFormat('yMMMd').format(_toDate).toString()}";
                                      newString = "$_fromText $_toText";
                                    });

                                    if (_dateController.text != newString) {
                                      _dateController.text = newString;

                                      dateFromString =
                                          apiFormatter.format(_fromDate);
                                      dateToString =
                                          apiFormatter.format(_toDate);
                                    }
                                  },
                                  child: Directionality(
                                    textDirection: ui.TextDirection.rtl,
                                    child: Container(
                                      // width: 330,
                                      width: 365.w,
                                      child: IgnorePointer(
                                        child: TextFormField(
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                          textInputAction: TextInputAction.next,
                                          controller: _dateController,
                                          decoration: kTextFieldDecorationFromTO
                                              .copyWith(
                                                  hintText: 'المدة من / إلى',
                                                  prefixIcon: Icon(
                                                    Icons
                                                        .calendar_today_rounded,
                                                    color: Colors.orange,
                                                  )),
                                        ),
                                      ),
                                    ),
                                  ));
                            },
                          ),
                        )),
                        Expanded(
                            child: ListView.builder(
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      daysofflist
                                              .reallocateUsers[index].isDayOff
                                          ? Card(
                                              child: Container(
                                                width: 250.w,
                                                padding: EdgeInsets.all(10),
                                                child: Text("يوم عطلة",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            )
                                          : Stack(
                                              children: [
                                                Card(
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    width: 250.w,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(daysofflist
                                                            .reallocateUsers[
                                                                index]
                                                            .shiftname),
                                                        Text(daysofflist
                                                            .reallocateUsers[
                                                                index]
                                                            .sitename),
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
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10),
                                                              height: 200.h,
                                                              width: double
                                                                  .infinity,
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              20),
                                                                      child:
                                                                          Text(
                                                                        "اختر الموقع و المناوبة",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.orange,
                                                                            fontWeight: FontWeight.w600),
                                                                        textAlign:
                                                                            TextAlign.center,
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
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Container(
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
                                                                                                              height: 40.h,
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

                                                                                                    value.shiftsBySite.forEach((element) {
                                                                                                      x.add(element.shiftName);
                                                                                                    });

                                                                                                    print("on changed $v");
                                                                                                    holder = x.indexOf(v);
                                                                                                    setState(() {
                                                                                                      prov.setDropDownShift(holder);
                                                                                                    });

                                                                                                    print("dropdown site index ${holder}");
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
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Icon(
                                                                            Icons.alarm,
                                                                            color:
                                                                                Colors.orange[600],
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                20,
                                                                          ),
                                                                          Flexible(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Container(
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
                                                                                                        height: 40.h,
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
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Icon(
                                                                            Icons.location_on,
                                                                            color:
                                                                                Colors.orange[600],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Spacer(),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            10),
                                                                    child: RoundedButton(
                                                                        title: "حفظ",
                                                                        onPressed: () async {
                                                                          String
                                                                              shiftName =
                                                                              Provider.of<ShiftsData>(context, listen: false).shiftsBySite[prov.dropDownShiftIndex].shiftName;
                                                                          await Provider.of<DaysOffData>(context, listen: false).setSiteAndShift(
                                                                              index,
                                                                              selectedVal,
                                                                              shiftName,
                                                                              getShiftid(shiftName));
                                                                          prov.setDropDownIndex(
                                                                              0);
                                                                          prov.setSiteValue(
                                                                              "كل المواقع");
                                                                          Navigator.pop(
                                                                              context);
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
                                                    decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        shape: BoxShape.circle),
                                                    child: Icon(
                                                      Icons.edit,
                                                      size: 15,
                                                    ),
                                                    padding: EdgeInsets.all(1),
                                                  ),
                                                ))
                                              ],
                                            ),
                                      Text(
                                          daysofflist
                                              .reallocateUsers[index].dayName,
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
                    ),
                  ),
                  shiftProv.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                          backgroundColor: Colors.orange,
                        ))
                      : RoundedButton(
                          onPressed: () async {
                            if (_fromText == null || _toText == null) {
                              Fluttertoast.showToast(
                                  msg: "برجاء ادخال المدة",
                                  gravity: ToastGravity.CENTER,
                                  backgroundColor: Colors.red);
                            } else {
                              print(userProvider.user.userToken);
                              print(userProvider.user.id);
                              print(userProvider.user.userShiftId);
                              String msg = await Provider.of<ShiftsData>(
                                      context,
                                      listen: false)
                                  .addShiftSchedule(
                                      daysofflist.reallocateUsers,
                                      userProvider.user.userToken,
                                      userProvider.user.id,
                                      userProvider.user.userShiftId,
                                      _fromDate,
                                      _toDate);
                              if (msg == "Success") {
                                Fluttertoast.showToast(
                                    msg: "تمت اضافة الجدولة بنجاح",
                                    gravity: ToastGravity.CENTER,
                                    backgroundColor: Colors.green);
                                Navigator.pop(context);
                              } else if (msg == "exists") {
                                Fluttertoast.showToast(
                                    msg: "تم طلب جدولة لهذا المستخدم مسبقا",
                                    gravity: ToastGravity.CENTER,
                                    backgroundColor: Colors.red);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "حدث خطأ ما",
                                    gravity: ToastGravity.CENTER,
                                    backgroundColor: Colors.red);
                              }
                            }
                          },
                          title: "حفظ",
                        )
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
