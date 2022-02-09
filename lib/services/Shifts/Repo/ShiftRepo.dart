import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:huawei_location/location/location.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';

class ShiftRepo {
  Future<Object> getLateAbsenceReport(String url, String userToken,
      bool isHawawi, Location huawi, Position location, String id) async {
    return NetworkApi().request(
        url,
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
}
