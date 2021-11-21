import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants.dart';

class AttendProof {
  Future<String> sendAttendProof(
      String userToken, String userId, String fcmToken, String senderID) async {
    var response = await http.post(
        Uri.parse("$baseURL/api/AttendProof/AddAttendProof"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        body: json.encode(
          {
            "userId": userId,
            "startTime": DateTime.now().toIso8601String(),
            "CreatedByUserId": senderID
          },
        ));
    print(response.body);
    print("status code : ${response.statusCode}");
    var decodedResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (fcmToken == null) {
        return "null";
      }
      if (decodedResponse["message"] ==
          "Failed : User was not present today!") {
        return "fail present";
      } else if (decodedResponse["message"] == "Failed : Shift Time Out!") {
        return "fail shift";
      }
    } else {
      return "fail";
    }

    return "success";
  }

  Future<int> getAttendProofID(String userId, String userToken) async {
    try {
      var response = await http.get(
          Uri.parse(
              "$baseURL/api/AttendProof/GetLastAttendProofbyUser/$userId"),
          headers: {'Authorization': "Bearer $userToken"});
      print(response.statusCode);
      print(response.body);
      var decodedResponse = jsonDecode(response.body);
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
    print(response.statusCode);
    print(response.body);
    var decodedResponse = json.decode(response.body);
    if (decodedResponse["message"] == "Fail : Proof time out!") {
      return "timeout";
    } else if (decodedResponse["message"] == "Fail : Location Failed") {
      return "wrong location";
    }
    return "success";
  }
}
