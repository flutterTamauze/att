import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
  int shiftID;
  TextEditingController timeInController = TextEditingController();
  TextEditingController timeOutController = TextEditingController();
}

class DaysOffData with ChangeNotifier {
  List<Day> weak = [Day(), Day(), Day(), Day(), Day(), Day(), Day()];
  List<Day> reallocateUsers = [];

  toggleDayOff(int i) {
    weak[i].isDayOff = false;
    notifyListeners();
  }

  toggleDayOn(int i) {
    weak[i].isDayOff = true;
    notifyListeners();
  }

  setSiteAndShift(int index, String sitename, String shiftname, int shiftID) {
    print("setting att $index $shiftID");
    reallocateUsers[index].sitename = sitename;
    reallocateUsers[index].shiftname = shiftname;
    reallocateUsers[index].shiftID = shiftID;

    notifyListeners();
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
