import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/constants.dart';

class AssignTaskToUser extends StatelessWidget {
  final String taskName;
  final IconData iconData;
  final Function function;
  AssignTaskToUser({
    this.iconData,
    this.function,
    this.taskName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: InkWell(
        onTap: function,
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                taskName,
                style: TextStyle(
                    height: 1.5.h, fontSize: setResponsiveFontSize(13)),
              ),
              Container(
                width: 25.w,
                height: 35.h,
                child: Icon(
                  iconData,
                  color: Colors.orange,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
