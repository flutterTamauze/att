import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/UserMissions/CompanyMissions.dart';

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
  List<CompanyMissions> companyMissionsList = [];
  List<CompanyMissions> singleUserMissionsList = [];
  bool isLoading = false;
  List<String> userNames = [];
  List<CompanyMissions> copyMissionsList = [];
  getAllUserNamesInMission() {
    userNames = [];
    companyMissionsList.forEach((element) {
      userNames.add(element.userName);
    });
    // notifyListeners();
  }

  setCopyByIndex(List<int> index) {
    copyMissionsList = [];

    for (int i = 0; i < index.length; i++) {
      copyMissionsList.add(companyMissionsList[index[i]]);
    }

    notifyListeners();
  }

  getSingleUserMissions(
    String userId,
    String userToken,
  ) async {
    String startTime = DateTime(
      DateTime.now().year,
      1,
      1,
    ).toIso8601String();
    String endingTime = DateTime(DateTime.now().year, 12, 30).toIso8601String();
    var response = await http.get(
        Uri.parse(
            "$baseURL/api/InternalMission/GetInExternalMissionPeriodbyUser/$userId/$startTime/$endingTime"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });

    print(response.body);
    var decodedResp = json.decode(response.body);
    if (decodedResp["message"] == "Success") {
      var missionsObj = jsonDecode(response.body)['data'][1] as List;
      var internalObj = jsonDecode(response.body)['data'][0] as List;

      List<CompanyMissions> externalMissions =
          missionsObj.map((json) => CompanyMissions.fromJson(json)).toList();
      List<CompanyMissions> internalMissions =
          internalObj.map((json) => CompanyMissions.fromJson(json)).toList();
      singleUserMissionsList =
          [...externalMissions, ...internalMissions].toSet().toList();
    }
    notifyListeners();
  }

  getCompanyMissions(int companyId, String userToken) async {
    isLoading = true;
    try {
      print(companyId);
      print(userToken);
      var response = await http.get(
          Uri.parse(
              "$baseURL/api/InternalMission/GetInExternalMissionbyCompany/$companyId"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      print(response.body);
      print(response.statusCode);
      var decodedResp = json.decode(response.body);
      if (decodedResp["message"] == "Success") {
        var missionsObj = jsonDecode(response.body)['data'][1] as List;
        var internalObj = jsonDecode(response.body)['data'][0] as List;

        List<CompanyMissions> externalMissions =
            missionsObj.map((json) => CompanyMissions.fromJson(json)).toList();
        List<CompanyMissions> internalMissions =
            internalObj.map((json) => CompanyMissions.fromJson(json)).toList();
        companyMissionsList =
            [...externalMissions, ...internalMissions].toSet().toList();
        getAllUserNamesInMission();
        print(companyMissionsList.length);
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

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
