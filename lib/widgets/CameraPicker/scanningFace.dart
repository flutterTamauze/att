import 'dart:developer';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as imglib;
import 'package:lottie/lottie.dart';

import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/services/permissions_data.dart';
import "package:qr_users/widgets/headers.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../main.dart';

class ScanningFaceCamera extends StatelessWidget {
  const ScanningFaceCamera({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          children: [
            HeaderBeforeLogin(),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 300.w,
                    height: 300.h,
                    alignment: Alignment.center,
                    child: Center(
                      child: Lottie.asset("resources/PersonScanning.json"),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AutoSizeText(
                    getTranslated(
                        context, "... برجاء انتظار انتهاء عملية المسح"),
                    style: TextStyle(
                      fontSize: setResponsiveFontSize(18),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
          ],
        ),
      ),
      Positioned(
        left: 4.0,
        top: 4.0,
        child: SafeArea(
          child: IconButton(
            icon: Icon(
              locator.locator<PermissionHan>().isEnglishLocale()
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: const Color(0xffF89A41),
              size: 40,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    ]);
  }
}
