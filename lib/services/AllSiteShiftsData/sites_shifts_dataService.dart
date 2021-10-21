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
  List<Shifts> getShiftsList(String siteName) {
    shifts = [];
    for (int i = 0; i < siteShiftList.length; i++) {
      if (siteShiftList[i].siteName == siteName) {
        shifts = siteShiftList[i].shifts;
        notifyListeners();
        return siteShiftList[i].shifts;
      }
    }
    return [
      Shifts(
          shiftName: "لا يوجد مناوبة",
          shiftEntime: "",
          shiftId: -1,
          shiftStTime: "")
    ];
  }

  getAllSitesAndShifts(int companyId, String userToken) async {
    var response = await http
        .get(Uri.parse(("$baseURL/api/Company/$companyId")), headers: {
      'Authorization': "Bearer $userToken",
      "Accept": "application/json"
    });
    log(response.body);
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
