import 'dart:convert';

import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/services/UserPermessions/Repo/user_permession_repo.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';

import '../../../main.dart';
import '../../user_data.dart';

class UserPermessionRepoImp implements PermessionAbstract {
  final userToken = locator.locator<UserData>().user.userToken;
  @override
  Future<Object> addPermession(
      UserPermessions userPermessions, String userToken, String userId) async {
    return NetworkApi().request(
        "$baseURL/api/Permissions/AddPerm",
        RequestType.POST,
        {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        json.encode({
          "type": userPermessions.permessionType,
          "date": (userPermessions.date.toIso8601String()),
          "time": userPermessions.duration,
          "userId": userId,
          "Desc": userPermessions.permessionDescription,
          "createdonDate": DateTime.now().toIso8601String(),
        }));
  }

  @override
  Future<Object> getSingleUserPermession(
      String userToken, String userId) async {
    final String startTime = DateTime(
      DateTime.now().year,
      1,
      1,
    ).toIso8601String();
    final String endingTime =
        DateTime(DateTime.now().year, 12, 30).toIso8601String();
    return NetworkApi().request(
      "$baseURL/api/Permissions/GetPermissionPeriod/$userId/$startTime/$endingTime?isMobile=true",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  @override
  getPendingCompanyPermessions(
      int companyId, String userToken, int pageIndex) async {
    List<UserPermessions> pendingList = [];
    if (locator.locator<UserPermessionsData>().keepRetriving) {
      final response = await NetworkApi().request(
        "$baseURL/api/Permissions/GetAllPermissionPending/$companyId?pageIndex=$pageIndex&pageSize=8",
        RequestType.GET,
        {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
      );
      final decodedResp = json.decode(response);
      if (decodedResp["message"] == "Success") {
        final permessionsObj = jsonDecode(response)['data'] as List;
        if (locator.locator<UserPermessionsData>().keepRetriving) {
          pendingList.addAll(permessionsObj
              .map((json) => UserPermessions.fromJsonWithCreatedOn(json))
              .toList());

          pendingList = pendingList.reversed.toList();
        }
      } else if (decodedResp["message"] ==
          "No Holidays exist for this company!") {
        locator.locator<UserPermessionsData>().keepRetriving = false;
      }
      return pendingList;
    }
    return pendingList;
  }

  @override
  Future<List<UserPermessions>> getFutureSinglePermession(
      String userId, String userToken) async {
    List<UserPermessions> userPermessions = [];
    if (locator.locator<UserPermessionsData>().keepRetriving) {
      final response = await NetworkApi().request(
        "$baseURL/api/Permissions/infuture/$userId",
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
        userPermessions =
            holidaysObj.map((json) => UserPermessions.fromJson(json)).toList();

        userPermessions = userPermessions.reversed.toList();
      }
    }
    return userPermessions;
  }

  @override
  getPendingPermessionDetailsByID(int permId, String token) {
    return NetworkApi().request(
      "$baseURL/api/Permissions/$permId",
      RequestType.GET,
      {'Content-type': 'application/json', 'Authorization': "Bearer $token"},
    );
  }

  @override
  getShiftByShiftId(int shiftId) {
    return NetworkApi().request(
      "$baseURL/api/Shifts/$shiftId",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }
}
