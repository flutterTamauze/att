import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/permissions_data.dart';

class MaintenanceWidget extends StatelessWidget {
  const MaintenanceWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300.w,
            height: 300.h,
            child: Lottie.asset("resources/maintenance.json"),
          ),
          Center(
              child: AutoSizeText(
            getTranslated(context,
                "التطبيق تحت الصيانة \n  برجاء اعادة المحاولة فى وقت لاحق"),
            style: boldStyle,
            textAlign: TextAlign.center,
          )),
        ],
      ),
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300.w,
            height: 270.h,
            child: Lottie.asset("resources/noNetwork.json"),
          ),
          Center(
              child: AutoSizeText(
            getTranslated(context,
                "لا يوجد اتصال بالأنترنت \n  برجاء اعادة المحاولة مرة اخرى"),
            style: boldStyle,
            textAlign: TextAlign.center,
          )),
        ],
      ),
    );
  }
}

class HandleExceptionsView extends StatelessWidget {
  final Widget noErrorWidget;
  const HandleExceptionsView(this.noErrorWidget);
  @override
  Widget build(BuildContext context) {
    return Provider.of<PermissionHan>(context, listen: false).isServerDown
        ? const MaintenanceWidget()
        : !Provider.of<PermissionHan>(context, listen: false)
                .isInternetConnected
            ? const NoInternetWidget()
            : noErrorWidget;
  }
}
