import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/user_data.dart';

class UserHolidays {
  String userId,
      fcmToken,
      userName,
      holidayDescription,
      adminResponse,
      approvedByUserId;
  int holidayNumber,
      holidayStatus, //1=>accept , //2 refused , //3 waiting..
      holidayType,
      osType;
  DateTime fromDate, toDate, createdOnDate, approvedDate;
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
      this.osType,
      this.userId,
      this.approvedByUserId,
      this.approvedDate,
      this.createdOnDate});
  factory UserHolidays.fromJson(dynamic json) {
    return UserHolidays(
        adminResponse: json["adminResponse"],
        fromDate: DateTime.tryParse(json["fromdate"]),
        toDate: DateTime.tryParse(json["toDate"]),
        holidayType: json["typeId"],
        userName: json["userName"],
        userId: json['userId'],
        holidayStatus: json["status"],
        holidayNumber: json["id"],
        fcmToken: json["fcmToken"],
        holidayDescription: json["desc"],
        approvedDate: DateTime.tryParse(json["approvedDate"]),
        osType: json["mobileOS"],
        approvedByUserId: json["aprrovedbyUserId"],
        createdOnDate: DateTime.tryParse(json["createdOn"]));
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

  deleteUserHoliday(int holidayID, String userToken, int holidayIndex) async {
    isLoading = true;
    notifyListeners();

    var response = await http.delete(
        Uri.parse("$baseURL/api/Holiday/DeleteHoliday?id=$holidayID"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    print(response.statusCode);
    print(response.body);
    isLoading = false;
    notifyListeners();
    var decodedResp = json.decode(response.body);
    if (decodedResp["message"] == "Success : Holiday Deleted!") {
      singleUserHoliday.removeAt(holidayIndex);
      notifyListeners();
    }
    return decodedResp["message"];
  }

  getPendingCompanyHolidays(int companyId, String userToken) async {
    var response = await http.get(
        Uri.parse("$baseURL/api/Holiday/GetAllHolidaysPending/$companyId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    print("holidays");
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
      String adminComment,
      DateTime fromDate,
      DateTime toDate) async {
    try {
      print(vacID);
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
            "adminResponse": adminComment,
            "Desc": desc,
            "fromdate": fromDate.toIso8601String(),
            "todate": toDate.toIso8601String()
          }));
      print(response.statusCode);
      isLoading = false;
      notifyListeners();
      print(response.body);
      var decodedResp = json.decode(response.body);
      if (response.statusCode == 200 &&
          (!decodedResp["message"].toString().contains("Fail"))) {
        pendingCompanyHolidays
            .removeWhere((element) => element.holidayNumber == vacID);

        print(decodedResp["message"]);
        notifyListeners();
        log(decodedResp["message"]);
        return decodedResp["message"];
      }
      return decodedResp["message"];
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
            if (singleUserHoliday[i].holidayType == 1 &&
                singleUserHoliday[i].holidayStatus == 1) {
              suddenVacationCount++;
            } else if (singleUserHoliday[i].holidayType == 2 &&
                singleUserHoliday[i].holidayStatus == 1) {
              sickVacationCount++;
            } else {
              if (singleUserHoliday[i].holidayStatus == 1)
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
    print(holiday.holidayDescription);
    isLoading = true;
    notifyListeners();

    var response = await http.post(Uri.parse("$baseURL/api/Holiday/AddHoliday"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        body: json.encode({
          "typeId": holiday.holidayType,
          "fromdate": holiday.fromDate.toIso8601String(),
          "toDate": holiday.toDate.toIso8601String(),
          "userId": userId,
          "desc": holiday.holidayDescription,
          "createdonDate": holiday.createdOnDate.toIso8601String(),
          "status": 3,
        }));
    isLoading = false;
    notifyListeners();
    print("adding holiday");
    print(response.body);
    return json.decode(response.body)["message"];
  }

  addExternalMission(DateTime fromDate, DateTime toDate, BuildContext context,
      String memId, String desc, String fcmToken) async {
    print(fromDate);
    print(toDate);
    if (fromDate != null && toDate != null) {
      String msg = await Provider.of<UserHolidaysData>(context, listen: false)
          .addHoliday(
              UserHolidays(
                  createdOnDate: DateTime.now(),
                  userId: memId,
                  holidayType: 4,
                  fromDate: fromDate,
                  toDate: toDate,
                  holidayDescription: desc),
              Provider.of<UserData>(context, listen: false).user.userToken,
              memId);
      if (msg == "Success : Holiday Created!") {
        Fluttertoast.showToast(
            msg: "تمت اضافة المأمورية بنجاح",
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER);
        await sendFcmMessage(
          category: "externalMission",
          message:
              "تم تسجيل مأمورية خارجية لك \n من ( ${fromDate.toString().substring(0, 11)} - ${toDate.toString().substring(0, 11)})",
          userToken: fcmToken,
          topicName: "",
          title: "تم تكليفك بمأمورية",
        ).then((value) => Navigator.pop(context));
      } else if (msg ==
          "Failed : Another Holiday not approved for this user!") {
        Fluttertoast.showToast(
            msg: "تم وضع مأمورية لهذا المستخدم من قبل",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else if (msg == "Failed : You can't request a holiday from today!") {
        Fluttertoast.showToast(
            msg: "لا يمكنك وضع مأمورية خارجية فى اليوم الحالى",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else if (msg ==
          "Failed : There are an internal Mission in this period!") {
        Fluttertoast.showToast(
            msg: "يوجد مأمورية داخلية فى هذا التاريخ",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else if (msg == "Failed : There are external mission in this period!") {
        Fluttertoast.showToast(
            msg: "يوجد مأمورية خارجية فى هذا التاريخ",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(
            msg: "خطأ في اضافة المأمورية",
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      }
    } else {
      Fluttertoast.showToast(
          msg: "برجاء ادخال المدة", backgroundColor: Colors.red);
    }
  }
}
