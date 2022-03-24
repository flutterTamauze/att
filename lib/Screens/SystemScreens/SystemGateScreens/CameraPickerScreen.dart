import 'dart:developer';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/MLmodule/recognition_services/FaceDetectorPainter.dart';

import 'package:image/image.dart' as img;
import 'package:qr_users/MLmodule/recognition_services/UtilsScanner.dart';
import 'package:qr_users/MLmodule/recognition_services/classifier.dart';
import 'package:qr_users/MLmodule/recognition_services/quant.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import "package:qr_users/widgets/headers.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import '../../../main.dart';
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
  FaceDetector faceDetector;

  CameraImage currentCameraImage;
  bool _isDetecting = false;
  int numberOfFacesDetected = -1;
  CameraController cameraController;

  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  initCamera() async {
    try {
      cameraController = CameraController(widget.camera,
          Platform.isIOS ? ResolutionPreset.high : ResolutionPreset.low);
      faceDetector = GoogleVision.instance.faceDetector(
          const FaceDetectorOptions(
              enableClassification: true,
              minFaceSize: 0.1,
              enableTracking: true,
              enableContours: true,
              enableLandmarks: true,
              mode: FaceDetectorMode.accurate));

      await cameraController.initialize().then((_) async {
        cameraController.startImageStream((imageFromStream) {
          if (!isWorking) {
            isWorking = true;
            performDetectionOnStreamFrame(imageFromStream);
          }
        });
        if (!mounted) {
          return;
        }
      });
    } catch (e) {
      log("ERROR");
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

    final CustomPainter customPainter =
        FaceDetectorPainter(imageSize, scannResult, cameraLensDirection);

    return CustomPaint(
      painter: customPainter,
    );
  }

  File image;
  Future<File> testCompressAndGetFile({File file, String targetPath}) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 30,
    );

    return result;
  }

  void _predict() async {
    final img.Image imageInput = img.decodeImage(imagePath.readAsBytesSync());
    print(imageInput.data);
    final pred = _classifier.predict(imageInput);
    print("pred $pred");
    setState(() {
      this.category = pred;
    });
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
    cameraController.dispose().then((value) => faceDetector.close());

    super.dispose();
  }

  Future<String> fillPath() async {
    return join(
      (await getTemporaryDirectory().catchError((e) {
        print("directory error $e");
      }))
          .path,
      '${DateTime.now()}.jpg',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final path = fillPath();
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
                      : Container(
                          child: const Center(
                            child: LoadingIndicator(),
                          ),
                        ),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                          await Future.delayed(const Duration(
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

                                          final File imgCompressed =
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

                                          // if (Platform.isAndroid) {
                                          //   GoogleVisionImage fbVisionImage =
                                          //       await GoogleVisionImage
                                          //           .fromFile(imagePath);
                                          //   List<Face> faceList =
                                          //       await faceDetector.processImage(
                                          //           fbVisionImage);
                                          //   if (!isFaceAvailable(faceList)) {
                                          //     Fluttertoast.showToast(
                                          //         msg: getTranslated(context,
                                          //             "برجاء تصوير وجهك بوضوح"),
                                          //         backgroundColor: Colors.red,
                                          //         gravity: ToastGravity.CENTER,
                                          //         toastLength:
                                          //             Toast.LENGTH_LONG);
                                          //     Navigator.of(context)
                                          //         .pushAndRemoveUntil(
                                          //             MaterialPageRoute(
                                          //                 builder: (context) =>
                                          //                     const NavScreenTwo(
                                          //                         1)),
                                          //             (Route<dynamic> route) =>
                                          //                 false);
                                          //   }
                                          // }

                                          if (category.label.substring(2) ==
                                              "mobiles") {
                                            Fluttertoast.showToast(
                                                msg: getTranslated(context,
                                                    "خطأ : برجاء التقاط صورة حقيقية"),
                                                backgroundColor: Colors.red,
                                                gravity: ToastGravity.CENTER,
                                                toastLength: Toast.LENGTH_LONG);
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const NavScreenTwo(
                                                                1)),
                                                    (Route<dynamic> route) =>
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
                                          else if (numberOfFacesDetected == 1) {
                                            if (widget.fromScreen ==
                                                "register") {
                                              Navigator.pop(context, image);
                                            } else {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 200),
                                                  () async {
                                                final msg = await Provider.of<
                                                            UserData>(context,
                                                        listen: false)
                                                    .attendByCard(
                                                        qrCode:
                                                            widget.shiftQrcode,
                                                        cardCode: widget.qrText,
                                                        image: imgCompressed);
                                                print(msg);

                                                switch (msg) {
                                                  case "Success : successfully registered":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "تم التسجيل بنجاح"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.black,
                                                        textColor:
                                                            Colors.orange);
                                                    break;
                                                  case "Failed : You can't attend outside your company!":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "لا يمكنك التسجيل لشخص خارج شركتك"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Success : already registered attend":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "لقد تم تسجيل الحضور من قبل"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.black,
                                                        textColor:
                                                            Colors.orange);
                                                    break;
                                                  case "Success : already registered leave":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "لقد تم تسجيل الأنصراف من قبل"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.black,
                                                        textColor:
                                                            Colors.orange);
                                                    break;
                                                  case "you can't register now during shift!":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "لا يمكن التسجيل بمناوبتك الأن"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.black,
                                                        textColor:
                                                            Colors.orange);
                                                    break;
                                                  case "Sorry : You have an external mission today!":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "لم يتم التسجيل: لديك مأمورية خارجية"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.black,
                                                        textColor:
                                                            Colors.orange);
                                                    break;

                                                  case "Failed : Location not found":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                          context,
                                                          "خطأ فى التسجيل: برجاء التواجد بموقع العمل",
                                                        ),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Sorry : You have an holiday today!":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "لم يتم التسجيل : اجازة شخصية"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Fail : You can't register leave now":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                          context,
                                                          "لا يمكنك تسجيل الإنصراف الأن",
                                                        ),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Failed : Mac address not match":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "خطأ فى التسجيل: بيانات الهاتف غير صحيحة\nبرجاء التسجيل من هاتفك أو مراجعة مدير النظام"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Failed : You are not allowed to sign by card! ":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "ليس مصرح لك التسجيل بالبطاقة"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Fail : Using another attend method":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "خطأ فى التسجيل: برجاء التسجيل بنفس طريقة تسجيل الحضور"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Failed : Qrcode not valid":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "خطأ فى التسجيل: كود غير صحيح"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "noInternet":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "خطأ فى التسجيل: لا يوجد اتصال بالانترنت"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "off":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "خطأ فى التسجيل: عدم تفعيل الموقع الجغرافى للهاتف"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "mock":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                          context,
                                                          "خطأ فى التسجيل: برجاء التواجد بموقع العمل",
                                                        ),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Sorry : Today is an official vacation!":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "لم يتم التسجيل : عطلة رسمية"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Success : User was not proof":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                          context,
                                                          "خطأ فى التسجيل: لم يتم اثبات حضور المستخدم",
                                                        ),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                    break;
                                                  case "Failed : Out of shift time":
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "التسجيل غير متاح الأن"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.orange,
                                                        textColor:
                                                            Colors.black);
                                                    break;

                                                  default:
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "خطأ فى التسجيل"),
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor:
                                                            Colors.black);
                                                }
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
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
                                                gravity: ToastGravity.CENTER,
                                                toastLength: Toast.LENGTH_LONG);
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const NavScreenTwo(
                                                                1)),
                                                    (Route<dynamic> route) =>
                                                        false);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: getTranslated(context,
                                                    "برجاء تصوير وجهك بوضوح"),
                                                backgroundColor: Colors.red,
                                                gravity: ToastGravity.CENTER,
                                                toastLength: Toast.LENGTH_LONG);
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const NavScreenTwo(
                                                                1)),
                                                    (Route<dynamic> route) =>
                                                        false);
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
                            const SizedBox(
                              height: 10,
                            ),
                            AutoSizeText(
                              getTranslated(context,
                                  "... برجاء انتظار انتهاء عملية المسح"),
                              style: TextStyle(
                                fontSize: setResponsiveFontSize(18),
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
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
              ]),
      ),
    );
  }
}
