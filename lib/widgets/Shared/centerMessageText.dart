import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:qr_users/Core/constants.dart';

class CenterMessageText extends StatelessWidget {
  const CenterMessageText({
    @required this.message,
    Key key,
  }) : super(
          key: key,
        );

  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 20,
        child: AutoSizeText(
          message,
          maxLines: 1,
          style: boldStyle.copyWith(fontSize: setResponsiveFontSize(17)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
