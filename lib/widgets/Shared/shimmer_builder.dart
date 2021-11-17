// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// // import 'package:shimmer/shimmer.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class ShimmerBuilder extends StatelessWidget {
//   final int listCount;
//   ShimmerBuilder(this.listCount);

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: listCount,
//       itemBuilder: (context, index) {
//         return Card(
//           elevation: 5,
//           child: Container(
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Directionality(
//                   textDirection: TextDirection.rtl,
//                   child: Row(
//                     children: [
//                       Shimmer.fromColors(
//                           child: Container(
//                             width: 64.w,
//                             height: 64.h,
//                             child: CircleAvatar(),
//                             padding: EdgeInsets.all(5),
//                           ),
//                           baseColor: Colors.grey[400],
//                           highlightColor: Colors.grey[300]),
//                       Container(
//                         child: Shimmer.fromColors(
//                             child: Container(
//                               height: 40.h,
//                               width: 200,
//                               child: SizedBox(
//                                 child: Text("جارى التحميل"),
//                               ),
//                               padding: EdgeInsets.only(top: 10.h, right: 5.w),
//                             ),
//                             baseColor: Colors.grey[400],
//                             highlightColor: Colors.grey[300]),
//                       )
//                     ],
//                   )),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
