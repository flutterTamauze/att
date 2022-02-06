// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:qr_users/Core/colorManager.dart';
// import 'dart:ui' as ui;

// import 'package:qr_users/widgets/Reports/DailyReport/dailyReportTableHeader.dart';

// class DataTableMissionsHeader extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: ui.TextDirection.rtl,
//       child: Container(
//           child: Row(
//         children: [
//           DataTableHeaderTitles("النوع", ColorManager.primary),
//           DataTableHeaderTitles("من", ColorManager.primary),
//           DataTableHeaderTitles("الى", ColorManager.primary),
//           Container(
//             height: 50.h,
//           ),
//         ],
//       )),
//     );
//   }
// }

// class SingleUserMissionHeader extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: ui.TextDirection.rtl,
//       child: Container(
//           height: 50.h,
//           decoration: const BoxDecoration(
//               color: Colors.orange,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(15),
//                 topRight: Radius.circular(15),
//               )),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 DataTableHeaderTitles("النوع", Colors.black),
//                 DataTableHeaderTitles("من", Colors.black),
//                 DataTableHeaderTitles("الى", Colors.black),
//               ],
//             ),
//           )),
//     );
//   }
// }
