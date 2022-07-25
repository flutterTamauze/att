import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      final response = await NetworkApi().request(
        "$baseURL/api/Company/Status?companyId=$comID",
        RequestType.GET,
        {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );
      if (response is Faliure) {
        if (response.code == UN_AUTHORIZED) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final List<String> userData =
              (prefs.getStringList('userData') ?? null);
          showDialog(
            context: navigatorKey.currentState.overlay.context,
            builder: (context) => RoundedLoadingIndicator(),
          );
          await locator.locator<UserData>().loginPost(userData[0], userData[1],
              navigatorKey.currentState.overlay.context, true);
          Navigator.pop(navigatorKey.currentState.overlay.context);
          Fluttertoast.showToast(
              msg: getTranslated(
                  navigatorKey.currentState.overlay.context, "مرحبا بعودتك"));
        }
        return false;
      }
      final decodedRes = json.decode(response);
      if (decodedRes["message"] == "Success") {
        this.suspentionTime =
            DateTime.tryParse(decodedRes["data"]["endofSubScription"]);
        return decodedRes["data"]["isSuspended"];
      }
    } catch (e) {
      print("erropr");
      log(e);
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
