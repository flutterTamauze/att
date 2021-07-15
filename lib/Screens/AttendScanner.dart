import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/headers.dart';

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
      body: Stack(
        children: [
          Column(
            children: <Widget>[Expanded(child: _buildQrView(context))],
          ),
          Positioned(
              child: Header(
            nav: false,
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
    if (msg == "Success : successfully registered") {
      Fluttertoast.showToast(
          msg: "تم التسجيل بنجاح",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.black,
          textColor: Colors.orange);
    } else if (msg == "Failed : Qrcode not valid") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: كود غير صحيح",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "Failed : Location not found") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: برجاء التواجد بموقع العمل",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "Failed : Mac address not match") {
      Fluttertoast.showToast(
          msg:
              "خطأ فى التسجيل: بيانات الهاتف غير صحيحة\nبرجاء التسجيل من هاتفك أو مراجعة مدير النظام",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "Fail : Using another attend method") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: برجاء التسجيل بنفس طريقة تسجيل الحضور",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else if (msg == "noInternet") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: لا يوجد اتصال بالانترنت",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          textColor: Colors.black);
    } else if (msg == "off") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: عدم تفعيل الموقع الجغرافى للهاتف",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          textColor: Colors.black);
    } else if (msg == "mock") {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل: برجاء التواجد بموقع العمل",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    } else {
      Fluttertoast.showToast(
          msg: "خطأ فى التسجيل",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.black);
    }
    if (Provider.of<UserData>(context, listen: false).user.userType == 0) {
      Navigator.of(context)
          .pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false)
          .then((value) => controller.resumeCamera());
    } else {
      Navigator.of(context)
          .pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => NavScreenTwo(0)),
              (Route<dynamic> route) => false)
          .then((value) => controller.resumeCamera());
    }
    print(qrText);
    print(msg);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
