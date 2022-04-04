// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_pickers/image_pickers.dart';
// import 'package:path/path.dart' as Path;
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_users/Screens/loginScreen.dart';
// import 'package:qr_users/constants.dart';
// import 'package:qr_users/services/company.dart';
// import 'package:qr_users/widgets/headers.dart';
// import 'package:qr_users/widgets/roundedAlert.dart';
// import 'package:qr_users/widgets/roundedButton.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class GuestCompanyScreen extends StatefulWidget {
//   GuestCompanyScreen();

//   @override
//   _GuestCompanyScreenState createState() => _GuestCompanyScreenState();
// }

// class _GuestCompanyScreenState extends State<GuestCompanyScreen> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     setImgToDefault();
//   }

//   setImgToDefault() async {
//     img = await getImageFileFromAssets("company.png");
//   }

//   final _formKey = GlobalKey<FormState>();

//   TextEditingController _nameArController = TextEditingController();
//   TextEditingController _nameEnController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();

//   var changedWidget = Image.asset("resources/company.png");

//   GalleryMode _galleryMode = GalleryMode.image;
//   List<Media> _listImagePaths = List();
//   File img;
//   String path = "empty";

//   Future<void> selectImages() async {
//     DateTime uploadTime = DateTime.now();

//     try {
//       _galleryMode = GalleryMode.image;
//       _listImagePaths = await ImagePickers.pickerPaths(
//         galleryMode: _galleryMode,
//         showGif: true,
//         selectCount: 1,
//         showCamera: true,
//         cropConfig: CropConfig(enableCrop: true, height: 1, width: 1),
//         compressSize: 500,
//         uiConfig: UIConfig(
//           uiThemeColor: Colors.orange,
//         ),
//       );
//       _listImagePaths.forEach((media) {
//         debugPrint(media.path.toString());
//       });

//       img = File(_listImagePaths[0].path);
//       path = Path.join(
//         // Store the picture in the temp directory.
//         // Find the temp directory using the `path_provider` plugin.
//         (await getTemporaryDirectory()).path,
//         '${DateTime.now()}.jpg',
//       );
//       await testCompressAndGetFile(file: img, targetPath: path);
//       setState(() {
//         changedWidget = Image.file(File(path));
//       });
//     } on PlatformException {}
//   }

//   Future<File> testCompressAndGetFile({File file, String targetPath}) async {
//     var result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 30,
//     );

