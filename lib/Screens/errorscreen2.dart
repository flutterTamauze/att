import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/enums/connectivity_status.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_data.dart';
import '../widgets/drawer.dart';
import '../widgets/headers.dart';

class ErrorScreen2 extends StatelessWidget {
  final Widget child;
  ErrorScreen2({this.child});
  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus == ConnectivityStatus.Wifi ||
        connectionStatus == ConnectivityStatus.Cellular) {
      print(connectionStatus);
      return child;
    }
    var userData = Provider.of<UserData>(context);
    return GestureDetector(
      onTap: () => print(userData.cachedUserData.isNotEmpty),
      child: Scaffold(
        drawer: DrawerI(),
        body: Column(
          children: [
            NewHeader(userData.cachedUserData),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Lottie.asset(
                          "resources/21485-wifi-outline-icon.json",
                          repeat: false),
                      height: 200.h,
                      width: 200.w,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Column(
                      children: [
                        Container(
                          height: 20,
                          child: AutoSizeText(
                            "لا يوجد اتصال بالأنترنت",
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(18, allowFontScalingSelf: true),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Container(
                          height: 20.h,
                          child: AutoSizeText(
                            "برجاء المحاولة مرة اخرى ",
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(14, allowFontScalingSelf: true),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 40.h,
                        ),
                        userData.isLoading
                            ? CircularProgressIndicator()
                            : Container()
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
