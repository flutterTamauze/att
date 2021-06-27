import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/Screens/SplashScreen.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';

import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/connectivity_service.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/report_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'enums/connectivity_status.dart';
import 'services/OrdersResponseData/OrdersReponse.dart';

List<CameraDescription> cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CompanyData(),
        ),
        ChangeNotifierProvider(
          create: (context) => DaysOffData(),
        ),
        ChangeNotifierProvider(
          create: (context) => ReportsData(),
        ),
        ChangeNotifierProvider(
          create: (context) => ShiftsData(),
        ),
        ChangeNotifierProvider(
          create: (context) => MemberData(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserData(),
        ),
        ChangeNotifierProvider(
          create: (context) => SiteData(),
        ),
        ChangeNotifierProvider(
          create: (context) => ShiftApi(),
        ),
        ChangeNotifierProvider(
          create: (context) => PermissionHan(),
        ),
        ChangeNotifierProvider(
          create: (context) => VacationData(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserPermessionsData(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderDataProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: Size(392.72, 807.27),
        builder: () {
          return StreamProvider<ConnectivityStatus>(
              create: (context) =>
                  ConnectivityService().connectionStatusController.stream,
              builder: (context, snapshot) {
                return MaterialApp(
                    title: "Chilango v3",
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(fontFamily: "Almarai-Regular"),
                    home: SplashScreen());
              });
        },
      ),
    );
  }
}
