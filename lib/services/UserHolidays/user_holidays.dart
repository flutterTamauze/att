import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/constants.dart';

class UserHolidays {
  String userId;
  String fcmToken;
  String userName;

  String holidayDescription, adminResponse;
  int holidayNumber;
  int holidayStatus; //1=>accept , //2 refused , //3 waiting..
  int holidayType; //عارضة مرضيه رصيد اجازات
  DateTime fromDate, toDate;
  UserHolidays(
      {this.adminResponse,
      this.fromDate,
      this.holidayStatus,
      this.holidayType,
      this.fcmToken,
      this.holidayNumber,
      this.holidayDescription,
      this.toDate,
      this.userName,
      this.userId});
  factory UserHolidays.fromJson(dynamic json) {
    return UserHolidays(
        adminResponse: json["adminResponse"],
        fromDate: DateTime.tryParse(json["fromDate"]),
        toDate: DateTime.tryParse(json["toDate"]),
        holidayType: json["typeId"],
        userName: json["userName"],
        userId: json['userId'] ?? "",
        holidayStatus: json["status"],
        holidayNumber: json["id"],
        fcmToken: json["fcmToken"] ?? "null",
        holidayDescription: json["desc"]);
  }
}

class UserHolidaysData with ChangeNotifier {
  bool isLoading = false;
  List<UserHolidays> holidaysList = [];
  List<UserHolidays> singleUserHoliday = [];
  List<UserHolidays> copyHolidaysList = [];
  List<UserHolidays> pendingCompanyHolidays = [];
  List<String> userNames = [];
  int sickVacationCount = 0, vacationCreditCount = 0, suddenVacationCount = 0;
  getAllUserNamesInHolidays() {
    userNames = [];
    holidaysList.forEach((element) {
      userNames.add(element.userName);
    });
    // notifyListeners();
  }

  setCopyByIndex(List<int> index) {
    print(holidaysList.length);
    copyHolidaysList = [];
    print(index);
    for (int i = 0; i < index.length; i++) {
      copyHolidaysList.add(holidaysList[index[i]]);
    }

    notifyListeners();
  }

  getPendingCompanyHolidays(int companyId, String userToken) async {
    var response = await http.get(
        Uri.parse("$baseURL/api/Holiday/GetAllHolidaysPending/$companyId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    print(response.body);
    var decodedResp = json.decode(response.body);
    if (decodedResp["message"] == "Success") {
      var permessionsObj = jsonDecode(response.body)['data'] as List;
      pendingCompanyHolidays =
          permessionsObj.map((json) => UserHolidays.fromJson(json)).toList();

      notifyListeners();
    }
  }

  Future<String> acceptOrRefusePendingVacation(
    int status,
    int vacID,
    String desc,
    String userToken,
  ) async {
    try {
      isLoading = true;
      notifyListeners();
      var response = await http.put(
          Uri.parse(
            "$baseURL/api/Holiday/Approve",
          ),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          },
          body: json.encode({
            "status": status,
            "id": vacID,
            "adminResponse": "",
            "Desc": desc
          }));
      print(response.statusCode);
      isLoading = false;
      notifyListeners();
      print(response.body);
      var decodedResp = json.decode(response.body);
      if (response.statusCode == 200) {
        pendingCompanyHolidays
            .removeWhere((element) => element.holidayNumber == vacID);

        print(decodedResp["message"]);
        notifyListeners();
        return decodedResp["message"];
      }
    } catch (e) {
      print(e);
    }

    return "fail";
  }

  Future<List<UserHolidays>> getSingleUserHoliday(
      String userId, String userToken) async {
    try {
      sickVacationCount = 0;
      suddenVacationCount = 0;
      vacationCreditCount = 0;
      var response = await http.get(
        Uri.parse("$baseURL/api/Holiday/GetHolidaybyUser/$userId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );
      print(response.body);
      var decodedResponse = json.decode(response.body);
      if (decodedResponse["message"] == "Success") {
        var permessionsObj = jsonDecode(response.body)['data'] as List;
        singleUserHoliday =
            permessionsObj.map((json) => UserHolidays.fromJson(json)).toList();
        singleUserHoliday = singleUserHoliday.reversed.toList();
        if (singleUserHoliday.length > 0) {
          for (int i = 0; i < singleUserHoliday.length; i++) {
            if (singleUserHoliday[i].holidayType == 1) {
              suddenVacationCount++;
            } else if (singleUserHoliday[i].holidayType == 2) {
              sickVacationCount++;
            } else {
              vacationCreditCount++;
            }
          }
        }

        notifyListeners();

        return singleUserHoliday;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<UserHolidays>> getAllHolidays(
      String userToken, int companyId) async {
    isLoading = true;
    // notifyListeners();
    var response = await http.get(
      Uri.parse("$baseURL/api/Holiday/GetAllHolidaysbyComId/$companyId"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
    print(response.body);
    var decodedResponse = json.decode(response.body);
    if (decodedResponse["message"] == "Success") {
      var holidayObj = jsonDecode(response.body)['data'] as List;
      holidaysList =
          holidayObj.map((json) => UserHolidays.fromJson(json)).toList();
      isLoading = false;
      getAllUserNamesInHolidays();
      notifyListeners();
    }

    return holidaysList;
  }

  Future<String> addHoliday(
      UserHolidays holiday, String userToken, String userId) async {
    isLoading = true;
    notifyListeners();
    var response = await http.post(Uri.parse("$baseURL/api/Holiday/AddHoliday"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        body: json.encode({
          "typeId": holiday.holidayType,
          "fromdate": (holiday.fromDate.toIso8601String()),
          "toDate": (holiday.toDate.toIso8601String()),
          "userId": userId,
          "desc": holiday.holidayDescription,
          "status": 3
        }));
    isLoading = false;
    notifyListeners();
    print("adding holiday");
    print(response.body);
    return json.decode(response.body)["message"];
  }
}
