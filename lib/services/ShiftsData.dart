import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/CameraPickerScreen.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/FuturedScheduleShift.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

import 'Shift.dart';
import 'ShiftSchedule/ShiftScheduleModel.dart';

class ShiftsData with ChangeNotifier {
  List<Shift> shiftsList = [];
  List<Shift> shiftsBySite = [];
  DateTime scheduleFromTime;
  DateTime scheduleTotime;
  Future futureListener;
  bool isLoading = false;
  InheritDefault inherit = InheritDefault();
  List<ShiftSheduleModel> shiftScheduleList = [];
  ShiftSheduleModel firstAvailableSchedule;
  FutureShiftSchedule satShift;
  findMatchingShifts(int siteId, bool addallshiftsBool) {
    try {
      print("findMatchingShifts : $siteId");
      shiftsBySite =
          shiftsList.where((element) => element.siteID == siteId).toList();
      if (addallshiftsBool == true) {
        shiftsBySite.insert(
            0,
            Shift(
              shiftEndTime: 0,
              shiftId: -100,
              shiftName: "كل المناوبات",
              shiftStartTime: 0,
              siteID: -100,
              shiftQrCode: "",
            ));
      }

      if (shiftsBySite.length == 0) {
        shiftsBySite = [
          Shift(
              shiftName: "لا يوجد مناوبات بهذا الموقع",
              shiftStartTime: -1,
              shiftEndTime: 0,
              shiftId: 0,
              siteID: 0)
        ];
      }
    } catch (e) {
      print(e);
    }
    print("shift by site length ${shiftsBySite.length}");
    return shiftsBySite.length;
  }

  setScheduleSiteAndShift(
    int scheduleIndex,
    int currentIndex,
    int siteId,
    int shiftId,
  ) {
    shiftScheduleList[scheduleIndex].scheduleSiteNumber[currentIndex] = siteId;
    shiftScheduleList[scheduleIndex].scheduleShiftsNumber[currentIndex] =
        shiftId;

    notifyListeners();
  }

  setScheduleShiftFromAndto(int scheduleIndex, DateTime to, DateTime from) {
    shiftScheduleList[scheduleIndex].scheduleToTime = to;
    shiftScheduleList[scheduleIndex].scheduleFromTime = from;
    notifyListeners();
  }

