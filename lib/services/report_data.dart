import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

class DailyReportUnit {
  String userId;
  String userName;
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
      if (time != "-") {
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
      if (time != "-") {
        int intTime = int.parse(time.replaceAll(":", ""));
        int hours = (intTime ~/ 100);

        return hours >= 12 ? 'pm' : 'am';
      } else {
        return time;
      }
    }

    return DailyReportUnit(
      userName: json['name'],
      userId: json['id'],
      timeIn: amPmChanger(json['attendTime']),
      timeInIcon: amOrPm(json['attendTime']),
      timeOut: amPmChanger(json['leavingTime']),
      timeOutIcon: amOrPm(json['leavingTime']),
      lateTime: getTimeToString(json['late'] as int),
      attendType: int.parse(json['userAttendType'] ?? "0"),
      userAttendPictureURL: json['userAttendPicture'] ?? "",
      userLeavePictureURL: json['userLeavePicture'] ?? "",
    );
  }
}

class DailyReport {
  List<DailyReportUnit> attendListUnits;
  bool isHoliday;
  int totalAttend;
  int totalAbsent;

  DailyReport(
      this.attendListUnits, this.totalAttend, this.totalAbsent, this.isHoliday);
}

class UserAttendanceReport {
  List<UserAttendanceReportUnit> userAttendListUnits;

  int totalAbsentDay;
  int totalLateDay;
  String totalLateDuration;
  int isDayOff;

  UserAttendanceReport(this.userAttendListUnits, this.totalAbsentDay,
      this.totalLateDay, this.totalLateDuration, this.isDayOff);
}

class LateAbsenceReport {
  List<LateAbsenceReportUnit> lateAbsenceReportUnitList;
  bool isDayOff;
  String lateRatio;
  String absentRatio;

  LateAbsenceReport(this.lateAbsenceReportUnitList, this.lateRatio,
      this.absentRatio, this.isDayOff);
}

class LateAbsenceReportUnit {
  String userName;
  String userId;
  String totalLateDays;
  String totalAbsence;
  String totalLate;

  LateAbsenceReportUnit(
      {this.userName,
      this.totalLateDays,
      this.totalAbsence,
      this.totalLate,
      this.userId});

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
  String timeInIsPm;
  String timeOutIsPm;

  UserAttendanceReportUnit(
      {this.date,
      this.timeIn,
      this.timeOut,
      this.late,
      this.timeInIsPm,
      this.timeOutIsPm});

