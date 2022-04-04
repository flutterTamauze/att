// import 'package:cron/cron.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_users/Screens/HomePage.dart';
// import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
// import 'package:qr_users/services/api.dart';

// class CroneScheduler {
//   shecdularFetching(BuildContext context) {
//     cron1 = new Cron();
//     var now = DateTime.now();
//     var formater = DateFormat("Hm");
//     int currentTime = int.parse(formater.format(now).replaceAll(":", ""));

//     // if (Provider.of<ShiftApi>(context, listen: false)
//     //     .searchForCurrentShift(currentTime)) {
//     //   shecdularFetching2(
//     //       Provider.of<ShiftApi>(context, listen: false)
//     //           .currentShift
//     //           .shiftEndTime,
//     //       context);
//     // } else {
//     //   debugPrint("cron 1: you are not in working timeline");

//     //   cron1.schedule(new Schedule.parse('*/1 * * * *'), () async {
//     //     now = DateTime.now();
//     //     formater = DateFormat("Hm");
//     //     currentTime = int.parse(formater.format(now).replaceAll(":", ""));

//     //     debugPrint(currentTime);
//     //     if (Provider.of<ShiftApi>(context, listen: false)
//     //         .searchForCurrentShift(currentTime)) {
//     //       Navigator.pushReplacement(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (context) => NavScreenTwo(1),
//     //           ));
//     //     } else {
//     //       debugPrint("cron 1: continue");
//     //     }
//     //     debugPrint('cron 1: every 1 minutes ');
//     //   });
//     // }
//   }

//   // shecdularFetching2(int endTime, BuildContext context) async {
//   //   var end = endTime % 2400;
//   //   debugPrint("crrent shift end Time = $end");
//   //   int hours = (end ~/ 100);
//   //   int min = end - (hours * 100);
//   //   cron1.close();
//   //   debugPrint("cron2: start,  working to $hours:$min");
//   //   Provider.of<ShiftApi>(context, listen: false).changeFlag(true);
//   //   cron2 = new Cron();
//   //   cron2.schedule(new Schedule.parse('$min $hours * * *'), () async {
//   //     debugPrint("cron2: end working");
//   //     shecdularFetching(context);
//   //     Provider.of<ShiftApi>(context, listen: false).changeFlag(false);
//   //     cron2.close();

//   //     Navigator.pushReplacement(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (context) => NavScreenTwo(1),
//   //         ));
//   //   });
//   // }
// }
