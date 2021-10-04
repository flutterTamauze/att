import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
// import 'package:audioplayers/audio_cache.dart';

// import 'package:audioplayers/audioplayers.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_location/location/location_request.dart';
import 'package:huawei_location/location/location_settings_request.dart';
import 'package:huawei_location/location/location_settings_states.dart';
import 'package:huawei_push/huawei_push_library.dart' as hawawi;
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart' as open_file;

import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';
import 'package:qr_users/Screens/AttendScanner.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

var cron1;
var cron2;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

Future<bool> detectJailBreak() async {
  bool jaibreak;

  try {
    jaibreak = await FlutterJailbreakDetection.jailbroken;
  } on PlatformException {
    jaibreak = true;
  }

  return jaibreak;
}

// AudioCache player = AudioCache();
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
void notificationPermessions() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  NotificationSettings settings = await firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print("User granted permession ${settings.authorizationStatus}");
}

bool showApk = true;

class _HomePageState extends State<HomePage> {
  static const MethodChannel _channel =
      MethodChannel('tdsChilango.com/channel_test');
  Map<String, String> channelMap = {
    "id": "ChilangoNotifications",
    "name": "tdsChilango",
    "description": "notifications",
  };
  createNewChannel() async {
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
    } catch (e) {
      print(e);
    }
  }

  Future downloadFromUrl(filename) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    ProgressDialog pr;
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: "Downloading  ...");

    final path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    await pr.show();

    final file = File("$path/$filename");
    log(file.path);
    await dio.download(
      "https://www.ostora.tv/download/v4/ostora_v4.8.apk",
      file.path,
      onReceiveProgress: (count, total) {
        setState(() {
          _isLoading = true;
          progress = ((count / total) * 100).toStringAsFixed(0) + " %";
          log(progress);
          pr.update(message: "Please wait : $progress");
        });
      },
    );
    pr.hide();
    setState(() {
      finalPath = file.path;
      _isLoading = false;
    });
    final snackBar = SnackBar(
      content: Text(
        'تم التحميل بنجاح',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        textAlign: TextAlign.right,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await open_file.OpenFile.open(file.path);
  }

  // void _onMessageReceived(hawawi.RemoteMessage remoteMessage) {
  //   //  Called when a data message is received
  //   log("message recieved ");
  //   var data = remoteMessage.data;
  //   log(data);

  //   var decodedREspo = json.decode(data);
  //   // NotificationDataService dataService = NotificationDataService();
  //   // dataService.showAttendanceCheckDialog(context);

  //   print(decodedREspo["pushbody"]);
  // }

  // void sendRemoteMsg() async {
  //   hawawi.RemoteMessageBuilder remoteMsg = hawawi.RemoteMessageBuilder(
  //       to: _token,
  //       data: {"Data": "test"},
  //       messageType: "my_type",
  //       ttl: 120,
  //       messageId: "122",
  //       collapseKey: '-1',
  //       sendMode: 1,
  //       receiptMode: 1);
  //   String result = await hawawi.Push.sendRemoteMessage(remoteMsg);
  //   print(result);
  // }

  // void _onMessageReceiveError(Object error) {
  //   // Called when an error occurs while receiving the data message
  // }
  var finalPath;
  String _filePath;
  bool _isLoading = false;
  Dio dio;
  String progress;

  @override
  void initState() {
    // test();
    print("initstate");
    print(showApk);
    dio = Dio();

    // initPlatformState();
    if (Platform.isAndroid) {
      if (showApk) {
        showApk = false;

        if (kReleaseData.isAfter(
            Provider.of<UserData>(context, listen: false).user.apkDate)) {
          Future.delayed(Duration.zero, () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RoundedAlert(
                      onPressed: () async {
                        Navigator.pop(context);
                        downloadFromUrl("ChilangoV3.apk");
                      },
                      title: 'يوجد نسخة جديدة من التطبيق',
                      content: "هل تريد تحميل النسخة الأخيرة ؟");
                });
          });
        }
      }
    }

    Provider.of<NotificationDataService>(context, listen: false)
        .firebaseMessagingConfig(context);
    Provider.of<NotificationDataService>(context, listen: false)
        .huaweiMessagingConfig(context);
    notificationPermessions();

    super.initState();
  }

  String _token = '';
  void _onTokenEvent(String event) {
    // Requested tokens can be obtained here
    setState(() {
      _token = event;
    });
    print("TokenEvent: " + _token);
  }

  void _onTokenError(Object error) {
    PlatformException e = error;
    print("TokenErrorEvent: " + e.message);
  }

  // Future<void> initPlatformState() async {
  //   var code = await hawawi.Push.getAAID();
  //   await hawawi.Push.getToken(code);
  //   if (!mounted) return;
  //   hawawi.Push.getTokenStream.listen(_onTokenEvent, onError: _onTokenError);
  //   if (!mounted) return;
  //   hawawi.Push.onMessageReceivedStream
  //       .listen(_onMessageReceived, onError: _onMessageReceiveError);
  // }

  static Future<String> getDeviceUUID() async {
    String identifier;

    try {
      if (Platform.isAndroid) {
        identifier = await FlutterUdid.udid; //UUID for Android
      } else if (Platform.isIOS) {
        final storage = new FlutterSecureStorage();
        identifier = await storage.read(key: "deviceMac"); //UUID for iOS
      }
    } catch (e) {
      print('Failed to get platform version');
    }
//if (!mounted) return;
    print(identifier);
    return identifier;
  }

  DateTime currentBackPressTime;
  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    showApk = false;
    SystemChrome.setEnabledSystemUIOverlays([]);
    print(Provider.of<PermissionHan>(context, listen: false)
        .attendProovTriggered);
    return Provider.of<PermissionHan>(context, listen: true)
            .attendProovTriggered
        ? StackedNotificaitonAlert(
            popWidget: false,
            isFromBackground: true,
            notificationTitle: "اثبات حضور",
            notificationContent: "برجاء اثبات حضورك قبل انتهاء الوقت المحدد",
            roundedButtonTitle: "اثبات",
            lottieAsset: "resources/notificationalarm.json",
            notificationToast: "تم اثبات الحضور بنجاح",
            showToast: true,
            repeatAnimation: true,
          )
        : WillPopScope(
            onWillPop: onWillPop,
            child: GestureDetector(
              onTap: () async {
                print(userDataProvider.user.apkDate);
                // HuaweiServices _huawei = HuaweiServices();
                // _huawei.huaweiPostNotification(
                //     "AHuhHui46-M2C1qnHjbr7G8w2bE1mMLrsSGtO3evA0bioqW-Y-XJBVaGVmYQdRDr8SucpuKwK5RpYroHi453nq75fyj5vyIxp34F_BODqD9-MYYHpPshUiohLboipAVOvw",
                //     "اثبات حضور",
                //     "برجاء اثبات حضورك الأن",
                //     "attend");

                // // await huaweiServices.huaweiPostNotification(
                //     "AGZ8A8VIgh_7YdND0zl4rdDyELzf8z7WTA29kFj92suWmP1ldxHBSWcLwAsioNduuEf1rXlM0ZRlbss9ba_reqYSivXdSLCxcKD8Kms0RTFMymlmMccP_qpm9g2-93WW1Q");
                // String accessToken = await (getAccessToken());
                // await huaweiPostNotification(accessToken, _token);
                // sendRemoteMsg();
                // FusedLocationProviderClient locationService =
                //     FusedLocationProviderClient();
                // LocationRequest locationRequest = LocationRequest();
                // LocationSettingsRequest locationSettingsRequest =
                //     LocationSettingsRequest(
                //   requests: <LocationRequest>[locationRequest],
                //   needBle: true,
                //   alwaysShow: true,
                // );

                // try {
                //   Location location = await locationService.getLastLocation();
                //   print(location.latitude);
                //   print(location.longitude);
                // } catch (e) {
                //   print(e.toString());
                // }
              },
              child: Scaffold(
                endDrawer: NotificationItem(),
                backgroundColor: Colors.white,
                drawer: userDataProvider.user.userType == 0 ? DrawerI() : null,
                body: Container(
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        userDataProvider.user.userType == 0
                            ? Header(
                                nav: true,
                              )
                            : Container(),
                        Expanded(
                          child: Center(
                            child: Lottie.asset("resources/qrlottie.json",
                                repeat: true),
                          ),
                        ),
                        Column(
                          children: [
                            Provider.of<PermissionHan>(context, listen: true)
                                        .showNotification ==
                                    true
                                ? Container()
                                : Container(
                                    child: RoundedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ScanPage(),
                                          ),
                                        );
                                      },
                                      title: "سجل الأن",
                                    ),
                                  ),
                            SizedBox(
                              height: 15.h,
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    ///check if he pressed back twich in the 2 seconds duration
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: "اضغط مره اخرى للخروج من التطبيق",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.orange,
        fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
      );
      return Future.value(false);
    } else {
      SystemNavigator.pop();
      return Future.value(false);
    }
  }
}
