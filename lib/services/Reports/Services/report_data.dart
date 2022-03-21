import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/services/Reports/Repo/ReportsRepo.dart';
import 'package:qr_users/services/Reports/Services/Attend_Proof_Model.dart';
import 'package:qr_users/services/Reports/Services/todays_user_Report_model.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

class DailyReportUnit {
  String userId;
  String userName, normalizedName;
  String timeIn;
  String timeOut;
  String timeInIcon;
  String timeOutIcon;
  String lateTime;
  int attendType;
  String userAttendPictureURL;
  String userLeavePictureURL;

  DailyReportUnit(
      {this.userId,
      this.userName,
      this.normalizedName,
      this.timeIn,
      this.timeOut,
      this.lateTime,
      this.attendType,
      // this.userAttendPictureURL,
      // this.userLeavePictureURL,
      this.timeInIcon,
      this.timeOutIcon});

  factory DailyReportUnit.fromJson(dynamic json) {
    String getTimeToString(int time) {
      if (time == 0) {
        return "-";
      } else {
        print(time);
        final double hoursDouble = time / 60.0;
        final int h = hoursDouble.toInt();
        print(h);
        final double minDouble = time.toDouble() % 60;
        final int m = minDouble.toInt();
        print(m);
        final NumberFormat formatter = new NumberFormat("00");
        return "${formatter.format(h)}:${formatter.format(m)}";
      }
    }

    String amPmChanger(String time) {
      switch (time) {
        case "*":
          return "غير مقيد بعد";
          break;
        case "1":
          return "عارضة";
          break;
        case "3":
          return "رصيد اجازات";
        case "2":
          return "مرضى";
        case "4":
          return "مأمورية خارجية";
        case "-":
          return "-";
        default:
          final int intTime = int.parse(time.replaceAll(":", ""));
          int hours = (intTime ~/ 100);
          final int min = intTime - (hours * 100);

          final ampm = hours >= 12 ? 'pm' : 'am';
          hours = hours % 12;
          hours = hours != 0 ? hours : 12; //

          final String hoursStr = hours < 10
              ? '0$hours'
              : hours.toString(); // the hour '0' should be '12'
          final String minStr = min < 10 ? '0$min' : min.toString();

          final strTime = '$hoursStr:$minStr';

          return strTime;
      }
    }

    String amOrPm(String time) {
      if (time != "-" && time.toString().contains(":")) {
        final int intTime = int.parse(time.replaceAll(":", ""));
        final int hours = (intTime ~/ 100);

        return hours >= 12 ? 'pm' : 'am';
      } else {
        return time;
      }
    }

    return DailyReportUnit(
      userName: json['name'],
      userId: json['id'], normalizedName: json["userName"],
      timeIn: amPmChanger(json['attendTime']),
      timeInIcon: amOrPm(json['attendTime']),
      timeOut: amPmChanger(json['leavingTime']),
      timeOutIcon: amOrPm(json['leavingTime']),
      lateTime: getTimeToString(json['late'] as int),
      attendType: (json['userAttendType']),
      // userAttendPictureURL: json['userAttendPicture'] ?? "",
      // userLeavePictureURL: json['userLeavePicture'] ?? "",
    );
  }
}

class DailyReport {
  List<DailyReportUnit> attendListUnits;

  bool isHoliday;
  String officialHoliday;
  int totalAttend;
  int totalAbsent;

  DailyReport(this.attendListUnits, this.totalAttend, this.totalAbsent,
      this.isHoliday, this.officialHoliday);
}

class UserAttendanceReport {
  List<UserAttendanceReportUnit> userAttendListUnits;
  double totalLateDeduction, totalDeduction, totalDeductionAbsent;
  int totalAbsentDay;
  int totalLateDay;
  String totalLateDuration;
  int isDayOff;
  int totalOfficialVacation;

