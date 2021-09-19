import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants.dart';

class CompanySettingsService {
  int lateAllowance, attendClearance, leaveClearance, settingsID;
  CompanySettingsService(
      {this.attendClearance, this.lateAllowance, this.leaveClearance});
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
    }
  }

  Future<bool> updateCompanySettingsTime(
      int settingsId,
      int comID,
      int lateAllow,
      int attendClearance,
      int leaveClearance,
      String userToken) async {
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
              "workingDays": 1,
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
