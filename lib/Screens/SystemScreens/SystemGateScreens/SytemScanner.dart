import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/api.dart';

import 'CameraPickerScreen.dart';

const frontCamera = 'FRONT CAMERA';

class SystemScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SystemScanPageState();
}

class _SystemScanPageState extends State<SystemScanPage> {
  var qrText = '';
  // AudioCache player = AudioCache();
  CameraDescription cameraDescription;
  _startUp() async {
    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
  }

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  @override
  void initState() {
    _startUp();
    super.initState();
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
                  Icons.chevron_left,
                  color: Colors.white,
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

  var shiftQrCode;
  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    bool isScanned = false;
    controller.flipCamera();
    controller.scannedDataStream.listen((scanData) async {
      qrText = scanData;
      if (!isScanned) {
        isScanned = true;
        shiftQrCode = Provider.of<ShiftApi>(context, listen: false)
            .currentShift
            .shiftQrCode;
        print("qrcode : $shiftQrCode");
        secondPageRoute();
      }
    });
  }

  secondPageRoute() async {
    print("Qr text $qrText");
    // player.play("cap.wav");
    controller?.pauseCamera();

    if (shiftQrCode != null && qrText != null) {
      print(shiftQrCode);
      print(qrText);
      print(cameraDescription);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraPicker(
              camera: cameraDescription,
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
