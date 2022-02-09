import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_admin.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_company_pie_chart.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Core/constants.dart';
import 'Notifications/Notifications.dart';

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
          body: Column(
            children: [
              NewHeader(userData.cachedUserData),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      message.toString().contains("لا يوجد اتصال بالانترنت")
                          ? Container()
                          : Container(),
                      SizedBox(
                        height: 10.h,
                      ),
                      Lottie.asset(
                          message.toString().contains("لا يوجد اتصال بالانترنت")
                              ? "resources/noNetwork.json"
                              : "resources/maintenance.json",
                          width: 300.w,
                          height: 300.h,
                          repeat: true),
                      Container(
                        height: 100.h,
                        child: AutoSizeText(
                          message,
                          style: TextStyle(
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(20, allowFontScalingSelf: true),
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
                          width: 260.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.orange),
                          child: Center(
                            child: AutoSizeText(
                              getTranslated(context, "اضغط للماحاولة مره اخرى"),
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
          .loginPost(userData[0], userData[1], context, true)
          .catchError(((e) {
        print(e);
      })).then((value) {
        print(value);
        if (value == -4 || value == USER_INVALID_RESPONSE || value == null) {
          setState(() {
            isLoading = false;
            message = getTranslated(context,
                "التطبيق تحت الصيانة\nنجرى حاليا تحسينات و صيانة للموقع \nلن تؤثر هذه الصيانة على بيانات حسابك \n نعتذر عن أي إزعاج");
          });
        } else if (value == NO_INTERNET) {
          print("mfeeesh net");
          setState(() {
            isLoading = false;
            message = getTranslated(context,
                "لا يوجد اتصال بالأنترنت \n  برجاء اعادة المحاولة مرة اخرى");
          });
        } else if (value == 6) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SuperAdminScreen(),
              ));
        } else if (value == 4 || value == 3) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SuperCompanyPieChart(),
              ));
        } else if (value > 0) {
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
        } else if (value == -2) {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      });
    }
  }
}
