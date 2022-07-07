import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image/image.dart' as imglib;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/MLmodule/recognition_services/FaceDetectorPainter.dart';

import 'package:image/image.dart' as img;
import 'package:qr_users/MLmodule/recognition_services/UtilsScanner.dart';
import 'package:qr_users/MLmodule/recognition_services/classifier.dart';
import 'package:qr_users/MLmodule/recognition_services/quant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/CameraPicker/loadingCamera.dart';
import 'package:qr_users/widgets/CameraPicker/scanningFace.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import '../../../main.dart';
import 'NavScreenPartTwo.dart';

class CameraPicker extends StatefulWidget {
  final String fromScreen, shiftQrcode, qrText;
  const CameraPicker({
    this.fromScreen,
    this.shiftQrcode,
    this.qrText,
    Key key,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<CameraPicker> {
  File imagePath;
  Size imageSize;
  Classifier _classifier;
  // FaceNetService _faceNetService = FaceNetService();
  // final DataBaseService _dataBaseService = DataBaseService();
  double predictedUserName = 0.0;
  bool isWorking = false;
  Size size;
  Category category;
  final faceDetector = GoogleVision.instance.faceDetector(
      const FaceDetectorOptions(
          enableContours: true,
          mode: FaceDetectorMode.accurate,
          enableClassification: true,
          enableTracking: true,
          enableLandmarks: true,
          minFaceSize: 0.1));
  CameraImage currentCameraImage;
  bool _isDetecting = false;
  int numberOfFacesDetected = -1;
  CameraController cameraController;
  CameraDescription description;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  initCamera() async {
    try {
      description = await ScannerUtils.getCamera(cameraLensDirection);
      cameraController = CameraController(description,
          Platform.isIOS ? ResolutionPreset.high : ResolutionPreset.high,
          enableAudio: false);
      await cameraController.initialize();
      await cameraController.startImageStream((CameraImage image) {
        if (_isDetecting) return;

        _isDetecting = true;

        ScannerUtils.detect(
          image: image,
          detectInImage: faceDetector.processImage,
          imageRotation: description.sensorOrientation,
        ).then(
          (dynamic results) {
            setState(() {
              scannResult = results;
            });
          },
        ).whenComplete(() => Future.delayed(
            const Duration(
              milliseconds: 100,
            ),
            () => {_isDetecting = false}));
      });
    } catch (e) {
      log("ERROR");
      errorToast(navigatorKey.currentState.overlay.context);
      Navigator.pushReplacement(
          navigatorKey.currentState.overlay.context,
          MaterialPageRoute(
            builder: (context) => const NavScreenTwo(1),
          ));
      Navigator.pop(navigatorKey.currentState.overlay.context);
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
              imageRotation: description.sensorOrientation)
          .then((dynamic result) async {
        if (mounted) {
          setState(() {
            scannResult = result;
          });
          currentCameraImage = imageFromStream;
        }
      }).whenComplete(() => Future.delayed(
                  const Duration(
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
    print('Starting camera ');
    _classifier = ClassifierQuant();
    initCamera();
  }

  Widget buildResult() {
    try {
      const Text noResultsText = Text("لا يوجد نتائج");
      if (scannResult == null ||
          cameraController == null ||
          !cameraController.value.isInitialized) {
        return noResultsText;
      }

      final Size imageSize = Size(cameraController.value.previewSize.height,
          cameraController.value.previewSize.width);

      final CustomPainter customPainter =
          FaceDetectorPainter(imageSize, scannResult, cameraLensDirection);

      return CustomPaint(
        painter: customPainter,
      );
    } catch (e) {
      print(e);
    }
  }

  File image;
  Future<File> testCompressAndGetFile({File file, String targetPath}) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 30,
      );

      return result;
    } catch (e) {
      print(e);
    }
  }

  void _predict() async {
    try {
      final img.Image imageInput = img.decodeImage(imagePath.readAsBytesSync());
      final pred = _classifier.predict(imageInput);
      debugPrint("pred $pred");
      setState(() {
        this.category = pred;
      });
    } catch (e) {
      print(e);
    }
  }

  bool isFaceAvailable(List<Face> facesList) {
    if (facesList[0].headEulerAngleY > 10 ||
        facesList[0].headEulerAngleY < -10) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    cameraController.dispose().then((_) => faceDetector.close());
    log("dispose is triggered !");
    super.dispose();
  }

  Future<String> fillPath() async {
    try {
      return join(
        (await getTemporaryDirectory().catchError((e) {
          debugPrint("directory error $e");
        }))
            .path,
        '${DateTime.now()}.jpg',
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final path = fillPath();
    // ignore: cascade_invocations

    return GestureDetector(
      child: Scaffold(
        endDrawer: NotificationItem(),
        body: cameraController == null
            ? const LoadingCamera()
            : image == null
                ? Stack(children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: (new AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: new CameraPreview(cameraController),
                      )),
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
                            color: const Color(0xffF89A41),
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
                                    margin: const EdgeInsets.only(bottom: 80),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                            child: Container(
                                              width: 70.w,
                                              height: 70.h,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.transparent,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: const Image(
                                                  image: const AssetImage(
                                                      "resources/imageface.png"),
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              try {
                                                // await _faceNetService.setCurrentPrediction(
                                                //     currentCameraImage, scannResult[0]);
                                              } catch (e) {
                                                print(e);
                                              }
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500));
                                              await cameraController
                                                  .stopImageStream();
                                              // await Future.delayed(const Duration(
                                              //     milliseconds: 200));
                                              File img;
                                              await cameraController
                                                  .takePicture()
                                                  .then((value) async =>
                                                      value.saveTo(await path));

                                              img = File(await path);
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

                                              final File imgCompressed =
                                                  await testCompressAndGetFile(
                                                      file: img,
                                                      targetPath: newPath);
                                              // _cameraService.cameraController.dispose();

                                              cameraController.dispose();
                                              // _cameraService.cameraController.dispose();
                                              debugPrint(
                                                  "=====Compressed==========");
                                              if (widget.fromScreen !=
                                                  "register") {
                                                // predictedUserName = _faceNetService.predict();
                                                // debugPrint(predictedUserName);
                                              }
                                              final GoogleVisionImage
                                                  fbVisionImage =
                                                  await GoogleVisionImage
                                                      .fromFile(imagePath);
                                              final List<Face> faceList =
                                                  await faceDetector
                                                      .processImage(
                                                          fbVisionImage);
                                              if (category.label.substring(2) ==
                                                  "mobiles") {
                                                displayErrorToast(context,
                                                    "خطأ : برجاء التقاط صورة حقيقية");
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const NavScreenTwo(
                                                                    1)),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              } else if (!isFaceAvailable(
                                                  faceList)) {
                                                displayErrorToast(context,
                                                    "برجاء تصوير وجهك بوضوح");
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const NavScreenTwo(
                                                                    1)),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              }
                                              // else if (predictedUserName >= 1) {
                                              //   Fluttertoast.showToast(
                                              //       msg: "خطا : لم يتم التعرف على الوجة ",
                                              //       backgroundColor: Colors.red,
                                              //       gravity: ToastGravity.CENTER,
                                              //       toastLength: Toast.LENGTH_LONG);
                                              //   Navigator.pop(context);
                                              // }
                                              else if (numberOfFacesDetected ==
                                                  1) {
                                                if (widget.fromScreen ==
                                                    "register") {
                                                  Navigator.pop(context, image);
                                                } else {
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 200),
                                                      () async {
                                                    final msg = await Provider
                                                            .of<UserData>(
                                                                context,
                                                                listen: false)
                                                        .attendByCard(
                                                            qrCode: widget
                                                                .shiftQrcode,
                                                            cardCode:
                                                                widget.qrText,
                                                            image:
                                                                imgCompressed);

                                                    switch (msg) {
                                                      case "Success : successfully registered":
                                                        displayToast(context,
                                                            "تم التسجيل بنجاح");
                                                        break;
                                                      case "Success : successfully leave registered":
                                                        displayToast(context,
                                                            "تم تسجيل الإنصراف بنجاح");

                                                        break;
                                                      case "Failed : You can't attend outside your company!":
                                                        displayErrorToast(
                                                            context,
                                                            "لا يمكنك التسجيل لشخص خارج شركتك");

                                                        break;
                                                      case "Success : already registered attend":
                                                        displayToast(context,
                                                            "لقد تم تسجيل الحضور من قبل");
                                                        break;
                                                      case "Success : already registered leave":
                                                        displayToast(context,
                                                            "لقد تم تسجيل الأنصراف من قبل");
                                                        break;
                                                      case "you can't register now during shift!":
                                                        displayToast(context,
                                                            "لا يمكن التسجيل بمناوبتك الأن");
                                                        break;
                                                      case "Sorry : You have an external mission today!":
                                                        displayToast(context,
                                                            "لم يتم التسجيل: لديك مأمورية خارجية");
                                                        break;

                                                      case "Failed : Location not found":
                                                        displayErrorToast(
                                                            context,
                                                            "خطأ فى التسجيل: برجاء التواجد بموقع العمل");
                                                        break;
                                                      case "Sorry : You have an holiday today!":
                                                        displayToast(context,
                                                            "لم يتم التسجيل : اجازة شخصية");
                                                        break;
                                                      case "Fail : You can't register leave now":
                                                        displayErrorToast(
                                                            context,
                                                            "لا يمكنك تسجيل الإنصراف الأن");
                                                        break;
                                                      case "Failed : Mac address not match":
                                                        displayErrorToast(
                                                            context,
                                                            "خطأ فى التسجيل: بيانات الهاتف غير صحيحة\nبرجاء التسجيل من هاتفك أو مراجعة مدير النظام");
                                                        break;
                                                      case "Failed : You are not allowed to sign by card! ":
                                                        displayErrorToast(
                                                            context,
                                                            "ليس مصرح لك التسجيل بالبطاقة");
                                                        break;
                                                      case "Fail : Using another attend method":
                                                        displayErrorToast(
                                                            context,
                                                            "خطأ فى التسجيل: برجاء التسجيل بنفس طريقة تسجيل الحضور");
                                                        break;
                                                      case "Failed : Qrcode not valid":
                                                        displayErrorToast(
                                                            context,
                                                            "خطأ فى التسجيل: كود غير صحيح");
                                                        break;
                                                      case "noInternet":
                                                        displayErrorToast(
                                                            context,
                                                            "خطأ فى التسجيل: لا يوجد اتصال بالانترنت");
                                                        break;
                                                      case "off":
                                                        displayErrorToast(
                                                            context,
                                                            "خطأ فى التسجيل: عدم تفعيل الموقع الجغرافى للهاتف");
                                                        break;
                                                      case "mock":
                                                        displayErrorToast(
                                                            context,
                                                            "خطأ فى التسجيل: برجاء التواجد بموقع العمل");
                                                        break;
                                                      case "Sorry : Today is an official vacation!":
                                                        displayErrorToast(
                                                            context,
                                                            "لم يتم التسجيل : عطلة رسمية");
                                                        break;
                                                      case "Success : User was not proof":
                                                        displayErrorToast(
                                                            context,
                                                            "خطأ فى التسجيل: لم يتم اثبات حضور المستخدم");
                                                        break;
                                                      case "Failed : Out of shift time":
                                                        displayErrorToast(
                                                            context,
                                                            "التسجيل غير متاح الأن");
                                                        break;

                                                      default:
                                                        displayErrorToast(
                                                            context,
                                                            "خطأ فى التسجيل");
                                                    }
                                                    Navigator.of(context)
                                                        .pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const NavScreenTwo(
                                                                            1)),
                                                            (Route<dynamic>
                                                                    route) =>
                                                                false);
                                                  });
                                                }
                                              } else if (numberOfFacesDetected >
                                                  1) {
                                                Fluttertoast.showToast(
                                                    msg: getTranslated(context,
                                                        "خطا : تم التعرف علي اكثر من وجة"),
                                                    backgroundColor: Colors.red,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    toastLength:
                                                        Toast.LENGTH_LONG);
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const NavScreenTwo(
                                                                    1)),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: getTranslated(context,
                                                        "برجاء تصوير وجهك بوضوح"),
                                                    backgroundColor: Colors.red,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    toastLength:
                                                        Toast.LENGTH_LONG);
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const NavScreenTwo(
                                                                    1)),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              }
                                            })
                                      ],
                                    ),
                                  )
                            : Container())
                  ])
                : const ScanningFaceCamera(),
      ),
    );
  }
}
