import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/services/UserHolidays/Repo/user_holidays_repo_implementer.dart';
import 'package:qr_users/services/UserPermessions/Repo/user_permession_repo_implementer.dart';

import '../../main.dart';

class UserPermessions {
  String user, permessionDescription, adminResponse, approvedByUserId;
  int permessionStatus; //1=>accept , //2 refused , //3 waiting..
  int permessionId, osType;
  String userID;
  String fcmToken;
  int permessionType;
  DateTime date, approvedDate;
  String duration;
  DateTime createdOn;
  UserPermessions(
      {this.date,
      this.adminResponse,
      this.duration,
      this.fcmToken,
      this.userID,
      this.osType,
      this.permessionStatus,
      this.permessionDescription,
      this.permessionType,
      this.user,
      this.approvedByUserId,
      this.createdOn,
      this.approvedDate,
      this.permessionId});

  factory UserPermessions.fromJson(dynamic json) {
    return UserPermessions(
        date: DateTime.tryParse(json["date"]),
        duration: json["time"],
        permessionType: json["type"],
        fcmToken: json["fcmToken"] ?? "null",
        userID: json['userId'] ?? "",
        permessionId: json["id"],
        osType: json["mobileOS"] ?? 1,
        permessionDescription: json["desc"],
        permessionStatus: json["status"],
        adminResponse: json["adminResponse"],
        // approvedByUserId: json["ApprovedbyUser"] ?? "غير معروف",
        createdOn: DateTime.tryParse(json["createdonDate"]),
        // approvedDate: DateTime.tryParse(
        //   json["approvedDate"] ?? "",
        // ),
        user: json["userName"]);
  }
  factory UserPermessions.fromJsonWithCreatedOn(dynamic json) {
    return UserPermessions(
        date: DateTime.tryParse(json["date"]),
        duration: json["time"],
        permessionType: json["type"],
        fcmToken: json["fcmToken"] ?? "null",
        permessionId: json["id"],
        permessionStatus: json["status"],
        createdOn: DateTime.tryParse(json["createdOn"]),
        user: json["userName"]);
  }
  factory UserPermessions.detailsFromJson(dynamic json) {
    return UserPermessions(
        date: DateTime.tryParse(json["date"]),
        permessionDescription: json["desc"],
        duration: json["time"],
        permessionType: json["type"],
        adminResponse: json["adminResponse"],
        permessionId: json["id"],
        fcmToken: json["fcmToken"]);
  }
}

class UserPermessionsData with ChangeNotifier {
  bool isLoading = false;
  bool paginatedLoading = false;
  bool permessionDetailLoading = false;

