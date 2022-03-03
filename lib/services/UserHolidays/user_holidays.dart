import 'dart:developer';

// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/services/UserHolidays/Repo/user_holidays_repo.dart';
import 'package:qr_users/services/UserHolidays/Repo/user_holidays_repo_implementer.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/user_data.dart';

import '../../main.dart';

class UserHolidays {
  String userId, fcmToken, userName, holidayDescription, adminResponse;
  int holidayNumber,
      holidayStatus, //1=>accept , //2 refused , //3 waiting..
      holidayType,
      osType;

  DateTime fromDate, toDate, createdOnDate;
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
      // this.approvedDate,
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
        osType: json["mobileOS"],
        createdOnDate: DateTime.tryParse(json["createdOn"]));
  }
  factory UserHolidays.detailsFromJson(dynamic json) {
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
      osType: json["mobileOS"],
    );
  }
}

enum Holiday {
  Success,
  External_Mission_InThis_Period,
  Holiday_Approved_InThis_Period,
  Internal_Mission_InThis_Period,
  Permession_InThis_Period,
  Another_Holiday_NOT_APPROVED,
  Failed
}

class UserHolidaysData with ChangeNotifier {
  bool isLoading = false;
  bool paginatedIsLoading = false;
  bool loadingHolidaysDetails = false;
  List<UserHolidays> holidaysList = [];
  UserHolidays holidaysSingleDetail;
  List<UserHolidays> singleUserHoliday = [];
  List<UserHolidays> copyHolidaysList = [];
  List<UserHolidays> pendingCompanyHolidays = [];
  List<String> userNames = [];
  bool keepRetriving = true;
  int pageIndex = 0;
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

