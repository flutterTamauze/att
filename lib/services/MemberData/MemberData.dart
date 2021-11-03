import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/CameraPickerScreen.dart';

import 'package:qr_users/constants.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

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

  searchUsersList(String filter, String userToken, siteId, int companyId,
      BuildContext context) async {
    if (siteId == -1) {
      siteId = "";
    }
    print(siteId);
    loadingSearch = true;
    var response = await http.get(
        Uri.parse(
            "$baseURL/api/Users/Search?companyId=$companyId&Username=$filter&siteid=$siteId"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    userSearchMember = [];

    if (response.statusCode == 200 || response.statusCode == 201) {
      var decodedRes = json.decode(response.body);
      print(response.body);
      if (decodedRes["message"] == "Success") {
        var memberObjJson = jsonDecode(response.body)['data'] as List;
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

  getUserById(String id, String userToken) async {
    try {
      var response = await http.get(
          Uri.parse(
            "$baseURL/api/Users/GetUser/$id",
          ),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });

      if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedRes = json.decode(response.body);

        if (decodedRes["message"] == "Success") {
          var memberObjJson = jsonDecode(response.body)['data'];
          singleMember = Member.fullDataMemberFromJson(memberObjJson);
          print("success");

          log(response.body);

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
  }

  getAllCompanyMember(int siteId, int companyId, String userToken,
      BuildContext context, int shiftId) {
    String url = "";
    isLoading = true;
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
          "$baseURL/api/Users/GetAllEmployeeInShift?shiftId=$shiftId&pageNumber=$byShiftPageIndex&pageSize=7";
      notifyListeners();
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
            "$baseURL/api/Users/GetAllEmployeeInCompany?companyId=$companyId&pageNumber=$allPageIndex&pageSize=7";
      } else {
        print("by site");
        if (bySitePageIndex == 1) {
          membersList = [];
          memberNewList = [];
          membersListScreenDropDownSearch = [];
          copyMemberList = [];
          keepRetriving = true;
        }

        url =
            "$baseURL/api/Users/GetAllEmployeeInSite?siteId=$siteId&pageNumber=$bySitePageIndex&pageSize=7";
      }
    }

    futureListener =
        getAllCompanyMemberApi(url, userToken, siteId, context, shiftId);
    return futureListener;
  }

  getAllCompanyMemberApi(String url, String userToken, int siteId,
      BuildContext context, shiftId) async {
    print("get all members");

    print(url);
    if (await isConnectedToInternet()) {
      try {
        print(("printing the page index $allPageIndex"));
        print(("printing the page index $bySitePageIndex"));
        print(("printing the page by shift index $byShiftPageIndex"));
        final response = await http.get(Uri.parse(url), headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            var memberObjJson = jsonDecode(response.body)['data'] as List;
            if (memberObjJson.isEmpty) {
              keepRetriving = false;
              notifyListeners();
            }
            if (keepRetriving) {
              memberNewList.addAll(memberObjJson
                  .map((memberJson) => Member.fromJson(memberJson))
                  .toSet()
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
    } else {
      return 'noInternet';
    }
  }

  allowMemberAttendByCard(
      String userID, bool allowValue, String userToken) async {
    try {
      var response = await http.put(Uri.parse("$baseURL/api/Users/isAttend"),
          body: json.encode({
            "usersId": [userID],
            "value": [allowValue]
          }),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      print(response.body);
    } catch (e) {
      print(e);
    }
  }

  exludeUserFromReport(String userID, bool allowValue, String userToken) async {
    try {
      var response = await http.put(
          Uri.parse("$baseURL/api/Users/excludeFromReport"),
          body: json.encode({
            "usersId": [userID],
            "value": [allowValue]
          }),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      print(response.body);
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
    print("get all members");
    print(siteId);
    List<Member> memberNewList;
    if (await isConnectedToInternet()) {
      final response = await http.get(
          Uri.parse("$baseURL/api/Users/GetAllEmployeeInSite?siteId=$siteId"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      print(response.statusCode);
      print(response.body);
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
          print("MEMBER DATA length");
          print(memberNewList.length);

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
        final response = await http.put(
            Uri.parse("$baseURL/api/Users/ResetUserDevice?userId=$id"),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

        var decodedRes = json.decode(response.body);
        print(response.body);

        if (decodedRes["message"] == "Success : User Device Reset Success") {
          print("before deleting");
          if (Platform.isIOS) {
            final storage = new FlutterSecureStorage();

            await storage
                .write(key: "deviceMac", value: "")
                .whenComplete(() => print("keychain is reseted successfully!"))
                .catchError((e) {
              print(e);
            });
          }
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
        final response = await http.delete(Uri.parse("$baseURL/api/Users/$id"),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });
        print(response.body);
        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await deleteMember(id, listIndex, userToken, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success : User Deleted Successfully") {
            membersListScreenDropDownSearch.removeAt(listIndex);

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

  addMember(Member member, String userToken, BuildContext context,
      String roleName) async {
    print(roleName);
    if (await isConnectedToInternet()) {
      try {
        final response = await http.post(
            Uri.parse("$baseURL/api/Authenticate/register"),
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
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });
        print(response.body);
        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await addMember(member, userToken, context, roleName);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "User created successfully!") {
            // var newMember = member;
            // newMember.id = userId;
            // membersList.add(newMember);
            // copyMemberList = membersList;
            // print(newMember.shiftId);
            // notifyListeners();
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

  editMember(Member member, int id, String userToken, BuildContext context,
      String roleName) async {
    print(
        "Shift id ${member.shiftId} , userType id ${member.userType}  , memid : ${member.id}, roleName $roleName}");

    if (await isConnectedToInternet()) {
      try {
        final response = await http.put(
            Uri.parse("$baseURL/api/Users/Update/${member.id}"),
            body: json.encode(
              {
                "id": member.id,
                "Name": member.name,
                "PhoneNo": member.phoneNumber,
                "Email": member.email,
                "Salary": member.salary,
                "JobTitle": member.jobTitle,
                "UserType": member.userType,
                "ShiftId": member.shiftId,
                "roleName": roleName
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
          await editMember(member, id, userToken, context, roleName);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);
          print(member.salary);
          if (decodedRes["message"] == "Success : User Updated Successfully ") {
            membersList[id] = member;

            var membersListId = findMemberInMembersList(member.id);

            membersList[membersListId] = member;
            membersListScreenDropDownSearch = [...membersList];

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
