import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

import 'Shift.dart';

class Day {
  String dayName;
  bool isDayOff = false;
  bool isActivated = false;
  String sitename;
  TimeOfDay fromDate;
  TimeOfDay toDate;
  String shiftname;
  TextEditingController timeInController = TextEditingController();
  TextEditingController timeOutController = TextEditingController();
}

class DaysOffData with ChangeNotifier {
  List<Day> weak = [Day(), Day(), Day(), Day(), Day(), Day(), Day()];
  List<Day> reallocateUsers = [];
  List<Day> advancedShift = [];
  toggleDayOff(int i) {
    weak[i].isDayOff = false;
    notifyListeners();
  }

  toggleDayOn(int i) {
    weak[i].isDayOff = true;
    notifyListeners();
  }

  setSiteAndShift(int index, String sitename, String shiftname) {
    reallocateUsers[index].sitename = sitename;
    reallocateUsers[index].shiftname = shiftname;
    notifyListeners();
  }

  setFromAndTo(
    int index,
    var from,
    var to,
  ) {
    advancedShift[index].fromDate = from;
    advancedShift[index].toDate = to;

    notifyListeners();
  }

  fillAdvancedShiftTime(timeIn, timeOut) {
    for (int i = 0; i < advancedShift.length; i++) {
      advancedShift[i].timeInController.text = timeIn;
      advancedShift[i].timeOutController.text = timeOut;
    }
  }

  String amPmChanger(int intTime) {
    int hours = (intTime ~/ 100);
    int min = intTime - (hours * 100);

    var ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours != 0 ? hours : 12; //

    String hoursStr = hours < 10
        ? '0$hours'
        : hours.toString(); // the hour '0' should be '12'
    String minStr = min < 10 ? '0$min' : min.toString();

    var strTime = '$hoursStr:$minStr$ampm';

    return strTime;
  }

  fillAdvancedShiftWithRealData(Shift shift, BuildContext context) {
    advancedShift[0].timeOutController.text = amPmChanger(shift.shiftEndTime);
    advancedShift[0].timeInController.text = amPmChanger(shift.shiftStartTime);
    advancedShift[1].timeOutController.text = amPmChanger(shift.sunShiftenTime);
    advancedShift[1].timeInController.text = amPmChanger(shift.sunShiftstTime);
    advancedShift[2].timeOutController.text =
        amPmChanger(shift.mondayShiftenTime);
    advancedShift[2].timeInController.text = amPmChanger(shift.monShiftstTime);
    advancedShift[3].timeOutController.text =
        amPmChanger(shift.tuesdayShiftenTime);
    advancedShift[3].timeInController.text =
        amPmChanger(shift.tuesdayShiftstTime);
    advancedShift[4].timeOutController.text =
        amPmChanger(shift.wednesDayShiftenTime);
    advancedShift[4].timeInController.text =
        amPmChanger(shift.wednesDayShiftstTime);
    advancedShift[5].timeOutController.text =
        amPmChanger(shift.thursdayShiftenTime);
    advancedShift[5].timeInController.text =
        amPmChanger(shift.thursdayShiftstTime);
    advancedShift[6].timeOutController.text =
        amPmChanger(shift.fridayShiftenTime);
    advancedShift[6].timeInController.text =
        amPmChanger(shift.fridayShiftstTime);
  }

  InheritDefault inheritDefault = InheritDefault();
  Future future;
  Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  getDaysOff(int companyId, String userToken, BuildContext context,
      [Shift shift]) {
    future = getDaysOffApi(companyId, userToken, context, shift);
    return future;
  }

