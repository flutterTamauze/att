import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/ChangePasswordScreen.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Screens/SystemScreens/forgetScreen.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    super.initState();
  }

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
                                    textAlign: TextAlign.right,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context).nextFocus(),
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return '??????????';
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
                                            hintText: "?????? ????????????????",
                                            suffixIcon: Icon(
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
                                            return '??????????';
                                          } else if (text.length >= 8 &&
                                              text.length <= 12) {
                                            Pattern pattern =
                                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                                            RegExp regex = new RegExp(pattern);
                                            if (!regex.hasMatch(text)) {
                                              return ' ???????? ???????????? ?????? ???? ?????????? ???? ???????? ???????????? ?????????? ?? ?????????? \n ?????????????? ??????????(!@#\$&*~) ?? ??????';
                                            } else {
                                              return null;
                                            }
                                          } else {
                                            return "???????? ???????????? ???? ???????? ???????? ???? 8 ???????? ?? ?????? ???? 12";
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
                                        textAlign: TextAlign.right,
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                          hintText: '???????? ????????????',
                                          suffixIcon: Icon(
                                            Icons.lock,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      IconButton(
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
                                          title: '?????????? ????????????',
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
                                        "???????? ???????? ???????????? ??",
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
                                    height: 5.h,
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
//                                      "???????????? ??????????",
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
                title: '?????????? ??????????',
                content: "?????????? ???????? ?????????????????? ?????????????? "));
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
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedAlertOkOnly(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    title: "???? ???????? ?????????? ??????????????????",
                    content: "?????????? ?????????? ???????????????? ?????? ????????");
              }).then((value) {
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
                  title: '?????? ???? ??????????????',
                  content: "?????? ?????? ???? ",
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
                    title: '?????? ???? ??????????????',
                    content:
                        "?????????????? ?????? ?????????????? \n  ?????????? ?????????? ???????????????? ???? ?????? ???????? ");
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
                    title: '?????? ???? ??????????????',
                    content:
                        "?????? ?????????? ?????? ???? ???????? ???? ?????????? \n  ?????????? ?????????? ???????????????? ?????? ????????");
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
                    title: '?????? ???? ???????????????? ????????????',
                    content: "???????????? ???????????? ??????????\n???? ???????? ???????? ???????? ????????????");
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
                  title: '?????? ???? ??????????????',
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
