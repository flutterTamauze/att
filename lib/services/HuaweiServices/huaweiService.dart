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
import '../../Core/constants.dart';

class HuaweiServices {
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

  huaweiSendToTopic(String title, String desc, String topicName) async {
    try {
      // log("sending huawei topic post");

      var tokenAccess = await getAccessToken();
      var response = await http.post(
          Uri.parse(
              "https://push-api.cloud.huawei.com/v1/$huaweiAppId/messages:send"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $tokenAccess"
          },
          body: json.encode({
            {
              "validate_only": false,
              "message": {
                "notification": {"title": title, "body": desc},
                "android": {
                  "notification": {
                    "click_action": {
                      "type": 1,
                      "action": "com.huawei.codelabpush.intent.action.test"
                    }
                  }
                },
                "topic": topicName
              }
            }
          }));
      log(response.body);
      // log("finshed sending..");
    } catch (e) {
      print(e);
    }
  }

  huaweiPostNotification(
      deviceToken, String title, String desc, String category) async {
    var mData = {
      "pushtype": 1,
      "pushbody": {"title": title, "description": desc, "category": category},
      "params": {"title": title, "description": desc}
    };
    try {
      // log("sending huawei post");

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
              "android": {
                "fast_app_target":
                    1, // The value 1 indicates that the message is sent to a quick app running on Quick App Loader. To send message to a quick app to be released on AppGallery, set the value to 2.
                "collapse_key": -1,
                "delivery_priority": "HIGH",
                "ttl": "1448s",
                "bi_tag": "Trump",
              },
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
