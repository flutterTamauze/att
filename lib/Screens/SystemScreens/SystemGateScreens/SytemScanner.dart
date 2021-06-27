import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';

const frontCamera = 'FRONT CAMERA';

class SystemScanPage extends StatefulWidget {
  final path;
  const SystemScanPage({
    Key key,
    this.path,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SystemScanPageState();
}

class _SystemScanPageState extends State<SystemScanPage> {
  var qrText = '';
  AudioCache player = AudioCache();

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(flex: 1, child: _buildQrView(context)),
            ],
          ),
          Positioned(
            left: 4.0,
            top: 4.0,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Color(0xffF89A41),
                  size: 40,
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => NavScreenTwo(1)),
                      (Route<dynamic> route) => false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    if (controller != null) {
      controller.flipCamera();
    }
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
            borderWidth: 10,
            cutOutSize: 300,
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    bool isScanned = false;
    controller.flipCamera();
    controller.scannedDataStream.listen((scanData) async {
      qrText = scanData;
      if (!isScanned) {
        isScanned = true;
        secondPageRoute();
      }
    });
  }

  secondPageRoute() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedLoadingIndicator();
        });
    print(qrText);
    print(widget.path);
    player.play("cap.wav");

    //  WidgetsFlutterBinding.ensureInitialized();

    var shiftQrCode =
        Provider.of<ShiftApi>(context, listen: false).currentShift.shiftQrCode;
    var msg = await Provider.of<UserData>(context, listen: false).attendByCard(
        qrCode: shiftQrCode, cardCode: qrText, image: File(widget.path));
    print(msg);

    if (msg == "Success : successfully registered") {
      Fluttertoast.showToast(
          msg: "تم التسجيل بنجاح",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black,
          textColor: Colors.orange);
    } else if (msg == "noInternet") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: لا يوجد اتصال بالانترنت",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "off") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: عدم تفعيل الموقع الجغرافى للهاتف",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "mock") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: برجاء التواجد بموقع العمل",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg ==
        "Failed : Invaild Qrcode Index was outside the bounds of the array.") {
      await Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: كود غير صحيح",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "Fail : Using another attend method") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: برجاء التسجيل بنفس طريقة تسجيل الحضور",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "Failed : Mac address not match") {
      //Error while saving Data : Object reference not set to an instance of an object.
      Fluttertoast.showToast(
          msg:
              "خطأ فى التسجيل: بيانات الهاتف غير صحيحة\nبرجاء التسجيل من هاتفك أو مراجعة مدير النظام",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "Failed : Location not found") {
      await Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: برجاء التواجد بموقع العمل",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "Failed : User Id not valid") {
      await Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: كود غير صحيح",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else {
      await Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: برجاء إعادة المحاولة",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NavScreenTwo(1)),
        (Route<dynamic> route) => false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
