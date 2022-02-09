import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/services/MemberData/Abstract/memberAbstract.dart';

import '../../../Core/constants.dart';

class MemberRepo implements AbstractMember {
  Future<Object> getMemberData(
      String username, String password, String token, bool isHuawei) async {
    return NetworkApi().request(
        "$baseURL/api/Authenticate/login",
        RequestType.POST,
        {'Content-type': 'application/json', 'x-api-key': apiKey},
        json.encode(
          {
            "Username": username,
            "Password": password,
            "FCMToken": token,
            "MobileOS": isHuawei
                ? 3
                : Platform.isIOS
                    ? 2
                    : 1
          },
        ));
  }

  Future<Object> getUserById(String userToken, String id) async {
    return NetworkApi().request(
      "$baseURL/api/Users/GetUser/$id",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  Future<Object> getAllMembersInCompany(String url, String userToken) async {
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
