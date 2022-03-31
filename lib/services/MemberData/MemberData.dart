import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/Network/networkInfo.dart';
import 'package:qr_users/services/MemberData/Repo/MembersRepo.dart';

import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

import '../../main.dart';

class SearchMember {
  String id, username;
  SearchMember({this.id, this.username});
  factory SearchMember.fromJson(json) {
    return SearchMember(id: json["id"], username: json["name"]);
  }
}

class Member {
  String name;
  String fcmToken, siteName, shiftName;
  double salary;
  DateTime hiredDate;
  bool isAllowedToAttend = false;
  bool excludeFromReport = false;
  int userType;
  String jobTitle;
  String userImageURL;
  String normalizedName;
  int shiftId, osType, siteId;
  String email;
  String phoneNumber;
  String id;

  Member(
      {this.name,
      this.userImageURL,
      this.userType,
      this.fcmToken,
      this.salary,
      this.hiredDate,
      this.isAllowedToAttend,
      this.excludeFromReport,
      this.jobTitle,
      this.email,
      this.shiftName,
      this.osType,
      this.normalizedName,
      this.id,
      this.shiftId,
      this.siteId,
      this.phoneNumber,
      this.siteName});

  factory Member.fromJson(dynamic json) {
    return Member(
        name: json['userName1'],
        userImageURL: json['userImage'],
        // email: json['email'],
        id: json['id'],
        isAllowedToAttend: json["isAllowtoAttend"],
        excludeFromReport: json["excludeFromReport"],
        // shiftId: json['shiftId'],
        fcmToken: json["fcmToken"],

        // phoneNumber: json['phoneNumber'],
        // salary: json["salary"],
        // hiredDate: DateTime.tryParse(json["createdOn"]),
        // userType: json['userType'],
        osType: json["mobileOS"],
        // normalizedName: json["userName"],
        jobTitle: json['userJob']);
  }
  factory Member.fullDataMemberFromJson(dynamic json) {
    return Member(
        name: json['userName1'],
        userImageURL: json['userImage'],
        email: json['email'],
        id: json['id'],
        isAllowedToAttend: json["isAllowtoAttend"],
        excludeFromReport: json["excludeFromReport"],
        shiftId: json['shiftId'],
        fcmToken: json["fcmToken"],
        phoneNumber: json['phoneNumber'],
        salary: json["salary"],
        hiredDate: DateTime.tryParse(json["createdOn"]),
        userType: json['userType'],
        shiftName: json["shiftName"],
        osType: json["mobileOS"],
        siteName: json["sitetName"],
        siteId: json["siteId"],
        normalizedName: json["userName"],
        jobTitle: json['userJob']);
  }
}

class MemberData with ChangeNotifier {
  List<Member> membersList = [];
  List<Member> membersListScreenDropDownSearch = [];
  List<Member> dropDownMembersList = [];
  List<Member> copyMemberList = [];
  List<Member> memberNewList = [];
  List<Member> copyMembersListScreenDropDownSearch = [];
  List<SearchMember> userSearchMember = [];
  Member singleMember = Member();
  Future futureListener;
  int allPageIndex = 0;
  int byShiftPageIndex = 0;
  int bySitePageIndex = 0;
  bool keepRetriving = true;
  bool loadingSearch = false;
  bool loadingShifts = false;
  bool isLoading = false;
  setMmemberList(List<Member> newList) {
    membersList = newList;
    membersListScreenDropDownSearch = [...membersList];
    notifyListeners();
  }

  resetPagination() {
    allPageIndex = 0;
    byShiftPageIndex = 0;
    bySitePageIndex = 0;
    keepRetriving = true;
  }

