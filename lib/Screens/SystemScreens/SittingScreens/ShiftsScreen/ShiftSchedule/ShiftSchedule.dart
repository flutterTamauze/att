// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/screen_util.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_users/Screens/Notifications/Notifications.dart';
// import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftSchedule/ReallocateUsers.dart';
// import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/CameraPickerScreen.dart';
// import 'package:qr_users/services/DaysOff.dart';
// import 'package:qr_users/services/MemberData.dart';
// import 'package:qr_users/services/Shift.dart';
// import 'package:qr_users/services/ShiftSchedule/ShiftScheduleModel.dart';
// import 'package:qr_users/services/ShiftsData.dart';
// import 'package:qr_users/services/Sites_data.dart';
// import 'package:qr_users/services/company.dart';
// import 'package:qr_users/services/user_data.dart';
// import 'package:qr_users/widgets/DirectoriesHeader.dart';
// import 'package:qr_users/widgets/headers.dart';
// import 'dart:ui' as ui;
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:qr_users/widgets/roundedAlert.dart';
// import 'package:qr_users/widgets/roundedButton.dart';

// class ShiftScheduleScreen extends StatefulWidget {
//   final Member member;
//   final int siteIndex;
//   final bool isEdit;
//   ShiftScheduleScreen({@required this.member, this.siteIndex, this.isEdit});
//   @override
//   _ShiftScheduleScreenState createState() => _ShiftScheduleScreenState();
// }

// class _ShiftScheduleScreenState extends State<ShiftScheduleScreen> {
//   Future getSchedules;
//   fillSchedules() async {
//     var userProvider = Provider.of<UserData>(context, listen: false);
//     debugPrint(widget.member.id);
//     getSchedules = Provider.of<ShiftsData>(context, listen: false)
//         .isShiftScheduleByIdEmpty(
//             userProvider.user.userToken, widget.member.id, context);
//   }

//   @override
//   void initState() {
//     fillSchedules();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var scheduleList =
//         Provider.of<ShiftsData>(context, listen: true).shiftScheduleList;
//     return Scaffold(
//       endDrawer: NotificationItem(),
//       backgroundColor: Colors.white,
//       floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
//       floatingActionButton:
//           Provider.of<UserData>(context, listen: false).user.userType == 2
//               ? Container()
//               : FloatingActionButton(
//                   elevation: 3,
//                   tooltip: "اضافة جدولة مناوبة",
//                   backgroundColor: Colors.orange[600],
//                   onPressed: () async {
//                     showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return RoundedLoadingIndicator();
//                         });
//                     var userProvider =
//                         Provider.of<UserData>(context, listen: false);

