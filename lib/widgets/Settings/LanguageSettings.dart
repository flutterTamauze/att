import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/permissions_data.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({
    this.locale,
    this.callBackFun,
    Key key,
  }) : super(key: key);
  final String locale;
  final Function callBackFun;
  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  String languageCode;
  @override
  void initState() {
    languageCode = widget.locale;
    log(languageCode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      child: StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: 20.0.w,
            vertical: 20.0.h,
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: Container(
            height: 100,
            width: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  getTranslated(
                    context,
                    "اختر لغة التطبيق",
                  ),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: setResponsiveFontSize(15)),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey)),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                    elevation: 2,
                    onChanged: (value) {
                      Locale _tempLocal;
                      switch (value) {
                        case 'Ar':
                          _tempLocal = const Locale("ar", "SA");
                          break;
                        case 'En':
                          _tempLocal = const Locale("en", "US");
                      }
                      setState(() {
                        languageCode = value;
                        Provider.of<PermissionHan>(context, listen: false)
                            .setLocale(_tempLocal);
                      });

                      setLocale(value == "En" ? "en" : "ar");
                      MyApp.setLocale(context, _tempLocal);
                      Navigator.maybePop(context);
                      Fluttertoast.showToast(
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.green,
                          msg: value == "En"
                              ? "Langugage has been saved successfully !"
                              : "تم حفظ اللغة بنجاح");
                      widget.callBackFun();
                    },
                    isExpanded: true,
                    value: languageCode,
                    items: [
                      DropdownMenuItem(
                        child: FadeIn(
                          child: LangugageDropdownItem(
                            langugage: getTranslated(context, "العربية"),
                            imagePath: "resources/saudiFlag.png",
                          ),
                        ),
                        value: "Ar",
                      ),
                      DropdownMenuItem(
                        child: FadeIn(
                          child: const LangugageDropdownItem(
                            langugage: "English",
                            imagePath: "resources/EnglishFlag.png",
                          ),
                        ),
                        value: "En",
                      )
                    ],
                  )),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

class LangugageDropdownItem extends StatelessWidget {
  final String langugage, imagePath;
  const LangugageDropdownItem({Key key, this.imagePath, this.langugage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 35.w,
            alignment: Alignment.center,
            height: 35.h,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(imagePath), fit: BoxFit.fill),
                shape: BoxShape.circle),
          ),
          Container(
            width: 100.w,
            child: AutoSizeText(
              langugage,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: setResponsiveFontSize(15)),
            ),
          ),
        ],
      ),
    );
  }
}
