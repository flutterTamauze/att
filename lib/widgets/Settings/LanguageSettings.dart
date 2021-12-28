import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/permissions_data.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({
    this.locale,
    Key key,
  }) : super(key: key);
  final String locale;
  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  String languageCode;
  @override
  void initState() {
    languageCode = widget.locale;
    print(languageCode);
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: Container(
            height: 100.h,
            width: 300.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "اختر لغة التطبيق",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Divider(),
                Expanded(
                    child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey)),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                    elevation: 2,
                    onChanged: (value) {
                      print(value);
                      Locale _tempLocal;
                      switch (value) {
                        case 'Ar':
                          _tempLocal = Locale("ar", "SA");
                          break;
                        case 'En':
                          _tempLocal = Locale("en", "US");
                      }
                      setState(() {
                        languageCode = value;
                        Provider.of<PermissionHan>(context, listen: false)
                            .setLocale(_tempLocal);
                      });
                      print("current local $_tempLocal");
                      MyApp.setLocale(context, _tempLocal);
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.green,
                          msg: value == "En"
                              ? "Langugage has been saved successfully !"
                              : "تم حفظ اللغة بنجاح");
                    },
                    isExpanded: true,
                    value: languageCode,
                    items: [
                      DropdownMenuItem(
                        child: FadeIn(
                          child: LangugageDropdownItem(
                            langugage: "Arabic",
                            imagePath: "resources/EgyptFlag.png",
                          ),
                        ),
                        value: "Ar",
                      ),
                      DropdownMenuItem(
                        child: FadeIn(
                          child: LangugageDropdownItem(
                            langugage: "English",
                            imagePath: "resources/EnglishFlag.png",
                          ),
                        ),
                        value: "En",
                      )
                    ],
                  )),
                ))
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AutoSizeText(
          langugage,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Image(
          width: 60,
          height: 30,
          image: AssetImage(
            imagePath,
          ),
          fit: BoxFit.cover,
        )
      ],
    );
  }
}
