import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:huawei_location/location/location.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:trust_location/trust_location.dart';

class ShiftApi with ChangeNotifier {
  List<Shift> shiftsListProvider = [];
  Position currentPosition;
  double currentSitePositionLat;
  double currentSitePositionLong;
  Shift qrShift = Shift();
  Location currentHuaweiLocation;
  DateTime currentBackPressTime;
  String currentCountryDate;
  bool isOnShift = true;

  String siteName;
  bool isOnLocation = false;
  int isLocationServiceOn = 0;
  bool isConnected = false;
  bool permissionOff = false;
  bool firstCall = false;
  Shift userShift;
  changeFlag(bool value) {
    isOnShift = value;
    print("shift closed/opened");
  }

  static Future<bool> detectJailBreak() async {
    bool jaibreak;

    try {
      jaibreak = await FlutterJailbreakDetection.jailbroken;
    } on PlatformException {
      jaibreak = true;
    }

    return jaibreak;
  }

  Future<int> getCurrentLocation() async {
    try {
      HuaweiServices _huawi = HuaweiServices();
      if (await _huawi.isHuaweiDevice()) {
        await _huawi.getHuaweiCurrentLocation().then((value) {
          currentHuaweiLocation = value;
        });
        return 0;
      } else {
        if (await Permission.location.isGranted) {
          bool enabled = false;
          enabled = await Geolocator.isLocationServiceEnabled();
          print("api");
          print("enable locaiton : $enabled");
          if (Platform.isIOS) {
            try {
              if (enabled) {
                bool isMock = await detectJailBreak();

                if (!isMock) {
                  await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.best)
                      .then((Position position) {
                    print("position : $position");
                    currentPosition = position;
                  }).catchError((e) {
                    print(e);
                  });
                  return 0;
                } else {
                  print("Mock true");
                  if (firstCall == true) {
                    return 1;
                  }
                }
              } else {
                return 2;
              }
            } catch (e) {
              print(e);
            }
          } else {
            if (enabled) {
              bool isMockLocation = await TrustLocation.isMockLocation;

              if (!isMockLocation) {
                await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.best)
                    .then((Position position) {
                  print("position : $position");
                  currentPosition = position;
                }).catchError((e) {
                  print(e);
                });
                return 0;
              } else {
                if (firstCall == true) {
                  return 1;
                } else {
                  return 2;
                }
              }
            } else {
              return 2;
            }
          }
        } else {
          await Permission.location.request();
          return 3;
        }
      }
    } catch (e) {
      print(e);
    }
    //  await checkPermissions();

    ///check if he pressed back twich in the 2 seconds duration
  }

  // Shift currentShift = Shift(
  //     shiftName: "",
  //     shiftStartTime: 0,
  //     shiftEndTime: 0,
  //     shiftQrCode: "",
  //     siteID: 0);
  Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
    return false;
  }

  getShiftByShiftId(int shiftID, String usertoken) async {
    var response = await http.get(
      Uri.parse("$baseURL/api/Shifts/$shiftID"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $usertoken"
      },
    );
    print(response.request.url);
    print(response.body);
    print(jsonDecode(response.body)["message"]);
    if (jsonDecode(response.body)["message"] == "Success") {
      var shiftObjJson = jsonDecode(response.body)['data'];
      userShift = Shift.fromJson(shiftObjJson);
      print(userShift.shiftId);
      notifyListeners();
    }
  }

  Future<bool> getShiftData(String id, String userToken) async {
    //3shan low my3radsh el code low bara el location : low bara we 3ala nafs el screen hyasht3'al 3adi...
    // if (shiftsListProvider.isEmpty) {
    print(id);
    if (await isConnectedToInternet()) {
      isConnected = true;
      List<Shift> shiftsList;

      HuaweiServices _huawi = HuaweiServices();
      bool isHawawi = await _huawi.isHuaweiDevice();
      int isMoc;
      if (isHawawi) {
        isMoc = 0;
      } else {
        isMoc = await getCurrentLocation();
      }
      print("IS MOC RESULT : $isMoc");
      print(id);
      if (isMoc == 0) {
        final response = await http.post(
            Uri.parse("$baseURL/api/Shifts/PostSiteShift"),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            },
            body: json.encode(
              {
                "ID": id,
                "Latitude": isHawawi
                    ? currentHuaweiLocation.latitude.toString().trim()
                    : currentPosition.latitude.toString().trim(),
                "Longitude": isHawawi
                    ? currentHuaweiLocation.longitude.toString().trim()
                    : currentPosition.longitude.toString().trim()
              },
            ));
        print(response.statusCode);

        log(response.body);
        if (jsonDecode(response.body)["message"] == "Success") {
          final shiftObjJson = jsonDecode(response.body)['data'];
          qrShift = Shift.fromJsonQR(shiftObjJson);
          currentCountryDate = jsonDecode(response.body)['data']["currentTime"];

          shiftsListProvider = shiftsList;

          isOnLocation = true;
          permissionOff = true;
          isLocationServiceOn = 1;
          notifyListeners();
          return true;
        } else if (jsonDecode(response.body)["message"] ==
            "Faild : Location not found ") {
          print("isNotInLocation");

          currentSitePositionLat =
              jsonDecode(response.body)["data"]["siteLatitue"] as double;
          currentSitePositionLong =
              jsonDecode(response.body)["data"]["siteLongitude"] as double;
          siteName = jsonDecode(response.body)['data']["siteName"];
          isOnLocation = false;
          isLocationServiceOn = 1;
          permissionOff = true;

          notifyListeners();
          return false;
        } else {
          isConnected = false;
          isLocationServiceOn = 0;
          isOnLocation = false;
          notifyListeners();
          return false;
        }
      } else if (isMoc == 1) {
        print("Mock location");
        isOnLocation = false;
        isLocationServiceOn = 2;
        permissionOff = true;
        notifyListeners();
        return false;
      } else if (isMoc == 3) {
        permissionOff = false;
        isLocationServiceOn = 0;
        isOnLocation = false;
        notifyListeners();
        return false;
      } else {
        print("location off");
        isLocationServiceOn = 0;
        isOnLocation = false;
        notifyListeners();
        return false;
      }
    } else {
      isConnected = false;
      isLocationServiceOn = 0;
      isOnLocation = false;
      notifyListeners();
      return false;
    }
  }

  // bool searchForCurrentShift(int currentTime) {
  //   for (int i = 0; i < shiftsListProvider.length; i++) {
  //     var shiftStart = shiftsListProvider[i].shiftStartTime;
  //     var shiftEnd = shiftsListProvider[i].shiftEndTime;

  //     print(
  //         "---$currentTime-${shiftsListProvider[i].siteID} : ${shiftsListProvider[i].shiftStartTime}");
  //     if (currentTime < shiftsListProvider[i].shiftStartTime &&
  //         currentTime < (shiftsListProvider[i].shiftEndTime % 2400)) {
  //       currentTime += 2400;
  //       print(currentTime);
  //     }
  //     if (shiftsListProvider[i].shiftStartTime + kBeforeStartShift >= 2400) {
  //       shiftEnd += 2400;
  //     }

  //     print(
  //         "id=$i ,-- start: ${shiftsListProvider[i].shiftStartTime} ,-- end:${shiftsListProvider[i].shiftEndTime}");
  //     currentShift = shiftsListProvider[i];
  //     // changeFlag(true);
  //     return true;
  //   }

  //   // changeFlag(false);
  //   return false;
  // }
}