  getDaysOffApi(int companyId, String userToken, BuildContext context,
      [Shift shift]) async {
    print("$baseURL/api/DaysOff/GetCompanyDaysOff/$companyId");
    if (await isConnectedToInternet()) {
      try {
        advancedShift.clear();
        reallocateUsers.clear();
        final response = await http.get(
            Uri.parse("$baseURL/api/DaysOff/GetCompanyDaysOff/$companyId"),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

        if (response.statusCode == 401) {
          await inheritDefault.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await getDaysOffApi(companyId, userToken, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          if (decodedRes["message"] == "Success") {
            weak[0].isDayOff = decodedRes["data"]["saturDay"] as bool;
            weak[0].dayName = "السبت";

            weak[1].isDayOff = decodedRes["data"]["sunDay"] as bool;
            weak[1].dayName = "الاحد";

            weak[2].isDayOff = decodedRes["data"]["monDay"] as bool;
            weak[2].dayName = "الاثنين";

            weak[3].isDayOff = decodedRes["data"]["tuesDay"] as bool;
            weak[3].dayName = "الثلاثاء";

            weak[4].isDayOff = decodedRes["data"]["wendseDay"] as bool;
            weak[4].dayName = "الاربعاء";

            weak[5].isDayOff = decodedRes["data"]["thurseDay"] as bool;
            weak[5].dayName = "الخميس";

            weak[6].isDayOff = decodedRes["data"]["friDay"] as bool;
            weak[6].dayName = "الجمعة";
            reallocateUsers = [...weak];
            advancedShift = [...weak];
            print(shift == null);
            if (shift == null) {
              print("shift is null");
              for (int i = 0; i < advancedShift.length; i++) {
                advancedShift[i].fromDate = null;
                advancedShift[i].toDate = null;
              }
            } else {
              advancedShift[0].fromDate =
                  (intToTimeOfDay(shift.shiftStartTime));
              advancedShift[0].toDate = (intToTimeOfDay(shift.shiftEndTime));
              advancedShift[1].fromDate =
                  (intToTimeOfDay(shift.sunShiftstTime));
              advancedShift[1].toDate = (intToTimeOfDay(shift.sunShiftenTime));
              advancedShift[2].fromDate =
                  (intToTimeOfDay(shift.monShiftstTime));
              advancedShift[2].toDate =
                  (intToTimeOfDay(shift.mondayShiftenTime));
              advancedShift[3].fromDate =
                  (intToTimeOfDay(shift.tuesdayShiftstTime));
              advancedShift[3].toDate =
                  (intToTimeOfDay(shift.thursdayShiftenTime));
              advancedShift[4].fromDate =
                  (intToTimeOfDay(shift.wednesDayShiftstTime));
              advancedShift[4].toDate =
                  (intToTimeOfDay(shift.wednesDayShiftenTime));
              advancedShift[5].fromDate =
                  (intToTimeOfDay(shift.thursdayShiftstTime));
              advancedShift[5].toDate =
                  (intToTimeOfDay(shift.thursdayShiftenTime));
              advancedShift[6].toDate =
                  (intToTimeOfDay(shift.fridayShiftstTime));
              advancedShift[6].toDate =
                  (intToTimeOfDay(shift.fridayShiftenTime));
              fillAdvancedShiftWithRealData(shift, context);
            }

            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Failed : user name and password not match ") {
            return "wrong";
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

  editDaysOffApi(int companyId, String userToken, BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http.put(
            Uri.parse("$baseURL/api/DaysOff?companyId=$companyId"),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            },
            body: json.encode(
              {
                "saturDay": weak[0].isDayOff,
                "sunDay": weak[1].isDayOff,
                "monDay": weak[2].isDayOff,
                "tuseDay": weak[3].isDayOff,
                "wendseDay": weak[4].isDayOff,
                "thurseDay": weak[5].isDayOff,
                "friDay": weak[6].isDayOff,
                "companyId": companyId
              },
            ));
        if (response.statusCode == 401) {
          await inheritDefault.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await editDaysOffApi(companyId, userToken, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(decodedRes);

          if (decodedRes["message"] == "Success : Update Successfully") {
            weak[0].isDayOff = decodedRes["data"]["saturDay"];
            weak[0].dayName = "السبت";

            weak[1].isDayOff = decodedRes["data"]["sunDay"];
            weak[1].dayName = "الاحد";

            weak[2].isDayOff = decodedRes["data"]["monDay"];
            weak[2].dayName = "الاثنين";

            weak[3].isDayOff = decodedRes["data"]["tuesDay"];
            weak[3].dayName = "الثلاثاء";

            weak[4].isDayOff = decodedRes["data"]["wendseDay"];
            weak[4].dayName = "الاربعاء";

            weak[5].isDayOff = decodedRes["data"]["thurseDay"];
            weak[5].dayName = "الخميس";

            weak[6].isDayOff = decodedRes["data"]["friDay"];
            weak[6].dayName = "الجمعة";
            reallocateUsers = [...weak];
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Failed : user name and password not match ") {
            return "wrong";
          }
        }
        return "failed";
      } catch (e) {
        print(e);
      }
    }
    return 'noInternet';
  }
}
