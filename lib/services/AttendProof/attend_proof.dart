import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants.dart';

class AttendProof {
  sendAttendProof(String userToken, String userId) async {
    var response = await http.post(
        Uri.parse("$baseURL/api/AttendProof/AddAttendProof"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        body: json.encode(
            {"userId": userId, "startTime": DateTime.now().toIso8601String()}));
    print(response.body);
  }

  Future<int> getAttendProofID(String userId) async {
    var response = await http.get(
        Uri.parse("$baseURL/api/AttendProof/GetLastAttendProofbyUser/$userId"));
    print(response.body);
    var decodedResponse = jsonDecode(response.body);
    if (decodedResponse["message"] == "Success") {
      return decodedResponse["data"];
    }
    return -1;
  }

  acceptAttendProof(String userToken, String attendId, Position latLng) async {
    var response = await http.put(
      Uri.parse("$baseURL/api/AttendProof/Approve"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
      body: json.encode({
        "id": attendId,
        "longitude": latLng.longitude,
        "latitude": latLng.latitude
      }),
    );
    print(response.body);
  }
}
