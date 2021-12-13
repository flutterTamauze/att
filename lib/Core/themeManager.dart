import 'package:flutter/material.dart';
import 'package:qr_users/Core/colorManager.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
      fontFamily: "Almarai-Regular",
      // main colors of the app
      primaryColor: ColorManager.primary,
      backgroundColor: ColorManager.backGroundColor,
      primaryColorLight: ColorManager.primaryOpacity70,
      disabledColor: ColorManager
          .grey, // will be used incase of disabled button for example
      accentColor: ColorManager.accentColor);
}
