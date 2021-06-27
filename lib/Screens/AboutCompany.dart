import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/image_pickers.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyProfileScreen extends StatefulWidget {
  @override
  _CompanyProfileScreenState createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  bool edit = false;

  final _profileFormKey = GlobalKey<FormState>();
  TextEditingController _nameArController = TextEditingController();
  TextEditingController _nameEnController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  TextEditingController _sitesController = TextEditingController();
  TextEditingController _usersController = TextEditingController();

  String bottomText = 'تعديل';
  Color textColor = Colors.black45;
  File img;

  // final ImagePicker _picker = ImagePicker();
  // PickedFile _imageFile;
  GalleryMode _galleryMode = GalleryMode.image;
  List<Media> _listImagePaths = List();

  Future<void> selectImages() async {
    try {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return RoundedLoadingIndicator();
          });
      _galleryMode = GalleryMode.image;
      _listImagePaths = await ImagePickers.pickerPaths(
        galleryMode: _galleryMode,
        showGif: true,
        selectCount: 1,
        showCamera: true,
        cropConfig: CropConfig(enableCrop: true, height: 1, width: 1),
        compressSize: 500,
        uiConfig: UIConfig(
          uiThemeColor: Colors.orange,
        ),
      );
      _listImagePaths.forEach((media) {
        print(media.path.toString());
      });

      img = File(_listImagePaths[0].path);
      final path = Path.join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.jpg',
      );
      await testCompressAndGetFile(file: img, targetPath: path);
      await Provider.of<CompanyData>(context, listen: false)
          .updateProfileImgFile(path,
              Provider.of<UserData>(context, listen: false).user.userToken)
          .then((value) {
        print("value = $value");
        if (value == "success") {
          Fluttertoast.showToast(
              msg: "تم التعديل بنجاح",
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
            msg: "خطأ في التعديل",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
          );
        }
      });

      Navigator.pop(context);
      print("done!");
    } on PlatformException {}
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

    super.initState();
    var comProvider = Provider.of<CompanyData>(context, listen: false).com;
    _emailController.text = comProvider.email;
    _nameArController.text = comProvider.nameAr;
    _nameEnController.text = comProvider.nameEn;
    _sitesController.text = " ${comProvider.companySites} الحد الاقصى للمواقع ";
    _usersController.text =
        " ${comProvider.companyUsers} الحد الاقصى للمستخدمين";
  }

  @override
  Widget build(BuildContext context) {
    var comProvider = Provider.of<CompanyData>(context, listen: false).com;
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
                  Provider.of<UserData>(context, listen: true).user.userType ==
                          5
                      ? ProfileHeader(
                          title: Provider.of<CompanyData>(context, listen: true)
                              .com
                              .nameAr,
                          headerImage: CachedNetworkImage(
                            imageUrl:
                                Provider.of<CompanyData>(context, listen: true)
                                    .com
                                    .logo,
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
                          onPressed: () {
                            selectImages();
                            // _onImageButtonPressed(ImageSource.gallery);
                          },
                        )
                      : Stack(
                          children: [
                            ClipPath(
                              clipper: MyClipper(),
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.height) / 2.75,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            ClipPath(
                              clipper: MyClipper(),
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.height) / 2.8,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                ),
                                child: Center(
                                  child: Stack(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.black,
                                            radius: 60,
                                            child: Container(
                                              height: 120.h,
                                              width: 120.w,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1,
                                                  color: Color(0xffFF7E00),
                                                ),
                                                // image: DecorationImage(
                                                //   image: headerImage,
                                                //   fit: BoxFit.fill,
                                                // ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          60.0),
                                                  child: CachedNetworkImage(
                                                    imageUrl: Provider.of<
                                                                CompanyData>(
                                                            context,
                                                            listen: true)
                                                        .com
                                                        .logo,
                                                    fit: BoxFit.fill,
                                                    placeholder:
                                                        (context, url) =>
                                                            Center(
                                                      child: CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.white,
                                                          valueColor:
                                                              new AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors
                                                                      .orange)),
                                                    ),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Provider.of<UserData>(
                                                                context,
                                                                listen: true)
                                                            .changedWidget,
                                                  )),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Container(
                                            height: 30.h,
                                            child: AutoSizeText(
                                              Provider.of<CompanyData>(context,
                                                      listen: true)
                                                  .com
                                                  .nameAr,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ScreenUtil().setSp(
                                                      20,
                                                      allowFontScalingSelf:
                                                          true),
                                                  color: Colors.orange),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Form(
                        key: _profileFormKey,
                        child: Column(
                          children: [
                            Container(
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(13, allowFontScalingSelf: true)),
                                enabled: edit,
                                onFieldSubmitted: (_) {},
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.right,
                                validator: (text) {
                                  if (text.length == 0) {
                                    return 'مطلوب';
                                  }
                                  return null;
                                },
                                controller: _nameArController,
                                decoration: kTextFieldDecorationWhite.copyWith(
                                    hintText: 'اسم الشركة',
                                    suffixIcon: Icon(
                                      Icons.title,
                                      color: Colors.orange,
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil()
                                  .setSp(13, allowFontScalingSelf: true),
                            ),
                            TextFormField(
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(13, allowFontScalingSelf: true)),
                              enabled: edit,
                              onFieldSubmitted: (_) {},
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.right,
                              validator: (text) {
                                if (text.length == 0) {
                                  return 'مطلوب';
                                }
                                return null;
                              },
                              controller: _nameEnController,
                              decoration: kTextFieldDecorationWhite.copyWith(
                                  hintText: 'اسم الشركة بالانجليزية',
                                  suffixIcon: Icon(
                                    Icons.title,
                                    color: Colors.orange,
                                  )),
                            ),
                            SizedBox(
                              height: 10.0.h,
                            ),
                            TextFormField(
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(13, allowFontScalingSelf: true)),
                              enabled: edit,
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.right,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'مطلوب';
                                } else {
                                  Pattern pattern =
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+\.[a-zA-Z]+";

                                  RegExp regex = new RegExp(pattern);
                                  if (!regex.hasMatch(text))
                                    return 'البريد الإلكترونى غير صحيح';
                                  else
                                    return null;
                                }
                              },
                              controller: _emailController,
                              decoration: kTextFieldDecorationWhite.copyWith(
                                  hintText: 'البريد الالكترونى',
                                  suffixIcon: Icon(
                                    Icons.email,
                                    color: Colors.orange,
                                  )),
                            ),
                            SizedBox(
                              height: 10.0.h,
                            ),
                            Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: TextFormField(
                                enabled: false,
                                style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(13, allowFontScalingSelf: true)),
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.right,
                                validator: (text) {
                                  if (text.length == 0) {
                                    return 'مطلوب';
                                  }
                                  return null;
                                },
                                controller: _sitesController,
                                decoration: kTextFieldDecorationWhite.copyWith(
                                    hintText: 'الحد الاقصى من المواقع',
                                    prefixIcon: Icon(
                                      Icons.location_on,
                                      color: Colors.orange,
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: 10.0.h,
                            ),
                            Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(13, allowFontScalingSelf: true)),
                                enabled: false,
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.right,
                                validator: (text) {
                                  if (text.length == 0) {
                                    return 'مطلوب';
                                  }
                                  return null;
                                },
                                controller: _usersController,
                                decoration: kTextFieldDecorationWhite.copyWith(
                                    hintText: 'الحد الاقصى من للمتسخدمين',
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.orange,
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: 10.0.h,
                            ),
                            Provider.of<UserData>(context, listen: true)
                                        .user
                                        .userType ==
                                    5
                                ? GestureDetector(
                                    onTap: () {
                                      if (edit == false) {
                                        setState(() {
                                          textColor = Colors.black;
                                          edit = true;
                                          bottomText = 'حفظ';
                                        });
                                      } else if (edit == true) {
                                        if (_profileFormKey.currentState
                                            .validate()) {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) =>
                                                SingleChildScrollView(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                  ),
                                                  height: 200.h,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      RoundedButton(
                                                        onPressed: () async {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return RoundedLoadingIndicator();
                                                              });

                                                          try {
                                                            var token = Provider.of<
                                                                        UserData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .user
                                                                .userToken;
                                                            var msg = await Provider.of<
                                                                        CompanyData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .editCompanyProfile(
                                                                    Company(
                                                                        email: _emailController
                                                                            .text,
                                                                        nameAr: _nameArController
                                                                            .text,
                                                                        nameEn: _nameEnController
                                                                            .text,
                                                                        id: Provider.of<CompanyData>(context,
                                                                                listen: false)
                                                                            .com
                                                                            .id),
                                                                    token,context);

                                                            if (msg ==
                                                                "success") {
                                                              setState(() {
                                                                edit = false;
                                                                bottomText =
                                                                    'تعديل';
                                                                textColor =
                                                                    Colors
                                                                        .black45;
                                                                Navigator.pop(
                                                                    context);
                                                                print(
                                                                    'Edit Done ');
                                                              });
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          "تم الحفظ بنجاح",
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT,
                                                                      // // gravity:
                                                                      // //     ToastGravity
                                                                      //         .CENTER,
                                                                      timeInSecForIosWeb:
                                                                          1,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                      fontSize: ScreenUtil().setSp(
                                                                          16,
                                                                          allowFontScalingSelf:
                                                                              true));
                                                              Navigator.pop(
                                                                  context);
                                                            } else {
                                                              setState(() {
                                                                edit = false;
                                                                bottomText =
                                                                    'تعديل';
                                                                textColor =
                                                                    Colors
                                                                        .black45;
                                                                print(
                                                                    'Edit Done ');
                                                              });
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "خطأ في حفظ البيانات",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      ScreenUtil().setSp(
                                                                          16,
                                                                          allowFontScalingSelf:
                                                                              true));
                                                              Navigator.pop(
                                                                  context);
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
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
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
                                            bottomText,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtil().setSp(18,
                                                  allowFontScalingSelf: true),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container()
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
            top: 4.0.h,
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