  UserAttendanceReport(
      {this.userAttendListUnits,
      this.totalAbsentDay,
      this.totalLateDay,
      this.totalLateDuration,
      this.isDayOff,
      this.totalLateDeduction,
      this.totalDeductionAbsent,
      this.totalDeduction,
      this.totalOfficialVacation});
  factory UserAttendanceReport.fromJson(dataDecoded) {
    return UserAttendanceReport(
        totalOfficialVacation: dataDecoded["totalOffcialVacation"] as int,
        totalAbsentDay: dataDecoded['totalAbsentDay'] as int,
        totalLateDay: dataDecoded['totalLateDay'] as int,
        totalLateDeduction: dataDecoded["totalLateDeduction"] + 0.0 as double,
        totalDeduction: dataDecoded["totalDeduction"] + 0.0 as double,
        totalDeductionAbsent:
            dataDecoded["totalDedutionAbsent"] + 0.0 as double);
  }
}

class LateAbsenceReport {
  List<LateAbsenceReportUnit> lateAbsenceReportUnitList;
  bool isDayOff;
  String lateRatio;
  String absentRatio;
  double totalDecutionForAllUsers;

  LateAbsenceReport(this.lateAbsenceReportUnitList, this.lateRatio,
      this.absentRatio, this.isDayOff, this.totalDecutionForAllUsers);
}

class LateAbsenceReportUnit {
  String userName;
  String userId;
  String totalLateDays;
  String totalAbsence;
  String totalLate;

  double totalDeduction;
  LateAbsenceReportUnit({
    this.userName,
    this.totalLateDays,
    this.totalDeduction,
    this.totalAbsence,
    this.totalLate,
    this.userId,
  });

  factory LateAbsenceReportUnit.fromJson(dynamic json) {
    String getTimeToString(int time) {
      if (time == 0) {
        return "-";
      } else {
        print(time);
        final double hoursDouble = time / 60.0;
        final int h = hoursDouble.toInt();
        print(h);
        final double minDouble = time.toDouble() % 60;
        final int m = minDouble.toInt();
        print(m);
        final NumberFormat formatter = new NumberFormat("00");
        return "${formatter.format(h)}:${formatter.format(m)}";
      }
    }

    return LateAbsenceReportUnit(
        userName: json['name'],
        totalDeduction: json["totalDeduction"] + 0.0 as double,
        totalLateDays: json['lateDays'].toString(),
        totalAbsence: json['absentDays'].toString(),
        totalLate: getTimeToString(json['lateTime'] as int),
        userId: json['id']);
  }
}

class UserAttendanceReportUnit {
  String date;
  String timeIn;
  String timeOut;
  String late;
  int status;
  int totalOfficialVacation;
  String timeInIsPm;
  String timeOutIsPm;

  UserAttendanceReportUnit(
      {this.date,
      this.timeIn,
      this.timeOut,
      this.status,
      this.late,
      this.timeInIsPm,
      this.timeOutIsPm,
      this.totalOfficialVacation});

  factory UserAttendanceReportUnit.fromJson(dynamic json) {
    String amPmChanger(String time) {
      if (time != "-" && time.toString().contains(":") && time != null) {
        final int intTime = int.parse(time.replaceAll(":", ""));
        int hours = (intTime ~/ 100);
        final int min = intTime - (hours * 100);

        // final ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours != 0 ? hours : 12; //

        final String hoursStr = hours < 10
            ? '0$hours'
            : hours.toString(); // the hour '0' should be '12'
        final String minStr = min < 10 ? '0$min' : min.toString();

        final strTime = '$hoursStr:$minStr';

        return strTime;
      } else {
        return time;
      }
    }

    String amOrPm(String time) {
      if (time != "-" && time.toString().contains(":")) {
        final int intTime = int.parse(time.replaceAll(":", ""));
        final int hours = (intTime ~/ 100);

        return hours >= 12 ? 'pm' : 'am';
      } else {
        return time;
      }
    }

    String getTimeToString(int time) {
      if (time == 0) {
        return "-";
      } else {
        print(time);
        final double hoursDouble = time / 60.0;
        final int h = hoursDouble.toInt();
        print(h);
        final double minDouble = time.toDouble() % 60;
        final int m = minDouble.toInt();
        print(m);
        final NumberFormat formatter = new NumberFormat("00");
        return "${formatter.format(h)}:${formatter.format(m)}";
      }
    }

    return UserAttendanceReportUnit(
        late: getTimeToString(json['lateTime'] as int),
        timeIn: amPmChanger(json['timeIn']),
        timeOut: amPmChanger(json['timeOut']),
        timeInIsPm: amOrPm(json['timeIn']),
        status: json["status"],
        timeOutIsPm: amOrPm(json['timeOut']),
        date: json['date']);
  }
}