  List<UserPermessions> permessionsList = [];
  List<UserPermessions> copyPermessionsList = [];
  List<UserPermessions> singleUserPermessions = [];
  UserPermessions singlePermessionDetail;

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
    String adminREsponse,
    DateTime permDate,
  ) async {
    print(desc);

    isLoading = true;
    notifyListeners();
    final response = await http.put(
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
          "permDate": permDate.toIso8601String(),
          "adminResponse": adminREsponse,
          "Desc": desc
        }));
    isLoading = false;
    notifyListeners();
    print(response.body);
    final decodedResp = json.decode(response.body);
    if (response.statusCode == 200) {
      if (decodedResp["message"] == "Success : User Updated!") {
        pendingCompanyPermessions
            .removeWhere((element) => element.permessionId == permID);

        print(decodedResp["message"]);
        notifyListeners();
        return decodedResp["message"];
      } else {
        print(decodedResp["message"]);
        return decodedResp["message"];
      }
    }
    return "fail";
  }

  bool keepRetriving = true;
  int pageIndex = 0;
  Future<String> getPendingCompanyPermessions(
      int companyId, String userToken) async {
    if (pageIndex == 0) {
      pendingCompanyPermessions = [];
    }
    pageIndex++;

    pendingCompanyPermessions.addAll(await UserPermessionRepoImp()
        .getPendingCompanyPermessions(companyId, userToken, pageIndex));
    paginatedLoading = false;
    notifyListeners();
    return "Success";
  }

  Future<void> getPendingPermessionDetailsByID(
      int permessionId, String userToken) async {
    print(permessionId);
    final permessions = pendingCompanyPermessions
        .where((element) => element.permessionId == permessionId)
        .toList();

    final int permessionyIndex =
        pendingCompanyPermessions.indexOf(permessions[0]);
    if (pendingCompanyPermessions[permessionyIndex].adminResponse == null ||
        pendingCompanyPermessions[permessionyIndex].permessionDescription ==
            null) {
      permessionDetailLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse("$baseURL/api/Permissions/$permessionId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );
      log(response.body);
      print(response.statusCode);

      permessionDetailLoading = false;
      notifyListeners();
      final decodedResponse = json.decode(response.body);
      if (decodedResponse["message"] == "Success") {
        singlePermessionDetail =
            UserPermessions.detailsFromJson(decodedResponse['data']);
        final permessions = pendingCompanyPermessions
            .where((element) => element.permessionId == permessionId)
            .toList();

        final int permIndex = pendingCompanyPermessions.indexOf(permessions[0]);
        pendingCompanyPermessions[permIndex].adminResponse =
            singlePermessionDetail.adminResponse;
        pendingCompanyPermessions[permIndex].permessionDescription =
            singlePermessionDetail.permessionDescription;
        pendingCompanyPermessions[permIndex].fcmToken =
            singlePermessionDetail.fcmToken;
        pendingCompanyPermessions[permIndex].adminResponse =
            singlePermessionDetail.adminResponse;
      }

      notifyListeners();
    } else {
      print("not null");
    }
  }

  Future<void> getPermessionDetailsByID(
      int permessionId, String userToken) async {
    try {
      print(permessionId);
      final permessions = singleUserPermessions
          .where((element) => element.permessionId == permessionId)
          .toList();

      final int permessionyIndex =
          singleUserPermessions.indexOf(permessions[0]);
      if (singleUserPermessions[permessionyIndex].permessionDescription ==
          null) {
        permessionDetailLoading = true;
        notifyListeners();

        final response = await http.get(
          Uri.parse("$baseURL/api/Permissions/$permessionId"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          },
        );
        log(response.body);
        print(response.statusCode);

        permessionDetailLoading = false;
        notifyListeners();
        final decodedResponse = json.decode(response.body);
        if (decodedResponse["message"] == "Success") {
          singlePermessionDetail =
              UserPermessions.detailsFromJson(decodedResponse['data']);
          final permessions = singleUserPermessions
              .where((element) => element.permessionId == permessionId)
              .toList();

          final int permIndex = singleUserPermessions.indexOf(permessions[0]);
          singleUserPermessions[permIndex].adminResponse =
              singlePermessionDetail.adminResponse;
          singleUserPermessions[permIndex].permessionDescription =
              singlePermessionDetail.permessionDescription;
        }

        notifyListeners();
      } else {
        print("not null");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<UserPermessions>> getFutureSinglePermession(
      String userId, String userToken) async {
    permessionDetailLoading = true;
    notifyListeners();

    singleUserPermessions = await UserPermessionRepoImp()
        .getFutureSinglePermession(userId, userToken);
    permessionDetailLoading = false;

    notifyListeners();

    return singleUserPermessions;
  }

  Future<String> getSingleUserPermession(
      String userId, String userToken) async {
    lateAbesenceCount = 0;
    earlyLeaversCount = 0;

    permessionDetailLoading = true;

    notifyListeners();

    try {
      final response = await UserPermessionRepoImp()
          .getSingleUserPermession(userToken, userId);
      permessionDetailLoading = false;
      notifyListeners();
      if (response is Faliure) {
        if (response.code == USER_INVALID_RESPONSE) {
          return "serverDown";
        } else if (response.code == NO_INTERNET) {
          return "noInternet";
        }
      } else {
        final decodedResponse = json.decode(response);
        if (decodedResponse["message"] == "Success") {
          final permessionsObj =
              jsonDecode(response)['data']["Permissions"] as List;
          singleUserPermessions = permessionsObj
              .map((json) => UserPermessions.detailsFromJson(json))
              .toList();

          singleUserPermessions = singleUserPermessions.reversed.toList();
          lateAbesenceCount = jsonDecode(response)['data']['TotalLate'];
          earlyLeaversCount = jsonDecode(response)['data']['TotalLeave'];

          notifyListeners();

          return "Success";
        }
      }
    } catch (e) {
      print(e);
    }
    return "Fail";
  }

  deleteUserPermession(int permID, String userToken, int permIndex) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await http.delete(
          Uri.parse("$baseURL/api/Permissions/DeletePerm?id=$permID"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });

      final decodedRsp = json.decode(response.body);
      isLoading = false;
      notifyListeners();
      if (decodedRsp["message"] == "Success : Permission Deleted!") {
        print(permIndex);
        singleUserPermessions.removeAt(permIndex);
        notifyListeners();
      }
      return decodedRsp["message"];
    } catch (e) {
      print(e);
    }
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

  // getAllPermessions(int companyId, String userToken) async {
  //   final response =
  //       await PermessionRepo().getAllPermessions(userToken, companyId);

  //   final decodedResponse = json.decode(response);
  //   if (decodedResponse["message"] == "Success") {
  //     final permessionsObj = jsonDecode(response)['data'] as List;
  //     permessionsList =
  //         permessionsObj.map((json) => UserPermessions.fromJson(json)).toList();
  //     getAllUserNamesInPermessions();
  //     notifyListeners();
  //   }
  // }

//اعطاء اذن
  Future<String> addUserPermession(
      UserPermessions userPermessions, String userToken, String userId) async {
    isLoading = false;
    log(userPermessions.date.toIso8601String());
    // log(userPermessions.createdOn.toIso8601String());
    print(userPermessions.permessionDescription);
    try {
      isLoading = true;
      notifyListeners();
      final response = await UserPermessionRepoImp()
          .addPermession(userPermessions, userToken, userId);
      isLoading = false;
      notifyListeners();
      final decodedMsg = json.decode(response)["message"];

      if (decodedMsg == "Success : Permission Created!") {
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
              "Failed : there is a holiday was not approved in this date!" ||
          decodedMsg == "Failed : there is a holiday still pending!") {
        print("not approved");
        return "holiday was not approved";
      }
      notifyListeners();
      return "failed";
    } catch (e) {
      print(e);
    }
    return "failed";
  }
}
