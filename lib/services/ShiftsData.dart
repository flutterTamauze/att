import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/FuturedScheduleShift.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/Shifts/Repo/ShiftsRepo.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

import 'AllSiteShiftsData/site_shifts_all.dart';
import 'Shift.dart';
import 'ShiftSchedule/ShiftScheduleModel.dart';
import 'Shifts/Repo/ShiftsRepoImplementer.dart';
import 'company.dart';

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
  List<String> sitesSchedules = [];
  List<String> shiftSchedules = [];

  FutureShiftSchedule satShift;
  findMatchingShifts(
    int siteId,
    bool addallshiftsBool,
  ) {
    try {
      debugPrint("findMatchingShifts : $siteId");
      shiftsBySite =
          shiftsList.where((element) => element.siteID == siteId).toList();
      debugPrint("shiftsBySite length : ${shiftsBySite.length}");
      debugPrint("shiftsLength : ${shiftsList.length}");

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
    debugPrint("shift by site length ${shiftsBySite.length}");
    return shiftsBySite.length;
  }

  setScheduleSiteAndShift(
      int scheduleIndex, int currentIndex, String sitename, String shiftname) {
    sitesSchedules[currentIndex] = sitename;
    shiftSchedules[currentIndex] = shiftname;
    notifyListeners();
  }

  setScheduleShiftFromAndto(int scheduleIndex, DateTime to, DateTime from) {
    shiftScheduleList[scheduleIndex].scheduleToTime = to;
    shiftScheduleList[scheduleIndex].scheduleFromTime = from;
    notifyListeners();
  }

  Future<String> deleteShiftScheduleById(
    int shiftId,
    String userToken,
  ) async {
    isLoading = true;
    notifyListeners();
    final response = await http.delete(
        Uri.parse("$baseURL/api/ShiftSchedule/Del_ScheduleShiftsbyId/$shiftId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });

    isLoading = false;
    notifyListeners();
    final decodedResponse = json.decode(response.body);
    return decodedResponse["message"];
  }

  Future<bool> getFirstAvailableSchedule(String userId) async {
    final response = await ShiftsRepoImp().getFirstAvailableSchedule(userId);
    final decodedResponse = json.decode(response);
    final scheduleJson = decodedResponse['data'];

    if (scheduleJson != null) {
      firstAvailableSchedule =
          ShiftSheduleModel.futuredSchedule(decodedResponse['data']);
      if (firstAvailableSchedule != null) {
        notifyListeners();
        return true;
      }
    } else {
      debugPrint("no schedules");
    }
    return false;
  }

  Future<bool> isShiftScheduleByIdEmpty(
      String usertoken, String userId, BuildContext context) async {
    debugPrint("user id $userId");
    final response = await http.get(
        Uri.parse("$baseURL/api/ShiftSchedule/GetScheduleByUserId/$userId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $usertoken"
        });
    debugPrint(response.statusCode.toString());
    debugPrint("asdms");
    final decodedResponse = json.decode(response.body);

    final scheduleJson = decodedResponse['data'] as List;
    shiftScheduleList = scheduleJson
        .map((shiftJson) => ShiftSheduleModel.fromJson(shiftJson))
        .toList();
    if (shiftScheduleList.isNotEmpty) {
      debugPrint("not empty");

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
    debugPrint(scheduleId.toString());

    final response = await http.put(
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
    notifyListeners();
    final decodedResponse = json.decode(response.body);
    if (decodedResponse["statusCode"] == 200) {
      if (decodedResponse["message"] == "Success") {
        return "Success";
      } else if (decodedResponse["message"] ==
          "Fail: FromDate less than today!") {
        return "less than today";
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
    debugPrint("adding shift sched for id $usershiftId");
    isLoading = true;
    notifyListeners();
    final response = await http.post(
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
    notifyListeners();
    final decodedResponse = json.decode(response.body);
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
    try {
      final response = await http
          .delete(Uri.parse("$baseURL/api/Shifts/$shiftId"), headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      });
      if (response.statusCode == 401) {
        await inherit.login(context);
        userToken =
            Provider.of<UserData>(context, listen: false).user.userToken;
        await deleteShift(shiftId, userToken, listIndex, context);
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedRes = json.decode(response.body);

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
          await sendFcmDataOnly(
              category: "reloadData",
              topicName:
                  "attend${Provider.of<CompanyData>(context, listen: false).com.id}");

          await Provider.of<SiteShiftsData>(context, listen: false)
              .getAllSitesAndShifts(
                  Provider.of<CompanyData>(context, listen: false).com.id,
                  Provider.of<UserData>(context, listen: false).user.userToken);
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
  }

  Future getShifts(int companyId, String userToken, BuildContext context,
      int userType, int siteId) async {
    if (userType == 2) {
      futureListener = getShiftsBySiteId(siteId, userToken, context);
    }
    // else {
    //   futureListener = getAllCompanyShiftsApi(companyId, userToken, context);
    // }
    return futureListener;
  }

  Future<String> getShiftsBySiteId(
      int siteId, String userToken, BuildContext context) async {
    debugPrint(siteId.toString());
    List<Shift> shiftsNewList = [];

    final response = await http.get(
        Uri.parse("$baseURL/api/Shifts/GetAllShiftInSite?siteId=$siteId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    debugPrint("GetAllShiftInSite");
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 401) {
      await inherit.login(context);
      userToken = Provider.of<UserData>(context, listen: false).user.userToken;
      await getShiftsBySiteId(
        siteId,
        userToken,
        context,
      );
    } else if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedRes = json.decode(response.body);

      if (decodedRes["message"] == "Success") {
        final shiftObjJson = jsonDecode(response.body)['data'] as List;
        shiftsNewList =
            shiftObjJson.map((shiftJson) => Shift.fromJson(shiftJson)).toList();
        log(shiftsNewList.length.toString());
        shiftsList = shiftsNewList;
        notifyListeners();
        return "Success";
      } else if (decodedRes["message"] ==
          "Error : There are no shifts at cuurent time") {
        shiftsList = [];
        notifyListeners();
      } else if (decodedRes["message"] ==
          "Failed : user name and password not match ") {
        return "wrong";
      }
    }

    return "failed";
  }

  // getAllCompanyShiftsApi(
  //     int companyId, String userToken, BuildContext context) async {
  //   List<Shift> shiftsNewList = [];
  //   if (await isConnectedToInternet()) {
  //     final response = await http.get(
  //         Uri.parse(
  //             "$baseURL/api/Shifts/GetAllShiftInCompany?companyId=$companyId&pageNumber=1&pageSize=100"),
  //         headers: {
  //           'Content-type': 'application/json',
  //           'Authorization': "Bearer $userToken"
  //         });
  //     debugPrint(response.statusCode);
  //     debugPrint(response.body);
  //     if (response.statusCode == 401) {
  //       await inherit.login(context);
  //       userToken =
  //           Provider.of<UserData>(context, listen: false).user.userToken;
  //       await getAllCompanyShiftsApi(
  //         companyId,
  //         userToken,
  //         context,
  //       );
  //     } else if (response.statusCode == 200 || response.statusCode == 201) {
  //       var decodedRes = json.decode(response.body);
  //       debugPrint(response.body);

  //       if (decodedRes["message"] == "Success") {
  //         var shiftObjJson = jsonDecode(response.body)['data'] as List;
  //         shiftsNewList = shiftObjJson
  //             .map((shiftJson) => Shift.fromJson(shiftJson))
  //             .toList();

  //         shiftsList = shiftsNewList;

  //         notifyListeners();

  //         return "Success";
  //       } else if (decodedRes["message"] ==
  //           "Failed : user name and password not match ") {
  //         return "wrong";
  //       }
  //     }

  //     return "failed";
  //   } else {
  //     return 'noInternet';
  //   }
  // }

  addShift(
      Shift shift, String userToken, BuildContext context, int index) async {
    try {
      print(("site id ${shift.siteID}"));
      print("shiftName ${shift.shiftName}");
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
      print(response.body);
      final decodedRes = json.decode(response.body);

      if (decodedRes["message"] == "Success") {
        final Shift newShift = Shift(
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
        Provider.of<SiteShiftsData>(context, listen: false)
            .siteShiftList[index]
            .shifts
            .add(Shifts(
                shiftName: newShift.shiftName, shiftId: newShift.shiftId));

        await sendFcmDataOnly(
            category: "reloadData",
            topicName:
                "attend${Provider.of<CompanyData>(context, listen: false).com.id}");
        String siteName = Provider.of<SiteShiftsData>(context, listen: false)
            .getSiteNameBySiteID(shift.siteID);
        await Provider.of<SiteShiftsData>(context, listen: false)
            .getShiftsList(siteName, false);
        await Provider.of<SiteShiftsData>(context, listen: false)
            .getAllSitesAndShifts(
                Provider.of<CompanyData>(context, listen: false).com.id,
                Provider.of<UserData>(context, listen: false).user.userToken);
        notifyListeners();
        return "Success";
      } else if (decodedRes["message"] ==
          "Fail : The same shift name already exists in site") {
        return "exists";
      } else if (decodedRes["message"] == "Fail : Time constants error") {
        debugPrint("s");
        return decodedRes["data"];
      } else {
        return "failed";
      }
    } catch (e) {
      print(e);
    }
    return "failed";
  }

  findShiftIndexInShiftsList(int id) {
    for (int i = 0; i < shiftsList.length; i++) {
      if (shiftsList[i].shiftId == id) {
        return i;
      }
    }
  }

  editShift(Shift shift, int id, String usertoken, BuildContext context,
      index) async {
    debugPrint("Shift ID : ${shift.shiftId}");
    debugPrint("Site ID : ${shift.siteID}");
    debugPrint(shift.fridayShiftenTime.toString());
    debugPrint("shift start = ${shift.sunShiftstTime.toString()}");
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
    if (response.statusCode == 401) {
      await inherit.login(context);
      usertoken = Provider.of<UserData>(context, listen: false).user.userToken;
      await editShift(shift, id, usertoken, context, index);
    } else if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedRes = json.decode(response.body);

      if (decodedRes["message"] == "Success") {
        final Shift newShift = Shift(
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
        // var shiftsListIndex = findShiftIndexInShiftsList(shift.shiftId);

        // shiftsList[shiftsListIndex] = newShift;

        // for (int i = 0;
        //     i <
        //         Provider.of<SiteShiftsData>(context, listen: false)
        //             .siteShiftList[index]
        //             .shifts
        //             .length;
        //     i++) {
        //   if (shift.shiftName ==
        //       Provider.of<SiteShiftsData>(context, listen: false)
        //           .siteShiftList[index]
        //           .shifts[i]
        //           .shiftName) {
        //     Provider.of<SiteShiftsData>(context, listen: false)
        //         .siteShiftList[index]
        //         .shifts[i]
        //         .shiftName = newShift.shiftName;
        //     Provider.of<SiteShiftsData>(context, listen: false)
        //         .siteShiftList[index]
        //         .shifts[i]
        //         .shiftId = newShift.shiftId;
        //   }

        // }
        await sendFcmDataOnly(
            category: "reloadData",
            topicName:
                "attend${Provider.of<CompanyData>(context, listen: false).com.id}");

        await Provider.of<SiteShiftsData>(context, listen: false)
            .getAllSitesAndShifts(
                Provider.of<CompanyData>(context, listen: false).com.id,
                Provider.of<UserData>(context, listen: false).user.userToken);

        notifyListeners();

        return "Success";
      } else if (decodedRes["message"] == "Fail : Shift Name already exists") {
        return "exists";
      } else if (decodedRes["message"] == "Fail : Time constants error") {
        debugPrint("s");
        return decodedRes["data"];
      } else {
        return "failed";
      }
    }

    return "failed";
  }
}
