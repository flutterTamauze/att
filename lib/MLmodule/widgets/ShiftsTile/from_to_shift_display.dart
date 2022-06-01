import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'date_data_field.dart';

class FromToShiftDisplay extends StatelessWidget {
  const FromToShiftDisplay(
      {Key key, @required this.start, @required this.end, this.weekDay})
      : super(key: key);

  final String start;
  final String weekDay;
  final String end;

  @override
  Widget build(BuildContext context) {
    return SlideInUp(
      child: Column(
        children: [
          Container(
            width: 500.w,
            child: AutoSizeText(
              getTranslated(context, weekDay),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: DateDataField(
                    controller: TextEditingController(text: start),
                    icon: Icons.alarm,
                    labelText: getTranslated(context, "من")),
              ),
              SizedBox(
                width: 5.0.w,
              ),
              Expanded(
                flex: 1,
                child: DateDataField(
                    controller: TextEditingController(text: end),
                    icon: Icons.alarm,
                    labelText: getTranslated(context, "إلى")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
