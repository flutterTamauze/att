import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/constants.dart';

class UserPermessions {
  String user;
  String permessionDescription, adminResponse;
  int permessionStatus; //1=>accept , //2 refused , //3 waiting..
  int permessionId;

  int permessionType;
  DateTime date;
  String duration;

  UserPermessions(
      {this.date,
      this.adminResponse,
      this.duration,
      this.permessionStatus,
      this.permessionDescription,
      this.permessionType,
      this.user,
      this.permessionId});

  factory UserPermessions.fromJson(dynamic json) {
    return UserPermessions(
        date: DateTime.tryParse(json["date"]),
        duration: json["time"],
        permessionType: json["type"],
        permessionId: json["id"],
        permessionDescription: json["desc"] ?? "",
        permessionStatus: json["status"],
        adminResponse: json["adminResponse"],
        user: json["userId"]);
  }
}

class UserPermessionsData with ChangeNotifier {
  bool isLoading = false;
  List<UserPermessions> permessionsList = [];
  List<UserPermessions> singleUserPermessions = [];
  Future<List<UserPermessions>> getSingleUserPermession(
      String userId, String userToken) async {
    try {
      var response = await http.get(
        Uri.parse("$baseURL/api/Permissions/GetPermissionbyUser/$userId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );
      print(response.body);
      var decodedResponse = json.decode(response.body);
      if (decodedResponse["message"] == "Success") {
        var permessionsObj = jsonDecode(response.body)['data'] as List;
        singleUserPermessions = permessionsObj
            .map((json) => UserPermessions.fromJson(json))
            .toList();

        notifyListeners();
        return singleUserPermessions;
      }
    } catch (e) {
      print(e);
    }
  }

  getAllPermessions(int companyId, String userToken) async {
    var response = await http.get(
      Uri.parse("$baseURL/api/Permissions/GetAllPermissionbyComId/$companyId"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
    print(response.body);
    var decodedResponse = json.decode(response.body);
    if (decodedResponse["message"] == "Success") {
      var permessionsObj = jsonDecode(response.body)['data'] as List;
      permessionsList =
          permessionsObj.map((json) => UserPermessions.fromJson(json)).toList();

      notifyListeners();
    }

    print(response.body);
  }

//اعطاء اذن
  Future<String> addUserPermession(
      UserPermessions userPermessions, String userToken, String userId) async {
    isLoading = false;
    try {
      //1 تأخخير عن الحضور
      isLoading = true;
      notifyListeners();
      var response = await http.post(
          Uri.parse("$baseURL/api/Permissions/AddPerm"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          },
          body: json.encode({
            "type": userPermessions.permessionType,
            "date": (userPermessions.date.toIso8601String()),
            "time": userPermessions.duration,
            "userId": userId,
            "Desc": userPermessions.permessionDescription,
            "Status": 3
          }));
      print(response.body);
      isLoading = false;
      print(json.decode(response.body)["message"]);

      if (json.decode(response.body)["message"] ==
          "Success : Permission Created!") {
        print(response.body);
        // permessionsList.add(userPermessions);
        notifyListeners();
        return "success";
      }
      notifyListeners();
      return "failed";
    } catch (e) {
      print(e);
    }
  }
}
