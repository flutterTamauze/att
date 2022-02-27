import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/services/MemberData/Abstract/memberAbstract.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';

import '../../../Core/constants.dart';
import '../../../main.dart';
import '../../user_data.dart';

class MemberRepo implements AbstractMember {
  final userToken = locator.locator<UserData>().user.userToken;
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

  Future<Object> getUserById(String id) async {
    return NetworkApi().request(
      "$baseURL/api/Users/GetUser/$id",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  Future<Object> resetMemberMac(String id) {
    return NetworkApi().request(
      "${Uri.parse("$baseURL/api/Users/ResetUserDevice?userId=$id")}",
      RequestType.PUT,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  Future<Object> deleteMember(String id) {
    return NetworkApi().request(
      "${Uri.parse("$baseURL/api/Users/$id")}",
      RequestType.DELETE,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
  }

  Future<Object> editMember(Member member, String roleName) async {
    return NetworkApi().request(
      "${Uri.parse("$baseURL/api/Users/Update/${member.id}")}",
      RequestType.PUT,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
      json.encode(
        {
          "Name": member.name,
          "PhoneNo": member.phoneNumber,
          "Salary": member.salary,
          "Email": member.email,
          "JobTitle": member.jobTitle,
          "UserType": member.userType,
          "ShiftId": member.shiftId,
          "roleName": roleName == "" ? "User" : roleName
        },
      ),
    );
  }

  Future<Object> addMember(Member member, String roleName) async {
    return NetworkApi().request(
      "${Uri.parse("$baseURL/api/Authenticate/register")}",
      RequestType.POST,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
      json.encode(
        {
          "Name": member.name,
          "PhoneNo": member.phoneNumber,
          "Salary": member.salary,
          "Email": member.email,
          "JobTitle": member.jobTitle,
          "UserType": member.userType,
          "ShiftId": member.shiftId,
          "roleName": roleName == "" ? "User" : roleName
        },
      ),
    );
  }

  Future<Object> getAllMembersInCompany(
    String url,
  ) async {
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
