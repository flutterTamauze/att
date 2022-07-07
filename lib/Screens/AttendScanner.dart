import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_users/Core/constants.dart';
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
    switch (msg) {
      case "Success : successfully registered":
        displayToast(context, "تم التسجيل بنجاح");
        break;
      case "Success : successfully leave registered":
        displayToast(context, "تم تسجيل الإنصراف بنجاح");

        break;
      case "Failed : You can't attend outside your company!":
        displayErrorToast(context, "لا يمكنك التسجيل لشخص خارج شركتك");

        break;
      case "Success : already registered attend":
        displayToast(context, "لقد تم تسجيل الحضور من قبل");

        break;
      case "Success : already registered leave":
        displayToast(context, "لقد تم تسجيل الأنصراف من قبل");

        break;
      case "you can't register now during shift!":
        displayToast(context, "لا يمكن التسجيل بمناوبتك الأن");

        break;
      case "Sorry : You have an external mission today!":
        displayToast(context, "لم يتم التسجيل: لديك مأمورية خارجية");

        break;

      case "Failed : Location not found":
        displayErrorToast(context, "خطأ فى التسجيل: برجاء التواجد بموقع العمل");

        break;
      case "Sorry : You have an holiday today!":
        displayToast(context, "لم يتم التسجيل : اجازة شخصية");

        break;
      case "Fail : You can't register leave now":
        displayErrorToast(context, "لا يمكنك تسجيل الإنصراف الأن");

        break;
      case "Failed : Mac address not match":
        displayErrorToast(context,
            "خطأ فى التسجيل: بيانات الهاتف غير صحيحة\nبرجاء التسجيل من هاتفك أو مراجعة مدير النظام");

        break;
      case "Fail : Using another attend method":
        displayErrorToast(
            context, "خطأ فى التسجيل: برجاء التسجيل بنفس طريقة تسجيل الحضور");

        break;
      case "Failed : Qrcode not valid":
        displayErrorToast(context, "خطأ فى التسجيل: كود غير صحيح");

        break;
      case "noInternet":
        displayErrorToast(context, "خطأ فى التسجيل: لا يوجد اتصال بالانترنت");

        break;
      case "off":
        displayErrorToast(
            context, "خطأ فى التسجيل: عدم تفعيل الموقع الجغرافى للهاتف");

        break;
      case "mock":
        displayErrorToast(context, "خطأ فى التسجيل: برجاء التواجد بموقع العمل");

        break;
      case "Sorry : Today is an official vacation!":
        displayErrorToast(context, "لم يتم التسجيل : عطلة رسمية");

        break;
      case "Success : User was not proof":
        displayErrorToast(
            context, "خطأ فى التسجيل: لم يتم اثبات حضور المستخدم");

        break;
      case "Failed : Out of shift time":
        displayToast(context, "التسجيل غير متاح الأن");

        break;
      default:
        displayErrorToast(context, "خطأ فى التسجيل");
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