class ReportsData with ChangeNotifier {
  Future futureListener;
  bool isLoading = false;
  List<AttendProofModel> attendProofList = [];
  DailyReport dailyReport = DailyReport([], 0, 0, false, "");
  InheritDefault inherit = InheritDefault();
  UserAttendanceReport userAttendanceReport = UserAttendanceReport(
      userAttendListUnits: [],
      totalAbsentDay: 0,
      totalLateDay: 0,
      totalLateDuration: "",
      totalLateDeduction: -1,
      isDayOff: 0,
      totalDeduction: 0,
      totalDeductionAbsent: 0,
      totalOfficialVacation: 0);

  LateAbsenceReport lateAbsenceReport =
      LateAbsenceReport([], "0%", "0%", true, 0.0);

  // Future<bool> isConnectedToInternet() async {
  //   final DataConnectionChecker dataConnectionChecker = DataConnectionChecker();
  //   final NetworkInfoImp networkInfoImp = NetworkInfoImp(dataConnectionChecker);
  //   final bool isConnected = await networkInfoImp.isConnected;
  //   if (isConnected) {
  //     return true;
  //   }
  //   return false;
  // }

  deleteAttendProofFromReport(
      String token, int id, int attendProofIndex) async {
    isLoading = true;
    notifyListeners();
    final response = await http.delete(
      Uri.parse("$baseURL/api/AttendProof/DeleteAttendProof?id=$id"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );
    isLoading = false;
    print(response.body);

    if (jsonDecode(response.body)["message"] ==
        "Success : AttendProof Deleted!") {
      attendProofList.removeAt(attendProofIndex);
    }
    notifyListeners();
    return jsonDecode(response.body)["message"];
  }

  TodayUserReport todayUserReport = TodayUserReport();
  Future<String> getTodayUserReport(String userId) async {
    final response = await ReprotsRepo().getTodayUserReport(userId);
    final decodedResponse = json.decode(response);
    if (decodedResponse["message"] == "Success") {
      todayUserReport = TodayUserReport.fromJson(decodedResponse["data"]);
      print(todayUserReport.attend);
      notifyListeners();
      return "Success";
    }
    return "fail";
  }

  getDailyAttendProofReport(
      String userToken, var apiId, String date, BuildContext context) {
    futureListener = getDailyAttendProofApi(
      userToken,
      apiId,
      date,
      context,
    );
    return futureListener;
  }

  getDailyAttendProofApi(
      String userToken, var apiId, String date, BuildContext context) async {
    attendProofList =
        await ReprotsRepo().getDailyAttendProofApi(apiId, userToken, date);
    notifyListeners();
  }

  getDailyReportUnits(
      String userToken, int siteId, String date, BuildContext context) {
    futureListener = getDailyReportUnitsApi(userToken, siteId, date, context);
    return futureListener;
  }

  Future<String> getDailyReportUnitsApi(
      String userToken, int siteId, String date, BuildContext context) async {
    List<DailyReportUnit> newReportList;

    isLoading = true;

    notifyListeners();
    final response = await ReprotsRepo().getDailyReport(
        "$baseURL/api/Reports/GetDailyReport?siteId=$siteId&date=$date",
        userToken);
    if (response is Faliure) {
      print(response.errorResponse);
      if (response.code == NO_INTERNET) {
        return "noInternet";
      }
    } else {
      final decodedRes = json.decode(response);

      if (decodedRes["message"] == "Success" ||
          decodedRes["message"] == "Success : Official Vacation Day" ||
          decodedRes["message"] == "Success : Holiday Day") {
        dailyReport.isHoliday = decodedRes['data']['isHoliDays'] as bool;
        // ignore: cascade_invocations
        dailyReport.totalAttend = decodedRes['data']['totalAttend'] as int;
        // ignore: cascade_invocations
        dailyReport.totalAbsent = decodedRes['data']['totalAbsent'] as int;
        if (decodedRes["message"] == "Success : Official Vacation Day") {
          dailyReport.officialHoliday =
              decodedRes["data"]["officialVactionName"];
        }
        if (decodedRes["data"]["users"] != null) {
          final reportObjJson = decodedRes['data']['users'] as List;

          newReportList = reportObjJson
              .map((reportJson) => DailyReportUnit.fromJson(reportJson))
              .toList();

          dailyReport.attendListUnits = [...newReportList];
          isLoading = false;
          notifyListeners();

          await Future.delayed(const Duration(milliseconds: 400), () {});
          return decodedRes["message"];
        } else {
          if (decodedRes["message"] == "Success : Official Vacation Day")
            return "No records found official vacation";
          else if (decodedRes["message"] == "Success : Holiday Day")
            return "No records found holiday";
        }
      } else if (decodedRes["message"] ==
          "Success : Date is older than company date") {
        return "Date is older than company date";
      } else if (decodedRes["message"] == "Success : Holiday Day") {
        dailyReport.isHoliday = decodedRes['data']['isHoliDays'] as bool;

        dailyReport.attendListUnits.clear();
        isLoading = false;
        notifyListeners();
        print("message ${dailyReport.isHoliday}");
        return "holiday";
      } else {
        return "wrong";
      }
    }
    return "failed";
  }

  getUserReportUnits(String userToken, String userId, String dateFrom,
      String dateTo, BuildContext context) {
    futureListener =
        getUserReportUnitsApi(userToken, userId, dateFrom, dateTo, context);
    return futureListener;
  }

  String getTimeToString(int time) {
    print(time);
    final double hoursDouble = time / 60.0;
    final int h = hoursDouble.toInt();
    print(h);
    final double minDouble = time.toDouble() % 60;
    final int m = minDouble.toInt();
    print(m);
    final NumberFormat formatter = new NumberFormat("00");
    return "${formatter.format(h)}:${formatter.format(m)}";
  }

  Future<String> getUserReportUnitsApi(String userToken, String userId,
      String dateFrom, String dateTo, BuildContext context) async {
    print("UseriD $userId , dateFrom = $dateFrom , dataTo = $dateTo");
    List<UserAttendanceReportUnit> newReportList;
    isLoading = true;

    final response = await ReprotsRepo().getUserReport(
        "${"$baseURL/api/Reports/GetUserAttendReport?userId=$userId&fromDate=$dateFrom&toDate=$dateTo"}",
        userToken);
    if (response is Faliure) {
      if (response.code == NO_INTERNET) {
        return "noInternet";
      }
    } else {
      final decodedRes = json.decode(response);
      final dataDecoded = decodedRes['data'];
      isLoading = false;

      if (decodedRes["message"] == "Success") {
        userAttendanceReport.totalOfficialVacation =
            decodedRes["data"]["totalOffcialVacation"];
        // ignore: cascade_invocations
        userAttendanceReport.totalLateDuration =
            getTimeToString(decodedRes['data']['totalLateDuration'] as int);
        userAttendanceReport = UserAttendanceReport();
        userAttendanceReport.totalAbsentDay =
            dataDecoded['totalAbsentDay'] as int;
        // ignore: cascade_invocations
        userAttendanceReport.totalLateDay = dataDecoded['totalLateDay'] as int;
        // ignore: cascade_invocations
        userAttendanceReport.totalLateDeduction =
            dataDecoded["totalLateDeduction"] + 0.0 as double;
        // ignore: cascade_invocations
        userAttendanceReport.totalDeduction =
            dataDecoded["totalDeduction"] + 0.0 as double;
        // ignore: cascade_invocations
        userAttendanceReport.totalDeductionAbsent =
            dataDecoded["totalDedutionAbsent"] + 0.0 as double;
        // ignore: cascade_invocations
        userAttendanceReport.totalLateDuration =
            getTimeToString(decodedRes['data']['totalLateDuration'] as int);

        final reportObjJson =
            jsonDecode(response)['data']['userDayAttends'] as List;
        userAttendanceReport.totalOfficialVacation =
            decodedRes["data"]["totalOffcialVacation"] as int;
        log(reportObjJson.toString());
        if (reportObjJson.isNotEmpty) {
          print("reportObjJson: $reportObjJson");
          userAttendanceReport.isDayOff = 0;
          newReportList = reportObjJson
              .map(
                  (reportJson) => UserAttendanceReportUnit.fromJson(reportJson))
              .toList();

          userAttendanceReport.userAttendListUnits = newReportList;
          notifyListeners();
          print("success");
          return "Success";
        } else {
          userAttendanceReport.userAttendListUnits = [];
          // ignore: cascade_invocations
          userAttendanceReport.isDayOff = 1;
          notifyListeners();

          return "dayOff";
        }
      } else if (decodedRes["message"] ==
          "Success: User Created after this period.") {
        return "user created after period";
      } else if (decodedRes["message"] ==
          "Failed : user name and password not match ") {
        return "wrong";
      }
    }
    return "failed";
  }

  getLateAbsenceReport(String userToken, int siteId, String dateFrom,
      String dateTo, BuildContext context) {
    futureListener =
        getLateAbsenceReportApi(userToken, siteId, dateFrom, dateTo, context);
    return futureListener;
  }

  getLateAbsenceReportApi(String userToken, int siteId, String dateFrom,
      String dateTo, BuildContext context) async {
    print("siteId $siteId , dateFrom = $dateFrom , dataTo = $dateTo");
    List<LateAbsenceReportUnit> newReportList;
    isLoading = true;
    notifyListeners();

    try {
      final response = await ReprotsRepo().getLateAbsenceReport(
          "$baseURL/api/Reports/GetLateAbsentReport?siteId=$siteId&fromDate=$dateFrom&toDate=$dateTo",
          userToken);
//  "https://ChilangoBackVUT.tamauzeds.com/api/Reports/GetLateAbsentReport_New?siteId=$siteId&fromDate=$dateFrom&toDate=$dateTo"

      final decodedRes = json.decode(response);
      if (response is Faliure) {
        if (response.code == NO_INTERNET) {
          return 'noInternet';
        }
      } else {
        if (decodedRes["message"] == "Success") {
          lateAbsenceReport.absentRatio = decodedRes['data']['absentRatio'];
          // ignore: cascade_invocations
          lateAbsenceReport.lateRatio = decodedRes['data']['lateRatio'];
          // ignore: cascade_invocations
          lateAbsenceReport.totalDecutionForAllUsers =
              decodedRes["data"]["totalDeductionForAllUsers"] + 0.0 as double;
          if (lateAbsenceReport.absentRatio == "%NaN" &&
              lateAbsenceReport.lateRatio == "%0") {
            lateAbsenceReport.isDayOff = true;
          } else {
            lateAbsenceReport.isDayOff = false;
          }

          final reportObjJson =
              jsonDecode(response)['data']['userLateAbsentReport'] as List;

          newReportList = reportObjJson
              .map((reportJson) => LateAbsenceReportUnit.fromJson(reportJson))
              .toList();

          lateAbsenceReport.lateAbsenceReportUnitList = newReportList;
          isLoading = false;
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 1500), () {});

          return "Success";
        } else if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return "wrong";
        } else if (decodedRes["message"] ==
            "Success: Date is older than company date") {
          return "Date is older than company date";
        }
      }
    } catch (e) {
      print(e);
    }
    return "failed";
  }
}
