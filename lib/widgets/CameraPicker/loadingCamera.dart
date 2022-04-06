import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingCamera extends StatelessWidget {
  const LoadingCamera({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90.w,
          height: 90.h,
          child: Lottie.asset(
            "resources/loadingCamera.json",
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        AutoSizeText(
          getTranslated(context, "برجاء الأنتظار"),
          style: boldStyle,
        )
      ],
    ));
  }
}
