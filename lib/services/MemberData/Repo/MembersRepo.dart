import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:qr_users/NetworkApi/Network.dart';
import 'package:qr_users/enums/request_type.dart';

import '../../../Core/constants.dart';

class MemberRepo {
  Future<Object> getMemberData(
      String username, String password, String token, bool isHuawei) async {
    try {
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
    } catch (e) {
      print(e);
    }
  }
}
