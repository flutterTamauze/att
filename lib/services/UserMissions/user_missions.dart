import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserMissions/CompanyMissions.dart';
import 'package:qr_users/services/user_data.dart';

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
  bool missionsLoading = false;
  List<String> userNames = [];
  List<CompanyMissions> copyMissionsList = [];
  int internalMissionsCount = 0, externalMissionsCount = 0;
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
    externalMissionsCount = 0;
    internalMissionsCount = 0;
    String startTime = DateTime(
      DateTime.now().year,
      1,
      1,
    ).toIso8601String();
    String endingTime = DateTime(DateTime.now().year, 12, 30).toIso8601String();
    try {
      missionsLoading = true;
      // notifyListeners();
      var response = await http.get(
          Uri.parse(
              "$baseURL/api/InternalMission/GetInExternalMissionPeriodbyUser/$userId/$startTime/$endingTime"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      log(response.body);
      missionsLoading = false;
      var decodedResp = json.decode(response.body);
      if (decodedResp["message"] == "Success") {
        var missionsObj =
            jsonDecode(response.body)['data']["ExternalMissions"] as List;
        var internalObj =
            jsonDecode(response.body)['data']["InternalMissions"] as List;

        List<CompanyMissions> externalMissions = missionsObj
            .map((json) => CompanyMissions.fromJsonExternal(json))
            .toList();
        List<CompanyMissions> internalMissions = internalObj
            .map((json) => CompanyMissions.fromJsonInternal(json))
            .toList();
        singleUserMissionsList =
            [...externalMissions, ...internalMissions].toSet().toList();
        if (singleUserMissionsList.length > 0) {
          externalMissionsCount =
              jsonDecode(response.body)['data']["TotalExternalMission"];
          internalMissionsCount =
              jsonDecode(response.body)['data']["TotalInternal"];
        }
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  addUserExternalMission(UserMissions userMissions, String userToken) async {
    isLoading = true;
    notifyListeners();
    var response = await http.post(
        Uri.parse("$baseURL/api/externalMissions/Add"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        body: json.encode({
          "fromdate": userMissions.fromDate.toIso8601String(),
          "shiftId": userMissions.shiftId,
          "toDate": userMissions.toDate.toIso8601String(),
          "userId": userMissions.userId,
          "desc": userMissions.description,
          "adminResponse": ""
        }));
    isLoading = false;
    notifyListeners();
    print(response.body);
    return json.decode(response.body)["message"];
  }

  addUserInternalMission(
    UserMissions userMissions,
    String userToken,
  ) async {
    isLoading = true;
    notifyListeners();
    print(userMissions.shiftId);
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
          "desc": userMissions.description,
        }));

    isLoading = false;
    notifyListeners();
    print(response.body);
    return json.decode(response.body)["message"];
  }

  addInternalMission(
      BuildContext context,
      picked,
      String description,
      DateTime fromDate,
      DateTime toDate,
      String userId,
      String fcmToken,
      int osType,
      String sitename,
      String shiftName) async {
    var prov = Provider.of<SiteData>(context, listen: false);
    if (prov.siteValue == "كل المواقع" || picked.isEmpty) {
      Fluttertoast.showToast(
          msg: "برجاء ادخال البيانات المطلوبة",
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER);
    } else {
      String msg = await addUserInternalMission(
        UserMissions(
            description: description ?? "لا يوجد تفاصيل",
            fromDate: fromDate,
            toDate: toDate,
            shiftId: Provider.of<SiteShiftsData>(context, listen: false)
                .shifts[prov.dropDownShiftIndex]
                .shiftId,
            userId: userId),
        Provider.of<UserData>(context, listen: false).user.userToken,
      );
      if (msg == "Success : InternalMission Created!") {
        Fluttertoast.showToast(
            msg: "تمت اضافة المأمورية بنجاح",
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER);
        HuaweiServices _huawei = HuaweiServices();
        if (osType == 3) {
          await _huawei.huaweiPostNotification(
            fcmToken,
            "تم تكليفك بمأمورية",
            " تم تسجيل مأمورية داخلية لك \n الى ( $sitename - $shiftName )\n من ( ${fromDate.toString().substring(0, 11)} - ${toDate.toString().substring(0, 11)})",
            fcmToken,
          );
          Navigator.pop(context);
        } else {
          sendFcmMessage(
            category: "internalMission",
            message:
                " تم تسجيل مأمورية داخلية لك \n الى ( $sitename - $shiftName )\n من ( ${fromDate.toString().substring(0, 11)} - ${toDate.toString().substring(0, 11)} )",
            userToken: fcmToken,
            topicName: "",
            title: "تم تكليفك بمأمورية",
          ).then((value) => Navigator.pop(context));
        }
      } else if (msg ==
          "Failed : Another InternalMission not approved for this user!") {
        Fluttertoast.showToast(
            msg: "تم وضع مأمورية لهذا المستخدم من قبل",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(
            msg: "خطأ فى اضافة المأمورية",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      }
    }
  }
  // getCompanyMissions(int companyId, String userToken) async {
  //   isLoading = true;
  //   try {
  //     print(companyId);
  //     print(userToken);
  //     var response = await http.get(
  //         Uri.parse(
  //             "$baseURL/api/InternalMission/GetInExternalMissionbyCompany/$companyId"),
  //         headers: {
  //           'Content-type': 'application/json',
  //           'Authorization': "Bearer $userToken"
  //         });
  //     print(response.body);
  //     print(response.statusCode);
  //     var decodedResp = json.decode(response.body);
  //     if (decodedResp["message"] == "Success") {
  //       var missionsObj = jsonDecode(response.body)['data'][1] as List;
  //       var internalObj = jsonDecode(response.body)['data'][0] as List;

  //       List<CompanyMissions> externalMissions =
  //           missionsObj.map((json) => CompanyMissions.fromJson(json)).toList();
  //       List<CompanyMissions> internalMissions =
  //           internalObj.map((json) => CompanyMissions.fromJson(json)).toList();
  //       companyMissionsList =
  //           [...externalMissions, ...internalMissions].toSet().toList();
  //       getAllUserNamesInMission();
  //       print(companyMissionsList.length);
  //     }
  //     isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
