import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUsersOrders.dart';
import 'package:qr_users/widgets/roundedButton.dart';

// ignore: must_be_immutable
class StackedNotificaitonAlert extends StatelessWidget {
  final String notificationTitle,
      notificationContent,
      notificationToast,
      roundedButtonTitle,
      lottieAsset;
  bool showToast = true, repeatAnimation;
  StackedNotificaitonAlert(
      {this.notificationContent,
      this.notificationTitle,
      this.lottieAsset,
      @required this.showToast,
      @required this.repeatAnimation,
      this.notificationToast,
      this.roundedButtonTitle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)), //this right here
            child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: Container(
                  height: 200.h,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50.h,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            notificationTitle,
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Divider(),
                        Text(notificationContent),
                        SizedBox(
                          height: 20.h,
                        ),
                        RoundedButton(
                            title: roundedButtonTitle,
                            onPressed: () {
                              if (showToast) {
                                Fluttertoast.showToast(
                                    msg: notificationToast,
                                    backgroundColor: Colors.green,
                                    gravity: ToastGravity.CENTER);

                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserOrdersView(),
                                    ));
                              }
                            }),
                      ],
                    ),
                  ),
                ))),
        Positioned(
            right: 125.w,
            top: 225.h,
            child: Container(
              width: 150.w,
              height: 150.h,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Lottie.asset(lottieAsset,
                    fit: BoxFit.fill, repeat: repeatAnimation),
              ),
            ))
      ],
    );
  }
}
