import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

class DisplayReportButton extends StatelessWidget {
  const DisplayReportButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AutoSizeText(
          getTranslated(context, "عرض التقرير"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(width: 2, height: 80.h, color: ColorManager.primary),
        const Icon(FontAwesomeIcons.fileAlt)
      ],
    );
  }
}
