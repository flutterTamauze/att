import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUsersOrders.dart';
import 'package:qr_users/services/AttendProof/attend_proof.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class StackedNotificaitonAlert extends StatefulWidget {
  bool isAdmin;
  bool popWidget = false, isFromBackground = false;
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
      this.isAdmin,
      @required this.showToast,
      this.popWidget,
      @required this.repeatAnimation,
      this.notificationToast,
      this.isFromBackground,
      this.roundedButtonTitle});

  @override
  _StackedNotificaitonAlertState createState() =>
      _StackedNotificaitonAlertState();
}

class _StackedNotificaitonAlertState extends State<StackedNotificaitonAlert> {
  AttendProof attendObj = AttendProof();
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData>(context, listen: false).user;

    return Stack(
      children: [
        Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)), //this right here
            child: Container(
              height: 200.h,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40.h,
                    ),
                    InkWell(
                      onTap: () async {},
                      child: AutoSizeText(
                        widget.notificationTitle,
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: setResponsiveFontSize(15),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Divider(),
                    AutoSizeText(widget.notificationContent),
                    SizedBox(
                      height: 20.h,
                    ),
                    isloading
                        ? const Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.orange,
                            ),
                          )
                        : RoundedButton(
                            title: widget.roundedButtonTitle,
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              if (widget.showToast) {
                                setState(() {
                                  isloading = true;
                                });
                                int attendId = await attendObj.getAttendProofID(
                                    user.id, user.userToken);
                                print(attendId);
                                Position currentPosition =
                                    await Geolocator.getCurrentPosition(
                                        desiredAccuracy: LocationAccuracy.best);

                                final String msg =
                                    await attendObj.acceptAttendProof(
                                        user.userToken,
                                        attendId.toString(),
                                        currentPosition);
                                setState(() {
                                  isloading = false;
                                });
                                prefs.setString("notifCategory", "");
                                if (msg == "timeout") {
                                  Fluttertoast.showToast(
                                      msg: getTranslated(context,
                                          "لم يتم اثبات الحضور انتهى وقت التسجيل"),
                                      backgroundColor: Colors.red,
                                      gravity: ToastGravity.CENTER);
                                } else if (msg == "wrong location") {
                                  Fluttertoast.showToast(
                                      msg: getTranslated(context,
                                          "لم يتم اثبات الحضور : خارج موقع العمل"),
                                      backgroundColor: Colors.red,
                                      gravity: ToastGravity.CENTER);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: widget.notificationToast,
                                      backgroundColor: Colors.green,
                                      gravity: ToastGravity.CENTER);
                                }
                                if (user.userType != 0 &&
                                    !widget.isFromBackground) {
                                  print("not user not back ground");
                                  Navigator.pop(context);
                                } else {
                                  print("normal user");
                                  if (!widget.isFromBackground) {
                                    Navigator.pop(context);
                                  }
                                }
                                Provider.of<PermissionHan>(context,
                                        listen: false)
                                    .setAttendProoftoDefault();

                                if (widget.popWidget) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              } else {
                                if (!widget.isAdmin) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserOrdersView(
                                          selectedOrder: widget
                                                      .notificationTitle
                                                      .contains("الأذن") ||
                                                  widget.notificationTitle
                                                      .contains("Perm")
                                              ? getTranslated(
                                                  context, "الأذونات")
                                              : getTranslated(
                                                  context, "الأجازات"),
                                          ordersList: [
                                            getTranslated(context, "الأجازات"),
                                            getTranslated(context, "الأذونات")
                                          ],
                                        ),
                                      ));
                                } else {
                                  Navigator.pop(context);
                                }
                              }
                            }),
                  ],
                ),
              ),
            )),
        Positioned(
            right: 125.w,
            top: widget.popWidget
                ? MediaQuery.of(context).size.height / 3.5
                : 180.h,
            child: Container(
              width: 150.w,
              height: 150.h,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Lottie.asset(widget.lottieAsset,
                    fit: BoxFit.fill, repeat: widget.repeatAnimation),
              ),
            ))
      ],
    );
  }
}
