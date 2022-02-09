import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_company_pie_chart.dart';
import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _forgetFormKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();
  intlPhone.PhoneNumber number =
      intlPhone.PhoneNumber(dialCode: "+20", isoCode: "EG");
  TextEditingController _usernameController = TextEditingController();
  var isLoading = false;

  String signature;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: NotificationItem(),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeaderBeforeLogin(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      height: (MediaQuery.of(context).size.height) / 1.5,
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Form(
                          key: _forgetFormKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 200.w,
                                height: 90.h,
                                child: Lottie.asset("resources/locklottie.json",
                                    height: 120.h, repeat: false),
                              ),
                              SizedBox(
                                height: 40.h,
                              ),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return getTranslated(context, "مطلوب");
                                  }
                                  return null;
                                },
                                controller: _usernameController,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ScreenUtil()
                                        .setSp(15, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold),
                                decoration: kTextFieldDecorationWhite.copyWith(
                                    hintText:
                                        getTranslated(context, "اسم المستخدم"),
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: Colors.orange,
                                    )),
                              ),
                              SizedBox(height: 10.0.h),
                              Container(
                                child: InternationalPhoneNumberInput(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: setResponsiveFontSize(15)),
                                  isEnabled: true,
                                  countries: [
                                    "EG",
                                    "SA",
                                    "BH",
                                    "KW",
                                    "IQ",
                                    "JO",
                                    "LB",
                                    "QA",
                                    "SY",
                                    "AE",
                                    "YE",
                                    "OM",
                                    "MA",
                                    "LY",
                                  ],
                                  onSubmit: () {},
                                  errorMessage: _phoneController.text.isEmpty
                                      ? "مطلوب"
                                      : "رقم خاطئ",
                                  inputDecoration:
                                      kTextFieldDecorationWhite.copyWith(
                                          hintText: getTranslated(
                                              context, "رقم الهاتف"),
                                          prefixIcon: Icon(
                                            Icons.phone,
                                            color: Colors.orange,
                                          )),
                                  onInputChanged:
                                      (intlPhone.PhoneNumber number2) {
                                    print(_phoneController.text);
                                    number = number2;
                                  },
                                  onInputValidated: (bool value) async {
                                    if (value) {}
                                  },
                                  spaceBetweenSelectorAndTextField: 0,
                                  selectorConfig: const SelectorConfig(
                                    showFlags: true,
                                    useEmoji: true,
                                    setSelectorButtonAsPrefixIcon: true,
                                    selectorType: PhoneInputSelectorType.DIALOG,
                                  ),
                                  cursorColor: Colors.grey,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  searchBoxDecoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: setResponsiveFontSize(15),
                                          fontWeight: FontWeight.w700),
                                      hintText: getTranslated(context,
                                          "اختر بأسم البلد او الرقم الدولى"),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0))),
                                  initialValue: number,
                                  textFieldController: _phoneController,
                                  formatInput: true,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  inputBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onSaved: (intlPhone.PhoneNumber number) {},
                                ),
                              ),
                              SizedBox(
                                height: 30.0.h,
                              ),
                              isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                      ),
                                    )
                                  : RoundedButton(
                                      onPressed: () async {
                                        forgetFunction();
                                      },
                                      title: getTranslated(context, 'متابعة'),
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
          Positioned(
            left: 4.0.w,
            top: 4.0.h,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: const Color(0xffF89A41),
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

  forgetFunction() async {
    if (_forgetFormKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      print(_usernameController.text);
      print(number.toString());
      await Provider.of<UserData>(context, listen: false)
          .forgetPassword(_usernameController.text, number.toString().trim())
          .catchError(((e) {
        print(e);
      })).then((value) {
        if (value == "success") {
          Fluttertoast.showToast(
              msg: getTranslated(context,
                  "تم ارسال رمز التفعيل على الهاتف و البريد الإلكترونى الخاص بكم"),
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.black,
              textColor: Colors.orange);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ForgetSetPassword(
                    _usernameController.text, number.toString().trim()),
              ));
        } else if (value == "noInternet") {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: getTranslated(context, 'خطأ في تغيير كلمة المرور'),
                    content: getTranslated(context, "لا يوجد اتصال بالانترنت"));
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } else if (value == "wrong") {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: getTranslated(context, 'خطأ في تغيير كلمة المرور'),
                    content: "رقم المستخدم غير موجود");
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } else if (value == "failed") {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: getTranslated(context, 'خطأ فى بيانات الحساب'),
                    content:
                        getTranslated(context, "من فضلك راجع مدير النظام"));
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
                  title: 'خطأ في تغيير كلمة المرور',
                  content: "",
                );
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        }
      });
      //      Provider.of<UserData>(context, listen: false)
      // .loginPost(_uniIdController.text, _passwordController.text);
      // print(Provider.of<UserData>(context, listen: false).user.userID);

    }

    // }

    else {
      print("validation error");
    }
  }
}

