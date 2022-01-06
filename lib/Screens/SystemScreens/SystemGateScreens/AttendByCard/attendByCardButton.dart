import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/SytemScanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendByCardButton extends StatelessWidget {
  const AttendByCardButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SystemScanPage(),
          )),
      child: Container(
        padding: EdgeInsets.all(10),
        width: 330.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1, color: Colors.orange[600])),
        child: Center(
          child: Container(
            height: 20,
            child: AutoSizeText(
              getTranslated(context, "التسجيل ببطاقة التعريف الشخصية"),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(18, allowFontScalingSelf: true),
                  color: Colors.orange[600]),
            ),
          ),
        ),
      ),
    );
  }
}
