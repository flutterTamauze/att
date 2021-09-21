import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants.dart';

class UserCurrentShifts extends StatefulWidget {
  @override
  _UserCurrentShiftsState createState() => _UserCurrentShiftsState();
}

String amPmChanger(int intTime) {
  int hours = (intTime ~/ 100);
  int min = intTime - (hours * 100);

  var ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours != 0 ? hours : 12; //

  String hoursStr =
      hours < 10 ? '0$hours' : hours.toString(); // the hour '0' should be '12'
  String minStr = min < 10 ? '0$min' : min.toString();

  var strTime = '$hoursStr:$minStr$ampm';

  return strTime;
}

TextEditingController _timeInController = TextEditingController(); //sat
TextEditingController _timeOutController = TextEditingController();

TextEditingController _sunTimeInController = TextEditingController(); //sun
TextEditingController _sunTimeOutController = TextEditingController();

TextEditingController _monTimeInController = TextEditingController();
TextEditingController _monTimeOutController = TextEditingController();

TextEditingController _tuesTimeInController = TextEditingController();
TextEditingController _tuesTimeOutController = TextEditingController();

TextEditingController _wedTimeInController = TextEditingController();
TextEditingController _wedTimeOutController = TextEditingController();

TextEditingController _thuTimeInController = TextEditingController();
TextEditingController _thuTimeOutController = TextEditingController();

TextEditingController _friTimeInController = TextEditingController();
TextEditingController _friTimeOutController = TextEditingController();
int shifttime = 1300;

class _UserCurrentShiftsState extends State<UserCurrentShifts> {
  @override
  void initState() {
    Shift userShift = Provider.of<ShiftApi>(context, listen: false).userShift;

    _timeInController.text = amPmChanger(userShift.shiftStartTime);
    _timeOutController.text = amPmChanger(userShift.shiftEndTime);
    _sunTimeInController.text = amPmChanger(userShift.sunShiftstTime);
    _sunTimeOutController.text = amPmChanger(userShift.sunShiftenTime);
    _monTimeInController.text = amPmChanger(userShift.monShiftstTime);
    _monTimeOutController.text = amPmChanger(userShift.mondayShiftenTime);
    _tuesTimeInController.text = amPmChanger(userShift.tuesdayShiftstTime);
    _tuesTimeOutController.text = amPmChanger(userShift.tuesdayShiftenTime);
    _wedTimeInController.text = amPmChanger(userShift.wednesDayShiftstTime);
    _wedTimeOutController.text = amPmChanger(userShift.wednesDayShiftenTime);
    _thuTimeInController.text = amPmChanger(userShift.thursdayShiftstTime);
    _thuTimeOutController.text = amPmChanger(userShift.thursdayShiftenTime);
    _friTimeInController.text = amPmChanger(userShift.fridayShiftstTime);
    _friTimeOutController.text = amPmChanger(userShift.fridayShiftenTime);
    super.initState();
  }

  String getShiftNameById(
    int id,
  ) {
    print("current id");
    print(id);

    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    print(list.length);

    List<Shift> currentShift =
        list.where((element) => element.shiftId == id).toList();
    return currentShift[0].shiftName;
  }

  String getSiteNameById(
    int id,
  ) {
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    print(list.length);

    List<Site> currentSite = list.where((element) => element.id == id).toList();
    return currentSite[0].name;
  }

  @override
  Widget build(BuildContext context) {
    var daysofflist = Provider.of<DaysOffData>(context, listen: true);
    var shiftDate =
        Provider.of<ShiftsData>(context, listen: false).firstAvailableSchedule;
    return GestureDetector(
      onTap: () {
        print(shiftDate.id);
      },
      child: Scaffold(
          endDrawer: NotificationItem(),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Header(
                    goUserHomeFromMenu: false,
                    nav: false,
                    goUserMenu: false,
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SmallDirectoriesHeader(
                            Lottie.asset("resources/shifts.json",
                                repeat: false),
                            "مناوباتى"),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ExpansionUserShiftTile(
                    title: "مناوباتى الأساسية",
                    isShedcule: false,
                  ),
                  shiftDate == null
                      ? Container()
                      : Provider.of<UserData>(context, listen: false)
                                  .user
                                  .userType ==
                              2
                          ? Container()
                          : Directionality(
                              textDirection: TextDirection.rtl,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Card(
                                  elevation: 5,
                                  child: ExpansionTile(
                                    collapsedIconColor: Colors.orange[600],
                                    iconColor: Colors.orange[600],
                                    textColor: Colors.orange[600],
                                    title: Row(
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.clock,
                                          color: Colors.orange[600],
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "مناوباتى المجدولة",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      Container(
                                        height: 500.h,
                                        child: ListView.builder(
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      daysofflist
                                                              .reallocateUsers[
                                                                  index]
                                                              .isDayOff
                                                          ? Card(
                                                              child: Container(
                                                                width: 250.w,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child: Text(
                                                                    "يوم عطلة",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            16),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                            )
                                                          : Card(
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                width: 250.w,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      weekDays[
                                                                          index],
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                    Text(
                                                                      getSiteNameById(
                                                                          shiftDate
                                                                              .scheduleSiteNumber[index]),
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                    ],
                                                  ),
                                                  Divider()
                                                ],
                                              ),
                                            );
                                          },
                                          itemCount: daysofflist
                                              .reallocateUsers.length,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                ],
              ),
            ),
          )),
    );
  }
}

class ExpansionUserShiftTile extends StatelessWidget {
  const ExpansionUserShiftTile({
    this.isShedcule,
    this.title,
    Key key,
  }) : super(key: key);
  final String title;
  final bool isShedcule;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Card(
          elevation: 5,
          child: ExpansionTile(
            collapsedIconColor: Colors.orange[600],
            iconColor: Colors.orange[600],
            textColor: Colors.orange[600],
            title: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.clock,
                  color: Colors.orange[600],
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            children: [
              Container(
                  width: 300.w,
                  child: Container(
                    child: Column(
                      children: [
                        AdvancedShiftPicker(
                          enableText: true,
                          timeInController: _timeInController,
                          timeOutController: _timeOutController,
                          weekDay: "السبت",
                        ),
                        AdvancedShiftPicker(
                          enableText: true,
                          weekDay: "الأحد",
                          timeInController: _sunTimeInController,
                          timeOutController: _sunTimeOutController,
                        ),
                        AdvancedShiftPicker(
                          enableText: true,
                          weekDay: "الأتنين",
                          timeInController: _monTimeInController,
                          timeOutController: _monTimeOutController,
                        ),
                        AdvancedShiftPicker(
                          enableText: true,
                          weekDay: "الثلاثاء",
                          timeInController: _tuesTimeInController,
                          timeOutController: _tuesTimeOutController,
                        ),
                        AdvancedShiftPicker(
                          enableText: true,
                          weekDay: "الأربعاء",
                          timeInController: _wedTimeInController,
                          timeOutController: _wedTimeOutController,
                        ),
                        AdvancedShiftPicker(
                          enableText: true,
                          weekDay: "الخميس",
                          timeInController: _thuTimeInController,
                          timeOutController: _thuTimeOutController,
                        ),
                        AdvancedShiftPicker(
                          enableText: true,
                          weekDay: "الجمعة",
                          timeInController: _friTimeInController,
                          timeOutController: _friTimeOutController,
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
