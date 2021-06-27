import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final baseURL = "https://attendanceback.tamauze.com";
// final baseURL = "http://192.168.1.38:45456";
final apiKey = "ByYM000OLlMQG6VVVp1OH7Xzyr7gHuw1qvUC5dcGt3SNM";

int kBeforeStartShift = 100;
int kAfterStartShift = 200;
int kAfterEndShift = 600;

double getkDeviceWidthFactor(BuildContext context, double widgetWidth) {
  return (MediaQuery.of(context).size.width / 392) * widgetWidth;
}

double getkDeviceHeightFactor(BuildContext context, double widgetHeight) {
  return (MediaQuery.of(context).size.height / 807) * widgetHeight;
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