//                     var comProvider =
//                         Provider.of<CompanyData>(context, listen: false);
//                     await Provider.of<DaysOffData>(context, listen: false)
//                         .getDaysOff(comProvider.com.id,
//                             userProvider.user.userToken, context);
//                     await Provider.of<SiteData>(context, listen: false)
//                         .setDropDownShift(0);
//                     await Provider.of<SiteData>(context, listen: false)
//                         .setDropDownIndex(0);
//                     await Provider.of<ShiftsData>(context, listen: false)
//                         .findMatchingShifts(
//                             Provider.of<SiteData>(context, listen: false)
//                                 .sitesList[Provider.of<SiteData>(context,
//                                         listen: false)
//                                     .dropDownSitesIndex]
//                                 .id,
//                             false);
//                     shiftScheduling();
//                   },
//                   child: Icon(
//                     Icons.add,
//                     color: Colors.black,
//                     size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
//                   ),
//                 ),
//       body: Container(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Header(
//               nav: false,
//               goUserHomeFromMenu: false,
//               goUserMenu: false,
//             ),
//             Directionality(
//               textDirection: ui.TextDirection.rtl,
//               child: SmallDirectoriesHeader(
//                   Lottie.asset("resources/shiftLottie.json", repeat: false),
//                   "جدولة المناوبات"),
//             ),
//             FutureBuilder(
//               future: getSchedules,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Expanded(
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         backgroundColor: Colors.orange,
//                       ),
//                     ),
//                   );
//                 }
//                 if (snapshot.hasData) {
//                   if (scheduleList.isEmpty) {
//                     return Expanded(
//                       child: Center(
//                         child: Text(
//                           "لا يوجد جدولة مناوبات لهذا المستخدم",
//                           style: TextStyle(
//                               fontSize: 15, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     );
//                   } else {
//                     return Expanded(
//                         child: ListView.builder(
//                       itemCount: scheduleList.length,
//                       itemBuilder: (context, index) {
//                         return ShiftScheduleCard(
//                           scheduleList: scheduleList,
//                           fromTimee: scheduleList[index].scheduleFromTime,
//                           endTimee: scheduleList[index].scheduleToTime,
//                           currentIndex: index,
//                           member: widget.member,
//                         );
//                       },
//                     ));
//                   }
//                 }
//                 return Container();
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   shiftScheduling() async {
//     var userProvider = Provider.of<UserData>(context, listen: false);
//     var comProvider = Provider.of<CompanyData>(context, listen: false);
//     String shiftName = getShiftName();

//     await Provider.of<DaysOffData>(context, listen: false)
//         .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
//     for (int i = 0; i < 7; i++) {
//       await Provider.of<DaysOffData>(context, listen: false).setSiteAndShift(
//           i,
//           Provider.of<SiteData>(context, listen: false)
//               .sitesList[widget.siteIndex]
//               .name,
//           shiftName,
//           getShiftid(shiftName),
//           getsiteIDbyShiftId(widget.member.shiftId));
//     }
//     Navigator.pop(context);

//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               ReAllocateUsers(widget.member, false, 0, [], []),
//         )).then((value) => setState(() {
//           fillSchedules();
//         }));
//   }

//   int getShiftid(String shiftName) {
//     var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;

//     List<Shift> currentShift =
//         list.where((element) => element.shiftName == shiftName).toList();

//     return currentShift[0].shiftId;
//   }

//   int getsiteIDbyShiftId(int shiftId) {
//     var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
//     List<Shift> currentSite =
//         list.where((element) => element.shiftId == shiftId).toList();
//     debugPrint(currentSite[0].siteID);
//     return currentSite[0].siteID;
//   }

//   int getSiteID(String siteName) {
//     var list = Provider.of<SiteData>(context, listen: false).sitesList;

//     List<Site> currentShift =
//         list.where((element) => element.name == siteName).toList();

//     return currentShift[0].id;
//   }

//   String getShiftName() {
//     var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;

//     List<Shift> findShift;
//     findShift = list
//         .where((element) => element.shiftId == widget.member.shiftId)
//         .toList();

//     return findShift[0].shiftName;
//   }
// }

// class ShiftScheduleCard extends StatefulWidget {
//   ShiftScheduleCard(
//       {@required this.scheduleList,
//       this.endTimee,
//       this.fromTimee,
//       this.currentIndex,
//       this.member});
//   final DateTime fromTimee, endTimee;
//   final int currentIndex;
//   final List<ShiftSheduleModel> scheduleList;
//   final Member member;
//   @override
//   _ShiftScheduleCardState createState() => _ShiftScheduleCardState();
// }

// class _ShiftScheduleCardState extends State<ShiftScheduleCard> {
//   String getShiftNameById(
//     int id,
//   ) {
//     debugPrint("current id");
//     var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
//     int index = list.length;
//     for (int i = 0; i < index; i++) {
//       if (list[i].shiftId == id) {
//         return list[i].shiftName;
//       }
//     }
//     return "";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//         elevation: 3,
//         child: Directionality(
//           textDirection: ui.TextDirection.rtl,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             child: Container(
//               width: double.infinity.w,
//               height: 60.h,
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today_rounded,
//                     size: ScreenUtil().setSp(35, allowFontScalingSelf: true),
//                     color: Colors.orange,
//                   ),
//                   SizedBox(
//                     width: 20.w,
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Container(
//                       height: 20,
//                       child: AutoSizeText(
//                         "من  ${widget.fromTimee}",
//                         maxLines: 1,
//                         style: TextStyle(
//                             fontSize: ScreenUtil()
//                                 .setSp(16, allowFontScalingSelf: true),
//                             fontWeight: FontWeight.w600),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Container(
//                       height: 20,
//                       child: AutoSizeText(
//                         "الى  ${widget.endTimee}",
//                         maxLines: 1,
//                         style: TextStyle(
//                             fontSize: ScreenUtil()
//                                 .setSp(16, allowFontScalingSelf: true),
//                             fontWeight: FontWeight.w600),
//                         textAlign: TextAlign.left,
//                       ),
//                     ),
//                   ),
//                   Expanded(child: Container()),
//                   Provider.of<UserData>(context, listen: false).user.userType ==
//                           2
//                       ? Container()
//                       : InkWell(
//                           onTap: () async {
//                             var userProvider =
//                                 Provider.of<UserData>(context, listen: false);
//                             var comProvider = Provider.of<CompanyData>(context,
//                                 listen: false);
//                             if (Provider.of<DaysOffData>(context, listen: false)
//                                 .reallocateUsers
//                                 .isEmpty) {
//                               await Provider.of<DaysOffData>(context,
//                                       listen: false)
//                                   .getDaysOff(comProvider.com.id,
//                                       userProvider.user.userToken, context);
//                             }

//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ReAllocateUsers(
//                                       widget.member, true, widget.currentIndex),
//                                 ));
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                     color: Colors.orange[600], width: 2)),
//                             child: FaIcon(Icons.edit,
//                                 size: 25, color: Colors.orange),
//                           ),
//                         ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   Provider.of<UserData>(context, listen: false).user.userType ==
//                           2
//                       ? Container()
//                       : InkWell(
//                           onTap: () async {
//                             debugPrint(widget.currentIndex);
//                             debugPrint(widget.scheduleList[widget.currentIndex].id);
//                             return showDialog(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return Provider.of<ShiftsData>(context,
//                                               listen: true)
//                                           .isLoading
//                                       ? Center(
//                                           child: CircularProgressIndicator(
//                                             backgroundColor: Colors.orange,
//                                           ),
//                                         )
//                                       : RoundedAlert(
//                                           onPressed: () async {
//                                             String msg =
//                                                 await Provider.of<ShiftsData>(
//                                                         context,
//                                                         listen: false)
//                                                     .deleteShiftScheduleById(
//                                                         widget
//                                                             .scheduleList[widget
//                                                                 .currentIndex]
//                                                             .id,
//                                                         Provider.of<UserData>(
//                                                                 context,
//                                                                 listen: false)
//                                                             .user
//                                                             .userToken,
//                                                         widget.currentIndex);
//                                             if (msg == "Success") {
//                                               Fluttertoast.showToast(
//                                                   msg: "تم حذف  الجدولة بنجاح",
//                                                   backgroundColor: Colors.green,
//                                                   gravity: ToastGravity.CENTER);
//                                             }
//                                             Navigator.pop(context);
//                                           },
//                                           title: 'ازالة جدولة ',
//                                           content:
//                                               "هل تريد ازالة هذه الجدولة ؟");
//                                 });
//                           },
//                           child: Container(
//                             child: FaIcon(FontAwesomeIcons.timesCircle,
//                                 size: 30, color: Colors.red),
//                           )),
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }
// }

