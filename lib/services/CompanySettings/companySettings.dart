import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';
import 'dart:convert';

import '../../Core/constants.dart';
import '../../main.dart';
import '../permissions_data.dart';

class CompanySettingsService {
  DateTime suspentionTime;
  int lateAllowance, attendClearance, leaveClearance, settingsID;
  // DateTime get getSuspentionTime {
  //   return suspentionTime;
  // }

  // DateTime setDate(DateTime date) {
  //   suspentionTime = date;
  // }

  CompanySettingsService({
    this.attendClearance,
    this.lateAllowance,
    this.leaveClearance,
  });
  getCompanySettingsTime(int comID, String userToken) async {
    final response = await http
        .get(Uri.parse("$baseURL/api/Settings?CompanyId=$comID"), headers: {
      'Content-type': 'application/json',
      'Authorization': "Bearer $userToken"
    });
    final decodedResponse = json.decode(response.body);
    if (decodedResponse["message"] == "Success") {
      this.attendClearance = decodedResponse["data"]["attendClearance"];
      this.lateAllowance = decodedResponse["data"]["lateAllowance"];
      this.leaveClearance = decodedResponse["data"]["leaveClearance"];

      this.settingsID = decodedResponse["data"]["id"];
    }
  }

  Future<bool> isCompanySuspended(int comID, String userToken) async {
    try {
      final response = await http.get(
        Uri.parse("$baseURL/api/Company/Status?companyId=$comID"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );

      if (response.statusCode == 500 || response.statusCode == 501) {
        locator.locator<PermissionHan>().setServerDown(true);
      } else if (response.statusCode == 200) {
        locator.locator<PermissionHan>().setServerDown(false);
        locator.locator<PermissionHan>().setInternetConnection(true);
        final decodedRes = json.decode(response.body);
        if (decodedRes["message"] == "Success") {
          this.suspentionTime =
              DateTime.tryParse(decodedRes["data"]["endofSubScription"]);
          return decodedRes["data"]["isSuspended"];
        }
      }
    } catch (e) {
      print(e);
      return false;
    }

    return true;
  }

  Future<bool> updateCompanySettingsTime(
    int settingsId,
    int comID,
    int lateAllow,
    int attendClearance,
    int leaveClearance,
    String userToken,
  ) async {
    final response =
        await http.put(Uri.parse("$baseURL/api/Settings/Edit/$comID"),
            headers: {
              'Authorization': "Bearer $userToken",
              'Content-type': 'application/json',
            },
            body: json.encode({
              "id": settingsID,
              "lateAllowance": lateAllow,
              "attendClearance": attendClearance,
              "leaveClearance": leaveClearance,
              "companyId": comID,
            }));
    final decodedResponse = json.decode(response.body);
    if (decodedResponse["message"] == "Success") {
      return true;
    }
    return false;
  }
}
