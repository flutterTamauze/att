import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/main.dart';

import '../../user_data.dart';

class ShiftsRepoImp {
  final userToken = locator.locator<UserData>().user.userToken;
  Future<Object> getQrData(Position location, String id) {
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
            "Latitude": location.latitude.toString().trim(),
            "Longitude": location.longitude.toString().trim()
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
