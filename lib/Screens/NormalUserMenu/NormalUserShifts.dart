import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/ShiftSchedule/ShiftScheduleModel.dart';
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
    return Scaffold(
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
                          Lottie.asset("resources/shifts.json", repeat: false),
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
                    : Directionality(
                        textDirection: TextDirection.rtl,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Card(
                            elevation: 5,
                            child: ExpansionTile(
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              children: [
                                SlideInUp(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            "من",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange[600]),
                                          ),
                                          Text(shiftDate.scheduleFromTime
                                              .toString()
                                              .substring(0, 11)),
                                          Text(
                                            "الى",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange[600]),
                                          ),
                                          Text(shiftDate.scheduleToTime
                                              .toString()
                                              .substring(0, 11)),
                                        ],
                                      ),
                                      Divider(),
                                      FeatureScheduleShiftCard(
                                          currentIndex: 0,
                                          startTime:
                                              shiftDate.satShift.startTime,
                                          endTime: shiftDate.satShift.endTime,
                                          shiftname:
                                              shiftDate.satShift.shiftName,
                                          sitename: shiftDate.satShift.siteName,
                                          shiftDate: shiftDate),
                                      FeatureScheduleShiftCard(
                                          startTime:
                                              shiftDate.sunShift.startTime,
                                          endTime: shiftDate.sunShift.endTime,
                                          currentIndex: 1,
                                          shiftname:
                                              shiftDate.sunShift.shiftName,
                                          sitename: shiftDate.sunShift.siteName,
                                          shiftDate: shiftDate),
                                      FeatureScheduleShiftCard(
                                          startTime:
                                              shiftDate.monShift.startTime,
                                          endTime: shiftDate.monShift.endTime,
                                          currentIndex: 2,
                                          shiftname:
                                              shiftDate.monShift.shiftName,
                                          sitename: shiftDate.monShift.siteName,
                                          shiftDate: shiftDate),
                                      FeatureScheduleShiftCard(
                                          startTime:
                                              shiftDate.tuesShift.startTime,
                                          endTime: shiftDate.tuesShift.endTime,
                                          currentIndex: 3,
                                          shiftname:
                                              shiftDate.tuesShift.shiftName,
                                          sitename:
                                              shiftDate.tuesShift.siteName,
                                          shiftDate: shiftDate),
                                      FeatureScheduleShiftCard(
                                          startTime:
                                              shiftDate.wednShift.startTime,
                                          endTime: shiftDate.wednShift.endTime,
                                          currentIndex: 4,
                                          shiftname:
                                              shiftDate.wednShift.shiftName,
                                          sitename:
                                              shiftDate.wednShift.siteName,
                                          shiftDate: shiftDate),
                                      FeatureScheduleShiftCard(
                                          startTime:
                                              shiftDate.thurShift.startTime,
                                          endTime: shiftDate.thurShift.endTime,
                                          shiftname:
                                              shiftDate.thurShift.shiftName,
                                          sitename:
                                              shiftDate.thurShift.siteName,
                                          currentIndex: 5,
                                          shiftDate: shiftDate),
                                      FeatureScheduleShiftCard(
                                          startTime:
                                              shiftDate.friShift.startTime,
                                          endTime: shiftDate.friShift.endTime,
                                          currentIndex: 6,
                                          shiftname:
                                              shiftDate.friShift.shiftName,
                                          sitename: shiftDate.friShift.siteName,
                                          shiftDate: shiftDate),
                                    ],
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
        ));
  }
}

class FeatureScheduleShiftCard extends StatelessWidget {
  const FeatureScheduleShiftCard({
    Key key,
    @required this.shiftDate,
    this.shiftname,
    this.sitename,
    this.startTime,
    this.endTime,
    this.currentIndex,
  }) : super(key: key);

  final ShiftSheduleModel shiftDate;
  final String shiftname, sitename;
  final int currentIndex;
  final String startTime, endTime;

  @override
  Widget build(BuildContext context) {
    var daysofflist = Provider.of<DaysOffData>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          daysofflist.reallocateUsers[currentIndex].isDayOff
              ? Card(
                  child: Container(
                    width: 250.w,
                    padding: EdgeInsets.all(10),
                    child: Text("يوم عطلة",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                        textAlign: TextAlign.center),
                  ),
                )
              : Card(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              weekDays[currentIndex],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.orange[600]),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                sitename,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(
                              shiftname,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: dateDataField(
                                controller: TextEditingController(
                                    text: amPmChanger(int.parse(startTime))),
                                icon: Icons.alarm,
                                labelText: "من"),
                          ),
                          SizedBox(
                            width: 5.0.w,
                          ),
                          Expanded(
                            flex: 1,
                            child: dateDataField(
                                controller: TextEditingController(
                                    text: amPmChanger(int.parse(endTime))),
                                icon: Icons.alarm,
                                labelText: "الى"),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      )
                    ],
                  ),
                ),
          Divider()
        ],
      ),
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
    return SlideInUp(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Card(
            elevation: 5,
            child: ExpansionTile(
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
                            timeInController: _timeInController,
                            timeOutController: _timeOutController,
                            isShiftsScreen: false,
                            weekDay: "السبت",
                          ),
                          AdvancedShiftPicker(
                            isShiftsScreen: false,
                            weekDay: "الأحد",
                            timeInController: _sunTimeInController,
                            timeOutController: _sunTimeOutController,
                          ),
                          AdvancedShiftPicker(
                            isShiftsScreen: false,
                            weekDay: "الأتنين",
                            timeInController: _monTimeInController,
                            timeOutController: _monTimeOutController,
                          ),
                          AdvancedShiftPicker(
                            isShiftsScreen: false,
                            weekDay: "الثلاثاء",
                            timeInController: _tuesTimeInController,
                            timeOutController: _tuesTimeOutController,
                          ),
                          AdvancedShiftPicker(
                            isShiftsScreen: false,
                            weekDay: "الأربعاء",
                            timeInController: _wedTimeInController,
                            timeOutController: _wedTimeOutController,
                          ),
                          AdvancedShiftPicker(
                            isShiftsScreen: false,
                            weekDay: "الخميس",
                            timeInController: _thuTimeInController,
                            timeOutController: _thuTimeOutController,
                          ),
                          AdvancedShiftPicker(
                            isShiftsScreen: false,
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
      ),
    );
  }
}
