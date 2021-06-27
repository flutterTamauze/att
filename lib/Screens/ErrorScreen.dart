import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorScreen extends StatefulWidget {
  final message;
  final rep;
  ErrorScreen(this.message, this.rep);

  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  var message;
  var isLoading = false;

  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    message = widget.message;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(builder: (context, userData, child) {
      return MaterialApp(
        theme: ThemeData(fontFamily: "Almarai-Regular"),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          drawer: DrawerI(),
          body: Column(
            children: [
              NewHeader(userData.cachedUserData),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      message.toString().contains("لا يوجد اتصال بالانترنت")
                          ? Container(
                              child: Lottie.asset(
                                  "resources/21485-wifi-outline-icon.json",
                                  repeat: false),
                              height: 200.h,
                              width: 200.w,
                            )
                          : Container(),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        height: 40,
                        child: AutoSizeText(
                          message,
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(18, allowFontScalingSelf: true),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          widget.rep ? login() : Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          // height: 100,
                          width: 260,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.orange),
                          child: Center(
                            child: AutoSizeText(
                              "اضغط للمحاولة مره اخرى",
                              maxLines: 1,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil()
                                      .setSp(18, allowFontScalingSelf: true),
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  login() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userData = (prefs.getStringList('userData') ?? null);

    if (userData == null || userData.isEmpty) {
      print('null');
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      print('not null');
      await Provider.of<UserData>(context, listen: false)
          .loginPost(userData[0], userData[1], context)
          .catchError(((e) {
        print(e);
      })).then((value) {
        if (value > 0) {
          print("laaa");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NavScreenTwo(0),
              ));
        } else if (value == 0) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ));
        } else if (value == -1) {
          print("mfeh");
          setState(() {
            isLoading = false;
            message = "لا يوجد اتصال بالانترنت";
          });
        } else if (value == -2) {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => LoginScreen()));
        } else if (value == -5) {
          print("mfeeesh net");
          setState(() {
            isLoading = false;
            message = "لا يوجد اتصال بالانترنت\nبرجاء المحاولة مرة اخرى";
          });
        } else if (value == -3) {
          print("mfeesh net wlahi");
          setState(() {
            isLoading = false;
            message = "خطأ فى بيانات الحساب\nمن فضلك راجع مدير النظام";
          });
        } else if (value == -4) {
          setState(() {
            isLoading = false;
            message =
                "خطأ فى بيانات الحساب\nالخدمة متوقفة حاليا\nمن فضلك راجع مدير النظام";
          });
        } else {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      });
    }
  }
}
