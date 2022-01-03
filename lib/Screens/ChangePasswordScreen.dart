import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/Screens/HomePage.dart';

import 'package:qr_users/Screens/intro.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_pickers/image_pickers.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:async';

import '../Core/constants.dart';
import 'Notifications/Notifications.dart';
import 'SystemScreens/SystemGateScreens/CameraPickerScreen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userType;
  final String userName;
  bool inAppEdit = false;

  ChangePasswordScreen(
      {this.userType, this.userName, @required this.inAppEdit});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  TextEditingController _rePasswordController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  var isLoading = false;
  File img;
  GalleryMode _galleryMode = GalleryMode.image;
  List<Media> _listImagePaths = List();

  Future<void> cameraPick(File image) async {
    try {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return RoundedLoadingIndicator();
          });

      RoundedLoadingIndicator();
      await Provider.of<UserData>(context, listen: false)
          .updateProfileImgFile(image.path)
          .then((value) {
        if (value == "success") {
          // print(value)

          Fluttertoast.showToast(
              msg: "تم حفظ الصورة بنجاح",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
        } else if (value == "noInternet") {
          Fluttertoast.showToast(
              msg: "خطأ في التعديل: لا يوجد اتصال بالانترنت",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
        } else {
          Fluttertoast.showToast(
              msg: "خطأ في حفظ الصورة",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
        }
      });
      Navigator.pop(context);
      print("done!");
    } catch (e) {
      print(e);
    }
  }

  Future<File> testCompressAndGetFile({File file, String targetPath}) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 30,
    );

    return result;
  }

  // void _showAddPhoto() {
  //   RoundedDialog _dialog = new RoundedDialog(
  //     cameraOnPressedFunc: () => cameraPick(),
  //     galleryOnPressedFunc: () => selectImages(),
  //   );

  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return _dialog;
  //       });
  // }

  @override
  void initState() {
    /// takes the front camera
    _startUp();

    super.initState();
  }

  _startUp() async {
    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
  }

  var result;
  CameraDescription cameraDescription;
  File imagePath;
  var _passwordVisible = true;
  var _repasswordVisible = true;
  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(builder: (context, userData, child) {
      return Scaffold(
        endDrawer: NotificationItem(),
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                print(Provider.of<UserData>(context, listen: false)
                    .user
                    .userImage);
              },
              behavior: HitTestBehavior.opaque,
              onPanDown: (_) {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ProfileHeader(
                          title:
                              widget.inAppEdit ? "" : "برجاء اختيار صورة شخصية",
                          headerImage: Container(
                            height: 140.h,
                            child: CachedNetworkImage(
                              imageUrl: userData.user.userImage,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.orange)),
                              ),
                              errorWidget: (context, url, error) =>
                                  Provider.of<UserData>(context, listen: true)
                                      .changedWidget,
                            ),
                          ),
                          onPressed: () {
                            // _onImageButtonPressed(ImageSource.gallery);
                          },
                        ),
                        Provider.of<UserData>(context, listen: false)
                                .user
                                .userImage
                                .contains("DefualtImage")
                            ? Positioned(
                                right: 135.w,
                                bottom: 120.h,
                                child: GestureDetector(
                                  onTap: () async {
                                    File result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CameraPicker(
                                            camera: cameraDescription,
                                            fromScreen: "register",
                                          ),
                                        ));

                                    await cameraPick(result);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xffFF7E00),
                                    ),
                                    height: 35.h,
                                    width: 35.w,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
                            : Container()
                      ],
                    ),
                    Container(
                      height: 20,
                      child: AutoSizeText(
                        "برجاء ادخال كلمة مرور ",
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: ScreenUtil()
                                .setSp(16, allowFontScalingSelf: true),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                          key: _profileFormKey,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  TextFormField(
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return getTranslated(context, "مطلوب");
                                      } else if (text.length >= 8 &&
                                          text.length <= 12) {
                                        Pattern pattern =
                                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                                        RegExp regex = new RegExp(pattern);
                                        if (!regex.hasMatch(text)) {
                                          return ' كلمة المرور يجب ان تتكون من احرف ابجدية كبيرة و صغيرة \n وعلامات ترقيم(!@#\$&*~) و رقم';
                                        } else {
                                          return null;
                                        }
                                      } else {
                                        return "كلمة المرور ان تكون اكثر من 8 احرف و اقل من 12";
                                      }
                                    },
                                    controller: _passwordController,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context).nextFocus(),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    obscureText: _passwordVisible,
                                    decoration:
                                        kTextFieldDecorationWhite.copyWith(
                                      hintText:
                                          getTranslated(context, 'كلمة المرور'),
                                      fillColor: Colors.white,
                                      suffixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      _passwordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                        FocusScope.of(context).requestFocus();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.0.h,
                              ),
                              Stack(
                                children: [
                                  TextFormField(
                                    onFieldSubmitted: (v) async {
                                      FocusScope.of(context).unfocus();
                                      await changePass();
                                    },
                                    controller: _rePasswordController,
                                    textInputAction: TextInputAction.done,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    validator: (text) {
                                      if (text.length >= 8 &&
                                          text.length <= 12) {
                                        Pattern pattern =
                                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                                        RegExp regex = new RegExp(pattern);
                                        if (!regex.hasMatch(text)) {
                                          return ' كلمة المرور يجب ان تتكون من احرف ابجدية كبيرة و صغيرة \n وعلامات ترقيم(!@#\$&*~) و رقم';
                                        } else if (text !=
                                            _passwordController.text) {
                                          return 'كلمة المرور غير متماثلتين';
                                        } else if (text == null ||
                                            text.isEmpty) {
                                          return getTranslated(
                                              context, "مطلوب");
                                        } else {
                                          return null;
                                        }
                                      } else {
                                        return "كلمة المرور ان تكون اكثر من 8 احرف و اقل من 12";
                                      }
                                    },
                                    obscureText: _repasswordVisible,
                                    decoration:
                                        kTextFieldDecorationWhite.copyWith(
                                      hintText: 'تأكيد كلمة المرور',
                                      fillColor: Colors.white,
                                      suffixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      _repasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      // Update the state i.e. toogle the state of passwordVisible variable
                                      setState(() {
                                        _repasswordVisible =
                                            !_repasswordVisible;
                                        FocusScope.of(context).requestFocus();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30.h,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (!widget.inAppEdit) {
                                    await changePass();
                                  } else {
                                    if (_profileFormKey.currentState
                                        .validate()) {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      var msg = await Provider.of<UserData>(
                                              context,
                                              listen: false)
                                          .editProfile(
                                              _passwordController.text);
                                      print(msg);
                                      if (msg == "success") {
                                        setState(() {
                                          prefs.setStringList('userData', [
                                            Provider.of<UserData>(context,
                                                    listen: false)
                                                .user
                                                .userID,
                                            _passwordController.text
                                          ]);

                                          Navigator.pop(context);
                                          print('Edit Done ');
                                        });
                                        successfulSaved();
                                        Navigator.pop(context);
                                      } else {
                                        setState(() {
                                          print('Edit Done ');
                                        });
                                        Fluttertoast.showToast(
                                            msg: "خطأ في حفظ البيانات",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                        Navigator.pop(context);
                                      }
                                    }
                                  }
                                },
                                child: userData.isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Container(
                                        width: 230.w,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Colors.orange),
                                        padding: EdgeInsets.all(15),
                                        child: Center(
                                          child: Container(
                                            height: 20,
                                            child: AutoSizeText(
                                              'حفظ',
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ScreenUtil().setSp(
                                                      18,
                                                      allowFontScalingSelf:
                                                          true)),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
                child: InkWell(
              onTap: () {
                Navigator.maybePop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: Colors.orange,
                size: 40,
              ),
            ))
          ],
        ),
      );
    });
  }

  Future changePass() async {
    if (_profileFormKey.currentState.validate()) {
      if (Provider.of<UserData>(context, listen: false)
          .user
          .userImage
          .contains("DefualtImage")) {
        Fluttertoast.showToast(
            msg: 'برجاء التقاط صورة شخصية للوجة اولا',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG);
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedLoadingIndicator();
            });

        SharedPreferences prefs = await SharedPreferences.getInstance();

        try {
          var msg = await Provider.of<UserData>(context, listen: false)
              .changePassword(_passwordController.text);

          print(msg);
          Navigator.pop(context);
          if (msg == "success") {
            try {
              if (Platform.isIOS) {
                final storage = new FlutterSecureStorage();
                final DeviceInfoPlugin deviceInfoPlugin =
                    new DeviceInfoPlugin();
                var data = await deviceInfoPlugin.iosInfo;
                String chainValue = await storage.read(key: "deviceMac");

                print(
                    "saving to the keychain mac : ${data.identifierForVendor}"); //UUID for iOS
                if (chainValue == "" || chainValue == null) {
                  print("chain Value is empty going to write in it");
                  await storage
                      .write(key: "deviceMac", value: data.identifierForVendor)
                      .whenComplete(
                          () => print("item added to keychain successfully !"))
                      .catchError((e) {
                    print(e);
                  });
                }
              }
            } catch (e) {
              print(e);
            }

            prefs.setStringList(
                'userData', [widget.userName, _passwordController.text]);
            if (widget.userType == 0) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ));
            } else if (widget.userType > 0) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageIntro(
                      userType: 1,
                    ),
                  ));
            }

            Fluttertoast.showToast(
                msg: "تم الحفظ بنجاح",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
          } else {
            Fluttertoast.showToast(
                gravity: ToastGravity.CENTER,
                msg: "خطأ في حفظ البيانات",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
            Navigator.pop(context);
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }
}
