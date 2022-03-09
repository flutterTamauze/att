// import 'package:flutter/cupertino.dart';
// import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
// import 'package:qr_users/Screens/SystemScreens/ReportScreens/RadioButtonWidget.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class HolidayTypeRadioButton extends StatefulWidget {
//   @override
//   State<HolidayTypeRadioButton> createState() => _HolidayTypeRadioButtonState();
//   int radioVal;
//   Function callBackFun;
//   HolidayTypeRadioButton(this.radioVal, this.callBackFun);
// }

// class _HolidayTypeRadioButtonState extends State<HolidayTypeRadioButton> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(right: 20.w),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           RadioButtonWidg(
//             radioVal2: widget.radioVal,
//             radioVal: 3,
//             title: getTranslated(context, "أذن"),
//             onchannge: (value) {
//               widget.callBackFun(value);
//             },
//           ),
//           RadioButtonWidg(
//             radioVal2: widget.radioVal,
//             radioVal: 1,
//             title: getTranslated(context, "اجازة"),
//             onchannge: (value) {
//               widget.callBackFun(value);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
