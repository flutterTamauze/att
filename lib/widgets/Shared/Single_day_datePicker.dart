import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants.dart';

class SingleDayDatePicker extends StatelessWidget {
  final String selectedDateString;
  final Function functionPicker;
  final DateTime firstDate, lastDate;
  SingleDayDatePicker(
      {this.functionPicker,
      this.selectedDateString,
      this.firstDate,
      this.lastDate});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      child: DateTimePicker(
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w500, fontSize: 13),
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
            prefixIcon: Icon(
              Icons.access_time,
              color: Colors.orange,
            )),
      ),
    );
  }
}
