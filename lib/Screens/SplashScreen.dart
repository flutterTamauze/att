import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/db/SqlfliteDB.dart';
import 'package:qr_users/MLmodule/db/database.dart';
import 'package:qr_users/MLmodule/recognition_services/facenet.service.dart';
import 'package:qr_users/Screens/ChangePasswordScreen.dart';
import 'package:qr_users/Screens/ErrorScreen.dart';
import 'package:qr_users/Screens/HomePage.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_admin.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Screens/errorscreen2.dart';
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:huawei_push/huawei_push_library.dart' as hawawi;
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;
import '../Screens/intro.dart';
import 'package:http/http.dart' as http;

import '../Core/constants.dart';
import 'SuperAdmin/Screen/super_company_pie_chart.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;

  DataBaseService _dataBaseService = DataBaseService();
  FaceNetService _faceNetService = FaceNetService();
  // MLKitService _mlKitService = MLKitService();
  Future checkSharedUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userData = (prefs.getStringList('userData') ?? null);
    print(userData);
    if (userData == null || userData.isEmpty) {
      await reverse("", 1);
    } else {
      var value = await login(userName: userData[0], password: userData[1]);

      print("VALUE OF USER $value");
      //  Provider.of<DaysOffData>(context, listen: false).getDaysOff(
      //       Provider.of<CompanyData>(context, listen: false).com.id,
      //       Provider.of<UserData>(context, listen: false).user.userToken,
      //       context);
      if (value == 4) {
        //subscribe admin channel
        bool isError = false;

        await firebaseMessaging.getToken().catchError((e) {
          print(e);
          isError = true;
        });
        if (isError == false) {
          print("topic name : ");
          print(
              "attend${Provider.of<CompanyData>(context, listen: false).com.id}");
          if (Provider.of<UserData>(context, listen: false).user.osType == 3) {
            await hawawi.Push.subscribe(
                "attend${Provider.of<CompanyData>(context, listen: false).com.id}");
          } else {
            await firebaseMessaging.subscribeToTopic(
                "attend${Provider.of<CompanyData>(context, listen: false).com.id}");
          }
        }
      }

      reverse(userData[0], value);
    }
  }

  checkAttendProovStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("notifCategory") == 'attend') {
      Provider.of<PermissionHan>(context, listen: false).triggerAttendProof();
    }
  }

  Future<int> login({String userName, String password}) async {
    Provider.of<UserData>(context, listen: false).getCurrentLocation();
    Provider.of<ShiftApi>(context, listen: false).getCurrentLocation();

    return Provider.of<UserData>(context, listen: false)
        .loginPost(userName, password, context, true)
        .catchError(((e) {
      print(e);
    }));
  }

  Future getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cachedUserData = (prefs.getStringList('allUserData') ?? null);
    if (cachedUserData == null || cachedUserData.isEmpty) {
      print('null');
    } else {
      print('not null');
      print(cachedUserData[4]);
      Provider.of<UserData>(context, listen: false)
          .setCacheduserData(cachedUserData);
    }
  }

  AnimationController animationController;
  reverse(String userName, value) {
    //Reverse animation Function
    final UserData userData = Provider.of<UserData>(context, listen: false);

    setState(() {
      animationController.reverse();
      Timer(new Duration(milliseconds: 2000), () async {
        if (userName != "") {
          if (Provider.of<UserData>(context, listen: false).changedPassword ==
              false) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen(
                    userType: value,
                    userName: userName,
                    inAppEdit: false,
                  ),
                ));
          } else {
            print(value);
            if (value == -4 ||
                value == USER_INVALID_RESPONSE ||
                value == UNKNOWN_ERROR ||
                value == -3 ||
                value == null) {
              await getUserData();
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (context) => ErrorScreen(
                      "?????????????? ?????? ??????????????\n???????? ?????????? ?????????????? ?? ?????????? ???????????? \n???? ???????? ?????? ?????????????? ?????? ???????????? ?????????? \n ?????????? ???? ???? ??????????",
                      true)));
            } else if (value == NO_INTERNET) {
              await getUserData();
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (context) => ErrorScreen(
                      "???? ???????? ?????????? ??????????????????\n?????????? ?????????? ????????????????", true)));
            } else if (value == 4 || value == 3) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuperCompanyPieChart(),
                  ));
            } else if (value > 0 && value < 6) {
              print(" usertype $value");

              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return NavScreenTwo(0);
              }));

              getUserData();
            } else if (value == 6) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return SuperAdminScreen();
              }));
              getUserData();
            } else if (value == 0) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Container(
                        child: userData.cachedUserData.isNotEmpty
                            ? ErrorScreen2(child: HomePage())
                            : HomePage()),
                  ));
              getUserData();
            } else if (value == -2) {
              Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(builder: (context) => LoginScreen()));
            } else {
              Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(builder: (context) => PageIntro()));
            }
          }
        } else {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => PageIntro()));
        }
      });
    });
  }

  // loadModel() async {
  //   var interpreterOptions = InterpreterOptions()..addDelegate(NnApiDelegate());
  //   final interpreter = await Interpreter.fromAsset('model_unquant.tflite',
  //       options: interpreterOptions);
  //   print("Result after loading model  : $interpreter");
  //   // var result = await Tflite.loadModel(
  //   //     labels: "assets/labels.txt", model: "assets/model_unquant.tflite");
  //   // print("Result after loading model  : $result");
  // }

  loadSecondModel() async {
    // start the services
    await _faceNetService.loadModel();
    await _dataBaseService.loadDB();

    // await firebaseMessaging.subscribeToTopic("testing");
    // _mlKitService.initialize();
  }

  String _token = "";
  void _onTokenEvent(String event) {
    _token = event;
    print("TokenEvent: " + _token);
  }

  initPlatformState() async {
    var code = await hawawi.Push.getAAID();
    await hawawi.Push.getToken(code);
    hawawi.Push.getTokenStream.listen(_onTokenEvent).onData((data) {
      Provider.of<UserData>(context, listen: false).hawawiToken = data;
    });
  }

  HuaweiServices huaweiServices = HuaweiServices();
  fillHuaweiToken() async {
    bool isHuawei = await huaweiServices.isHuaweiDevice();
    if (isHuawei) {
      log("iS HUAWEI IS SUCCESS");
      await initPlatformState();
    }
  }

  @override
  void initState() {
    super.initState();
    // filterList();
    // loadModel();
    if (Platform.isAndroid) {
      fillHuaweiToken();
    }

    loadSecondModel();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    //start Animation
    animationController.forward();

    new Timer(new Duration(milliseconds: 1), () async {
      await checkSharedUserData();
      await checkAttendProovStatus();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: !isLoading
          ? Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: <Widget>[
                  FadeTransition(
                    opacity: animationController.drive(
                      CurveTween(curve: Curves.fastOutSlowIn),
                    ),
                    child: Stack(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                            child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              'resources/image.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          height: 150.h,
                          width: 150.w,
                        )),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              width: 500.w,
                              child: Lottie.asset("resources/fire.json",
                                  fit: BoxFit.fitWidth),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10.h,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 140.w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 130.h,
                                      child: Image.asset(
                                        'resources/TDSlogo.png',
                                        fit: BoxFit.fitHeight,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
                  backgroundColor: Colors.black,
                ),
              ),
            ),
    );
  }
}
