// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_users/Screens/HomePage.dart';
// import 'package:qr_users/Screens/SystemScreens/ReportScreens/ReportScreen.dart';
// import 'package:qr_users/Screens/SystemScreens/SittingScreens/SettingsScreen.dart';
// import 'package:qr_users/Screens/SystemScreens/SystemHomePage.dart';
// import 'package:qr_users/services/user_data.dart';
// import 'package:qr_users/widgets/drawer.dart';
// import 'package:qr_users/widgets/headers.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../services/permissions_data.dart';

// class NavScreen extends StatefulWidget {
//   final int index;

//   NavScreen(this.index);

//   @override
//   _NavScreenState createState() => _NavScreenState(index);
// }

// class _NavScreenState extends State<NavScreen> {
//   _NavScreenState(this.getIndex);
//   final keyOne = GlobalKey();
//   final keyTwo = GlobalKey();
//   final keyThree = GlobalKey();
//   final keyFour = GlobalKey();
//   final getIndex;
//   var current = 0;
//   var x = true;

//   PageController _controller = PageController();

//   List<Widget> _screens = [
//     HomePage(),
//     SystemHomePage(),
//     ReportsScreen(),
//     SettingsScreen(),
//   ];

//   _onPageChange(int indx) {
//     print("change");
//     setState(() {
//       current = indx;
//     });
//   }

//   @override
//   void initState() {
//     current = getIndex;
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     print("entering now");
//     WidgetsBinding.instance.addPostFrameCallback(
//       (_) => ShowCaseWidget.of(context).startShowCase([
//         keyOne,
//         keyTwo,
//         keyThree,
//         keyFour,
//       ]),
//     );

//     super.didChangeDependencies();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();

