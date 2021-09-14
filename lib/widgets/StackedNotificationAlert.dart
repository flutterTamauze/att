import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUsersOrders.dart';
import 'package:qr_users/services/AttendProof/attend_proof.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class StackedNotificaitonAlert extends StatefulWidget {
  bool isAdmin;
  bool popWidget = false;
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
    var user = Provider.of<UserData>(context, listen: false).user;

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
                          onTap: () async {},
                          child: Text(
                            widget.notificationTitle,
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Divider(),
                        Text(widget.notificationContent),
                        SizedBox(
                          height: 20.h,
                        ),
                        isloading
                            ? Center(
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
                                    int attendId =
                                        await attendObj.getAttendProofID(
                                            user.id, user.userToken);
                                    print(attendId);
                                    Position currentPosition =
                                        await Geolocator.getCurrentPosition(
                                            desiredAccuracy:
                                                LocationAccuracy.best);

                                    String msg =
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
                                          msg:
                                              "لم يتم اثبات الحضور انتهى وقت التسجيل",
                                          backgroundColor: Colors.red,
                                          gravity: ToastGravity.CENTER);
                                    } else if (msg == "wrong location") {
                                      Fluttertoast.showToast(
                                          msg:
                                              "لم يتم اثبات الحضور : خارج موقع العمل",
                                          backgroundColor: Colors.red,
                                          gravity: ToastGravity.CENTER);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: widget.notificationToast,
                                          backgroundColor: Colors.green,
                                          gravity: ToastGravity.CENTER);
                                    }

                                    Provider.of<PermissionHan>(context,
                                            listen: false)
                                        .setAttendProoftoDefault();

                                    if (widget.popWidget) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    } else {}
                                  } else {
                                    Navigator.pop(context);
                                    if (!widget.isAdmin) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserOrdersView(
                                                    selectedOrder: widget
                                                            .notificationTitle
                                                            .contains("الأذن")
                                                        ? "الأذونات"
                                                        : "الأجازات"),
                                          ));
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  }
                                }),
                      ],
                    ),
                  ),
                ))),
        Positioned(
            right: 125.w,
            top: widget.popWidget ? 170.h : 180.h,
            child: Container(
              width: 150.w,
              height: 150.h,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle),
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