// class ScheduleWeekDayInfo extends StatefulWidget {
//   final List<ShiftSheduleModel> schudleList;
//   final String dayName;
//   final int currentIndex, scheduleShiftsNumber;
//   ScheduleWeekDayInfo(
//       {this.schudleList,
//       this.dayName,
//       this.currentIndex,
//       this.scheduleShiftsNumber});
//   @override
//   _ScheduleWeekDayInfoState createState() => _ScheduleWeekDayInfoState();
// }

// class _ScheduleWeekDayInfoState extends State<ScheduleWeekDayInfo> {
//   String getShiftNameById(
//     int id,
//   ) {
//     var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
//     List<Shift> currentShift =
//         list.where((element) => element.shiftId == id).toList();

//     return currentShift[0].shiftName;
//   }

//   String getSiteNameById(
//     int id,
//   ) {
//     var list = Provider.of<SiteData>(context, listen: false).sitesList;
//     List<Site> currentShift =
//         list.where((element) => element.id == id).toList();

//     return currentShift[0].name;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 10.w),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(widget.dayName,
//                   style: TextStyle(fontWeight: FontWeight.w800),
//                   textAlign: TextAlign.right),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: Text(
//                   getShiftNameById(
//                     widget.schudleList[widget.currentIndex]
//                         .scheduleShiftsNumber[widget.scheduleShiftsNumber],
//                   ),
//                   style: TextStyle(
//                     fontWeight: FontWeight.w800,
//                   ),
//                   textAlign: TextAlign.left),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
