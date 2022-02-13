import 'dart:convert';

import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/UserHolidays/Repo/user_holidays_repo.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';

class UserHolidaysRepoImplementer implements UserHolidaysRepo {
  Future<List<UserHolidays>> getPendingCompanyHolidays(
      int companyId, String userToken, int pageIndex) async {
    List<UserHolidays> pendingList = [];
    if (locator.locator<UserHolidaysData>().keepRetriving) {
      final response = await NetworkApi().request(
        "$baseURL/api/Holiday/GetAllHolidaysPending/$companyId?pageindex=$pageIndex&pageSize=8",
        RequestType.GET,
        {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );
      final decodedResp = json.decode(response);
      if (decodedResp["message"] == "Success") {
        final permessionsObj = jsonDecode(response)['data'] as List;
        if (locator.locator<UserHolidaysData>().keepRetriving) {
          pendingList.addAll(permessionsObj
              .map((json) => UserHolidays.fromJson(json))
              .toList());

          pendingList = pendingList.reversed.toList();
        }
      } else if (decodedResp["message"] ==
          "No Holidays exist for this company!") {
        locator.locator<UserHolidaysData>().keepRetriving = false;
      }
      return pendingList;
    }
    return pendingList;
  }

  @override
  getFutureSingleUserHoliday(String userId, String userToken) async {
    List<UserHolidays> pendingList = [];
    if (locator.locator<UserHolidaysData>().keepRetriving) {
      final response = await NetworkApi().request(
        "$baseURL/api/Holiday/infuture/$userId",
        RequestType.GET,
        {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );
      if (response is Faliure) {
        return [];
      }
      final decodedResponse = json.decode(response);
      if (decodedResponse["message"] == "Success") {
        final holidaysObj = jsonDecode(response)['data'] as List;
        pendingList =
            holidaysObj.map((json) => UserHolidays.fromJson(json)).toList();

        pendingList = pendingList.reversed.toList();
      }
      return pendingList;
    }
  }

  @override
  Future<Object> getSingleUserHoliday(String userToken, String userId) async {
    final String startTime = DateTime(
      DateTime.now().year,
      1,
      1,
    ).toIso8601String();
    final String endingTime =
        DateTime(DateTime.now().year, 12, 30).toIso8601String();
    return NetworkApi().request(
      "$baseURL/api/Holiday/GetHolidaybyPeriod/$userId/$startTime/$endingTime?isMobile=true",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }
}
