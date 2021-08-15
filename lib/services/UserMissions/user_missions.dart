import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/constants.dart';

class UserMissions {
  DateTime fromDate, toDate;
  String description, userId;
  int shiftId;
  UserMissions(
      {this.description,
      this.fromDate,
      this.shiftId,
      this.toDate,
      this.userId});
  factory UserMissions.fromJson(dynamic json) {
    return UserMissions(
        description: json["desc"],
        fromDate: DateTime.tryParse(json["fromdate"]),
        toDate: DateTime.tryParse(json["toDate"]),
        shiftId: json["shiftId"],
        userId: json["userId"]);
  }
}

class MissionsData with ChangeNotifier {
  List<UserMissions> missionsList = [];
  bool isLoading = false;
  addUserMission(
    UserMissions userMissions,
    String userToken,
  ) async {
    isLoading = true;
    notifyListeners();
    var response = await http.post(
        Uri.parse("$baseURL/api/InternalMission/AddInternalMission"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        body: json.encode({
          "fromdate": userMissions.fromDate.toIso8601String(),
          "shiftId": userMissions.shiftId,
          "toDate": userMissions.toDate.toIso8601String(),
          "userId": userMissions.userId,
          "desc": userMissions.description
        }));
    isLoading = false;
    notifyListeners();
    print(response.body);
    return json.decode(response.body)["message"];
  }
}
