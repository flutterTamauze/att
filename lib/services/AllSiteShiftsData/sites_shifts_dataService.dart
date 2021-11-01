import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/CameraPickerScreen.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/site_shifts_all.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:qr_users/services/Shift.dart';

class SiteShiftsData with ChangeNotifier {
  List<SiteShiftsModel> siteShiftList = [];
  List<Shifts> shifts = [];

  List<Shifts> getShiftsList(String siteName, bool addallshiftsBool) {
    shifts = [];

    for (int i = 0; i < siteShiftList.length; i++) {
      if (siteShiftList[i].siteName == siteName) {
        shifts = siteShiftList[i].shifts;

        if (shifts.length == 0) {
          shifts = [
            Shifts(
                shiftName: "لا يوجد مناوبات بهذا الموقع",
                shiftEntime: "-1",
                shiftId: 0,
                shiftStTime: "-1")
          ];
          notifyListeners();
          return siteShiftList[i].shifts;
        } else {
          if (addallshiftsBool == true) {
            if (shifts[0].shiftName != "كل المناوبات") {
              shifts.insert(
                  0,
                  Shifts(
                      shiftEntime: "-100",
                      shiftId: -100,
                      shiftName: "كل المناوبات",
                      shiftStTime: "-100"));
            }
          }
        }

        notifyListeners();
        return siteShiftList[i].shifts;
      }
    }
    return shifts;
  }

  getAllSitesAndShifts(int companyId, String userToken) async {
    var response = await http
        .get(Uri.parse(("$baseURL/api/Company/$companyId")), headers: {
      'Authorization': "Bearer $userToken",
      "Accept": "application/json"
    });
    log(response.body);
    print(response.statusCode);
    var decodedResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      if (decodedResponse["message"] == "Success") {
        var responseObj = jsonDecode(response.body)['data'] as List;

        siteShiftList =
            responseObj.map((json) => SiteShiftsModel.fromJson(json)).toList();
        log("got all the needed data successfully !! ${siteShiftList.length}");
        print(siteShiftList.length);

        notifyListeners();
      }
    }
  }
}
