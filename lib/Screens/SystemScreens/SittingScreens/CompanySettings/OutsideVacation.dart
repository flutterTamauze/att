import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/DailyReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import '../../../../constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

class OutsideVacation extends StatefulWidget {
  final Member member;
  OutsideVacation(this.member);
  @override
  _OutsideVacationState createState() => _OutsideVacationState();
}

var selectedAction = "عارضة";
var selectedMission = "داخلية";
var sleectedMember;
DateTime toDate;
DateTime fromDate;
DateTime yesterday;

String dateToString = "";
String dateFromString = "";
List<String> actions = ["مرضى", "عارضة", "رصيد الاجازات", "حالة وفاة"];
List<String> missions = ["داخلية", "خارجية"];

class _OutsideVacationState extends State<OutsideVacation> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  TextEditingController _dateController = TextEditingController();
  addExternalMission() async {
    if (fromDate != null && toDate != null) {
      String msg = await Provider.of<UserHolidaysData>(context, listen: false)
          .addHoliday(
              UserHolidays(
                userId: widget.member.id,
                holidayType: 4,
                fromDate: fromDate,
                toDate: toDate,
              ),
              Provider.of<UserData>(context, listen: false).user.userToken,
              widget.member.id);
      if (msg == "Success : Holiday Created!") {
        Fluttertoast.showToast(
            msg: "تمت اضافة المأمورية بنجاح",
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER);
      } else if (msg ==
          "Failed : Another Holiday not approved for this user!") {
        Fluttertoast.showToast(
            msg: "تم وضع مأمورية لهذا المستخدم من قبل",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(
            msg: "خطأ في اضافة المأمورية",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      }
    } else {
      Fluttertoast.showToast(
          msg: "برجاء ادخال المدة", backgroundColor: Colors.red);
    }
  }

  List<DateTime> picked = [];
  addInternalMission() async {
    var prov = Provider.of<SiteData>(context, listen: false);
    if (prov.siteValue == "كل المواقع" || picked.isEmpty) {
      Fluttertoast.showToast(
          msg: "برجاء ادخال البيانات المطلوبة",
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER);
    } else {
      String msg = await Provider.of<MissionsData>(context, listen: false)
          .addUserMission(
        UserMissions(
            fromDate: fromDate,
            toDate: toDate,
            shiftId: Provider.of<ShiftsData>(context, listen: false)
                .shiftsBySite[prov.dropDownShiftIndex]
                .shiftId,
            userId: widget.member.id),
        Provider.of<UserData>(context, listen: false).user.id,
      );
      if (msg == "Success : InternalMission Created!") {
        Fluttertoast.showToast(
            msg: "تمت اضافة المأمورية بنجاح",
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER);
      } else if (msg ==
          "Failed : Another InternalMission not approved for this user!") {
        Fluttertoast.showToast(
            msg: "تم وضع مأمورية لهذا المستخدم من قبل",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(
            msg: "خطأ فى اضافة المأمورية",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      }
    }
  }

  Future getAllPermessions;
  Future getAllHolidays;
  @override
  void initState() {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);

    var now = DateTime.now();
    if (Provider.of<UserPermessionsData>(context, listen: false)
        .permessionsList
        .isEmpty) {
      getAllPermessions = Provider.of<UserPermessionsData>(context,
              listen: false)
          .getAllPermessions(comProvider.com.id, userProvider.user.userToken);
    }
    if (Provider.of<UserHolidaysData>(context, listen: false)
        .holidaysList
        .isEmpty) {
      getAllHolidays = Provider.of<UserHolidaysData>(context, listen: false)
          .getAllHolidays(userProvider.user.userToken, comProvider.com.id);
    }

    fromDate = DateTime(now.year, now.month, now.day);
    toDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    yesterday = DateTime(now.year, DateTime.december, 30);
    sleectedMember =
        Provider.of<MemberData>(context, listen: false).membersList[0].name;
    super.initState();
  }

  var radioVal2 = 2;
  @override
  void dispose() {
    super.dispose();
  }

  var selectedVal = "كل المواقع";
  @override
  Widget build(BuildContext context) {
    var permessionProv =
        Provider.of<UserPermessionsData>(context, listen: false)
            .permessionsList;
    var holidayProv =
        Provider.of<UserHolidaysData>(context, listen: false).holidaysList;
    var prov = Provider.of<SiteData>(context, listen: false);
    var list = Provider.of<SiteData>(context, listen: true).dropDownSitesList;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          print(picked);
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
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SmallDirectoriesHeader(
                                  Lottie.asset("resources/calender.json",
                                      repeat: false),
                                  "الأجازات و المأموريات",
                                ),
                              ],
                            ),
                          ),
                          VacationCardHeader(
                            header:
                                "تسجيل طلب للمستخدم : ${widget.member.name}",
                          ),
                          // Directionality(
                          //   textDirection: ui.TextDirection.rtl,
                          //   child: Container(
                          //     child: SearchableDropdown.single(
                          //       dialogBox: false,
                          //       menuConstraints:
                          //           BoxConstraints.tight(Size.fromHeight(400)),
                          //       items: Provider.of<MemberData>(context,
                          //               listen: false)
                          //           .membersList
                          //           .map(
                          //             (value) => DropdownMenuItem(
                          //                 child: Container(
                          //                     alignment: Alignment.topRight,
                          //                     height: 20,
                          //                     child: AutoSizeText(
                          //                       value.name,
                          //                       style: TextStyle(
                          //                           color: Colors.black,
                          //                           fontSize: ScreenUtil().setSp(12,
                          //                               allowFontScalingSelf: true),
                          //                           fontWeight: FontWeight.w700),
                          //                     )),
                          //                 value: value.name),
                          //           )
                          //           .toList(),
                          //       value: sleectedMember,
                          //       hint: "اسم المستخدم",
                          //       closeButton: "غلق",
                          //       onChanged: (value) {
                          //         setState(() {
                          //           sleectedMember = value;
                          //         });
                          //       },
                          //       isExpanded: true,
                          //     ),
                          //   ),
                          // ),
                          VacationCardHeader(
                            header: "نوع الطلب",
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RadioButtonWidg(
                                  radioVal2: radioVal2,
                                  radioVal: 3,
                                  title: "أذن",
                                  onchannge: (value) {
                                    setState(() {
                                      radioVal2 = value;
                                    });
                                  },
                                ),
                                RadioButtonWidg(
                                  radioVal2: radioVal2,
                                  radioVal: 1,
                                  title: "اجازة",
                                  onchannge: (value) {
                                    setState(() {
                                      radioVal2 = value;
                                    });
                                  },
                                ),
                                RadioButtonWidg(
                                  radioVal: 2,
                                  radioVal2: radioVal2,
                                  title: "مأمورية",
                                  onchannge: (value) {
                                    setState(() {
                                      radioVal2 = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          radioVal2 == 1
                              ? Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        child: VacationCardHeader(
                                          header: "كل الأجازات",
                                        ),
                                      ),
                                      Container(
                                          child: DataTableholidayHeader()),
                                      Directionality(
                                        textDirection: ui.TextDirection.rtl,
                                        child: Expanded(
                                            child: FutureBuilder(
                                                future: getAllHolidays,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.orange,
                                                      ),
                                                    );
                                                  } else {
                                                    if (holidayProv.isEmpty) {
                                                      return Center(
                                                        child: Text(
                                                          "لا يوجد اجازات",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      );
                                                    }
                                                    return ListView.builder(
                                                        itemCount:
                                                            holidayProv.length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Column(
                                                            children: [
                                                              DataTableHolidayRow(
                                                                  holidayProv[
                                                                      index]),
                                                              holidayProv[index]
                                                                          .holidayType ==
                                                                      4
                                                                  ? Container()
                                                                  : Divider(
                                                                      thickness:
                                                                          1,
                                                                    )
                                                            ],
                                                          );
                                                        });
                                                  }
                                                })),
                                      ),
                                    ],
                                  ),
                                )
                              : radioVal2 == 2
                                  ? Column(
                                      children: [
                                        VacationCardHeader(
                                          header: "نوع المأمورية",
                                        ),
                                        Directionality(
                                          textDirection: ui.TextDirection.rtl,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                alignment: Alignment.topRight,
                                                padding: EdgeInsets.only(
                                                    right: 10.w),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border:
                                                        Border.all(width: 1)),
                                                width: 150.w,
                                                height: 40.h,
                                                child:
                                                    DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                  elevation: 2,
                                                  isExpanded: true,
                                                  items:
                                                      missions.map((String x) {
                                                    return DropdownMenuItem<
                                                            String>(
                                                        value: x,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            x,
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .orange,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ));
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedMission = value;
                                                    });
                                                  },
                                                  value: selectedMission,
                                                )),
                                              ),
                                            ),
                                          ),
                                        ),
                                        selectedMission == "داخلية"
                                            ? SitesAndMissionsWidg(
                                                prov: prov,
                                                selectedVal: selectedVal,
                                                list: list,
                                                onchannge: (value) {
                                                  setState(() {
                                                    selectedVal = value;
                                                  });
                                                },
                                              )
                                            : Container(),
                                        VacationCardHeader(
                                          header: "مدة المأمورية",
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
                                                    picked = await DateRagePicker
                                                        .showDatePicker(
                                                            context: context,
                                                            initialFirstDate:
                                                                DateTime(
                                                                    DateTime.now()
                                                                        .year,
                                                                    DateTime.now()
                                                                        .month,
                                                                    DateTime.now()
                                                                        .day),
                                                            initialLastDate:
                                                                toDate,
                                                            firstDate: DateTime(
                                                                DateTime.now()
                                                                    .year,
                                                                DateTime.now()
                                                                    .month,
                                                                DateTime.now()
                                                                    .day),
                                                            lastDate:
                                                                yesterday);
                                                    var newString = "";
                                                    setState(() {
                                                      fromDate = picked.first;
                                                      toDate = picked.last;

                                                      String fromText =
                                                          " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                      String toText =
                                                          " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
                                                      newString =
                                                          "$fromText $toText";
                                                    });

                                                    if (_dateController.text !=
                                                        newString) {
                                                      _dateController.text =
                                                          newString;

                                                      dateFromString =
                                                          apiFormatter
                                                              .format(fromDate);
                                                      dateToString =
                                                          apiFormatter
                                                              .format(toDate);
                                                    }
                                                  },
                                                  child: Directionality(
                                                    textDirection:
                                                        ui.TextDirection.rtl,
                                                    child: Container(
                                                      // width: 330,
                                                      width: 365.w,
                                                      child: IgnorePointer(
                                                        child: TextFormField(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          controller:
                                                              _dateController,
                                                          decoration:
                                                              kTextFieldDecorationFromTO
                                                                  .copyWith(
                                                                      hintText:
                                                                          'المدة من / إلى',
                                                                      prefixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .calendar_today_rounded,
                                                                        color: Colors
                                                                            .orange,
                                                                      )),
                                                        ),
                                                      ),
                                                    ),
                                                  ));
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Provider.of<UserHolidaysData>(context)
                                                    .isLoading ||
                                                Provider.of<MissionsData>(
                                                        context)
                                                    .isLoading
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              )
                                            : RoundedButton(
                                                onPressed: () async {
                                                  if (selectedMission ==
                                                      "خارجية") {
                                                    addExternalMission();
                                                  } //داخلية
                                                  else {
                                                    addInternalMission();
                                                  }
                                                },
                                                title: "حفظ",
                                              )
                                      ],
                                    )
                                  : Expanded(
                                      child: Column(
                                        children: [
                                          Container(
                                            child: VacationCardHeader(
                                              header: "كل الأذونات",
                                            ),
                                          ),
                                          Container(
                                              child:
                                                  DataTablePermessionHeader()),
                                          Directionality(
                                            textDirection: ui.TextDirection.rtl,
                                            child: Expanded(
                                                child: FutureBuilder(
                                                    future: getAllPermessions,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                        );
                                                      } else {
                                                        if (permessionProv
                                                            .isEmpty) {
                                                          return Center(
                                                            child: Text(
                                                              "لا يوجد اذونات",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          );
                                                        }
                                                        return ListView.builder(
                                                            itemCount:
                                                                permessionProv
                                                                    .length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              return Column(
                                                                children: [
                                                                  DataTablePermessionRow(
                                                                      permessionProv[
                                                                          index]),
                                                                  Divider(
                                                                    thickness:
                                                                        1,
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      }
                                                    })),
                                          ),
                                        ],
                                      ),
                                    ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class RadioButtonWidg extends StatelessWidget {
  final Function onchannge;
  final int radioVal;
  final String title;
  const RadioButtonWidg({
    this.onchannge,
    this.radioVal,
    this.title,
    Key key,
    @required this.radioVal2,
  }) : super(key: key);

  final int radioVal2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Radio(
          activeColor: Colors.orange,
          value: radioVal,
          groupValue: radioVal2,
          onChanged: (value) {
            print(value);
            onchannge(value);
          },
        ),
        Text(title),
      ],
    );
  }
}

