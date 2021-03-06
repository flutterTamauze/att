import 'dart:io';
import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image/image.dart' as imglib;
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/recognition_services/FaceDetectorPainter.dart';

import 'package:image/image.dart' as img;
import 'package:qr_users/MLmodule/recognition_services/UtilsScanner.dart';
import 'package:qr_users/MLmodule/recognition_services/classifier.dart';
import 'package:qr_users/MLmodule/recognition_services/quant.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/user_data.dart';
import "package:qr_users/widgets/headers.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'NavScreenPartTwo.dart';

const shift = (0xFF << 24);

class CameraPicker extends StatefulWidget {
  final CameraDescription camera;
  final String fromScreen, shiftQrcode, qrText;
  const CameraPicker({
    this.fromScreen,
    this.shiftQrcode,
    this.qrText,
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<CameraPicker>
    with WidgetsBindingObserver {
  File imagePath;
  Size imageSize;
  Classifier _classifier;
  // FaceNetService _faceNetService = FaceNetService();
  // final DataBaseService _dataBaseService = DataBaseService();
  double predictedUserName = 0.0;

  bool isWorking = false;
  Size size;
  Category category;
  CameraController cameraController;
  FaceDetector faceDetector;

  CameraImage currentCameraImage;
  bool _isDetecting = false;
  int numberOfFacesDetected = -1;

  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  initCamera() async {
    try {
      cameraController = CameraController(widget.camera,
          Platform.isIOS ? ResolutionPreset.high : ResolutionPreset.low);

      faceDetector = GoogleVision.instance.faceDetector(FaceDetectorOptions(
          enableClassification: true,
          minFaceSize: 0.1,
          enableTracking: true,
          enableContours: true,
          enableLandmarks: true,
          mode: FaceDetectorMode.accurate));

      await cameraController.initialize();
      cameraController.startImageStream((imageFromStream) {
        if (!isWorking) {
          isWorking = true;
          performDetectionOnStreamFrame(imageFromStream);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  imglib.Image finalImage;
  List<Face> scannResult = [];
  performDetectionOnStreamFrame(CameraImage imageFromStream) {
    try {
      if (_isDetecting) return;

      ScannerUtils.detect(
              image: imageFromStream,
              detectInImage: faceDetector.processImage,
              imageRotation: widget.camera.sensorOrientation)
          .then((dynamic result) async {
        if (mounted) {
          setState(() {
            scannResult = result;
          });
          currentCameraImage = imageFromStream;
        }
      }).whenComplete(() => Future.delayed(
                  Duration(
                    milliseconds: 100,
                  ), () {
                _isDetecting = false;
                isWorking = false;
              }));
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _classifier = ClassifierQuant();
    initCamera();
  }

  Widget buildResult() {
    if (scannResult == null ||
        cameraController == null ||
        !cameraController.value.isInitialized) {
      return Container();
    }

    final Size imageSize = Size(cameraController.value.previewSize.height,
        cameraController.value.previewSize.width);

    CustomPainter customPainter =
        FaceDetectorPainter(imageSize, scannResult, cameraLensDirection);

    return CustomPaint(
      painter: customPainter,
    );
  }

  File image;
  Future<File> testCompressAndGetFile({File file, String targetPath}) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 30,
    );

    return result;
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(imagePath.readAsBytesSync());
    print(imageInput.data);
    var pred = _classifier.predict(imageInput);
    print("pred $pred");
    setState(() {
      this.category = pred;
    });
  }

  @override
  void dispose() {
    cameraController.dispose().then((value) => faceDetector.close());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ignore: cascade_invocations

    return GestureDetector(
      child: Scaffold(
        endDrawer: NotificationItem(),
        body: image == null
            ? Stack(children: <Widget>[
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: (cameraController.value.isInitialized)
                      ? new AspectRatio(
                          aspectRatio: cameraController.value.aspectRatio,
                          child: new CameraPreview(cameraController),
                        )
                      : Container(),
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
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Positioned(
                    left: 0.0,
                    width: size.width,
                    height: size.height,
                    child: buildResult()),
                Positioned(
                    top: size.height - 250.h,
                    left: 0,
                    width: size.width,
                    height: 450.h,
                    child: scannResult.length == 1
                        ? scannResult[0].headEulerAngleY > 10 ||
                                scannResult[0].headEulerAngleY < -10
                            ? Container()
                            : Container(
                                margin: EdgeInsets.only(bottom: 80),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        child: Container(
                                          width: 70.w,
                                          height: 70.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.transparent,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image(
                                              image: AssetImage(
                                                  "resources/imageface.jpeg"),
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          final path = join(
                                            (await getTemporaryDirectory()
                                                    .catchError((e) {
                                              print("directory error $e");
                                            }))
                                                .path,
                                            '${DateTime.now()}.jpg',
                                          );
                                          try {
                                            // await _faceNetService.setCurrentPrediction(
                                            //     currentCameraImage, scannResult[0]);
                                          } catch (e) {
                                            print(e);
                                          }
                                          await Future.delayed(
                                              Duration(milliseconds: 500));
                                          await cameraController
                                              .stopImageStream();
                                          await Future.delayed(
                                              Duration(milliseconds: 200));
                                          File img;
                                          await cameraController
                                              .takePicture()
                                              .then((value) =>
                                                  value.saveTo(path));

                                          img = File(path);
                                          print(path);
                                          // if (widget.fromScreen == "register") {
                                          //   // await signUp(context);
                                          // }

                                          // await applyModelOnImage(img);

                                          try {
                                            if (mounted) {
                                              setState(() {
                                                numberOfFacesDetected =
                                                    scannResult.length;
                                                imagePath = File(img.path);
                                              });

                                              _predict();
                                            }
                                          } catch (e) {
                                            print(e);
                                          }

                                          final newPath = join(
                                            (await getTemporaryDirectory())
                                                .path,
                                            '${DateTime.now()}.jpg',
                                          );

                                          if (mounted)
                                            setState(() {
                                              image = File(newPath);
                                            });

                                          File imgCompressed =
                                              await testCompressAndGetFile(
                                                  file: img,
                                                  targetPath: newPath);
                                          // _cameraService.cameraController.dispose();

                                          cameraController.dispose();
                                          // _cameraService.cameraController.dispose();
                                          print("=====Compressed==========");
                                          if (widget.fromScreen != "register") {
                                            // predictedUserName = _faceNetService.predict();
                                            // print(predictedUserName);
                                          }

                                          if (category.label.substring(2) ==
                                              "mobiles") {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "?????? : ?????????? ???????????? ???????? ????????????",
                                                backgroundColor: Colors.red,
                                                gravity: ToastGravity.CENTER,
                                                toastLength: Toast.LENGTH_LONG);
                                            Navigator.pop(context);
                                          }
                                          // else if (predictedUserName >= 1) {
                                          //   Fluttertoast.showToast(
                                          //       msg: "?????? : ???? ?????? ???????????? ?????? ?????????? ",
                                          //       backgroundColor: Colors.red,
                                          //       gravity: ToastGravity.CENTER,
                                          //       toastLength: Toast.LENGTH_LONG);
                                          //   Navigator.pop(context);
                                          // }
                                          else if (numberOfFacesDetected == 1) {
                                            if (widget.fromScreen ==
                                                "register") {
                                              Navigator.pop(context, image);
                                            } else {
                                              Future.delayed(
                                                  const Duration(seconds: 3),
                                                  () async {
                                                var msg = await Provider.of<
                                                            UserData>(context,
                                                        listen: false)
                                                    .attendByCard(
                                                        qrCode:
                                                            widget.shiftQrcode,
                                                        cardCode: widget.qrText,
                                                        image: imgCompressed);
                                                print(msg);
                                                if (msg ==
                                                    "Success : successfully registered") {
                                                  Fluttertoast.showToast(
                                                      msg: "???? ?????????????? ??????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.orange,
                                                      textColor: Colors.white);
                                                } else if (msg ==
                                                    "Success : already registered attend") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ?????????? ???????????? ???? ??????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      backgroundColor:
                                                          Colors.black,
                                                      textColor: Colors.orange);
                                                } else if (msg ==
                                                    "Success : already registered leave") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ?????????? ???????????????? ???? ??????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      backgroundColor:
                                                          Colors.black,
                                                      textColor: Colors.orange);
                                                } else if (msg ==
                                                    "Success : User was not proof") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ??????????????: ???? ?????? ?????????? ???????? ????????????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "you can't register now during shift!") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "???? ???????? ?????????????? ???????????????? ????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "Sorry : You have an external mission today!") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "???? ?????? ??????????????: ???????? ?????????????? ???????????? ",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      backgroundColor:
                                                          Colors.black,
                                                      textColor: Colors.orange);
                                                } else if (msg ==
                                                    "Sorry : Today is an official vacation!") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          " ???? ?????? ?????????????? : ???????? ??????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "noInternet") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ??????????????: ???? ???????? ?????????? ??????????????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "Sorry : You have an holiday today!") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          " ???? ?????? ??????????????: ?????????? ??????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg == "off") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ??????????????: ?????? ?????????? ???????????? ???????????????? ????????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg == "mock") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ??????????????: ?????????? ?????????????? ?????????? ??????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "Failed : Invaild Qrcode Index was outside the bounds of the array.") {
                                                  await Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ??????????????: ?????? ?????? ????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "Fail : Using another attend method") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ??????????????: ?????????? ?????????????? ???????? ?????????? ?????????? ????????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "Failed : You are not allowed to sign by card! ") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???????? ???? ?????????????? ????????????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "Failed : Mac address not match") {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ??????????????: ???????????? ???????????? ?????? ??????????\n?????????? ?????????????? ???? ?????????? ???? ???????????? ???????? ????????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "Failed : Location not found") {
                                                  await Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ??????????????: ?????????? ?????????????? ?????????? ??????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "Failed : User Id not valid") {
                                                  await Fluttertoast.showToast(
                                                      msg:
                                                          "?????? ???? ??????????????: ?????? ?????? ????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                } else if (msg ==
                                                    "Failed : Out of shift time") {
                                                  await Fluttertoast.showToast(
                                                      msg:
                                                          "?????????????? ?????? ???????? ????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.orange,
                                                      textColor: Colors.black);
                                                } else {
                                                  await Fluttertoast.showToast(
                                                      msg: "?????? ???? ??????????????",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black);
                                                }
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                NavScreenTwo(
                                                                    1)),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              });
                                            }
                                          } else if (numberOfFacesDetected >
                                              1) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "?????? : ???? ???????????? ?????? ???????? ???? ?????? ",
                                                backgroundColor: Colors.red,
                                                gravity: ToastGravity.CENTER,
                                                toastLength: Toast.LENGTH_LONG);
                                            Navigator.pop(context);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "?????????? ?????????? ???????? ??????????",
                                                backgroundColor: Colors.red,
                                                gravity: ToastGravity.CENTER,
                                                toastLength: Toast.LENGTH_LONG);
                                            Navigator.pop(context);
                                          }
                                        })
                                  ],
                                ),
                              )
                        : Container())
              ])
            : Stack(children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: Column(
                    children: [
                      HeaderBeforeLogin(),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 300.w,
                              height: 300.h,
                              alignment: Alignment.center,
                              child: Center(
                                child: Lottie.asset(
                                    "resources/PersonScanning.json"),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "... ?????????? ???????????? ???????????? ?????????? ?????????? ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
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
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ]),
      ),
    );
  }
}
