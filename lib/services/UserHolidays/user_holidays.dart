import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/constants.dart';

class UserHolidays {
  String userId;
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
        holidayStatus: json["status"],
        holidayNumber: json["id"],
        holidayDescription: json["desc"]);
  }
}

class UserHolidaysData with ChangeNotifier {
  bool isLoading = false;
  List<UserHolidays> holidaysList = [];
  List<UserHolidays> singleUserHoliday = [];
  Future<List<UserHolidays>> getSingleUserHoliday(
      String userId, String userToken) async {
    try {
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
    notifyListeners();
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