class SitesAndMissionsWidg extends StatefulWidget {
  final Function onchannge;
  SitesAndMissionsWidg({
    this.onchannge,
    Key key,
    @required this.prov,
    @required this.selectedVal,
    @required this.list,
  }) : super(key: key);

  final SiteData prov;
  final String selectedVal;
  final List<Site> list;

  @override
  _SitesAndMissionsWidgState createState() => _SitesAndMissionsWidgState();
}

class _SitesAndMissionsWidgState extends State<SitesAndMissionsWidg> {
  @override
  Widget build(BuildContext context) {
    int shiftId;
    int holder;
    return Column(
      children: [
        VacationCardHeader(
          header: "الموقع و المناوبة للمأمورية",
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 60.h,
          child: Container(
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
                                  ignoring:
                                      widget.prov.siteValue == "كل المواقع"
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
                                                          color: Colors.black,
                                                          fontSize: ScreenUtil()
                                                              .setSp(12,
                                                                  allowFontScalingSelf:
                                                                      true),
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    )),
                                                value: value.shiftName),
                                          )
                                          .toList(),
                                      onChanged: (v) async {
                                        if (widget.selectedVal !=
                                            "كل المواقع") {
                                          List<String> x = [];

                                          value.shiftsBySite.forEach((element) {
                                            x.add(element.shiftName);
                                          });

                                          print("on changed $v");
                                          holder = x.indexOf(v);

                                          widget.prov.setDropDownShift(holder);
                                          shiftId =
                                              value.shiftsList[holder].shiftId;
                                        }
                                      },
                                      hint: Text("كل المناوبات"),
                                      value:
                                          widget.prov.siteValue == "كل المواقع"
                                              ? null
                                              : value
                                                  .shiftsBySite[widget
                                                      .prov.dropDownShiftIndex]
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
                                                    fontSize: ScreenUtil().setSp(
                                                        12,
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
                                    print(v);
                                    widget.prov.setDropDownShift(0);

                                    if (v != "كل المواقع") {
                                      widget.prov.setDropDownIndex(widget
                                              .prov.dropDownSitesStrings
                                              .indexOf(v) -
                                          1);
                                    } else {
                                      widget.prov.setDropDownIndex(0);
                                    }
                                    await Provider.of<ShiftsData>(context,
                                            listen: false)
                                        .findMatchingShifts(
                                            Provider.of<SiteData>(context,
                                                    listen: false)
                                                .sitesList[widget
                                                    .prov.dropDownSitesIndex]
                                                .id,
                                            false);

                                    widget.prov.fillCurrentShiftID(widget
                                        .list[
                                            widget.prov.dropDownSitesIndex + 1]
                                        .id);

                                    widget.prov.setSiteValue(v);
                                    widget.onchannge(v);
                                    print(widget.prov.dropDownSitesStrings);
                                  },
                                  value: widget.selectedVal,
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
    );
  }
}

class VacationCardHeader extends StatelessWidget {
  final String header;
  VacationCardHeader({
    this.header,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Text(
                header,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
