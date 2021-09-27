import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_location/location/location_request.dart';
import 'package:huawei_location/location/location_settings_request.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';

class HuaweiServices {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> isUnsupportedHuaweiDevice() async {
    bool isFirebaseSupported = true;
    await firebaseMessaging.getToken().catchError((e) {
      isFirebaseSupported = false;
    });
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.model == "HUAWEI" && isFirebaseSupported == false) {
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
}
