


// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import "dart:ui" as ui;

// ///----Bottom Sheet details----
// class DetailsRow extends StatelessWidget {
//   final String title;
//   final String url;
//   final Widget icon;

//   DetailsRow({
//     this.title,
//     this.url,
//     this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         launch(url);
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 10),
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.black,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 icon,
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Expanded(
//                   child: Container(
//                     child: Directionality(
//                       textDirection: ui.TextDirection.rtl,
//                       child: Text(
//                         title,
//                         style: TextStyle(color: Colors.orange, fontSize: 18),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             )),
//       ),
//     );
//   }
// }
