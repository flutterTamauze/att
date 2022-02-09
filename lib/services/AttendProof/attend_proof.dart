import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:qr_users/Network/networkInfo.dart';
import 'dart:convert';

import '../../Core/constants.dart';
import '../../main.dart';

class AttendProof {
  Future<String> sendAttendProof(
      String userToken, String userId, String fcmToken, String senderID) async {
    print(userId);
    final response = await http.post(
      Uri.parse("$baseURL/api/AttendProof/AddAttendProof?userid=$userId"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );

    print("status code : ${response.statusCode}");
    final decodedResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (fcmToken == null) {
        return "null";
      }

      if (decodedResponse["message"] ==
          "Failed : User was not present today!") {
        return "fail present";
      } else if (decodedResponse["message"] ==
          "Success : AttendProof Created!") {
        return "success";
      } else if (decodedResponse["message"] == "Failed : Shift Time Out!") {
        return "fail shift";
      } else if (decodedResponse["message"] ==
          "Failed : You have exceeded proofs limits!") {
        return "limit exceed";
      }
    } else {
      return "fail";
    }

    return "fail";
  }

  Future<int> getAttendProofID(String userId, String userToken) async {
    try {
      final response = await http.get(
          Uri.parse(
              "$baseURL/api/AttendProof/GetLastAttendProofbyUser/$userId"),
          headers: {'Authorization': "Bearer $userToken"});
      print(response.statusCode);
      print(response.body);
      final decodedResponse = jsonDecode(response.body);
      print(decodedResponse["message"]);
      if (decodedResponse["message"] == "Success") {
        return decodedResponse["data"];
      } else {
        return -1;
      }
    } catch (e) {
      print(e);
    }
    return -1;
  }

  Future<String> acceptAttendProof(
      String userToken, String attendId, Position latLng) async {
    final response = await http.put(
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
    print(response.statusCode);
    print(response.body);
    final decodedResponse = json.decode(response.body);
    if (decodedResponse["message"] == "Fail : Proof time out!") {
      return "timeout";
    } else if (decodedResponse["message"] == "Fail : Location Failed") {
      return "wrong location";
    }
    return "success";
  }
}
