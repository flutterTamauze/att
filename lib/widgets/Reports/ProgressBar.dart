import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProgressBar extends StatelessWidget {
  final int percent;
  final int maxValue;
  final int maxPercent;

  const ProgressBar(this.percent, this.maxValue, this.maxPercent);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 50),
      child: Column(
        children: [
          Container(
            width: 400.w,
            height: 300.h,
            child: Lottie.asset("resources/kiteLoader.json"),
          ),
          AutoSizeText(
            percent > maxPercent
                ? getTranslated(context, "على وشك الأنتهاء ")
                : getTranslated(context, "برجاء الأنتظار"),
            style: TextStyle(
                fontSize: setResponsiveFontSize(17),
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 30.h,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FAProgressBar(
                currentValue: (percent),
                backgroundColor: Colors.grey[200],
                maxValue: (maxValue),
                progressColor: ColorManager.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
