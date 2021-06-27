import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:qr_users/constants.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

class Member {
  String name;
  int userType;
  String jobTitle;
  String userImageURL;
  String normalizedName;
  int shiftId;
  String email;
  String phoneNumber;
  String id;
  String countryLanguage;

  Member(
      {this.name,
      this.userImageURL,
      this.userType,
      this.jobTitle,
      this.email,
      this.normalizedName,
      this.id,
      this.shiftId,
      this.phoneNumber,
      this.countryLanguage});

  factory Member.fromJson(dynamic json) {
    return Member(
        name: json['userName1'],
        userImageURL: json['userImage'],
        email: json['email'],
        id: json['id'],
        shiftId: json['shiftId'],
        phoneNumber: json['phoneNumber'],
        userType: json['userType'],
        normalizedName: json["userName"],
        jobTitle: json['userJob']);
  }
}

class MemberData with ChangeNotifier {
  List<String> rolesList = [
    "مستخدم",
    "مسئول تسجيل",
    "مدير موقع",
    "موارد بشرية",
    "ادمن",
  ];
  InheritDefault inherit = InheritDefault();
  List<Member> membersList = [];
  List<Member> membersListScreenDropDownSearch = [];
  List<Member> dropDownMembersList = [];
  List<Member> copyMemberList = [];
  List<Member> copyMembersListScreenDropDownSearch = [];
  Future futureListener;
  setMmemberList(List<Member> newList) {
    membersList = newList;
    membersListScreenDropDownSearch = [...membersList];
    notifyListeners();
  }

  searchUsersList(String filter) {
    List<Member> tmpList = [];
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i].name.toLowerCase().contains(filter.toLowerCase())) {
        tmpList.add(membersList[i]);
      }
    }
    membersListScreenDropDownSearch = tmpList;
    notifyListeners();
  }

  resetUsers() {
    membersListScreenDropDownSearch = [...membersList];
    notifyListeners();
  }

  Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
    return false;
  }

  getAllCompanyMember(
      int siteId, int companyId, String userToken, BuildContext context) {
    String url = "";
    if (siteId == -1) {
      url = "$baseURL/api/Users/GetAllEmployeeInCompany?companyId=$companyId";
    } else {
      url = "$baseURL/api/Users/GetAllEmployeeInSite?siteId=$siteId";
    }
    futureListener = getAllCompanyMemberApi(url, userToken, siteId, context);
    return futureListener;
  }

  getAllCompanyMemberApi(
      String url, String userToken, int siteId, BuildContext context) async {
    print("get all members");
    List<Member> memberNewList;
    if (await isConnectedToInternet()) {
      try {
        final response = await http.get(url, headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });

        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await getAllCompanyMemberApi(url, userToken, siteId, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);
          if (decodedRes["message"] == "Success") {
            var memberObjJson = jsonDecode(response.body)['data'] as List;
            memberNewList = memberObjJson
                .map((memberJson) => Member.fromJson(memberJson))
                .toList();

            membersList = memberNewList;
            membersListScreenDropDownSearch = [...membersList];

            copyMemberList = membersList;
            notifyListeners();

            return "Success";
          } else if (decodedRes["message"] ==
              "Failed : user name and password not match ") {
            return "wrong";
          }
        }
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }

  getAllSiteMembers(int siteId, String userToken, BuildContext context) {
    futureListener = getAllSiteMembersApi(siteId, userToken, context);
    return futureListener;
  }

  getAllSiteMembersApi(
      int siteId, String userToken, BuildContext context) async {
    print("get all members");
    List<Member> memberNewList;
    if (await isConnectedToInternet()) {
      try {
        final response = await http.get(
            "$baseURL/api/Users/GetAllEmployeeInSite?siteId=$siteId",
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await getAllSiteMembersApi(siteId, userToken, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);
          if (decodedRes["message"] == "Success") {
            var memberObjJson = jsonDecode(response.body)['data'] as List;
            memberNewList = memberObjJson
                .map((memberJson) => Member.fromJson(memberJson))
                .toList();

            dropDownMembersList = memberNewList;
            notifyListeners();

            return "Success";
          } else if (decodedRes["message"] ==
              "Failed : user name and password not match ") {
            return "wrong";
          }
        }
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }

  findMemberInMembersList(String id) {
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i].id == id) {
        return i;
      }
    }
  }

  resetMemberMac(String id, String userToken, BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        print("reseeeeeeeetMac");
        final response = await http
            .put("$baseURL/api/Users/ResetUserDevice?userId=$id", headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });

        var decodedRes = json.decode(response.body);
        print(response.body);

        if (decodedRes["message"] == "Success : User Device Reset Success") {
          print("before deleting");
          //Only local//
          // Provider.of<UserData>(context, listen: false).changedWidget =
          //     Image.asset("resources/personicon.png");
          // notifyListeners();
          return "Success";
        } else if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return "wrong";
        }
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }

  deleteMember(
      String id, int listIndex, String userToken, BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http.delete("$baseURL/api/Users/$id", headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await deleteMember(id, listIndex, userToken, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success : User Deleted Successfully") {
            var membersListId = findMemberInMembersList(id);
            membersListScreenDropDownSearch.removeAt(listIndex);
            membersList.removeAt(membersListId);
            copyMemberList = membersList;
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Failed : user name and password not match ") {
            return "wrong";
          }
        }
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }

  addMember(Member member, String userToken, BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http.post("$baseURL/api/Authenticate/register",
            body: json.encode(
              {
                "Name": member.name,
                "PhoneNo": member.phoneNumber,
                "Email": member.email,
                "JobTitle": member.jobTitle,
                "UserType": member.userType,
                "ShiftId": member.shiftId,
              },
            ),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await addMember(member, userToken, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "User created successfully!") {
            var userId = decodedRes['data']['userId'];
            var newMember = member;
            newMember.id = userId;
            membersList.add(newMember);
            copyMemberList = membersList;
            print(newMember.shiftId);
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] == "Fail : Email Already exists") {
            return "exists";
          } else if (decodedRes["message"] == "Fail : Users Limit Reached") {
            return "Limit Reached";
          }
        }
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }

  editMember(
      Member member, int id, String userToken, BuildContext context) async {
    print(
        "Shift id ${member.shiftId} , userType id ${member.userType}  , memid : ${member.id}");

    if (await isConnectedToInternet()) {
      try {
        final response = await http.put(
            "$baseURL/api/Users/Update/${member.id}",
            body: json.encode(
              {
                "id": member.id,
                "Name": member.name,
                "PhoneNo": member.phoneNumber,
                "Email": member.email,
                "JobTitle": member.jobTitle,
                "UserType": member.userType,
                "ShiftId": member.shiftId,
              },
            ),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await editMember(member, id, userToken, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success : User Updated Successfully ") {
            membersList[id] = member;
            print(
                "Shift id ${membersList[id].shiftId} , userType id ${membersList[id].userType}  , memid : ${membersList[id].id}");

            var membersListId = findMemberInMembersList(member.id);

            membersList[membersListId] = member;
            membersListScreenDropDownSearch = [...membersList];
            copyMemberList[membersListId] = member;

            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] == "Failed : Email Already Exist") {
            return "exists";
          }
        }
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }
}