class ForgetSetPassword extends StatefulWidget {
  final userName;
  final email;

  const ForgetSetPassword(this.userName, this.email);

  @override
  _ForgetSetPasswordState createState() => _ForgetSetPasswordState();
}

class _ForgetSetPasswordState extends State<ForgetSetPassword>
    with TickerProviderStateMixin {
  final _setPasswordFormKey = GlobalKey<FormState>();
  DateTime currentBackPressTime = DateTime.now();
  TextEditingController _pinCodeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _rePasswordController = TextEditingController();
  var isLoading = false;
  var reSend = true;
  var _passwordVisible = true;
  var _rePasswordVisible = true;
  AnimationController _controller;
  int levelClock = 180;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    startTimeout();
    super.initState();
  }

  final int timerMaxSeconds = 60;

  int currentSeconds = 0;
  final interval = const Duration(seconds: 1);
  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout([int milliseconds]) {
    final duration = interval;
    Timer.periodic(duration, (timer) {
      setState(() {
        print(timer.tick);
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) {
          timer.cancel();
          setState(() {
            reSend = !reSend;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeaderBeforeLogin(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      height: (MediaQuery.of(context).size.height) / 1.5,
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Form(
                          key: _setPasswordFormKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 60.h,
                              ),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return getTranslated(context, "مطلوب");
                                  }
                                  return null;
                                },
                                controller: _pinCodeController,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ScreenUtil()
                                        .setSp(17, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold),
                                decoration: kTextFieldDecorationWhite.copyWith(
                                  hintText:
                                      getTranslated(context, 'رمز التفعيل'),
                                  suffixIcon: const Icon(
                                    Icons.lock_clock,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0.h,
                              ),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return getTranslated(context, "مطلوب");
                                  } else if (text.length >= 8 &&
                                      text.length <= 12) {
                                    const Pattern pattern =
                                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                                    final RegExp regex = new RegExp(pattern);
                                    if (!regex.hasMatch(text)) {
                                      return getTranslated(context,
                                          "كلمة المرور يجب ان تتكون من احرف ابجدية كبيرة و صغيرة");
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
                                    fontSize: ScreenUtil()
                                        .setSp(17, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold),
                                decoration: kTextFieldDecorationWhite.copyWith(
                                  hintText:
                                      getTranslated(context, 'كلمة المرور'),
                                  suffixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.orange,
                                  ),
                                  prefixIcon: IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      _passwordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0.h,
                              ),
                              TextFormField(
                                onFieldSubmitted: (_) {
                                  changePasswordFunction();
                                },
                                textInputAction: TextInputAction.done,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return getTranslated(context, "مطلوب");
                                  } else if (text != _passwordController.text) {
                                    return 'كلمة المرور غير متطابقتان';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                obscureText: _rePasswordVisible,
                                controller: _rePasswordController,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ScreenUtil()
                                        .setSp(17, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold),
                                decoration: kTextFieldDecorationWhite.copyWith(
                                  hintText: getTranslated(
                                      context, 'تأكيد كلمة المرور'),
                                  suffixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.orange,
                                  ),
                                  prefixIcon: IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      _rePasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _rePasswordVisible =
                                            !_rePasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30.0.h,
                              ),
                              isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                      ),
                                    )
                                  : RoundedButton(
                                      onPressed: () async {
                                        changePasswordFunction();
                                      },
                                      title: getTranslated(
                                        context,
                                        'متابعة',
                                      )),
                              SizedBox(
                                height: 5.h,
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (!reSend) {
                                    await textChanger();
                                    startTimeout();
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  child: AutoSizeText(
                                    (!reSend)
                                        ? getTranslated(
                                            context, "اعادة ارسال رمز التفعيل")
                                        : getTranslated(context,
                                            "لم يصلك رمز التفعيل ؟\n لإعادة الإرسال برجاء الانتظار"),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(13,
                                            allowFontScalingSelf: true),
                                        fontWeight: FontWeight.w600,
                                        height: 2,
                                        decoration: (!reSend)
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        color: (!reSend)
                                            ? Colors.orange
                                            : Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              reSend
                                  ? AutoSizeText(
                                      timerText,
                                      style: TextStyle(
                                          fontSize: setResponsiveFontSize(17),
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Container()
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

  textChanger() {
    final DateTime now = DateTime.now();

    ///check if he pressed back twich in the 2 seconds duration
    if (now.difference(currentBackPressTime) > const Duration(seconds: 10)) {
      currentBackPressTime = now;
      forgetFunction();
    } else {
      Fluttertoast.showToast(
          msg: getTranslated(
            context,
            "يرجى الانتظار قليلا للحصول على رمز التفعيل قبل إعادة المحاولة مرة أخرى",
          ),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.orange,
          fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
    }
  }

  Future<void> forgetFunction() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<UserData>(context, listen: false)
        .forgetPassword(widget.userName, widget.email)
        .catchError(((e) {
      print(e);
    })).then((value) {
      if (value == "success") {
        setState(() {
          reSend = true;
        });

        Fluttertoast.showToast(
            msg: getTranslated(
                context, "تم ارسال رمز التفعيل بنجاح على رقم الهاتف الخاص بكم"),
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black,
            textColor: Colors.orange);
      } else if (value == "noInternet") {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedAlertOkOnly(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: getTranslated(context, 'خطأ في تغيير كلمة المرور'),
                  content: getTranslated(context, "لا يوجد اتصال بالانترنت"));
            }).then((value) {
          setState(() {
            isLoading = false;
          });
        });
      } else if (value == "wrong") {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedAlertOkOnly(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: getTranslated(context, 'خطأ في تغيير كلمة المرور'),
                  content: getTranslated(context, "رقم المستخدم غير موجود"));
            }).then((value) {
          setState(() {
            isLoading = false;
          });
        });
      } else if (value == "failed") {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedAlertOkOnly(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: getTranslated(context, 'خطأ فى بيانات الحساب'),
                  content: getTranslated(context, "من فضلك راجع مدير النظام"));
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
                title: getTranslated(context, 'خطأ في تغيير كلمة المرور'),
                content: "",
              );
            }).then((value) {
          setState(() {
            isLoading = false;
          });
        });
      }
    });
  }

  changePasswordFunction() async {
    if (_setPasswordFormKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await Provider.of<UserData>(context, listen: false)
          .setPassword(
              password: _passwordController.text,
              pinCode: _pinCodeController.text,
              username: widget.userName)
          .catchError(((e) {
        print(e);
      })).then((value) {
        if (value == "success") {
          loginFunction();
          Fluttertoast.showToast(
              msg: "تم تغيير كلمة المرور بنجاح",
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.black,
              textColor: Colors.orange);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
        } else if (value == "noInternet") {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: getTranslated(context, 'خطأ في تغيير كلمة المرور'),
                    content: getTranslated(context, "لا يوجد اتصال بالانترنت"));
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } else if (value == "wrong") {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: getTranslated(context, 'خطأ في تغيير كلمة المرور'),
                    content: getTranslated(context, "رمز تفعيل غير صحيح"));
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } else if (value == "failed") {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: getTranslated(context, 'خطأ فى بيانات الحساب'),
                    content:
                        getTranslated(context, "من فضلك راجع مدير النظام"));
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
                  title: 'خطأ في تغيير كلمة المرور',
                  content: "",
                );
              }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        }
      });
    }

    // }

    else {
      print("validation error");
    }
  }

  loginFunction() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await Provider.of<UserData>(context, listen: false)
        .loginPost(widget.userName, _passwordController.text, context, true)
        .catchError(((e) {
      print(e);
    })).then((value) async {
      if (value == 0) {
        prefs.setStringList(
            'userData', [widget.userName, _passwordController.text]);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
      } else if (value == NO_INTERNET) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedAlertOkOnly(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: getTranslated(context, 'لا يوجد اتصال بالانترنت'),
                  content: getTranslated(context, "برجاء المحاولة مرة اخرى"));
            }).then((value) {
          setState(() {
            isLoading = false;
          });
        });
      } else if (value == USER_INVALID_RESPONSE) {
        return serverDownDialog(context).then((value) {
          setState(() {
            isLoading = false;
          });
        });
      } else if (value == 4 || value == 3) {
        prefs.setStringList(
            'userData', [widget.userName, _passwordController.text]);
        await Provider.of<UserData>(context, listen: false)
            .getSuperCompanyChart(
                Provider.of<UserData>(context, listen: false).user.userToken,
                Provider.of<CompanyData>(context, listen: false).com.id);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuperCompanyPieChart(),
            ));
      } else if (value > 0) {
        prefs.setStringList(
            'userData', [widget.userName, _passwordController.text]);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const NavScreenTwo(0),
            ));
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
      } else if (value == -4 || value == null) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedAlertOkOnly(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: getTranslated(context, 'خطأ فى البيانات الحساب'),
                  content: getTranslated(context,
                      "الخدمة متوقفة حاليا\nمن فضلك راجع مدير النظام"));
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
    });
  }
}
