import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/CameraPickerScreen.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/site_shifts_all.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Sites_data.dart';

class SiteShiftsData with ChangeNotifier {
  List<SiteShiftsModel> siteShiftList = [];
  List<Shifts> shifts = [];
  List<Site> sites = [];
  List<Shifts> dropDownShifts = [];

  List<Shifts> getShiftsList(String siteName, bool addallshiftsBool) {
    shifts = [];
    dropDownShifts = [];
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
          dropDownShifts = [...shifts];
          if (dropDownShifts[0].shiftName == "كل المناوبات") {
            dropDownShifts.removeAt(0);
          }
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
        dropDownShifts = [...shifts];
        if (dropDownShifts[0].shiftName == "كل المناوبات") {
          dropDownShifts.removeAt(0);
        }

        // notifyListeners();
        return siteShiftList[i].shifts;
      }
    }

    return shifts;
  }

  getAllSitesAndShifts(int companyId, String userToken) async {
    siteShiftList.clear();
    sites.clear();
    var response = await http
        .get(Uri.parse(("$baseURL/api/Company/$companyId")), headers: {
      'Authorization': "Bearer $userToken",
      "Accept": "application/json"
    });
    log(response.body);
    print("get all siteshift response code ${response.statusCode}");
    var decodedResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      if (decodedResponse["message"] == "Success") {
        var responseObj = jsonDecode(response.body)['data'] as List;

        siteShiftList = [
          ...responseObj.map((json) => SiteShiftsModel.fromJson(json)).toList()
        ];
        log("got all the needed data successfully !! ${siteShiftList.length}");
        print(siteShiftList.length);
        if (sites.isEmpty) {
          for (int i = 0; i < siteShiftList.length; i++) {
            sites.add(Site(
                id: siteShiftList[i].siteId, name: siteShiftList[i].siteName));
          }
          sites.insert(
            0,
            Site(id: -1, name: "كل المواقع", lat: 0, long: 0),
          );
        }

        print(sites.length);
        notifyListeners();
      }
    }
  }
}
