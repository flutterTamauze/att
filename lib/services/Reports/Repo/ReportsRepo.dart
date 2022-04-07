import 'dart:convert';

import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/services/Reports/Services/Attend_Proof_Model.dart';

import '../../../main.dart';
import '../../user_data.dart';

class ReprotsRepo {
  final userToken = locator.locator<UserData>().user.userToken;
  Future<Object> getDailyReport(String url, String userToken) async {
    return NetworkApi().request(
      url,
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  Future<Object> getUserReport(String url, String userToken) async {
    return NetworkApi().request(
      url,
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  Future<Object> getTodayUserReport(String userId) async {
    return NetworkApi().request(
      "$baseURL/api/AttendLogin/todayAttend/$userId",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  Future<List<AttendProofModel>> getDailyAttendProofApi(
      siteId, String userToken, String date) async {
    List<AttendProofModel> attendProofList = [];
    final response = await NetworkApi().request(
      "$baseURL/api/attendproof/GetProofbySite?siteId=$siteId&Date=$date",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
    if (response is Faliure) {
      return [];
    } else {
      final decodedRes = json.decode(response);

      if (decodedRes["message"] == "Success") {
        final reportObjJson = jsonDecode(response)['data'] as List;

        attendProofList = reportObjJson
            .map((reportJson) => AttendProofModel.fromJson(reportJson))
            .toList();
      } else if (decodedRes["message"] == "No AttendProofs was found!") {
        attendProofList.clear();
      }
    }

    return attendProofList;
  }

  Future<Object> getLateAbsenceReport(String url, String userToken) async {
    return NetworkApi().request(
      url,
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }
}