//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Container(
//           child: GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onPanDown: (_) {
//               FocusScope.of(context).unfocus();
//             },
//             child: Stack(
//               children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ProfileHeader(
//                       headerImage: changedWidget,
//                       onPressed: () {
//                         selectImages();
//                       },
//                     ),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               height: 10.h,
//                             ),
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 30.0.w),
//                               child: Form(
//                                 key: _formKey,
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: <Widget>[
//                                     TextFormField(
//                                       onFieldSubmitted: (_) {},
//                                       textInputAction: TextInputAction.next,
//                                       textAlign: TextAlign.right,
//                                       validator: (text) {
//                                         if (text.length == 0) {
//                                           return 'مطلوب';
//                                         }
//                                         return null;
//                                       },
//                                       controller: _nameArController,
//                                       decoration:
//                                           kTextFieldDecorationWhite.copyWith(
//                                               hintText: 'اسم الشركة',
//                                               suffixIcon: Icon(
//                                                 Icons.apartment,
//                                                 color: Colors.orange,
//                                               )),
//                                     ),
//                                     SizedBox(
//                                       height: 10.0.h,
//                                     ),
//                                     TextFormField(
//                                       onFieldSubmitted: (_) {},
//                                       textInputAction: TextInputAction.next,
//                                       textAlign: TextAlign.right,
//                                       validator: (text) {
//                                         if (text.length == 0) {
//                                           return 'مطلوب';
//                                         }
//                                         return null;
//                                       },
//                                       controller: _nameEnController,
//                                       decoration:
//                                           kTextFieldDecorationWhite.copyWith(
//                                               hintText:
//                                                   'اسم الشركة بالانجليزية',
//                                               suffixIcon: Icon(
//                                                 Icons.title,
//                                                 color: Colors.orange,
//                                               )),
//                                     ),
//                                     SizedBox(
//                                       height: 10.0.h,
//                                     ),
//                                     TextFormField(
//                                       textInputAction: TextInputAction.next,
//                                       textAlign: TextAlign.right,
//                                       validator: (text) {
//                                         if (text == null || text.isEmpty) {
//                                           return 'مطلوب';
//                                         } else {
//                                           Pattern pattern =
//                                               r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+\.[a-zA-Z]+";

//                                           RegExp regex = new RegExp(pattern);
//                                           if (!regex.hasMatch(text))
//                                             return 'البريد الإلكترونى غير صحيح';
//                                           else
//                                             return null;
//                                         }
//                                       },
//                                       controller: _emailController,
//                                       decoration:
//                                           kTextFieldDecorationWhite.copyWith(
//                                               hintText: 'البريد الالكترونى',
//                                               suffixIcon: Icon(
//                                                 Icons.email,
//                                                 color: Colors.orange,
//                                               )),
//                                     ),
//                                     SizedBox(
//                                       height: 10.0.h,
//                                     ),
//                                     // TextFormField(
//                                     //   textInputAction: TextInputAction.next,
//                                     //   textAlign: TextAlign.right,
//                                     //   validator: (text) {
//                                     //     if (text == null || text.isEmpty) {
//                                     //       return 'مطلوب';
//                                     //     } else {
//                                     //       String pattern = r'(^[0-9]{11,13}$)';
//                                     //       RegExp regExp = new RegExp(pattern);
//                                     //       if (!regExp.hasMatch(text))
//                                     //         return 'رقم الهاتف غير صحيح';
//                                     //       else
//                                     //         return null;
//                                     //     }
//                                     //   },
//                                     //   controller: _phoneController,
//                                     //   decoration:
//                                     //       kTextFieldDecorationWhite.copyWith(
//                                     //           hintText: 'رقم الهاتف',
//                                     //           suffixIcon: Icon(
//                                     //             Icons.phone,
//                                     //             color: Colors.orange,
//                                     //           )),
//                                     // ),
//                                     SizedBox(
//                                       height: 10.0.h,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10.h,
//                             ),
//                             RoundedButton(
//                               onPressed: () async {
//                                 if (_formKey.currentState.validate()) {
//                                   showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
//                                         return RoundedLoadingIndicator();
//                                       });

//                                   var msg = await Provider.of<CompanyData>(
//                                           context,
//                                           listen: false)
//                                       .addGuestCompany(
//                                           context: context,
//                                           image: img,
//                                           company: Company(
//                                               nameEn: _nameEnController.text,
//                                               nameAr: _nameArController.text,
//                                               email: _emailController.text,
//                                               adminPhoneNumber: "0238895523"));
//                                   debugPrint("MEssssaageeee : ==========$msg");
//                                   if (msg == "Success") {
//                                     Fluttertoast.showToast(
//                                       msg:
//                                           "تم انشاء الشركة بنجاح\nتم ارسال اسم مستخدم و كلمة مرور مؤقتة إلى البريد الالكترونى الخاص بكم\nبرجاء استخدامهم لتسجيل الدخول",
//                                       toastLength: Toast.LENGTH_LONG,
//                                       gravity: ToastGravity.TOP,
//                                       timeInSecForIosWeb: 1,
//                                       backgroundColor: Colors.green,
//                                       textColor: Colors.white,
//                                       fontSize: ScreenUtil().setSp(16,
//                                           allowFontScalingSelf: true),
//                                     );

//                                     Navigator.of(context).pushAndRemoveUntil(
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 LoginScreen()),
//                                         (Route<dynamic> route) => false);
//                                   } else if (msg == "nameExists") {
//                                     Fluttertoast.showToast(
//                                       msg:
//                                           "خطأ في البايانات :اسم الشركة مستخدم مسبقا",
//                                       toastLength: Toast.LENGTH_SHORT,
//                                       timeInSecForIosWeb: 1,
//                                       backgroundColor: Colors.red,
//                                       gravity: ToastGravity.CENTER,
//                                       textColor: Colors.black,
//                                       fontSize: ScreenUtil().setSp(16,
//                                           allowFontScalingSelf: true),
//                                     );
//                                     Navigator.pop(context);
//                                   } else if (msg == "exists") {
//                                     Fluttertoast.showToast(
//                                       msg:
//                                           "خطأ في البايانات :البريد الإلكتروني مستخدم مسبقا",
//                                       toastLength: Toast.LENGTH_SHORT,
//                                       timeInSecForIosWeb: 1,
//                                       backgroundColor: Colors.red,
//                                       gravity: ToastGravity.CENTER,
//                                       textColor: Colors.black,
//                                       fontSize: ScreenUtil().setSp(16,
//                                           allowFontScalingSelf: true),
//                                     );
//                                     Navigator.pop(context);
//                                   } else if (msg == "failed") {
//                                     Fluttertoast.showToast(
//                                       msg: "خطأ في البايانات",
//                                       toastLength: Toast.LENGTH_SHORT,
//                                       timeInSecForIosWeb: 1,
//                                       backgroundColor: Colors.red,
//                                       gravity: ToastGravity.CENTER,
//                                       textColor: Colors.black,
//                                       fontSize: ScreenUtil().setSp(16,
//                                           allowFontScalingSelf: true),
//                                     );
//                                     Navigator.pop(context);
//                                   } else if (msg == "noInternet") {
//                                     Fluttertoast.showToast(
//                                       msg: "خطأ في البايانات",
//                                       toastLength: Toast.LENGTH_SHORT,
//                                       timeInSecForIosWeb: 1,
//                                       backgroundColor: Colors.red,
//                                       gravity: ToastGravity.CENTER,
//                                       textColor: Colors.black,
//                                       fontSize: ScreenUtil().setSp(16,
//                                           allowFontScalingSelf: true),
//                                     );
//                                     Navigator.pop(context);
//                                   } else {
//                                     Fluttertoast.showToast(
//                                       msg: "خطأ في البايانات",
//                                       toastLength: Toast.LENGTH_SHORT,
//                                       timeInSecForIosWeb: 1,
//                                       gravity: ToastGravity.CENTER,
//                                       backgroundColor: Colors.red,
//                                       textColor: Colors.black,
//                                       fontSize: ScreenUtil().setSp(16,
//                                           allowFontScalingSelf: true),
//                                     );
//                                     Navigator.pop(context);
//                                   }
//                                 }
//                               },
//                               title: "إضافة",
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 Positioned(
//                   left: 5.0.w,
//                   top: 5.0.h,
//                   child: Container(
//                     width: 50.w,
//                     height: 50.h,
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<File> getImageFileFromAssets(String path) async {
//     final byteData = await rootBundle.load('resources/$path');

//     final file = File('${(await getTemporaryDirectory()).path}/$path');
//     await file.writeAsBytes(byteData.buffer
//         .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

//     return file;
//   }
// }
