import 'package:flutter/material.dart';
import 'package:qr_users/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localization.dart';

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'en';
const String ARABIC = 'ar';

Future<Locale> setLocale(String languageCode) async {
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = "";
  if (_prefs.getBool('appPolicy') ?? false) {
    languageCode = _prefs.getString(LAGUAGE_CODE) ?? "ar";
  } else {
    languageCode = "en";
  }

  debugPrint("cached langugage is $languageCode");
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, 'US');
    case ARABIC:
      return const Locale(ARABIC, "SA");

    default:
      return const Locale(ENGLISH, 'US');
  }
}

String getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(navigatorKey.currentState.overlay.context)
      .translate(key.trim());
}
