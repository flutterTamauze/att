import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class DateDataField extends StatelessWidget {
  final IconData icon;

  final String labelText;
  final TextEditingController controller;

  const DateDataField({this.icon, this.controller, this.labelText});

  Widget build(BuildContext context) {
    return Container(
      height: getkDeviceHeightFactor(context, 40),
      child: TextFormField(
        enabled: false,
        controller: controller,
        style: TextStyle(
            color: Colors.black,
            fontSize: ScreenUtil().setSp(11, allowFontScalingSelf: true),
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: const Color(0xffD7D7D7), width: 1.0.w),
          ),
          prefixIcon: Icon(
            icon,
            color: ColorManager.primary,
          ),
        ),
      ),
    );
  }
}
