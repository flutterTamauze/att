import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationDataService with ChangeNotifier {
  bool showNotificationDot = false;

  // setNotificationList(List<NotificationMessage> notifyList) {
  //   notification = notifyList;
  // }
  bool finshed = false;
  firebaseMessagingConfig(BuildContext context) async {
    finshed = false;
    FirebaseMessaging.onMessage.listen(
      (event) {
        print(event.notification.body);
        print(event.notification.title);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            Future.delayed(Duration(minutes: 1), () {
              Navigator.of(context).pop();
            });
            return Stack(
              children: [
                Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0)), //this right here
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
                                    "اثبات حضور",
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Divider(),
                                Text(
                                    "برجاء اثبات حضورك قبل انتهاء الوقت المحدد"),
                                SizedBox(
                                  height: 20.h,
                                ),
                                RoundedButton(
                                    title: "اثبات",
                                    onPressed: () {
                                      Fluttertoast.showToast(
                                          msg: "تم اثبات الحضور بنجاح",
                                          backgroundColor: Colors.green,
                                          gravity: ToastGravity.CENTER);
                                      finshed = true;
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }),
                              ],
                            ),
                          ),
                        ))),
                Positioned(
                    right: 125.w,
                    top: 200.h,
                    child: Container(
                      width: 150.w,
                      height: 150.h,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Lottie.asset("resources/notificationalarm.json",
                            fit: BoxFit.fill),
                      ),
                    ))
              ],
            );
          },
        );
      },
    );
  }
}
// Provider.of<PermissionHan>(context, listen: false)
//     .setDialogonStreambool(false);
// Provider.of<PermissionHan>(context, listen: false)
//     .setNotificationbool(true);
