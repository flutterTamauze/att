import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/constants.dart';

class UserPermessions {
  String user;
  String permessionDescription, adminResponse;
  int permessionStatus; //1=>accept , //2 refused , //3 waiting..
  int permessionId;
  String userID;
  String fcmToken;
  int permessionType;
  DateTime date;
  String duration;

  UserPermessions(
      {this.date,
      this.adminResponse,
      this.duration,
      this.fcmToken,
      this.userID,
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
        fcmToken: json["fcmToken"] ?? "null",
        userID: json['userId'] ?? "",
        permessionId: json["id"],
        permessionDescription: json["desc"] ?? "",
        permessionStatus: json["status"],
        adminResponse: json["adminResponse"],
        user: json["userName"]);
  }
}

class UserPermessionsData with ChangeNotifier {
  bool isLoading = false;
  List<UserPermessions> permessionsList = [];
  List<UserPermessions> copyPermessionsList = [];
  List<UserPermessions> singleUserPermessions = [];
  List<UserPermessions> pendingCompanyPermessions = [];
  int earlyLeaversCount = 0;
  int lateAbesenceCount = 0;
  List<String> userNames = [];
  getAllUserNamesInPermessions() {
    userNames = [];
    permessionsList.forEach((element) {
      userNames.add(element.user);
    });
    // notifyListeners();
  }

  Future<String> acceptOrRefusePendingPermession(
      int status,
      int permID,
      String userId,
      String desc,
      String userToken,
      String adminREsponse) async {
    print(desc);
    isLoading = true;
    notifyListeners();
    var response = await http.put(
        Uri.parse(
          "$baseURL/api/Permissions/isApproved",
        ),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        body: json.encode({
          "status": status,
          "id": permID,
          "userId": userId,
          "adminResponse": adminREsponse,
          "Desc": desc
        }));
    isLoading = false;
    notifyListeners();
    print(response.body);
    var decodedResp = json.decode(response.body);
    if (response.statusCode == 200) {
      pendingCompanyPermessions
          .removeWhere((element) => element.permessionId == permID);

      print(decodedResp["message"]);
      notifyListeners();
      return decodedResp["message"];
    }
    return "fail";
  }

  getPendingCompanyPermessions(int companyId, String userToken) async {
    pendingCompanyPermessions = [];
    var response = await http.get(
        Uri.parse(
            "$baseURL/api/Permissions/GetAllPermissionPending/$companyId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    print(response.body);
    var decodedResp = json.decode(response.body);
    if (decodedResp["message"] == "Success") {
      var permessionsObj = jsonDecode(response.body)['data'] as List;
      pendingCompanyPermessions =
          permessionsObj.map((json) => UserPermessions.fromJson(json)).toList();
      pendingCompanyPermessions = pendingCompanyPermessions.reversed.toList();
      notifyListeners();
    }
  }

  Future<List<UserPermessions>> getSingleUserPermession(
      String userId, String userToken) async {
    try {
      lateAbesenceCount = 0;
      earlyLeaversCount = 0;
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

        singleUserPermessions = singleUserPermessions.reversed.toList();
        print(singleUserPermessions[0].permessionType);
        if (singleUserPermessions.length > 0) {
          for (int i = 0; i < singleUserPermessions.length; i++) {
            if (singleUserPermessions[i].permessionType == 2) {
              earlyLeaversCount++;
            } else if (singleUserPermessions[i].permessionType == 1) {
              lateAbesenceCount++;
            }
          }
        }

        notifyListeners();

        return singleUserPermessions;
      }
    } catch (e) {
      print(e);
    }
  }

  deleteUserPermession(int permID, String userToken) async {
    isLoading = true;
    notifyListeners();

    var response = await http.delete(
        Uri.parse("$baseURL/api/Permissions/DeletePerm?id=$permID"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    print(response.statusCode);
    print(response.body);
    var decodedRsp = json.decode(response.body);
    isLoading = false;
    notifyListeners();
    return decodedRsp["message"];
  }

  setCopyByIndex(List<int> index) {
    print(permessionsList.length);
    copyPermessionsList = [];
    print(index);
    for (int i = 0; i < index.length; i++) {
      copyPermessionsList.add(permessionsList[index[i]]);
    }

    notifyListeners();
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
      getAllUserNamesInPermessions();
      notifyListeners();
    }

    print(response.body);
  }

//اعطاء اذن
  Future<String> addUserPermession(
      UserPermessions userPermessions, String userToken, String userId) async {
    isLoading = false;
    print(userPermessions.permessionDescription);
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
      notifyListeners();
      var decodedMsg = json.decode(response.body)["message"];

      if (decodedMsg == "Success : Permission Created!") {
        print(response.body);
        // permessionsList.add(userPermessions);
        notifyListeners();
        return "success";
      } else if (decodedMsg ==
          "Failed : Another permission not approved for this user!") {
        return "already exist";
      } else if (decodedMsg == "Failed : Another permission in this date!") {
        return "dublicate permession";
      } else if (decodedMsg ==
          "Failed : there is an external mission in this date!") {
        return "external mission";
      } else if (decodedMsg == "Failed : there is a holiday in this date!") {
        return "holiday";
      } else if (decodedMsg ==
          "Failed : there is a holiday was not approved in this date!") {
        return "holiday was not approved";
      }
      notifyListeners();
      return "failed";
    } catch (e) {
      print(e);
    }
  }
}
