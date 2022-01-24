import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_pickers/image_pickers.dart';

import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Screens/ChangePasswordScreen.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

TextEditingController _rePasswordController = new TextEditingController();
TextEditingController _passwordController = TextEditingController();

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
    _passwordController.text = "";
    _rePasswordController.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userProv = Provider.of<UserData>(context, listen: false).user;
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                ProfileHeader(
                  headerImage: Container(
                    height: 150.h,
                    child: CachedNetworkImage(
                      imageUrl: Provider.of<UserData>(context, listen: true)
                          .user
                          .userImage,
                      httpHeaders: {
                        "Authorization": "Bearer " +
                            Provider.of<UserData>(context, listen: false)
                                .user
                                .userToken
                      },
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _profileFormKey,
                    child: Directionality(
                      textDirection: ui.TextDirection.rtl,
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
                            height: 5.h,
                          ),
                          // Stack(
                          //   children: [
                          //     TextFormField(
                          //       textInputAction: TextInputAction.next,
                          //       onFieldSubmitted: (_) =>
                          //           FocusScope.of(context).nextFocus(),
                          //       validator: (text) {
                          //         if (text == null || text.isEmpty) {
                          //           return 'مطلوب';
                          //         } else if (text.length >= 8 &&
                          //             text.length <= 12) {
                          //           Pattern pattern =
                          //               r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                          //           RegExp regex = new RegExp(pattern);
                          //           if (!regex.hasMatch(text)) {
                          //             return ' كلمة المرور يجب ان تتكون من احرف ابجدية كبيرة و صغيرة \n وعلامات ترقيم(!@#\$&*~) و رقم';
                          //           } else {
                          //             return null;
                          //           }
                          //         } else {
                          //           return "كلمة المرور يجب ان تكون اكثر من 8 احرف و اقل من 12";
                          //         }
                          //       },
                          //       controller: _passwordController,
                          //       textAlign: TextAlign.right,
                          //       style: TextStyle(
                          //         color: textColor,
                          //       ),
                          //       enabled: edit,
                          //       obscureText: _passwordVisible,
                          //       decoration:
                          //           kTextFieldDecorationWhite.copyWith(
                          //         hintText: 'كلمة المرور',
                          //         suffixIcon: Icon(
                          //           Icons.lock,
                          //           color: Colors.orange,
                          //         ),
                          //       ),
                          //     ),
                          //     IconButton(
                          //       icon: Icon(
                          //         // Based on passwordVisible state choose the icon
                          //         _passwordVisible
                          //             ? Icons.visibility_off
                          //             : Icons.visibility,
                          //         color: Colors.grey,
                          //       ),
                          //       onPressed: () {
                          //         setState(() {
                          //           _passwordVisible = !_passwordVisible;
                          //           FocusScope.of(context).requestFocus();
                          //         });
                          //       },
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(
                          //   height: 15.0.h,
                          // ),
                          // Stack(
                          //   children: [
                          //     TextFormField(
                          //       onFieldSubmitted: (value) =>
                          //           FocusScope.of(context).unfocus(),
                          //       controller: _rePasswordController,
                          //       textInputAction: TextInputAction.done,
                          //       textAlign: TextAlign.right,
                          //       style: TextStyle(
                          //         color: textColor,
                          //       ),
                          //       validator: (text) {
                          //         if (text != _passwordController.text) {
                          //           return 'كلمة المرور غير متماثلتين';
                          //         }
                          //         return null;
                          //       },
                          //       enabled: edit,
                          //       obscureText: _repasswordVisuble,
                          //       decoration:
                          //           kTextFieldDecorationWhite.copyWith(
                          //         hintText: 'تأكيد كلمة المرور',
                          //         suffixIcon: Icon(
                          //           Icons.lock,
                          //           color: Colors.orange,
                          //         ),
                          //       ),
                          //     ),
                          //     IconButton(
                          //       icon: Icon(
                          //         // Based on passwordVisible state choose the icon
                          //         _repasswordVisuble
                          //             ? Icons.visibility_off
                          //             : Icons.visibility,
                          //         color: Colors.grey,
                          //       ),
                          //       onPressed: () {
                          //         setState(() {
                          //           _repasswordVisuble = !_repasswordVisuble;
                          //           FocusScope.of(context).requestFocus();
                          //         });
                          //       },
                          //     ),
                          //   ],
                          // ),
                          SizedBox(
                            height: 10.h,
                          ),
                          UserDataField(
                            icon: Icons.title,
                            text: userProv.userJob,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          UserDataFieldInReport(
                              icon: Icons.phone,
                              text: plusSignPhone(userProv.phoneNum)
                                  .replaceAll(new RegExp(r"\s+\b|\b\s"), "")),
                          SizedBox(
                            height: 5.h,
                          ),
                          UserDataField(
                              icon: FontAwesomeIcons.moneyBill,
                              text: "${userProv.salary} جنية مصرى"),
                          SizedBox(
                            height: 5.h,
                          ),

                          UserDataField(
                            icon: Icons.email,
                            text: userProv.email,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                  "تاريخ التعيين",
                                ),
                                AutoSizeText(DateFormat('yMMMd')
                                    .format(userProv.createdOn)
                                    .toString())
                              ],
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 10.h,
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangePasswordScreen(
                                              userType: 0,
                                              userName: "",
                                              inAppEdit: true),
                                    ));
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  "تغير كلمة السر ",
                                  style: TextStyle(
                                      color: ColorManager.primary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                          )
                          // GestureDetector(
                          //   onTap: () {
                          //     if (edit == false) {
                          //       setState(() {
                          //         textColor = Colors.black;
                          //         edit = true;
                          //         bottomText = 'حفظ';
                          //       });
                          //     } else if (edit == true) {
                          //       if (_profileFormKey.currentState.validate()) {
                          //         showModalBottomSheet(
                          //           context: context,
                          //           isScrollControlled: true,
                          //           builder: (context) => Container(
                          //             padding: EdgeInsets.only(
                          //                 bottom: MediaQuery.of(context)
                          //                     .viewInsets
                          //                     .bottom),
                          //             child: Container(
                          //               decoration: BoxDecoration(
                          //                 color: Colors.black,
                          //               ),
                          //               height: 200.h,
                          //               child: Column(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.center,
                          //                 children: [
                          //                   RoundedButton(
                          //                     onPressed: () async {
                          //                       showDialog(
                          //                           context: context,
                          //                           builder: (BuildContext
                          //                               context) {
                          //                             return RoundedLoadingIndicator();
                          //                           });
                          //                       SharedPreferences prefs =
                          //                           await SharedPreferences
                          //                               .getInstance();

                          //                       try {
                          //                         var msg = await Provider.of<
                          //                                     UserData>(
                          //                                 context,
                          //                                 listen: false)
                          //                             .editProfile(
                          //                                 _passwordController
                          //                                     .text);

                          //                         if (msg == "success") {
                          //                           setState(() {
                          //                             prefs.setStringList(
                          //                                 'userData', [
                          //                               Provider.of<UserData>(
                          //                                       context,
                          //                                       listen: false)
                          //                                   .user
                          //                                   .userID,
                          //                               _passwordController
                          //                                   .text
                          //                             ]);
                          //                             edit = false;
                          //                             bottomText = 'تعديل';
                          //                             textColor =
                          //                                 Colors.black45;
                          //                             Navigator.pop(context);
                          //                             print('Edit Done ');
                          //                           });
                          //                           successfulSaved();
                          //                           Navigator.pop(context);
                          //                         } else {
                          //                           setState(() {
                          //                             edit = false;
                          //                             bottomText = 'تعديل';
                          //                             textColor =
                          //                                 Colors.black45;
                          //                             print('Edit Done ');
                          //                           });
                          //                           Fluttertoast.showToast(
                          //                               msg:
                          //                                   "خطأ في حفظ البيانات",
                          //                               toastLength: Toast
                          //                                   .LENGTH_SHORT,
                          //                               gravity: ToastGravity
                          //                                   .CENTER,
                          //                               timeInSecForIosWeb: 1,
                          //                               backgroundColor:
                          //                                   Colors.red,
                          //                               textColor:
                          //                                   Colors.white,
                          //                               fontSize: ScreenUtil()
                          //                                   .setSp(16,
                          //                                       allowFontScalingSelf:
                          //                                           true));
                          //                           Navigator.pop(context);
                          //                         }
                          //                       } catch (e) {
                          //                         print(e);
                          //                       }
                          //                     },
                          //                     title: "حفظ ؟",
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //     }
                          //   },
                          //   child: Container(
                          //     width: 230.w,
                          //     decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(25),
                          //         color: Colors.orange),
                          //     padding: EdgeInsets.all(15),
                          //     child: Center(
                          //       child: Container(
                          //         height: 20,
                          //         child: AutoSizeText(
                          //           bottomText,
                          //           maxLines: 1,
                          //           style: TextStyle(
                          //               color: Colors.black,
                          //               fontWeight: FontWeight.bold,
                          //               fontSize: ScreenUtil().setSp(18,
                          //                   allowFontScalingSelf: true)),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
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
