import 'package:http/http.dart' as http;
import 'package:qr_users/NetworkApi/ApiStatus.dart';
import 'package:qr_users/NetworkApi/Network.dart';
import 'package:qr_users/enums/request_type.dart';
import 'dart:convert';

import '../../constants.dart';

class CompanySettingsService {
  DateTime suspentionTime;
  int lateAllowance, attendClearance, leaveClearance, settingsID, workingDays;
  // DateTime get getSuspentionTime {
  //   return suspentionTime;
  // }

  // DateTime setDate(DateTime date) {
  //   suspentionTime = date;
  // }

  CompanySettingsService(
      {this.attendClearance,
      this.lateAllowance,
      this.leaveClearance,
      this.workingDays});
  getCompanySettingsTime(int comID, String userToken) async {
    var response = await http
        .get(Uri.parse("$baseURL/api/Settings?CompanyId=$comID"), headers: {
      'Content-type': 'application/json',
      'Authorization': "Bearer $userToken"
    });
    print(response.body);
    var decodedResponse = json.decode(response.body);
    if (decodedResponse["message"] == "Success") {
      this.attendClearance = decodedResponse["data"]["attendClearance"];
      this.lateAllowance = decodedResponse["data"]["lateAllowance"];
      this.leaveClearance = decodedResponse["data"]["leaveClearance"];

      this.settingsID = decodedResponse["data"]["id"];
      this.workingDays = decodedResponse["data"]["workingDays"];
    }
  }

  Future<bool> isCompanySuspended(int comID, String userToken) async {
    var response = await NetworkApi().request(
      "$baseURL/api/Company/Status?companyId=$comID",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
    print(response);
    if (response is Faliure) {
      return false;
    }
    var decodedRes = json.decode(response);
    if (decodedRes["message"] == "Success") {
      this.suspentionTime =
          DateTime.tryParse(decodedRes["data"]["endofSubScription"]);
      return decodedRes["data"]["isSuspended"];
    }
    return false;
  }

  Future<bool> updateCompanySettingsTime(
    int settingsId,
    int comID,
    int lateAllow,
    int attendClearance,
    int leaveClearance,
    String userToken,
    int workingDays,
  ) async {
    print(workingDays);
    print(lateAllow);
    print(attendClearance);
    print(leaveClearance);
    print(comID);
    var response =
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
              "workingDays": workingDays,
              "companyId": comID,
            }));
    print(response.statusCode);
    print(response.body);
    var decodedResponse = json.decode(response.body);
    if (decodedResponse["message"] == "Success") {
      return true;
    }
    return false;
  }
}
