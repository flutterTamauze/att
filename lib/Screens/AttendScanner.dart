import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/headers.dart';
import 'Notifications/Screen/Notifications.dart';

const frontCamera = 'FRONT CAMERA';

class ScanPage extends StatefulWidget {
  const ScanPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  AudioCache player = AudioCache();
  var qrText = '';
  var ifScanned = false;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: NotificationItem(),
      body: Stack(
        children: [
          Column(
            children: <Widget>[Expanded(child: _buildQrView(context))],
          ),
          Positioned(
              child: Header(
            nav: false,
            goUserMenu: false,
            goUserHomeFromMenu: false,
          ))
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          Future.microtask(() => controller?.updateDimensions(qrKey));
          return false;
        },
        child: SizeChangedLayoutNotifier(
            key: const Key('qr-size-notifier'),
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10.w,
                cutOutSize: ScreenUtil().setSp(300, allowFontScalingSelf: true),
              ),
            )));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    bool scanned = false;
    controller.scannedDataStream.listen((scanData) async {
      qrText = scanData;
      if (!scanned) {
        scanned = true;
        secondPageRoute();
      }
    });
  }

  secondPageRoute() async {
    player.play("cap.wav");

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedLoadingIndicator();
        });
    controller?.pauseCamera();
    final msg = await Provider.of<UserData>(context, listen: false).attend(
      qrCode: qrText,
    );
    log(msg.toString());
    switch (msg) {
      case "Success : successfully registered":
        Fluttertoast.showToast(
            msg: getTranslated(context, "تم التسجيل بنجاح"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black,
            textColor: Colors.orange);
        break;
      case "Failed : You can't attend outside your company!":
        Fluttertoast.showToast(
            msg: getTranslated(context, "لا يمكنك التسجيل لشخص خارج شركتك"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "Success : already registered attend":
        Fluttertoast.showToast(
            msg: getTranslated(context, "لقد تم تسجيل الحضور من قبل"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black,
            textColor: Colors.orange);
        break;
      case "Success : already registered leave":
        Fluttertoast.showToast(
            msg: getTranslated(context, "لقد تم تسجيل الأنصراف من قبل"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black,
            textColor: Colors.orange);
        break;
      case "you can't register now during shift!":
        Fluttertoast.showToast(
            msg: getTranslated(context, "لا يمكن التسجيل بمناوبتك الأن"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black,
            textColor: Colors.orange);
        break;
      case "Sorry : You have an external mission today!":
        Fluttertoast.showToast(
            msg: getTranslated(context, "لم يتم التسجيل: لديك مأمورية خارجية"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black,
            textColor: Colors.orange);
        break;

      case "Failed : Location not found":
        Fluttertoast.showToast(
            msg: getTranslated(
              context,
              "خطأ فى التسجيل: برجاء التواجد بموقع العمل",
            ),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "Sorry : You have an holiday today!":
        Fluttertoast.showToast(
            msg: getTranslated(context, "لم يتم التسجيل : اجازة شخصية"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "Fail : You can't register leave now":
        Fluttertoast.showToast(
            msg: getTranslated(context, "لا يمكنك تسجيل الإنصراف الأن"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "Failed : Mac address not match":
        Fluttertoast.showToast(
            msg: getTranslated(context,
                "خطأ فى التسجيل: بيانات الهاتف غير صحيحة\nبرجاء التسجيل من هاتفك أو مراجعة مدير النظام"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "Fail : Using another attend method":
        Fluttertoast.showToast(
            msg: getTranslated(context,
                "خطأ فى التسجيل: برجاء التسجيل بنفس طريقة تسجيل الحضور"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "Failed : Qrcode not valid":
        Fluttertoast.showToast(
            msg: getTranslated(context, "خطأ فى التسجيل: كود غير صحيح"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "noInternet":
        Fluttertoast.showToast(
            msg: getTranslated(
                context, "خطأ فى التسجيل: لا يوجد اتصال بالانترنت"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "off":
        Fluttertoast.showToast(
            msg: getTranslated(
                context, "خطأ فى التسجيل: عدم تفعيل الموقع الجغرافى للهاتف"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "mock":
        Fluttertoast.showToast(
            msg: getTranslated(
              context,
              "خطأ فى التسجيل: برجاء التواجد بموقع العمل",
            ),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "Sorry : Today is an official vacation!":
        Fluttertoast.showToast(
            msg: getTranslated(context, "لم يتم التسجيل : عطلة رسمية"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "Success : User was not proof":
        Fluttertoast.showToast(
            msg: getTranslated(
              context,
              "خطأ فى التسجيل: لم يتم اثبات حضور المستخدم",
            ),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
        break;
      case "Failed : Out of shift time":
        Fluttertoast.showToast(
            msg: getTranslated(context, "التسجيل غير متاح الأن"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.orange,
            textColor: Colors.black);
        break;
      default:
        Fluttertoast.showToast(
            msg: getTranslated(context, "خطأ فى التسجيل"),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.black);
    }
    if (mounted) if (Provider.of<UserData>(context, listen: false)
            .user
            .userType ==
        0) {
      Navigator.of(context)
          .pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false)
          .then((value) => controller.resumeCamera());
    } else {
      Navigator.of(context)
          .pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const NavScreenTwo(0)),
              (Route<dynamic> route) => false)
          .then((value) => controller.resumeCamera());
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