  searchUsersList(String filter, String userToken, dynamic siteId,
      int companyId, BuildContext context) async {
    debugPrint("site id");
    debugPrint(siteId);
    if (siteId == -1) {
      siteId = "";
    }

    loadingSearch = true;
    final response = await http.get(
        Uri.parse(
            "$baseURL/api/Users/Search?companyId=$companyId&Username=$filter&siteid=$siteId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    userSearchMember = [];

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedRes = json.decode(response.body);
      if (decodedRes["message"] == "Success") {
        final memberObjJson = jsonDecode(response.body)['data'] as List;
        if (membersList.isEmpty) {
          Provider.of<ReportsData>(context, listen: false)
              .userAttendanceReport
              .userAttendListUnits
              .length = 0;
        }
        if (memberObjJson != null) {
          userSearchMember = memberObjJson
              .map((memberJson) => SearchMember.fromJson(memberJson))
              .toList();
          loadingSearch = false;
          notifyListeners();
        }
      }
    }
    // List<Member> tmpList = [];
    // for (int i = 0; i < membersList.length; i++) {
    //   if (membersList[i].name.toLowerCase().contains(filter.toLowerCase())) {
    //     tmpList.add(membersList[i]);
    //   }
    // }
    // membersListScreenDropDownSearch = tmpList;
    // notifyListeners();
  }

  resetUsers() {
    membersListScreenDropDownSearch = [...membersList];
    notifyListeners();
  }

  // Future<bool> isConnectedToInternet() async {
  //   final DataConnectionChecker dataConnectionChecker = DataConnectionChecker();
  //   final NetworkInfoImp networkInfoImp = NetworkInfoImp(dataConnectionChecker);
  //   final bool isConnected = await networkInfoImp.isConnected;
  //   if (isConnected) {
  //     return true;
  //   }
  //   return false;
  // }

  Future<String> getUserById(
    String id,
  ) async {
    try {
      final response = await MemberRepo().getUserById(id);
      isLoading = true;
      notifyListeners();
      if (response is Faliure) {
        isLoading = false;
        notifyListeners();
        if (response.code == NO_INTERNET) {
          return "noInternet";
        } else if (response.code == USER_INVALID_RESPONSE) {
          return "serverDown";
        }
      } else {
        final decodedRes = json.decode(response);

        if (decodedRes["message"] == "Success") {
          final memberObjJson = jsonDecode(response)['data'];
          singleMember = Member.fullDataMemberFromJson(memberObjJson);
          isLoading = false;
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
    return "wrong";
  }

  getAllCompanyMember(int siteId, int companyId, String userToken,
      BuildContext context, int shiftId) {
    String url = "";
    isLoading = true;
    debugPrint("loading $isLoading");
    if (shiftId != -1) {
      byShiftPageIndex++;
      loadingShifts = true;
      if (byShiftPageIndex == 1) {
        membersList = [];
        memberNewList = [];
        membersListScreenDropDownSearch = [];
        copyMemberList = [];
        keepRetriving = true;
      }

      url =
          "$baseURL/api/Users/GetAllEmployeeInShift?shiftId=$shiftId&pageNumber=$byShiftPageIndex&pageSize=8";
      // notifyListeners();
    } else {
      if (siteId == -1) {
        loadingShifts = false;
        allPageIndex++;
        if (allPageIndex > 1) {
          notifyListeners();
        }
      } else {
        bySitePageIndex++;
        if (bySitePageIndex > 1) {
          notifyListeners();
        }
      }

      if (siteId == -1) {
        loadingShifts = false;
        if (allPageIndex == 1) {
          membersList = [];
          memberNewList = [];
          membersListScreenDropDownSearch = [];
          keepRetriving = true;
        }
        url =
            "$baseURL/api/Users/GetAllEmployeeInCompany?companyId=$companyId&pageNumber=$allPageIndex&pageSize=8";
      } else {
        debugPrint("by site");
        if (bySitePageIndex == 1) {
          membersList = [];
          memberNewList = [];
          membersListScreenDropDownSearch = [];
          copyMemberList = [];
          keepRetriving = true;
        }

        url =
            "$baseURL/api/Users/GetAllEmployeeInSite?siteId=$siteId&pageNumber=$bySitePageIndex&pageSize=8";
      }
    }

    futureListener =
        getAllCompanyMemberApi(url, userToken, siteId, context, shiftId);
    return futureListener;
  }

  getAllCompanyMemberApi(String url, String userToken, int siteId,
      BuildContext context, shiftId) async {
    debugPrint("get all members");

    try {
      debugPrint(("printing the page index $allPageIndex"));
      debugPrint(("printing the page index $bySitePageIndex"));
      debugPrint(("printing the page by shift index $byShiftPageIndex"));
      final response = await MemberRepo().getAllMembersInCompany(
        url,
      );
      if (response is Faliure) {
        if (response.code == NO_INTERNET) {
          return "noInternet";
        }
      } else {
        final decodedRes = json.decode(response);

        if (decodedRes["message"] == "Success") {
          final memberObjJson = decodedRes['data'] as List;
          if (memberObjJson.isEmpty) {
            keepRetriving = false;
            notifyListeners();
          }
          if (keepRetriving) {
            memberNewList.addAll(memberObjJson
                .map((memberJson) => Member.fromJson(memberJson))
                .toList());

            membersList = memberNewList;
            membersListScreenDropDownSearch = memberNewList;
          }

          log(membersList.length.toString());
          isLoading = false;
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
  }

  allowMemberAttendByCard(
      String userID, bool allowValue, String userToken) async {
    try {
      await http.put(Uri.parse("$baseURL/api/Users/isAttend"),
          body: json.encode({
            "usersId": [userID],
            "value": allowValue
          }),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
    } catch (e) {
      print(e);
    }
  }

  exludeUserFromReport(String userID, bool allowValue, String userToken) async {
    try {
      final response = await http.put(
          Uri.parse("$baseURL/api/Users/excludeFromReport"),
          body: json.encode({
            "usersId": [userID],
            "value": allowValue
          }),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
    } catch (e) {
      print(e);
    }
  }

  getAllSiteMembers(int siteId, String userToken, BuildContext context) {
    futureListener = getAllSiteMembersApi(siteId, userToken, context);
    return futureListener;
  }

  getAllSiteMembersApi(
      int siteId, String userToken, BuildContext context) async {
    debugPrint("get all members");
    List<Member> memberNewList;
    final response = await http.get(
        Uri.parse("$baseURL/api/Users/GetAllEmployeeInSite?siteId=$siteId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedRes = json.decode(response.body);
      if (decodedRes["message"] == "Success") {
        final memberObjJson = jsonDecode(response.body)['data'] as List;
        memberNewList = memberObjJson
            .map((memberJson) => Member.fromJson(memberJson))
            .toList();
        debugPrint("MEMBER DATA length");

        membersList = [...memberNewList];
        membersListScreenDropDownSearch = [...membersList];
        copyMemberList = membersList;
        dropDownMembersList = memberNewList;
        notifyListeners();

        return "Success";
      } else if (decodedRes["message"] ==
          "Failed : user name and password not match ") {
        return "wrong";
      }
    }

    return "failed";
  }

  resetMemberMac(String id, BuildContext context) async {
    try {
      debugPrint("reseeeeeeeetMac");
      final response = await MemberRepo().resetMemberMac(id);

      final decodedRes = json.decode(response);

      if (decodedRes["message"] == "Success : User Device Reset Success") {
        debugPrint("before deleting");
        if (Platform.isIOS) {
          const storage = FlutterSecureStorage();

          await storage
              .write(key: "deviceMac", value: "")
              .whenComplete(
                  () => debugPrint("keychain is reseted successfully!"))
              .catchError((e) {
            print(e);
          });
        }

        return "Success";
      } else if (decodedRes["message"] ==
          "Failed : user name and password not match ") {
        return "wrong";
      }
    } catch (e) {
      print(e);
    }
    return "failed";
  }

  deleteMember(String id, int listIndex, BuildContext context) async {
    try {
      final response = await MemberRepo().deleteMember(id);

      final decodedRes = json.decode(response);

      if (decodedRes["message"] == "Success : User Deleted Successfully") {
        membersListScreenDropDownSearch.removeAt(listIndex);

        notifyListeners();
        return "Success";
      } else if (decodedRes["message"] ==
          "Failed : user name and password not match ") {
        return "wrong";
      }
    } catch (e) {
      print(e);
    }
    return "failed";
  }

  addMember(Member member, BuildContext context, String roleName) async {
    try {
      final response = await MemberRepo().addMember(
        member,
        roleName,
      );

      final decodedRes = json.decode(response);

      if (decodedRes["message"] == "User created successfully!") {
        return "Success";
      } else if (decodedRes["message"] == "Fail : Phone No Already exists") {
        return "exists";
      } else if (decodedRes["message"] == "Fail : Users Limit Reached") {
        return "Limit Reached";
      }
    } catch (e) {
      print(e);
    }
    return "failed";
  }

  findMemberInMembersList(String id) {
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i].id == id) {
        return i;
      }
    }
  }

  editMember(
    Member member,
    int id,
    BuildContext context,
    String roleName,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseURL/api/Users/Update/${member.id}"),
        headers: {
          'Content-type': 'application/json',
          'Authorization':
              "Bearer ${locator.locator<UserData>().user.userToken}",
        },
        body: json.encode(
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

      final decodedRes = json.decode(response.body);

      if (decodedRes["message"] == "Success : User Updated Successfully ") {
        membersList[id] = member;

        final membersListId = findMemberInMembersList(member.id);

        membersList[membersListId] = member;
        membersListScreenDropDownSearch = [...membersList];

        notifyListeners();
        return "Success";
      } else if (decodedRes["message"] == "Fail : Phone no already exist!") {
        return "exists";
      } else if (decodedRes["message"] == "Failed : User Not Exist") {
        return "not exist";
      }
    } catch (e) {
      print(e);
    }
    return "failed";
  }
}
