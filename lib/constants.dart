import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'dart:ui' as ui;

import 'package:fluttertoast/fluttertoast.dart';

//http://192.168.0.119:8010
//https://Chilangoback.tamauzeds.com
final googleDriveLink =
    "https://download1484.mediafire.com/f48w8k7ip7xg/kij2aisrzghhz5p/ChilangoV3.apk";
final baseURL = "https://Chilangoback.tamauzeds.com";
final localURL = "http://192.168.0.123:8010";
final huaweiAppId = "104665933";
final huaweiSecret =
    "88bd9c196a990ad91dc127047819d569e5ade79022e727d35ba98467d3a218bf";
// final baseURL = "http://192.168.1.38:45456";
final apiKey = "ByYM000OLlMQG6VVVp1OH7Xzyr7gHuw1qvUC5dcGt3SNM";
List<String> weekDays = [
  "السبت",
  "الأحد",
  "الأتنين",
  "الثلاثاء",
  "الأربعاء",
  "الخميس",
  "الجمعة"
];
DateTime kReleaseData = DateTime(DateTime.now().year, 11, 12);
int kBeforeStartShift = 100;
// int kAfterStartShift = 200;
// int kAfterEndShift = 600;
successfullDelete() {
  Fluttertoast.showToast(
    msg: "تم الحذف بنجاح",
    gravity: ToastGravity.CENTER,
    toastLength: Toast.LENGTH_SHORT,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

errorToast() {
  Fluttertoast.showToast(
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      msg: "حدث خطأ ما");
}

successfulSaved() {
  Fluttertoast.showToast(
      msg: "تم الحفظ بنجاح",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
}

unSuccessfullDelete() {
  Fluttertoast.showToast(
    msg: "خطأ في الحذف",
    gravity: ToastGravity.CENTER,
    toastLength: Toast.LENGTH_SHORT,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

double getkDeviceWidthFactor(BuildContext context, double widgetWidth) {
  return (MediaQuery.of(context).size.width / 392) * widgetWidth;
}

double getkDeviceHeightFactor(BuildContext context, double widgetHeight) {
  return (MediaQuery.of(context).size.height / 807) * widgetHeight;
}

int kCalcDateDifferance(String strtDate, String endDate) {
  DateTime startDate = DateTime.parse(strtDate);
  DateTime endingDate = DateTime.parse(endDate);

  final differancee = endingDate.difference(startDate).inDays;
  return differancee;
}

class DetialsTextField extends StatelessWidget {
  final TextEditingController commentController;
  DetialsTextField(this.commentController);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: TextField(
          controller: commentController,
          cursorColor: Colors.orange,
          maxLines: null,
          decoration: InputDecoration(
            errorStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Colors.orange),
            ),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 4)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey, width: 0)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey, width: 0)),
            hintStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            hintText: "قم بأدخال التفاصيل هنا",
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}

ThemeData clockTheme = ThemeData.dark().copyWith(
  primaryColor: Colors.black,
  accentColor: Colors.white,
  colorScheme: ColorScheme.dark(
    primary: Colors.orange,
    onPrimary: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
  ),
  highlightColor: Colors.orange,
  buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
  dialogBackgroundColor: Colors.black87,
);

ThemeData clockTheme1 = ThemeData.dark().copyWith(
  backgroundColor: Colors.black,
  primaryColor: Colors.black,
  accentColor: Colors.orange,
  colorScheme: ColorScheme.dark(
    primary: Colors.orange,
    onPrimary: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
  ),
  buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
  dialogBackgroundColor: Colors.black87,
);

const kTextFieldDecorationWhite = InputDecoration(
  isDense: true,

  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
  hintText: 'Enter a value',
  hintStyle:
      TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
  fillColor: Colors.white,
  filled: true,
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xffD7D7D7), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
//  contentPadding: EdgeInsets.symmetric(),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff4a4a4a), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff4a4a4a), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
);
const kTextFieldDecorationTime = InputDecoration(
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
  hintText: 'Enter a value',
  hintStyle: TextStyle(
    color: Colors.grey,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  ),
  fillColor: Colors.white,
  filled: true,
//  contentPadding: EdgeInsets.symmetric(),
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xffD7D7D7), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff4a4a4a), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff4a4a4a), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
);
const kTextFieldTime = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
  hintText: 'Enter a value',
  hintStyle: TextStyle(
    color: Colors.grey,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  ),
  fillColor: Colors.white,
  filled: true,
//  contentPadding: EdgeInsets.symmetric(),
);
const kTextFieldDecorationFromTO = InputDecoration(
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
  hintText: 'Enter a value',
  hintStyle:
      TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
  fillColor: Colors.white,
  filled: true,
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xffEDEDED), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
//  contentPadding: EdgeInsets.symmetric(),
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff4a4a4a), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff4a4a4a), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
);

  // Future<String> _fileFromImageUrl(String path, String name) async {
  //   final response = await http.get(Uri.parse(path));

  //   final documentDirectory = await getApplicationDocumentsDirectory();

  //   final file = File(p.join(documentDirectory.path, '$name.png'));

  //   file.writeAsBytesSync(response.bodyBytes);

  //   return file.path;
  // }