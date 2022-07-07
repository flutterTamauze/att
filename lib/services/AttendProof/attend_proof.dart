import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Core/constants.dart';

class AttendProof {
  // String proofId;
  // String getProofId() => proofId;
  Future<String> sendAttendProof(
      String userToken, String userId, String fcmToken, String senderID) async {
    final response = await http.post(
      Uri.parse("$baseURL/api/AttendProof/AddAttendProof?userid=$userId"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
    final decodedResponse = jsonDecode(response.body);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      if (fcmToken == null) {
        return "null";
      }
      // proofId = decodedResponse["data"];
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
      } else if (decodedResponse["message"] ==
          "Failed : You can't send attend proof for this user!") {
        return "cant send";
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

      final decodedResponse = jsonDecode(response.body);
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
      String userToken, String userId, Position latLng) async {
    final response = await http.put(
      Uri.parse("$baseURL/api/AttendProof/Approve"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
      body: json.encode({
        "userId": userId,
        "longitude": latLng.longitude,
        "latitude": latLng.latitude
      }),
    );
    print(userId);

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