    final response = await http.delete(
        Uri.parse("$baseURL/api/Holiday/DeleteHoliday?id=$holidayID"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    print(response.statusCode);
    print(response.body);
    isLoading = false;
    notifyListeners();
    final decodedResp = json.decode(response.body);
    if (decodedResp["message"] == "Success : Holiday Deleted!") {
      singleUserHoliday.removeAt(holidayIndex);
      notifyListeners();
    }
    return decodedResp["message"];
  }

  getPendingCompanyHolidays(int companyId, String userToken) async {
    if (pageIndex == 0) {
      pendingCompanyHolidays.clear();
    } else {
      paginatedIsLoading = true;
      notifyListeners();
    }
    pageIndex++;
    pendingCompanyHolidays.addAll(await UserHolidaysRepoImplementer()
        .getPendingCompanyHolidays(companyId, userToken, pageIndex));
    paginatedIsLoading = false;

    notifyListeners();
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

      final response = await http.put(
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
      final decodedResp = json.decode(response.body);
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

  Future<void> getPendingHolidayDetailsByID(
      int holidayId, String userToken) async {
    print("holiday id $holidayId");
    final holidays = pendingCompanyHolidays
        .where((element) => element.holidayNumber == holidayId)
        .toList();
    final int holidayIndex = pendingCompanyHolidays.indexOf(holidays[0]);

    if (pendingCompanyHolidays[holidayIndex].holidayDescription == null) {
      loadingHolidaysDetails = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse("$baseURL/api/Holiday/$holidayId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );
      print(response.statusCode);

      log(response.body);
      loadingHolidaysDetails = false;
      notifyListeners();
      final decodedResponse = json.decode(response.body);
      if (decodedResponse["message"] == "Success") {
        holidaysSingleDetail = UserHolidays.fromJson(decodedResponse['data']);

        pendingCompanyHolidays[holidayIndex].adminResponse =
            holidaysSingleDetail.adminResponse;
        pendingCompanyHolidays[holidayIndex].holidayDescription =
            holidaysSingleDetail.holidayDescription;
        pendingCompanyHolidays[holidayIndex].fcmToken =
            holidaysSingleDetail.fcmToken;
        pendingCompanyHolidays[holidayIndex].adminResponse =
            pendingCompanyHolidays[holidayIndex].adminResponse;
        // pendingCompanyHolidays[holidayIndex].createdOnDate =
        //     pendingCompanyHolidays[holidayIndex].createdOnDate;

        notifyListeners();
      }
      loadingHolidaysDetails = false;
      notifyListeners();
    } else {
      print("not null");
    }
  }

  Future<void> getHolidayDetailsByID(int holidayId, String userToken) async {
    final holidays = singleUserHoliday
        .where((element) => element.holidayNumber == holidayId)
        .toList();

    final int holidayIndex = singleUserHoliday.indexOf(holidays[0]);
    if (singleUserHoliday[holidayIndex].adminResponse == null &&
        singleUserHoliday[holidayIndex].holidayDescription == null) {
      loadingHolidaysDetails = true;
      notifyListeners();
      print("holiday id $holidayId");

      final response = await http.get(
        Uri.parse("$baseURL/api/Holiday/$holidayId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );
      print(response.statusCode);

      log(response.body);
      loadingHolidaysDetails = false;
      notifyListeners();
      final decodedResponse = json.decode(response.body);
      if (decodedResponse["message"] == "Success") {
        holidaysSingleDetail =
            UserHolidays.detailsFromJson(decodedResponse['data']);
        final holidays = singleUserHoliday
            .where((element) => element.holidayNumber == holidayId)
            .toList();

        final int holidayIndex = singleUserHoliday.indexOf(holidays[0]);
        singleUserHoliday[holidayIndex].adminResponse =
            holidaysSingleDetail.adminResponse;
        singleUserHoliday[holidayIndex].holidayDescription =
            holidaysSingleDetail.holidayDescription;
        singleUserHoliday[holidayIndex].holidayType =
            holidaysSingleDetail.holidayType;
      }

      notifyListeners();
    }
  }

  Future<List<UserHolidays>> getFutureSingleUserHoliday(
      String userId, String userToken) async {
    sickVacationCount = 0;
    suddenVacationCount = 0;
    vacationCreditCount = 0;
    loadingHolidaysDetails = true;

    singleUserHoliday = await UserHolidaysRepoImplementer()
        .getFutureSingleUserHoliday(userId, userToken);
    loadingHolidaysDetails = false;
    notifyListeners();

    return singleUserHoliday;
  }

  Future<List<UserHolidays>> getSingleUserHoliday(
      String userId, String userToken) async {
    sickVacationCount = 0;
    suddenVacationCount = 0;
    vacationCreditCount = 0;

    loadingHolidaysDetails = true;
    // notifyListeners();

    final response = await UserHolidaysRepoImplementer()
        .getSingleUserHoliday(userToken, userId);
    loadingHolidaysDetails = false;
    notifyListeners();
    if (response is Faliure) {
      return [];
    }

    final decodedResponse = json.decode(response);
    if (decodedResponse["message"] == "Success") {
      final permessionsObj = jsonDecode(response)['data']["Holidays"] as List;
      singleUserHoliday =
          permessionsObj.map((json) => UserHolidays.fromJson(json)).toList();

      singleUserHoliday = singleUserHoliday.reversed.toList();
      sickVacationCount = jsonDecode(response)['data']["Sick"];
      suddenVacationCount = jsonDecode(response)['data']["Excep"];
      vacationCreditCount = jsonDecode(response)['data']["Credit"];
      notifyListeners();

      return singleUserHoliday;
    }
    return singleUserHoliday;
  }

  Future<Holiday> addHoliday(
      UserHolidays holiday, String userToken, String userId) async {
    print(holiday.holidayDescription);

    isLoading = true;
    notifyListeners();
    final response = await http.post(
        Uri.parse("$baseURL/api/Holiday/AddHoliday"),
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
          "createdonDate": DateTime.now().toIso8601String(),
          "status": 3,
        }));
    isLoading = false;
    notifyListeners();
    print("adding holiday");
    print(response.body);
    final decodedMessage = json.decode(response.body)["message"];
    switch (decodedMessage) {
      case "Success : Holiday Created!":
        return Holiday.Success;
        break;
      case "Failed : There are external mission in this period!":
        return Holiday.External_Mission_InThis_Period;
        break;
      case "Failed : Another Holiday not approved for this user!":
        return Holiday.Another_Holiday_NOT_APPROVED;
        break;
      case "Failed : There are an holiday approved in this period!":
        return Holiday.Holiday_Approved_InThis_Period;
        break;
      case "Failed : There are an internal Mission in this period!":
        return Holiday.Internal_Mission_InThis_Period;
        break;
      case "Failed : There are an permission in this period!":
        return Holiday.Permession_InThis_Period;
        break;

      default:
        return Holiday.Failed;
    }
  }

  addExternalMission(DateTime fromDate, DateTime toDate, BuildContext context,
      String memId, String desc, String fcmToken) async {
    print(fromDate);
    print(toDate);
    if (fromDate != null && toDate != null) {
      final String msg = await Provider.of<MissionsData>(context, listen: false)
          .addUserExternalMission(
              UserMissions(
                  description: desc,
                  fromDate: fromDate,
                  toDate: toDate,
                  userId: memId),
              Provider.of<UserData>(context, listen: false).user.userToken);

      if (msg == "Success : External Missions Created!") {
        Fluttertoast.showToast(
            msg: getTranslated(context, "تم الإضافة بنجاح"),
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER);
        await sendFcmMessage(
            category: "externalMission",
            message:
                "${getTranslated(context, "تم تسجيل مأمورية خارجية لك")} \n ${getTranslated(context, "من")} ( ${fromDate.toString().substring(0, 11)} - ${toDate.toString().substring(0, 11)})",
            userToken: fcmToken,
            topicName: "",
            title: getTranslated(
              context,
              "تم تكليفك بمأمورية",
            )).then((value) => Navigator.pop(context));
      } else if (msg == "Failed : There are external mission in this period!") {
        Fluttertoast.showToast(
            msg: getTranslated(
                context, "تم وضع مأمورية خارجية لهذا المستخدم من قبل"),
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else if (msg ==
          "Failed : You can't request an external mission from today!") {
        Fluttertoast.showToast(
            msg: getTranslated(
                context, "لا يمكنك وضع مأمورية خارجية فى اليوم الحالى"),
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else if (msg ==
          "Failed : There are an internal Mission in this period!") {
        Fluttertoast.showToast(
            msg: getTranslated(context, "يوجد مأمورية داخلية فى هذا التاريخ"),
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(
            msg: getTranslated(context, "خطأ في اضافة المأمورية"),
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER);
      }
    } else {
      Fluttertoast.showToast(
          msg: getTranslated(
            context,
            "برجاء ادخال المدة",
          ),
          backgroundColor: Colors.red);
    }
  }
}