//     // TODO: implement dispose
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userDataProvider = Provider.of<UserData>(context, listen: false);
//     final showWigds = Provider.of<PermissionHan>(context, listen: true);
//     return Scaffold(
//         backgroundColor: Colors.white,
//         drawer: DrawerI(),
//         bottomNavigationBar: CurvedNavigationBar(
//           color: Colors.black,
//           height: 60.h,
//           index: current,
//           backgroundColor: Colors.white,
//           onTap: (value) {
//             setState(() {
//               current = value;
//               _controller.jumpToPage(value);
//             });
//           },
//           items: userDataProvider.user.userType >= 2
//               ? userDataProvider.user.userType == 4
//                   ? [
//                       Icon(
//                         Icons.home,
//                         size:
//                             ScreenUtil().setSp(30, allowFontScalingSelf: true),
//                         color: Colors.orange,
//                       ),
//                       showWigds.showQr
//                           ? Showcase(
//                               contentPadding: EdgeInsets.all(10),
//                               showcaseBackgroundColor: Colors.orange,
//                               descTextStyle:
//                                   TextStyle(fontWeight: FontWeight.w600),
//                               key: keyTwo,
//                               child: Icon(
//                                 Icons.qr_code,
//                                 size: ScreenUtil()
//                                     .setSp(30, allowFontScalingSelf: true),
//                                 color: Colors.orange,
//                               ),
//                               title: "التسجيل بطريقة اخرى",
//                               description:
//                                   "التسجيل عن طريق مدير الموقع ببطاقة التعريف الشخصية")
//                           : Icon(
//                               Icons.qr_code,
//                               size: ScreenUtil()
//                                   .setSp(30, allowFontScalingSelf: true),
//                               color: Colors.orange,
//                             ),
//                       showWigds.showReport
//                           ? Showcase(
//                               contentPadding: EdgeInsets.all(5),
//                               showcaseBackgroundColor: Colors.orange,
//                               descTextStyle: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               key: keyThree,
//                               child: Icon(
//                                 Icons.article_sharp,
//                                 size: ScreenUtil()
//                                     .setSp(30, allowFontScalingSelf: true),
//                                 color: Colors.orange,
//                               ),
//                               description:
//                                   "تقارير الحضور و الأنصراف اليومية  للموظفين")
//                           : Icon(
//                               Icons.article_sharp,
//                               size: ScreenUtil()
//                                   .setSp(30, allowFontScalingSelf: true),
//                               color: Colors.orange,
//                             ),
//                       showWigds.showSettings
//                           ? Showcase(
//                               key: keyFour,
//                               showcaseBackgroundColor: Colors.orange,
//                               descTextStyle: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               contentPadding: EdgeInsets.all(15),
//                               child: Icon(
//                                 Icons.settings,
//                                 color: Colors.orange,
//                                 size: ScreenUtil()
//                                     .setSp(30, allowFontScalingSelf: true),
//                               ),
//                               title: "صفحة الأعدادات",
//                               description:
//                                   " ضبط اعدادات المواقع و الورديات و العطلات للموظفين")
//                           : Icon(
//                               Icons.settings,
//                               color: Colors.orange,
//                               size: ScreenUtil()
//                                   .setSp(30, allowFontScalingSelf: true),
//                             ),
//                     ]
//                   : [
//                       Icon(
//                         Icons.home,
//                         size:
//                             ScreenUtil().setSp(30, allowFontScalingSelf: true),
//                         color: Colors.orange,
//                       ),
//                       Showcase(
//                           contentPadding: EdgeInsets.all(10),
//                           showcaseBackgroundColor: Colors.orange,
//                           descTextStyle: TextStyle(fontWeight: FontWeight.w600),
//                           key: keyTwo,
//                           child: Icon(
//                             Icons.qr_code,
//                             size: ScreenUtil()
//                                 .setSp(30, allowFontScalingSelf: true),
//                             color: Colors.orange,
//                           ),
//                           title: "التسجيل بطريقة اخرى",
//                           description:
//                               "التسجيل عن طريق مدير الموقع ببطاقة التعريف الشخصية"),
//                       Showcase(
//                           contentPadding: EdgeInsets.all(5),
//                           showcaseBackgroundColor: Colors.orange,
//                           descTextStyle: TextStyle(
//                             fontWeight: FontWeight.w600,
//                           ),
//                           key: keyThree,
//                           child: Icon(
//                             Icons.article_sharp,
//                             size: ScreenUtil()
//                                 .setSp(30, allowFontScalingSelf: true),
//                             color: Colors.orange,
//                           ),
//                           description:
//                               "تقارير الحضور و الأنصراف اليومية  للموظفين"),
//                     ]
//               : [
//                   Icon(
//                     Icons.home,
//                     color: Colors.orange,
//                     size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
//                   ),
//                   Showcase(
//                       contentPadding: EdgeInsets.all(10),
//                       showcaseBackgroundColor: Colors.orange,
//                       descTextStyle: TextStyle(fontWeight: FontWeight.w600),
//                       key: keyTwo,
//                       child: Icon(
//                         Icons.qr_code,
//                         size:
//                             ScreenUtil().setSp(30, allowFontScalingSelf: true),
//                         color: Colors.orange,
//                       ),
//                       title: "التسجيل بطريقة اخرى",
//                       description:
//                           "التسجيل عن طريق مدير الموقع ببطاقة التعريف الشخصية"),
//                 ],
//         ),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Showcase(showcaseBackgroundColor: Colors.orange,
//                     contentPadding: EdgeInsets.all(10),

//                     descTextStyle: TextStyle(fontWeight: FontWeight.w600),
//                     key: keyOne,
//                     child: Header(
//                       nav: true,
//                     ),
//                     description:
//                         "من هنا يمكنك فتح القائمة و تعديل الحساب الشخصى"),
//                 Expanded(
//                   child: PageView.builder(
//                     itemBuilder: (context, index) {
//                       return _screens[current];
//                     },
//                     physics: new NeverScrollableScrollPhysics(),
//                     itemCount: _screens.length,
//                     scrollDirection: Axis.horizontal,
//                     controller: _controller,
//                     onPageChanged: _onPageChange,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ));
//   }
// }
