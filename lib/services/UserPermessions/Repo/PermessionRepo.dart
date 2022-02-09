import 'dart:convert';

import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';

abstract class PermessionAbstract {
  addPermession(
      UserPermessions userPermessions, String userToken, String userId);
  getSingleUserPermession(String userToken, String userId);
}

class PermessionRepo implements PermessionAbstract {
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
}
