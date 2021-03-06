import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
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
      this.userAttendPictureURL,
      this.userLeavePictureURL,
      this.timeInIcon,
      this.timeOutIcon});

  factory DailyReportUnit.fromJson(dynamic json) {
    String getTimeToString(int time) {
      if (time == 0) {
        return "-";
      } else {
        print(time);
        double hoursDouble = time / 60.0;
        int h = hoursDouble.toInt();
        print(h);
        double minDouble = time.toDouble() % 60;
        int m = minDouble.toInt();
        print(m);
        NumberFormat formatter = new NumberFormat("00");
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
          int intTime = int.parse(time.replaceAll(":", ""));
          int hours = (intTime ~/ 100);
          int min = intTime - (hours * 100);

          var ampm = hours >= 12 ? 'pm' : 'am';
          hours = hours % 12;
          hours = hours != 0 ? hours : 12; //

          String hoursStr = hours < 10
              ? '0$hours'
              : hours.toString(); // the hour '0' should be '12'
          String minStr = min < 10 ? '0$min' : min.toString();

          var strTime = '$hoursStr:$minStr';

          return strTime;
      }
    }

    String amOrPm(String time) {
      if (time != "-" && time.toString().contains(":")) {
        int intTime = int.parse(time.replaceAll(":", ""));
        int hours = (intTime ~/ 100);

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
      userLeavePictureURL: json['userLeavePicture'] ?? "",
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
      this.userAttendListUnits,
      this.totalAbsentDay,
      this.totalLateDay,
      this.totalLateDuration,
      this.isDayOff,
      this.totalLateDeduction,
      this.totalDeductionAbsent,
      this.totalDeduction,
      this.totalOfficialVacation);
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
        double hoursDouble = time / 60.0;
        int h = hoursDouble.toInt();
        print(h);
        double minDouble = time.toDouble() % 60;
        int m = minDouble.toInt();
        print(m);
        NumberFormat formatter = new NumberFormat("00");
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
        int intTime = int.parse(time.replaceAll(":", ""));
        int hours = (intTime ~/ 100);
        int min = intTime - (hours * 100);

        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours != 0 ? hours : 12; //

        String hoursStr = hours < 10
            ? '0$hours'
            : hours.toString(); // the hour '0' should be '12'
        String minStr = min < 10 ? '0$min' : min.toString();

        var strTime = '$hoursStr:$minStr';

        return strTime;
      } else {
        return time;
      }
    }

    String amOrPm(String time) {
      if (time != "-" && time.toString().contains(":")) {
        int intTime = int.parse(time.replaceAll(":", ""));
        int hours = (intTime ~/ 100);

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
        double hoursDouble = time / 60.0;
        int h = hoursDouble.toInt();
        print(h);
        double minDouble = time.toDouble() % 60;
        int m = minDouble.toInt();
        print(m);
        NumberFormat formatter = new NumberFormat("00");
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
  UserAttendanceReport userAttendanceReport =
      UserAttendanceReport([], 0, 0, "", -1, 0, 0, 0, 0);

  LateAbsenceReport lateAbsenceReport =
      LateAbsenceReport([], "0%", "0%", true, 0.0);

  Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
    return false;
  }

  deleteAttendProofFromReport(
      String token, int id, int attendProofIndex) async {
    isLoading = true;
    notifyListeners();
    var response = await http.delete(
      Uri.parse("$baseURL/api/AttendProof/DeleteAttendProof?id=$id"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );
    isLoading = false;
    print(response.body);
    attendProofList.removeAt(attendProofIndex);

    print(response.statusCode);
    print(response.body);
    notifyListeners();
    return jsonDecode(response.body)["message"];
  }

  TodayUserReport todayUserReport = TodayUserReport();
  Future<String> getTodayUserReport(String userToken, String userId) async {
    final response = await http.get(
        Uri.parse("$baseURL/api/AttendLogin/todayAttend/$userId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    print(response.body);
    final decodedResponse = json.decode(response.body);
    if (decodedResponse["message"] == "Success") {
      todayUserReport = TodayUserReport.fromJson(decodedResponse["data"]);
      print(todayUserReport.attend);
      notifyListeners();
      return "Success";
    }
    return "fail";
  }

  getDailyAttendProofReport(String userToken, var apiId, String date,
      BuildContext context, int userType) {
    futureListener = getDailyAttendProofApi(
      userToken,
      apiId,
      userType,
      date,
      context,
    );
    return futureListener;
  }

  Future<String> getDailyAttendProofApi(String userToken, var apiId,
      int userType, String date, BuildContext context) async {
    if (await isConnectedToInternet()) {
      print(date);
      String url;
      if (userType == 3) {
        url = "$baseURL/api/AttendProof/GetProofbyCreatedUserId/$date";
      } else {
        url =
            "$baseURL/api/AttendProof/GetProofbycompanyId?companyid=$apiId&date=$date";
      }
      print(url);
      final response = await http.get(
          Uri.parse(
            url,
          ),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedRes = json.decode(response.body);
        print(response.body);
        if (decodedRes["message"] == "Success") {
          var reportObjJson = jsonDecode(response.body)['data'] as List;

          attendProofList = reportObjJson
              .map((reportJson) => AttendProofModel.fromJson(reportJson))
              .toList();

          notifyListeners();
          return decodedRes["message"];
        } else if (decodedRes["message"] == "No AttendProofs was found!") {
          attendProofList.clear();
        }
      }
    }

    return 'noInternet';
  }

  getDailyReportUnits(
      String userToken, int siteId, String date, BuildContext context) {
    futureListener = getDailyReportUnitsApi(userToken, siteId, date, context);
    return futureListener;
  }

  Future<String> getDailyReportUnitsApi(
      String userToken, int siteId, String date, BuildContext context) async {
    List<DailyReportUnit> newReportList;
    print("site id $siteId");
    if (await isConnectedToInternet()) {
      final response = await http.get(
          Uri.parse(
              "$localURL/api/Reports/GetDailyReport?siteId=$siteId&date=$date"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      print(response.statusCode);
      log(response.body);
      if (response.statusCode == 401) {
        await inherit.login(context);
        userToken =
            Provider.of<UserData>(context, listen: false).user.userToken;
        await getDailyReportUnitsApi(userToken, siteId, date, context);
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedRes = json.decode(response.body);
        print(response.body);
        if (decodedRes["message"] == "Success" ||
            decodedRes["message"] == "Success : Official Vacation Day" ||
            decodedRes["message"] == "Success : Holiday Day") {
          dailyReport.isHoliday = decodedRes['data']['isHoliDays'] as bool;
          dailyReport.totalAttend = decodedRes['data']['totalAttend'] as int;
          dailyReport.totalAbsent = decodedRes['data']['totalAbsent'] as int;
          if (decodedRes["message"] == "Success : Official Vacation Day") {
            dailyReport.officialHoliday =
                decodedRes["data"]["officialVactionName"];
          }
          if (decodedRes["data"]["users"] != null) {
            var reportObjJson =
                jsonDecode(response.body)['data']['users'] as List;

            newReportList = reportObjJson
                .map((reportJson) => DailyReportUnit.fromJson(reportJson))
                .toList();

            dailyReport.attendListUnits = [...newReportList];
            notifyListeners();
            print("message ${dailyReport.isHoliday}");
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
          notifyListeners();
          print("message ${dailyReport.isHoliday}");
          return "holiday";
        }
        // else if (decodedRes["message"] == "Success : Official Vacation Day") {
        //   dailyReport.officialHoliday =
        //       decodedRes["data"]["officialVactionName"];
        //   dailyReport.attendListUnits.clear();
        //   notifyListeners();

        //   return "officialHoliday";
        // }
        else {
          return "wrong";
        }
      }

      return "failed";
    } else {
      return 'noInternet';
    }
  }

  getUserReportUnits(String userToken, String userId, String dateFrom,
      String dateTo, BuildContext context) {
    futureListener =
        getUserReportUnitsApi(userToken, userId, dateFrom, dateTo, context);
    return futureListener;
  }

  String getTimeToString(int time) {
    print(time);
    double hoursDouble = time / 60.0;
    int h = hoursDouble.toInt();
    print(h);
    double minDouble = time.toDouble() % 60;
    int m = minDouble.toInt();
    print(m);
    NumberFormat formatter = new NumberFormat("00");
    return "${formatter.format(h)}:${formatter.format(m)}";
  }

  Future<String> getUserReportUnitsApi(String userToken, String userId,
      String dateFrom, String dateTo, BuildContext context) async {
    print("UseriD $userId , dateFrom = $dateFrom , dataTo = $dateTo");
    List<UserAttendanceReportUnit> newReportList;
    isLoading = true;
    if (await isConnectedToInternet()) {
      final response = await http.get(
          Uri.parse(
              "$baseURL/api/Reports/GetUserAttendReport?userId=$userId&fromDate=$dateFrom&toDate=$dateTo"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });

      print(response.statusCode);
      if (response.statusCode == 401) {
        await inherit.login(context);
        userToken =
            Provider.of<UserData>(context, listen: false).user.userToken;
        await getUserReportUnitsApi(
            userToken, userId, dateFrom, dateTo, context);
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedRes = json.decode(response.body);
        isLoading = false;
        print(response.body);

        if (decodedRes["message"] == "Success") {
          userAttendanceReport.totalOfficialVacation =
              decodedRes["data"]["totalOffcialVacation"];
          userAttendanceReport.totalLateDuration =
              getTimeToString(decodedRes['data']['totalLateDuration'] as int);
          userAttendanceReport.totalAbsentDay =
              decodedRes['data']['totalAbsentDay'] as int;
          userAttendanceReport.totalLateDay =
              decodedRes['data']['totalLateDay'] as int;
          userAttendanceReport.totalLateDeduction =
              decodedRes["data"]["totalLateDeduction"] + 0.0 as double;
          userAttendanceReport.totalDeduction =
              decodedRes["data"]["totalDeduction"] + 0.0 as double;
          userAttendanceReport.totalDeductionAbsent =
              decodedRes["data"]["totalDedutionAbsent"] + 0.0 as double;
          var reportObjJson =
              jsonDecode(response.body)['data']['userDayAttends'] as List;
          userAttendanceReport.totalOfficialVacation =
              decodedRes["data"]["totalOffcialVacation"] as int;

          if (reportObjJson.isNotEmpty) {
            print("reportObjJson: $reportObjJson");
            userAttendanceReport.isDayOff = 0;
            newReportList = reportObjJson
                .map((reportJson) =>
                    UserAttendanceReportUnit.fromJson(reportJson))
                .toList();

            userAttendanceReport.userAttendListUnits = newReportList;
            notifyListeners();
            print("success");
            return "Success";
          } else {
            userAttendanceReport.userAttendListUnits = [];
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
      print(response.statusCode);
      return "failed";
    } else {
      return 'noInternet';
    }
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
    if (await isConnectedToInternet()) {
      try {
        final response = await http.get(
            Uri.parse(
                "$baseURL/api/Reports/GetLateAbsentReport?siteId=$siteId&fromDate=$dateFrom&toDate=$dateTo"),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });
        print(response.statusCode);
        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await getLateAbsenceReportApi(
              userToken, siteId, dateFrom, dateTo, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          log(response.body);

          if (decodedRes["message"] == "Success") {
            lateAbsenceReport.absentRatio = decodedRes['data']['absentRatio'];
            lateAbsenceReport.lateRatio = decodedRes['data']['lateRatio'];
            lateAbsenceReport.totalDecutionForAllUsers =
                decodedRes["data"]["totalDeductionForAllUsers"] + 0.0 as double;
            if (lateAbsenceReport.absentRatio == "%NaN" &&
                lateAbsenceReport.lateRatio == "%0") {
              lateAbsenceReport.isDayOff = true;
            } else {
              lateAbsenceReport.isDayOff = false;
            }

            var reportObjJson = jsonDecode(response.body)['data']
                ['userLateAbsentReport'] as List;

            newReportList = reportObjJson
                .map((reportJson) => LateAbsenceReportUnit.fromJson(reportJson))
                .toList();

            lateAbsenceReport.lateAbsenceReportUnitList = newReportList;
            notifyListeners();

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
    } else {
      return 'noInternet';
    }
  }
}
