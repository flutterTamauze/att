import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/permissions_data.dart';

import '../../../main.dart';
import 'CameraPickerScreen.dart';

const frontCamera = 'FRONT CAMERA';

class SystemScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SystemScanPageState();
}

class _SystemScanPageState extends State<SystemScanPage> {
  var qrText = '';
  AudioCache player = AudioCache();

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  flipCamera() async {
    await controller.flipCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: NotificationItem(),
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
                  locator.locator<PermissionHan>().isEnglishLocale()
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const NavScreenTwo(1)),
                      (Route<dynamic> route) => false);
                },
              ),
            ),
          ),
          Positioned(
            bottom: 4.0,
            right: 4.0,
            child: SafeArea(
                child: FloatingActionButton(
              backgroundColor: ColorManager.primary,
              onPressed: () {
                flipCamera();
              },
              child: const Icon(
                Icons.swap_horizontal_circle_sharp,
              ),
            )),
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

  var shiftQrCode;
  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    bool isScanned = false;
    controller.flipCamera();
    controller.scannedDataStream.listen((scanData) async {
      try {
        log(scanData);
        qrText = scanData;
        if (!isScanned) {
          isScanned = true;
          shiftQrCode =
              Provider.of<ShiftApi>(context, listen: false).qrShift.shiftQrCode;
          secondPageRoute();
        }
      } catch (e) {
        print(e);
      }
    });
  }

  secondPageRoute() async {
    debugPrint("Qr text $qrText");
    player.play("cap.wav");
    controller?.pauseCamera();

    if (shiftQrCode != null && qrText != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraPicker(
              qrText: qrText,
              shiftQrcode: shiftQrCode,
            ),
          ));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