  Future<String> deleteShiftScheduleById(
      int shiftId, String userToken, int currentIndex) async {
    print(currentIndex);
    print(shiftScheduleList[currentIndex].id);
    isLoading = true;
    notifyListeners();
    var response = await http.delete(
        Uri.parse("$baseURL/api/ShiftSchedule/Del_ScheduleShiftsbyId/$shiftId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    shiftScheduleList.removeAt(currentIndex);
    isLoading = false;
    notifyListeners();
    print(response.body);
    var decodedResponse = json.decode(response.body);
    return decodedResponse["message"];
  }

  Future<void> getFirstAvailableSchedule(
      String userToken, String userId) async {
    var response = await http.get(
        Uri.parse(
            "$localURL/api/ShiftSchedule/GetFutureScheduledShiftsbyUserId/$userId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    print(response.body);
    var decodedResponse = json.decode(response.body);
    var scheduleJson = decodedResponse['data'];

    if (scheduleJson != null) {
      firstAvailableSchedule =
          ShiftSheduleModel.futuredSchedule(decodedResponse['data']);
      log("تمت بحمد الله");
      if (firstAvailableSchedule != null) {
        notifyListeners();
      }
    } else {
      print("no schedules");
      print(firstAvailableSchedule == null);
    }
  }

  Future<bool> isShiftScheduleByIdEmpty(
      String usertoken, String userId, BuildContext context) async {
    print("user id $userId");
    var response = await http.get(
        Uri.parse("$baseURL/api/ShiftSchedule/GetScheduleByUserId/$userId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $usertoken"
        });
    print(response.statusCode);
    print("asdms");
    print(response.body);
    var decodedResponse = json.decode(response.body);

    var scheduleJson = decodedResponse['data'] as List;
    shiftScheduleList = scheduleJson
        .map((shiftJson) => ShiftSheduleModel.fromJson(shiftJson))
        .toList();
    if (shiftScheduleList.isNotEmpty) {
      print("not empty");

      notifyListeners();
      return false;
    } else {
      scheduleFromTime = null;
      scheduleTotime = null;
    }
    notifyListeners();
    return true;
  }

  Future<String> editShiftSchedule(
      List<Day> shiftIds,
      String usertoken,
      String userId,
      int usershiftId,
      DateTime from,
      DateTime to,
      userSiteid,
      int scheduleId) async {
    isLoading = true;
    notifyListeners();
    var response = await http.put(
        Uri.parse(
          "$baseURL/api/ShiftSchedule/Edit/$scheduleId",
        ),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $usertoken"
        },
        body: json.encode({
          "id": scheduleId,
          "fromDate": from.toIso8601String(),
          "toDate": to.toIso8601String(),
          "saturdayShift": shiftIds[0].shiftID,
          "sunShift": shiftIds[1].shiftID,
          "mondayShift": shiftIds[2].shiftID,
          "tuesdayShift": shiftIds[3].shiftID,
          "wednesdayShift": shiftIds[4].shiftID,
          "thursdayShift": shiftIds[5].shiftID,
          "fridayShift": shiftIds[6].shiftID,
          "SatSiteId": shiftIds[0].siteID,
          "SunSiteId": shiftIds[1].siteID,
          "MonSiteId": shiftIds[2].siteID,
          "TueSiteId": shiftIds[3].siteID,
          "WedSiteId": shiftIds[4].siteID,
          "ThursSiteId": shiftIds[5].siteID,
          "FridaySiteId": shiftIds[6].siteID,
          "OriginalSiteId": userSiteid,
          "userId": userId,
          "originalShift": usershiftId
        }));
    isLoading = false;
    print(response.body);
    notifyListeners();
    var decodedResponse = json.decode(response.body);
    if (decodedResponse["statusCode"] == 200) {
      if (decodedResponse["message"] == "Success") {
        return "Success";
      } else if (decodedResponse["message"] ==
          "Fail: Schedle Shift not exist") {
        return "not exist";
      } else {
        return "fail";
      }
    }
    notifyListeners();
    return "error";
  }

  Future<String> addShiftSchedule(
    List<Day> shiftIds,
    String usertoken,
    String userId,
    int usershiftId,
    DateTime from,
    DateTime to,
    userSiteid,
  ) async {
    print("adding shift sched for id $usershiftId");
    isLoading = true;
    notifyListeners();
    var response = await http.post(
        Uri.parse(
          "$baseURL/api/ShiftSchedule/Add",
        ),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $usertoken"
        },
        body: json.encode({
          "fromDate": from.toIso8601String(),
          "toDate": to.toIso8601String(),
          "saturdayShift": shiftIds[0].shiftID,
          "sunShift": shiftIds[1].shiftID,
          "mondayShift": shiftIds[2].shiftID,
          "tuesdayShift": shiftIds[3].shiftID,
          "wednesdayShift": shiftIds[4].shiftID,
          "thursdayShift": shiftIds[5].shiftID,
          "fridayShift": shiftIds[6].shiftID,
          "SatSiteId": shiftIds[0].siteID,
          "SunSiteId": shiftIds[1].siteID,
          "MonSiteId": shiftIds[2].siteID,
          "TueSiteId": shiftIds[3].siteID,
          "WedSiteId": shiftIds[4].siteID,
          "ThursSiteId": shiftIds[5].siteID,
          "FridaySiteId": shiftIds[6].siteID,
          "OriginalSiteId": userSiteid,
          "userId": userId,
          "originalShift": usershiftId
        }));
    isLoading = false;
    print(response.body);
    notifyListeners();
    var decodedResponse = json.decode(response.body);
    if (decodedResponse["statusCode"] == 200) {
      if (decodedResponse["message"] == "Success") {
        return "Success";
      } else if (decodedResponse["message"] ==
          "Fail: Schedle Shift exist for this user!") {
        return "exists";
      }
    }
    notifyListeners();
    return "error";
  }

  deleteFromAllShiftsList(int shiftId) {
    for (int i = 0; i < shiftsList.length; i++) {
      if (shiftsList[i].shiftId == shiftId) {
        shiftsList.removeAt(i);
        break;
      }
    }
  }

  deleteShift(int shiftId, String userToken, int listIndex,
      BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http
            .delete(Uri.parse("$baseURL/api/Shifts/$shiftId"), headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
        print(response.body);
        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await deleteShift(shiftId, userToken, listIndex, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            if (shiftsBySite.length > 1) {
              shiftsBySite.removeAt(listIndex);
            } else {
              shiftsBySite = [
                Shift(
                    shiftName: "لا يوجد مناوبات بهذا الموقع",
                    shiftStartTime: -1,
                    shiftEndTime: 0,
                    shiftId: 0,
                    siteID: 0)
              ];
            }
            deleteFromAllShiftsList(shiftId);
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Fail : You must delete all users in shift then delete shift") {
            return "hasData";
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

  Future getShifts(int companyId, String userToken, BuildContext context,
      int userType, int siteId) async {
    if (userType == 2) {
      futureListener = getShiftsBySiteId(siteId, userToken, context);
    } else {
      futureListener = getAllCompanyShiftsApi(companyId, userToken, context);
    }
    return futureListener;
  }

  getShiftsBySiteId(int siteId, String userToken, BuildContext context) async {
    List<Shift> shiftsNewList;
    if (await isConnectedToInternet()) {
      final response = await http.get(
          Uri.parse("$baseURL/api/Shifts/GetAllShiftInSite?siteId=$siteId"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 401) {
        await inherit.login(context);
        userToken =
            Provider.of<UserData>(context, listen: false).user.userToken;
        await getShiftsBySiteId(
          siteId,
          userToken,
          context,
        );
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedRes = json.decode(response.body);
        print(response.body);

        if (decodedRes["message"] == "Success") {
          var shiftObjJson = jsonDecode(response.body)['data'] as List;
          shiftsNewList = shiftObjJson
              .map((shiftJson) => Shift.fromJson(shiftJson))
              .toList();

          shiftsList = shiftsNewList;
          notifyListeners();
          print("got shifts for site admin");
          return "Success";
        } else if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return "wrong";
        }
      }

      return "failed";
    } else {
      return 'noInternet';
    }
  }

  getAllCompanyShiftsApi(
      int companyId, String userToken, BuildContext context) async {
    List<Shift> shiftsNewList;
    if (await isConnectedToInternet()) {
      final response = await http.get(
          Uri.parse(
              "$baseURL/api/Shifts/GetAllShiftInCompany?companyId=$companyId"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 401) {
        await inherit.login(context);
        userToken =
            Provider.of<UserData>(context, listen: false).user.userToken;
        await getAllCompanyShiftsApi(
          companyId,
          userToken,
          context,
        );
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedRes = json.decode(response.body);
        print(response.body);

        if (decodedRes["message"] == "Success") {
          var shiftObjJson = jsonDecode(response.body)['data'] as List;
          shiftsNewList = shiftObjJson
              .map((shiftJson) => Shift.fromJson(shiftJson))
              .toList();

          shiftsList = shiftsNewList;
          notifyListeners();

          return "Success";
        } else if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return "wrong";
        }
      }

      return "failed";
    } else {
      return 'noInternet';
    }
  }

  addShift(Shift shift, String userToken, BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http.post(Uri.parse("$baseURL/api/Shifts"),
            body: json.encode(
              {
                "shiftEntime": shift.shiftEndTime.toString(),
                "shiftName": shift.shiftName,
                "shiftSttime": shift.shiftStartTime.toString(),
                "siteId": shift.siteID,
                "FridayShiftSttime": shift.fridayShiftstTime.toString(),
                "FridayShiftEntime": shift.fridayShiftenTime.toString(),
                "MonShiftSttime": shift.monShiftstTime.toString(),
                "MondayShiftEntime": shift.mondayShiftenTime.toString(),
                "SunShiftSttime": shift.sunShiftstTime.toString(),
                "SunShiftEntime": shift.sunShiftenTime.toString(),
                "ThursdayShiftSttime": shift.thursdayShiftstTime.toString(),
                "ThursdayShiftEntime": shift.thursdayShiftenTime.toString(),
                "TuesdayShiftSttime": shift.tuesdayShiftstTime.toString(),
                "TuesdayShiftEntime": shift.tuesdayShiftenTime.toString(),
                "WednesdayShiftSttime": shift.wednesDayShiftstTime.toString(),
                "WednesdayShiftEntime": shift.wednesDayShiftenTime.toString(),
              },
            ),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await addShift(
            shift,
            userToken,
            context,
          );
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            Shift newShift = Shift(
                fridayShiftenTime:
                    int.parse(decodedRes['data']["fridayShiftEntime"]),
                fridayShiftstTime:
                    int.parse(decodedRes['data']["fridayShiftSttime"]),
                monShiftstTime: int.parse(decodedRes['data']["monShiftSttime"]),
                mondayShiftenTime:
                    int.parse(decodedRes['data']["mondayShiftEntime"]),
                sunShiftenTime: int.parse(decodedRes['data']["sunShiftEntime"]),
                sunShiftstTime: int.parse(decodedRes['data']["sunShiftSttime"]),
                thursdayShiftenTime:
                    int.parse(decodedRes['data']["thursdayShiftEntime"]),
                thursdayShiftstTime:
                    int.parse(decodedRes['data']["thursdayShiftSttime"]),
                tuesdayShiftenTime:
                    int.parse(decodedRes['data']["tuesdayShiftEntime"]),
                tuesdayShiftstTime:
                    int.parse(decodedRes['data']["tuesdayShiftSttime"]),
                wednesDayShiftenTime:
                    int.parse(decodedRes['data']["wednesdayShiftEntime"]),
                wednesDayShiftstTime:
                    int.parse(decodedRes['data']["wednesdayShiftSttime"]),
                shiftId: decodedRes['data']['id'],
                shiftName: decodedRes['data']['shiftName'],
                shiftStartTime: int.parse(decodedRes['data']['shiftSttime']),
                shiftEndTime: int.parse(decodedRes['data']['shiftEntime']),
                siteID: decodedRes['data']['siteId'] as int);

            shiftsList.add(newShift);
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Fail : The same shift name already exists in site") {
            return "exists";
          } else if (decodedRes["message"] == "Fail : Time constants error") {
            print("s");
            return decodedRes["data"];
          } else {
            return "failed";
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

  findShiftIndexInShiftsList(int id) {
    for (int i = 0; i < shiftsList.length; i++) {
      if (shiftsList[i].shiftId == id) {
        return i;
      }
    }
  }

  editShift(Shift shift, int id, String usertoken, BuildContext context) async {
    print("Shift ID : ${shift.shiftId}");
    print("Site ID : ${shift.siteID}");
    print("index : $id");
    print(shift.fridayShiftenTime);
    if (await isConnectedToInternet()) {
      print("shift start = ${shift.sunShiftstTime.toString()}");
      final response = await http.put(
          Uri.parse("$baseURL/api/Shifts/${shift.shiftId}"),
          body: json.encode(
            {
              "id": shift.shiftId,
              "shiftEntime": shift.shiftEndTime.toString(),
              "shiftName": shift.shiftName,
              "shiftSttime": shift.shiftStartTime.toString(),
              "siteId": shift.siteID,
              "FridayShiftSttime": shift.fridayShiftstTime.toString(),
              "FridayShiftEntime": shift.fridayShiftenTime.toString(),
              "MonShiftSttime": shift.monShiftstTime.toString(),
              "MondayShiftEntime": shift.mondayShiftenTime.toString(),
              "SunShiftSttime": shift.sunShiftstTime.toString(),
              "SunShiftEntime": shift.sunShiftenTime.toString(),
              "ThursdayShiftSttime": shift.thursdayShiftstTime.toString(),
              "ThursdayShiftEntime": shift.thursdayShiftenTime.toString(),
              "TuesdayShiftSttime": shift.tuesdayShiftstTime.toString(),
              "TuesdayShiftEntime": shift.tuesdayShiftenTime.toString(),
              "WednesdayShiftSttime": shift.wednesDayShiftstTime.toString(),
              "WednesdayShiftEntime": shift.wednesDayShiftenTime.toString(),
            },
          ),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $usertoken"
          });
      print(response.body);
      if (response.statusCode == 401) {
        await inherit.login(context);
        usertoken =
            Provider.of<UserData>(context, listen: false).user.userToken;
        await editShift(
          shift,
          id,
          usertoken,
          context,
        );
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedRes = json.decode(response.body);
        print(response.body);

        if (decodedRes["message"] == "Success") {
          Shift newShift = Shift(
              fridayShiftenTime:
                  int.parse(decodedRes['data']["fridayShiftEntime"]),
              fridayShiftstTime:
                  int.parse(decodedRes['data']["fridayShiftSttime"]),
              monShiftstTime: int.parse(decodedRes['data']["monShiftSttime"]),
              mondayShiftenTime:
                  int.parse(decodedRes['data']["mondayShiftEntime"]),
              sunShiftenTime: int.parse(decodedRes['data']["sunShiftEntime"]),
              sunShiftstTime: int.parse(decodedRes['data']["sunShiftSttime"]),
              thursdayShiftenTime:
                  int.parse(decodedRes['data']["thursdayShiftEntime"]),
              thursdayShiftstTime:
                  int.parse(decodedRes['data']["thursdayShiftSttime"]),
              tuesdayShiftenTime:
                  int.parse(decodedRes['data']["tuesdayShiftEntime"]),
              tuesdayShiftstTime:
                  int.parse(decodedRes['data']["tuesdayShiftSttime"]),
              wednesDayShiftenTime:
                  int.parse(decodedRes['data']["wednesdayShiftEntime"]),
              wednesDayShiftstTime:
                  int.parse(decodedRes['data']["wednesdayShiftSttime"]),
              shiftId: decodedRes['data']['id'],
              shiftName: decodedRes['data']['shiftName'],
              shiftStartTime: int.parse(decodedRes['data']['shiftSttime']),
              shiftEndTime: int.parse(decodedRes['data']['shiftEntime']),
              siteID: decodedRes['data']['siteId'] as int);
          var shiftsListIndex = findShiftIndexInShiftsList(shift.shiftId);

          shiftsList[shiftsListIndex] = newShift;
          shiftsBySite[id] = newShift;
          notifyListeners();

          return "Success";
        } else if (decodedRes["message"] ==
            "Fail : Shift Name already exists") {
          return "exists";
        } else if (decodedRes["message"] == "Fail : Time constants error") {
          print("s");
          return decodedRes["data"];
        } else {
          return "failed";
        }
      }

      return "failed";
    } else {
      return 'noInternet';
    }
  }
}
// Future<void> getCompanySites(int companyID, String userToken) async {
//   print("GETTING COMPANY SITES NEWWW");
//   String url = "https://attendanceback.tamauze.com/api/Company/$companyID";
//   try {
//     companySitesProv = [];
//     final response = await http.get(
//       url,
//       headers: {
//         "Accept": "application/json",
//         'Authorization': "Bearer $userToken"
//       },
//     );
//     var decodedRes = json.decode(response.body);
//     if (jsonDecode(response.body)["message"] == "Success") {
//       var jsonObj = await jsonDecode(response.body)["data"] as List;
//       companySitesProv = jsonObj
//           .map((categoires) => CompanySites.fromJson(categoires))
//           .toList();

//       for (int i = 0; i < companySitesProv.length; i++) {
//         for (int k = 0; k < companySitesProv[i].shiftsList.length; k++) {
//           print(companySitesProv[i].shiftsList.length);
//           sitess.addAll(
//               {companySitesProv[i].siteID: companySitesProv[k].shiftsList});
//         }
//       }
//       print(sitess.length);
//       print(sitess.keys);
//       print(sitess.values);
//       print(sitess[4].length);

//       // print(companySitesProv[0].shiftsList.length);
//       // print(companySitesProv[0].shiftsList[1].shiftName);

//       // print(companySitesProv.length);
//       // print(companySitesProv[0].siteName);
//       // print("shhift id ${companySitesProv[0].shiftsList[0].shifID}");

//       notifyListeners();
//     }
//   } catch (e) {
//     print(e);
//   }
// }
