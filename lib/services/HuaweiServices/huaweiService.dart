import 'dart:convert';
import 'dart:developer';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_location/location/location_request.dart';
import 'package:huawei_location/location/location_settings_request.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:http/http.dart' as http;
import 'package:huawei_push/huawei_push_library.dart' as hawawi;
import '../../constants.dart';

class HuaweiServices {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> isHuaweiDevice() async {
    bool isFirebaseSupported = true;
    await firebaseMessaging.getToken().catchError((e) {
      isFirebaseSupported = false;
    });
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String deviceType = androidInfo.manufacturer;
    if ((deviceType == "HUAWEI" ||
            deviceType == "Huawei" ||
            deviceType == "huawei") &&
        isFirebaseSupported == false) {
      return true;
    }
    return false;
  }

  Future<Location> getHuaweiCurrentLocation() async {
    try {
      FusedLocationProviderClient locationService =
          FusedLocationProviderClient();
      LocationRequest locationRequest = LocationRequest();
      LocationSettingsRequest locationSettingsRequest = LocationSettingsRequest(
        requests: <LocationRequest>[locationRequest],
        needBle: true,
        alwaysShow: true,
      );

      Location location = await locationService.getLastLocation();
      return location;
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<String> getAccessToken() async {
    var response = await http.post(
      Uri.parse(
        "https://oauth-login.cloud.huawei.com/oauth2/v3/token",
      ),
      body: {
        "grant_type": 'client_credentials',
        "client_id": huaweiAppId,
        "client_secret": huaweiSecret
      },
    );
    print(response.body);
    return json.decode(response.body)["access_token"];
  }

  huaweiPostNotification(
      deviceToken, String title, String desc, String category) async {
    var mData = {
      "pushtype": 0,
      "pushbody": {"title": title, "description": desc, "category": category}
    };
    try {
      log("sending huawei post");

      var tokenAccess = await getAccessToken();
      var response = await http.post(
          Uri.parse(
              "https://push-api.cloud.huawei.com/v1/$huaweiAppId/messages:send"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $tokenAccess"
          },
          body: json.encode({
            "validate_only": false,
            "message": {
              "data": json.encode(mData),
              "android": {"fast_app_target": 1},
              "token": [deviceToken],
            }
          }));
      log(response.body);
      log("finshed sending..");
    } catch (e) {
      print(e);
    }
  }
}
