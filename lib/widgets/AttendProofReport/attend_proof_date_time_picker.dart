import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/user_data.dart';

import '../../Core/constants.dart';

class AttendProofDatePicker extends StatelessWidget {
  final String selectedDateString;
  final Function functionPicker;
  final DateTime firstDate, lastDate;
  const AttendProofDatePicker(
      {this.functionPicker,
      this.selectedDateString,
      this.firstDate,
      this.lastDate});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Provider.of<UserData>(context, listen: false).user.userType == 2
          ? 300.w
          : 200.w,
      child: DateTimePicker(
        style: TextStyle(
            color: Colors.black,
            height: 2.97.h,
            fontWeight: FontWeight.w500,
            fontSize: setResponsiveFontSize(13)),
        initialValue: selectedDateString,
        onChanged: (value) {
          functionPicker(value);
        },
        type: DateTimePickerType.date,
        firstDate: firstDate,
        lastDate: lastDate,
        decoration: kTextFieldDecorationTime.copyWith(
            hintStyle: TextStyle(
                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1),
            contentPadding: EdgeInsets.only(top: 20.h),
            hintText: getTranslated(context, 'اليوم'),
            suffixIcon: Padding(
              padding: EdgeInsets.only(top: 30.h),
              child: const Icon(
                Icons.access_time,
                color: Colors.orange,
              ),
            )),
      ),
    );
  }
}
