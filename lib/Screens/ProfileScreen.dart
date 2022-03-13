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
// import 'package:image_pickers/image_pickers.dart';

import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/ChangePasswordScreen.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../main.dart';
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
  // GalleryMode _galleryMode = GalleryMode.image;
  // List<Media> _listImagePaths = List();
  String encryptUserName(String userName) {
    final output = [];

    final String encCode = "@QnhU64!z&9#Ke84hfogueb748%H&*@DghJ!kwfJLp&@A3z%s7";
    final String cUserId = "TECH/$userName/XSec";

    for (var i = 0; i < cUserId.length; i++) {
      final charCode = cUserId.codeUnitAt(i) ^ encCode.codeUnitAt(i);
      output.add(new String.fromCharCode(charCode));
    }
    print(output.length);
    for (var i = cUserId.length; i < encCode.length; i++) {
      output.add(" ");
    }
    return output.join("");
  }

  Future<File> testCompressAndGetFile({File file, String targetPath}) async {
    final result = await FlutterImageCompress.compressAndGetFile(
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
    final userProv = Provider.of<UserData>(context, listen: false).user;
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange)),
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
                    child: Column(
                      children: [
                        Container(
                          height: 200.h,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2.w, color: Colors.black)),
                              child: QrImage(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                //plce where the QR Image will be shown
                                data: encryptUserName(
                                    Provider.of<UserData>(context, listen: true)
                                        .user
                                        .userID),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 20,
                          child: AutoSizeText(
                            getTranslated(
                              context,
                              "كود بطاقة التعريف الشخصية",
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
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
                            text: plusSignPhone(userProv.phoneNum)),
                        SizedBox(
                          height: 5.h,
                        ),
                        UserDataField(
                            icon: FontAwesomeIcons.moneyBill,
                            text:
                                "${userProv.salary} ${getTranslated(context, "جنية مصرى")}"),
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
                                getTranslated(context, "تاريخ التعيين"),
                              ),
                              Text(DateFormat('yMMMd')
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
                                    builder: (context) => ChangePasswordScreen(
                                        userType: 0,
                                        userName: "",
                                        inAppEdit: true),
                                  ));
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: AutoSizeText(
                                getTranslated(context, "تغير كلمة السر"),
                                style: TextStyle(
                                    color: ColorManager.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        )
                      ],
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
                  locator.locator<PermissionHan>().isEnglishLocale()
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: const Color(0xffF89A41),
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
                        size:
                            ScreenUtil().setSp(40, allowFontScalingSelf: true),
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
                          getTranslated(context, "الغاء"),
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: setResponsiveFontSize(17),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
