import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

TextEditingController _rePasswordController = new TextEditingController();
TextEditingController _passwordController = TextEditingController();
var _passwordVisible = true;
var _repasswordVisuble = true;

final _profileFormKey = GlobalKey<FormState>();

class _ProfileScreenState extends State<ProfileScreen> {
  bool edit = false;

  String bottomText = 'تعديل';
  Color textColor = Colors.black45;
  File img;

  // final ImagePicker _picker = ImagePicker();
  // PickedFile _imageFile;
  GalleryMode _galleryMode = GalleryMode.image;
  List<Media> _listImagePaths = List();
  String encryptUserName(String userName) {
    var output = [];

    String encCode = "@QnhU64!z&9#Ke84hfogueb748%H&*@DghJ!kwfJLp&@A3z%s7";
    String cUserId = "TECH/$userName/XSec";

    for (var i = 0; i < cUserId.length; i++) {
      var charCode = cUserId.codeUnitAt(i) ^ encCode.codeUnitAt(i);
      output.add(new String.fromCharCode(charCode));
    }
    print(output.length);
    for (var i = cUserId.length; i < encCode.length; i++) {
      output.add(" ");
    }
    return output.join("");
  }

  Future<File> testCompressAndGetFile({File file, String targetPath}) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 30,
    );

    return result;
  }

  @override
  void initState() {
    // TODO: implement initState

    _passwordController.text = "";
    _rePasswordController.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    headerImage: Container(
                      height: 150.h,
                      child: CachedNetworkImage(
                        imageUrl: Provider.of<UserData>(context, listen: true)
                            .user
                            .userImage,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.orange)),
                        ),
                        errorWidget: (context, url, error) =>
                            Provider.of<UserData>(context, listen: true)
                                .changedWidget,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: _profileFormKey,
                        child: Column(
                          children: [
                            Container(
                              height: getkDeviceHeightFactor(context, 200.h),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2.w, color: Colors.black)),
                                  child: QrImage(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    //plce where the QR Image will be shown
                                    data: encryptUserName(Provider.of<UserData>(
                                            context,
                                            listen: true)
                                        .user
                                        .userID),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 20,
                              child: AutoSizeText(
                                "كود بطاقة التعريف الشخصية",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Stack(
                              children: [
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).nextFocus(),
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'مطلوب';
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
                                      return "كلمة المرور يجب ان تكون اكثر من 8 احرف و اقل من 12";
                                    }
                                  },
                                  controller: _passwordController,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                  enabled: edit,
                                  obscureText: _passwordVisible,
                                  decoration:
                                      kTextFieldDecorationWhite.copyWith(
                                    hintText: 'كلمة المرور',
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
                                  onFieldSubmitted: (value) =>
                                      FocusScope.of(context).unfocus(),
                                  controller: _rePasswordController,
                                  textInputAction: TextInputAction.done,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                  validator: (text) {
                                    if (text != _passwordController.text) {
                                      return 'كلمة المرور غير متماثلتين';
                                    }
                                    return null;
                                  },
                                  enabled: edit,
                                  obscureText: _repasswordVisuble,
                                  decoration:
                                      kTextFieldDecorationWhite.copyWith(
                                    hintText: 'تأكيد كلمة المرور',
                                    suffixIcon: Icon(
                                      Icons.lock,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _repasswordVisuble
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _repasswordVisuble = !_repasswordVisuble;
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
                              onTap: () {
                                if (edit == false) {
                                  setState(() {
                                    textColor = Colors.black;
                                    edit = true;
                                    bottomText = 'حفظ';
                                  });
                                } else if (edit == true) {
                                  if (_profileFormKey.currentState.validate()) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => Container(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                          ),
                                          height: 200.h,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              RoundedButton(
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return RoundedLoadingIndicator();
                                                      });
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();

                                                  try {
                                                    var msg = await Provider.of<
                                                                UserData>(
                                                            context,
                                                            listen: false)
                                                        .editProfile(
                                                            _passwordController
                                                                .text);

                                                    if (msg == "success") {
                                                      setState(() {
                                                        prefs.setStringList(
                                                            'userData', [
                                                          Provider.of<UserData>(
                                                                  context,
                                                                  listen: false)
                                                              .user
                                                              .userID,
                                                          _passwordController
                                                              .text
                                                        ]);
                                                        edit = false;
                                                        bottomText = 'تعديل';
                                                        textColor =
                                                            Colors.black45;
                                                        Navigator.pop(context);
                                                        print('Edit Done ');
                                                      });
                                                      Fluttertoast.showToast(
                                                          msg: "تم الحفظ بنجاح",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          // // gravity:
                                                          // //     ToastGravity
                                                          //         .CENTER,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor:
                                                              Colors.green,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: ScreenUtil()
                                                              .setSp(16,
                                                                  allowFontScalingSelf:
                                                                      true));
                                                      Navigator.pop(context);
                                                    } else {
                                                      setState(() {
                                                        edit = false;
                                                        bottomText = 'تعديل';
                                                        textColor =
                                                            Colors.black45;
                                                        print('Edit Done ');
                                                      });
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "خطأ في حفظ البيانات",
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor:
                                                              Colors.red,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: ScreenUtil()
                                                              .setSp(16,
                                                                  allowFontScalingSelf:
                                                                      true));
                                                      Navigator.pop(context);
                                                    }
                                                  } catch (e) {
                                                    print(e);
                                                  }
                                                },
                                                title: "حفظ ؟",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                width: 230.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.orange),
                                padding: EdgeInsets.all(15),
                                child: Center(
                                  child: Container(
                                    height: 20,
                                    child: AutoSizeText(
                                      bottomText,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: ScreenUtil().setSp(18,
                                              allowFontScalingSelf: true)),
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
            left: 4.0.w,
            top: 4.0.w,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Color(0xffF89A41),
                  size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedDialog extends StatelessWidget {
  final Function cameraOnPressedFunc;
  final Function galleryOnPressedFunc;

  RoundedDialog({this.cameraOnPressedFunc, this.galleryOnPressedFunc});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          height: 170.h,
          width: 300.w,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: cameraOnPressedFunc,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.camera_alt,
                          size: ScreenUtil()
                              .setSp(40, allowFontScalingSelf: true),
                          color: Colors.orange,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                          height: 20,
                          child: AutoSizeText(
                            "التقاط صورة",
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(18, allowFontScalingSelf: true)),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  SizedBox(
                    width: 150.0.w,
                    child: Material(
                      elevation: 5.0,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15.0),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        minWidth: 130.w,
                        height: 30.h,
                        child: Container(
                          height: 20,
                          child: AutoSizeText(
                            "الغاء",
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
