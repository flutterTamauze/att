import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:huawei_location/location/location.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/main.dart';

import '../../user_data.dart';

class ShiftsRepoImp {
  final userToken = locator.locator<UserData>().user.userToken;
  Future<Object> getQrData(
      bool isHawawi, Location huawi, Position location, String id) {
    return NetworkApi().request(
        "$baseURL/api/Shifts/PostSiteShift",
        RequestType.POST,
        {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        json.encode(
          {
            "ID": id,
            "Latitude": isHawawi
                ? huawi.latitude.toString().trim()
                : location.latitude.toString().trim(),
            "Longitude": isHawawi
                ? huawi.longitude.toString().trim()
                : location.longitude.toString().trim()
          },
        ));
  }

  Future<Object> getFirstAvailableSchedule(String userId) {
    return NetworkApi().request(
        "$baseURL/api/ShiftSchedule/DetailedScheduleShiftsbyUserId/$userId",
        RequestType.GET, {
      'Content-type': 'application/json',
      'Authorization': "Bearer $userToken"
    });
  }
}