  factory UserAttendanceReportUnit.fromJson(dynamic json) {
    String amPmChanger(String time) {
      if (time != "-") {
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
      if (time != "-") {
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
        timeOutIsPm: amOrPm(json['timeOut']),
        date: json['date']);
  }
}

class ReportsData with ChangeNotifier {
  Future futureListener;
  DailyReport dailyReport = DailyReport([], 0, 0, false);
InheritDefault inherit=InheritDefault();
  UserAttendanceReport userAttendanceReport =
      UserAttendanceReport([], 0, 0, "", -1);

  LateAbsenceReport lateAbsenceReport = LateAbsenceReport([], "0%", "0%", true);

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

  getDailyReportUnits(String userToken, int siteId, String date,BuildContext context) {
    futureListener = getDailyReportUnitsApi(userToken, siteId, date,context);
    return futureListener;
  }

  getDailyReportUnitsApi(String userToken, int siteId, String date,BuildContext context) async {
    List<DailyReportUnit> newReportList;
    if (await isConnectedToInternet()) {
      try {
        final response = await http.get(
            "$baseURL/api/Reports/GetDailyReport?siteId=$siteId&date=$date",
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });


                       if (response.statusCode==401)
        {
        await  inherit.login(context);
        userToken=Provider.of<UserData>(context,listen: false).user.userToken;
        await getDailyReportUnitsApi(userToken, siteId, date,context);
        }
        else if (response.statusCode==200 || response.statusCode==201)
        {      var decodedRes = json.decode(response.body);
        print(response.body);
        if (decodedRes["message"] == "Success") {
          dailyReport.isHoliday = decodedRes['data']['isHoliDays'] as bool;
          dailyReport.totalAttend = decodedRes['data']['totalAttend'] as int;
          dailyReport.totalAbsent = decodedRes['data']['totalAbsent'] as int;

          var reportObjJson =
              jsonDecode(response.body)['data']['users'] as List;

          newReportList = reportObjJson
              .map((reportJson) => DailyReportUnit.fromJson(reportJson))
              .toList();

          dailyReport.attendListUnits = [...newReportList];
          notifyListeners();
          print("message ${dailyReport.isHoliday}");
          return "Success";
        } else if (decodedRes["message"] == "Success : Holiday Day") {
          dailyReport.isHoliday = decodedRes['data']['isHoliDays'] as bool;
          dailyReport.attendListUnits.clear();
          notifyListeners();
          print("message ${dailyReport.isHoliday}");
          return "holiday";
        } else {
          return "wrong";
        }}
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }

  getUserReportUnits(
      String userToken, String userId, String dateFrom, String dateTo,BuildContext context) {
    futureListener = getUserReportUnitsApi(userToken, userId, dateFrom, dateTo,context);
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

  getUserReportUnitsApi(
      String userToken, String userId, String dateFrom, String dateTo,BuildContext context) async {
    print("UseriD $userId , dateFrom = $dateFrom , dataTo = $dateTo");
    List<UserAttendanceReportUnit> newReportList;
    if (await isConnectedToInternet()) {
      try {
        final response = await http.get(
            "$baseURL/api/Reports/GetUserAttendReport?userId=$userId&fromDate=$dateFrom&toDate=$dateTo",
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

                       if (response.statusCode==401)
        {
        await  inherit.login(context);
        userToken=Provider.of<UserData>(context,listen: false).user.userToken;
        await getUserReportUnitsApi(userToken, userId, dateFrom,dateTo,context);
        }
        else if (response.statusCode==200 || response.statusCode==201)
        {      var decodedRes = json.decode(response.body);
        print(response.body);

        if (decodedRes["message"] == "Success") {
          userAttendanceReport.totalLateDuration =
              getTimeToString(decodedRes['data']['totalLateDuration'] as int);
          userAttendanceReport.totalAbsentDay =
              decodedRes['data']['totalAbsentDay'] as int;
          userAttendanceReport.totalLateDay =
              decodedRes['data']['totalLateDay'] as int;

          var reportObjJson =
              jsonDecode(response.body)['data']['userDayAttends'] as List;

          if (reportObjJson.isNotEmpty) {
            print("reportObjJson: $reportObjJson");
            userAttendanceReport.isDayOff = 0;
            newReportList = reportObjJson
                .map((reportJson) =>
                    UserAttendanceReportUnit.fromJson(reportJson))
                .toList();

            userAttendanceReport.userAttendListUnits = newReportList;
            notifyListeners();
            return "Success";
          } else {
            userAttendanceReport.userAttendListUnits = [];
            userAttendanceReport.isDayOff = 1;
            notifyListeners();
            print("dayOff");
            return "dayOff";
          }
        } else if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return "wrong";
        }}
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }

  getLateAbsenceReport(
      String userToken, int siteId, String dateFrom, String dateTo,BuildContext context) {
    futureListener =
        getLateAbsenceReportApi(userToken, siteId, dateFrom, dateTo,context);
    return futureListener;
  }

  getLateAbsenceReportApi(
      String userToken, int siteId, String dateFrom, String dateTo,BuildContext context) async {
    print("siteId $siteId , dateFrom = $dateFrom , dataTo = $dateTo");
    List<LateAbsenceReportUnit> newReportList;
    if (await isConnectedToInternet()) {
      try {
        final response = await http.get(
            "$baseURL/api/Reports/GetLateAbsentReport?siteId=$siteId&fromDate=$dateFrom&toDate=$dateTo",
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

    
                       if (response.statusCode==401)
        {
        await  inherit.login(context);
        userToken=Provider.of<UserData>(context,listen: false).user.userToken;
        await getLateAbsenceReportApi(userToken, siteId, dateFrom,dateTo,context);
        }
        else if (response.statusCode==200 || response.statusCode==201)
        {      var decodedRes = json.decode(response.body);
        print(response.body);


        if (decodedRes["message"] == "Success") {
          lateAbsenceReport.absentRatio = decodedRes['data']['absentRatio'];
          lateAbsenceReport.lateRatio = decodedRes['data']['lateRatio'];
          if (lateAbsenceReport.absentRatio == "%NaN" &&
              lateAbsenceReport.lateRatio == "%0") {
            lateAbsenceReport.isDayOff = true;
          } else {
            lateAbsenceReport.isDayOff = false;
          }

          var reportObjJson =
              jsonDecode(response.body)['data']['userLateAbsentReport'] as List;

          newReportList = reportObjJson
              .map((reportJson) => LateAbsenceReportUnit.fromJson(reportJson))
              .toList();

          lateAbsenceReport.lateAbsenceReportUnitList = newReportList;
          notifyListeners();

          return "Success";
        } else if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return "wrong";
        }}
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }
}
