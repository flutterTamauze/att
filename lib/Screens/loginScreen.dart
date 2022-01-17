import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/ChangePasswordScreen.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Screens/SystemScreens/forgetScreen.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Settings/LanguageSettings.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../main.dart';
import 'Notifications/Notifications.dart';
import 'SuperAdmin/Screen/super_admin.dart';
import 'SuperAdmin/Screen/super_company_pie_chart.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  TextEditingController _uniIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  var _passwordVisible = true;
  void initState() {
    languageCode =
        Provider.of<PermissionHan>(context, listen: false).isEnglishLocale()
            ? "En"
            : "Ar";

    super.initState();
  }

  String languageCode;

  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      endDrawer: NotificationItem(),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () =>
                print(Provider.of<UserData>(context, listen: false).loggedIn),
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeaderBeforeLogin(),
                Expanded(
                  child: Container(
                    height: (MediaQuery.of(context).size.height) / 1.5,
                    child: Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Form(
                        key: _loginFormKey,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: <Widget>[
                                  TextFormField(
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context).nextFocus(),
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return getTranslated(context, "مطلوب");
                                      }
                                      return null;
                                    },
                                    controller: _uniIdController,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: ScreenUtil().setSp(17,
                                            allowFontScalingSelf: true),
                                        fontWeight: FontWeight.bold),
                                    decoration:
                                        kTextFieldDecorationWhite.copyWith(
                                            hintText: getTranslated(
                                                context, "اسم المستخدم"),
                                            prefixIcon: Icon(
                                              Icons.person,
                                              color: Colors.orange,
                                            )),
                                  ),
                                  SizedBox(height: 10.0.h),
                                  Stack(
                                    children: [
                                      TextFormField(
                                        onFieldSubmitted: (_) async {
                                          FocusScope.of(context).unfocus();
                                          chechPermissions();
                                        },
                                        textInputAction: TextInputAction.done,
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return getTranslated(
                                                context, "مطلوب");
                                          } else if (text.length >= 8 &&
                                              text.length <= 12) {
                                            Pattern pattern =
                                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                                            RegExp regex = new RegExp(pattern);
                                            if (!regex.hasMatch(text)) {
                                              return ' كلمة المرور يجب ان تتكون من احرف ابجدية كبيرة و صغيرة \n وعلامات ترقيم(!@#\$&*~) و رقم';
                                            } else {
                                              return null;
                                            }
                                          } else {
                                            return getTranslated(context,
                                                "كلمة المرور يجب ان تكون اكثر من 8 احرف و اقل من 12");
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        obscureText: _passwordVisible,
                                        controller: _passwordController,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: ScreenUtil().setSp(17,
                                                allowFontScalingSelf: true),
                                            fontWeight: FontWeight.bold),
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                          hintText: getTranslated(
                                              context, 'كلمة المرور'),
                                          prefixIcon: Icon(
                                            Icons.lock,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      Provider.of<PermissionHan>(context)
                                              .isEnglishLocale()
                                          ? Positioned(
                                              right: 0,
                                              child: IconButton(
                                                icon: Icon(
                                                  // Based on passwordVisible state choose the icon
                                                  _passwordVisible
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                  setState(() {
                                                    _passwordVisible =
                                                        !_passwordVisible;
                                                    FocusScope.of(context)
                                                        .requestFocus();
                                                  });
                                                },
                                              ),
                                            )
                                          : Positioned(
                                              left: 0,
                                              child: IconButton(
                                                icon: Icon(
                                                  // Based on passwordVisible state choose the icon
                                                  _passwordVisible
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                  setState(() {
                                                    _passwordVisible =
                                                        !_passwordVisible;
                                                    FocusScope.of(context)
                                                        .requestFocus();
                                                  });
                                                },
                                              ),
                                            ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30.0.h,
                                  ),
                                  isLoading
                                      ? Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(Colors.orange),
                                          ),
                                        )
                                      : RoundedButton(
                                          onPressed: () {
                                            chechPermissions();
                                            setState(() {});
                                          },
                                          title: getTranslated(
                                              context, 'تسجيل الدخول'),
                                        ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        new MaterialPageRoute(
                                          builder: (context) =>
                                              ForgetPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      height: 20,
                                      child: AutoSizeText(
                                        getTranslated(
                                                context, "نسيت كلمة المرور") ??
                                            "نسيت كلمة المرور ؟",
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(15,
                                                allowFontScalingSelf: true),
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.orange),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        child: AutoSizeText(
                                          getTranslated(context, "لغة التطبيق"),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                        height: 10,
                                      ),
                                      Container(
                                        height: 40.h,
                                        width: 60.w,
                                        child: Container(
                                          child: Container(
                                            width: 60,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey)),
                                            child: DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                              elevation: 2,
                                              icon: Visibility(
                                                  visible: false,
                                                  child: Icon(
                                                      Icons.arrow_downward)),
                                              onChanged: (value) {
                                                print(value);
                                                Locale _tempLocal;
                                                switch (value) {
                                                  case 'Ar':
                                                    _tempLocal =
                                                        Locale("ar", "SA");
                                                    break;
                                                  case 'En':
                                                    _tempLocal =
                                                        Locale("en", "US");
                                                }
                                                setState(() {
                                                  languageCode = value;
                                                  Provider.of<PermissionHan>(
                                                          context,
                                                          listen: false)
                                                      .setLocale(_tempLocal);
                                                });
                                                print(
                                                    "current local $_tempLocal");
                                                setLocale(value == "En"
                                                    ? "en"
                                                    : "ar");
                                                MyApp.setLocale(
                                                    context, _tempLocal);
                                                Fluttertoast.showToast(
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor:
                                                        Colors.green,
                                                    msg: value == "En"
                                                        ? "Langugage has been saved successfully !"
                                                        : "تم حفظ اللغة بنجاح");
                                              },
                                              isExpanded: true,
                                              value: languageCode,
                                              items: [
                                                DropdownMenuItem(
                                                  child: FadeIn(
                                                    child:
                                                        LangugageDropdownItem(
                                                      langugage: "Arabic",
                                                      imagePath:
                                                          "resources/EgyptFlag.png",
                                                    ),
                                                  ),
                                                  value: "Ar",
                                                ),
                                                DropdownMenuItem(
                                                  child: FadeIn(
                                                    child:
                                                        LangugageDropdownItem(
                                                      langugage: "English",
                                                      imagePath:
                                                          "resources/EnglishFlag.png",
                                                    ),
                                                  ),
                                                  value: "En",
                                                )
                                              ],
                                            )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
//                                  InkWell(
//                                    onTap: () {
//                                      Navigator.of(context).push(
//                                        new MaterialPageRoute(
//                                          builder: (context) =>
//                                              GuestCompanyScreen(),
//                                        ),
//                                      );
//                                    },
//                                    child: AutoSizeText(
//                                      "الدخول كزائر",
//                                      style: TextStyle(
//                                          fontSize: 15,
//                                          decoration: TextDecoration.underline,
//                                          color: Colors.orange),
//                                    ),
//                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  chechPermissions() async {
    print("CHECKING PERMESSION");
    if (_loginFormKey.currentState.validate()) {
      if (await Permission.location.isGranted &&
          await Permission.camera.isGranted) {
        loginFunction();
      } else {
        showModalBottomSheet(
            enableDrag: true,
            context: context,
            isScrollControlled: true,
            builder: (context) => PermissionAlert(
                allAccepted: () {
                  // loginFunction();
                  Navigator.pop(context);
                },
                title: getTranslated(context, 'اعطاء تصريح'),
                content:
                    getTranslated(context, "برجاء قبول التصريحات التالية ")));
      }
    } else {
      print("validation error");
    }
  }

  loginFunction() async {
    Provider.of<UserData>(context, listen: false).getCurrentLocation();
    Provider.of<ShiftApi>(context, listen: false).getCurrentLocation();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted)
      setState(() {
        isLoading = true;
      });

    await Provider.of<UserData>(context, listen: false)
        .loginPost(
            _uniIdController.text, _passwordController.text, context, false)
        .catchError(((e) {
      print(e);
    })).then((value) async {
      if (Provider.of<UserData>(context, listen: false).changedPassword ==
          false) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePasswordScreen(
                userType: value,
                userName: _uniIdController.text,
                inAppEdit: false,
              ),
            ));
      } else {
        print("VALUE OF USER");
        print(value);
        if (value == NO_INTERNET) {
          return noInternetDialog(context).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } else if (value == null) {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: getTranslated(
                    context,
                    'خطأ في التسجيل',
                  ),
                  content: getTranslated(context, "حدث خطأ ما "),
                );
              }).then((value) => setState(() {
                isLoading = false;
              }));
        } else if (value == USER_INVALID_RESPONSE ||
            value == CONNECTION_TIMEOUT ||
            value == -3) {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: getTranslated(context, 'خطأ في التسجيل'),
                    content: getTranslated(context,
                        "التطبيق تحت الصيانة \n  برجاء اعادة المحاولة فى وقت لاحق"));
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } else if (value == 0) {
          prefs.setStringList(
              'userData', [_uniIdController.text, _passwordController.text]);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        } else if (value == 4 || value == 3) {
          prefs.setStringList(
              'userData', [_uniIdController.text, _passwordController.text]);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SuperCompanyPieChart(),
              ));
        } else if (value > 0 && value < 5) {
          prefs.setStringList(
              'userData', [_uniIdController.text, _passwordController.text]);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NavScreenTwo(0),
              ));
        } else if (value == 6) {
          prefs.setStringList(
              'userData', [_uniIdController.text, _passwordController.text]);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SuperAdminScreen()));
        } else if (value == -2) {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: getTranslated(context, 'خطأ في التسجيل'),
                    content: getTranslated(context,
                        "لقد ادخلت رقم او كلمة سر خاطئة \n  برجاء اعادة المحاولة مرة اخرى"));
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } else if (value == -4) {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: getTranslated(context, 'خطأ فى البيانات الحساب'),
                    content: getTranslated(context,
                        "الشركة متوقفة حاليا\nمن فضلك راجع مدير النظام"));
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } else {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: getTranslated(context, 'خطأ في التسجيل'),
                  content: "",
                );
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        }
      }
    });
  }
}
