import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/user_data.dart';

import '../../Core/constants.dart';

class SingleDayDatePicker extends StatelessWidget {
  final String selectedDateString;
  final Function functionPicker;
  final DateTime firstDate, lastDate;
  const SingleDayDatePicker(
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
            height: 2.5,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: setResponsiveFontSize(13)),
        initialValue: selectedDateString,
        onChanged: (value) {
          functionPicker(value);
        },
        type: DateTimePickerType.date,
        firstDate: firstDate,
        lastDate: lastDate,
        textAlign: TextAlign.right,
        decoration: kTextFieldDecorationTime.copyWith(
            hintStyle: TextStyle(
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            hintText: 'اليوم',
            prefixIcon: const Icon(
              Icons.access_time,
              color: Colors.orange,
            )),
      ),
    );
  }
}
