import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

import 'Shift.dart';

class ShiftsData with ChangeNotifier {
  List<Shift> shiftsList = [];
  List<Shift> shiftsBySite = [];
  Future futureListener;

  InheritDefault inherit = InheritDefault();

  findMatchingShifts(int siteId, bool addallshiftsBool) {
    print("findMatchingShifts : $siteId");
    shiftsBySite =
        shiftsList.where((element) => element.siteID == siteId).toList();
    if (addallshiftsBool == true) {
      shiftsBySite.insert(
          0,
          Shift(
            shiftEndTime: 0,
            shiftId: -100,
            shiftName: "كل المناوبات",
            shiftStartTime: 0,
            siteID: -100,
            shiftQrCode: "",
          ));
    }

    if (shiftsBySite.length == 0) {
      shiftsBySite = [
        Shift(
            shiftName: "لا يوجد مناوبات بهذا الموقع",
            shiftStartTime: -1,
            shiftEndTime: 0,
            shiftId: 0,
            siteID: 0)
      ];
    }

    return shiftsBySite.length;
  }

  deleteFromAllShiftsList(int shiftId) {
    for (int i = 0; i < shiftsList.length; i++) {
      if (shiftsList[i].shiftId == shiftId) {
        shiftsList.removeAt(i);
        break;
      }
    }
  }

  deleteShift(int shiftId, String userToken, int listIndex,
      BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http.delete("$baseURL/api/Shifts/$shiftId",
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await deleteShift(shiftId, userToken, listIndex, context);
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            if (shiftsBySite.length > 1) {
              shiftsBySite.removeAt(listIndex);
            } else {
              shiftsBySite = [
                Shift(
                    shiftName: "لا يوجد مناوبات بهذا الموقع",
                    shiftStartTime: -1,
                    shiftEndTime: 0,
                    shiftId: 0,
                    siteID: 0)
              ];
            }
            deleteFromAllShiftsList(shiftId);
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Fail : You must delete all users in shift then delete shift") {
            return "hasData";
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

  Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future getAllCompanyShifts(
      int companyId, String userToken, BuildContext context) async {
    futureListener = getAllCompanyShiftsApi(companyId, userToken, context);
    return futureListener;
  }

  getAllCompanyShiftsApi(
      int companyId, String userToken, BuildContext context) async {
    List<Shift> shiftsNewList;
    if (await isConnectedToInternet()) {
      try {
        final response = await http.get(
            "$baseURL/api/Shifts/GetAllShiftInCompany?companyId=$companyId",
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await getAllCompanyShiftsApi(
            companyId,
            userToken,
            context,
          );
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            var shiftObjJson = jsonDecode(response.body)['data'] as List;
            shiftsNewList = shiftObjJson
                .map((shiftJson) => Shift.fromJson(shiftJson))
                .toList();

            shiftsList = shiftsNewList;
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

  addShift(Shift shift, String userToken, BuildContext context) async {
    print(shift.siteID);
    if (await isConnectedToInternet()) {
      try {
        final response = await http.post("$baseURL/api/Shifts",
            body: json.encode(
              {
                "shiftEntime": shift.shiftEndTime.toString(),
                "shiftName": shift.shiftName,
                "shiftSttime": shift.shiftStartTime.toString(),
                "siteId": shift.siteID
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
          await addShift(
            shift,
            userToken,
            context,
          );
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            Shift newShift = Shift(
                shiftId: decodedRes['data']['id'] as int,
                shiftName: decodedRes['data']['shiftName'],
                shiftStartTime: int.parse(decodedRes['data']['shiftSttime']),
                shiftEndTime: int.parse(decodedRes['data']['shiftEntime']),
                siteID: decodedRes['data']['siteId'] as int);

            shiftsList.add(newShift);
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Fail : The same shift name already exists in site") {
            return "exists";
          } else if (decodedRes["message"] == "Fail : Time constants error") {
            print("s");
            return decodedRes["data"];
          } else {
            return "failed";
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

  findShiftIndexInShiftsList(int id) {
    for (int i = 0; i < shiftsList.length; i++) {
      if (shiftsList[i].shiftId == id) {
        return i;
      }
    }
  }

  editShift(Shift shift, int id, String usertoken, BuildContext context) async {
    print("Shift ID : ${shift.shiftId}");
    print("Site ID : ${shift.siteID}");
    print("index : $id");

    if (await isConnectedToInternet()) {
      try {
        final response = await http.put("$baseURL/api/Shifts/${shift.shiftId}",
            body: json.encode(
              {
                "id": shift.shiftId,
                "shiftEntime": shift.shiftEndTime.toString(),
                "shiftName": shift.shiftName,
                "shiftSttime": shift.shiftStartTime.toString(),
                "siteId": shift.siteID,
              },
            ),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $usertoken"
            });

        if (response.statusCode == 401) {
          await inherit.login(context);
          usertoken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await editShift(
            shift,
            id,
            usertoken,
            context,
          );
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            Shift newShift = Shift(
                shiftId: decodedRes['data']['id'],
                shiftName: decodedRes['data']['shiftName'],
                shiftStartTime: int.parse(decodedRes['data']['shiftSttime']),
                shiftEndTime: int.parse(decodedRes['data']['shiftEntime']),
                siteID: decodedRes['data']['siteId'] as int);
            var shiftsListIndex = findShiftIndexInShiftsList(shift.shiftId);

            shiftsList[shiftsListIndex] = newShift;
            shiftsBySite[id] = newShift;
            notifyListeners();

            return "Success";
          } else if (decodedRes["message"] ==
              "Fail : Shift Name already exists") {
            return "exists";
          } else if (decodedRes["message"] == "Fail : Time constants error") {
            print("s");
            return decodedRes["data"];
          } else {
            return "failed";
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
// Future<void> getCompanySites(int companyID, String userToken) async {
//   print("GETTING COMPANY SITES NEWWW");
//   String url = "https://attendanceback.tamauze.com/api/Company/$companyID";
//   try {
//     companySitesProv = [];
//     final response = await http.get(
//       url,
//       headers: {
//         "Accept": "application/json",
//         'Authorization': "Bearer $userToken"
//       },
//     );
//     var decodedRes = json.decode(response.body);
//     if (jsonDecode(response.body)["message"] == "Success") {
//       var jsonObj = await jsonDecode(response.body)["data"] as List;
//       companySitesProv = jsonObj
//           .map((categoires) => CompanySites.fromJson(categoires))
//           .toList();

//       for (int i = 0; i < companySitesProv.length; i++) {
//         for (int k = 0; k < companySitesProv[i].shiftsList.length; k++) {
//           print(companySitesProv[i].shiftsList.length);
//           sitess.addAll(
//               {companySitesProv[i].siteID: companySitesProv[k].shiftsList});
//         }
//       }
//       print(sitess.length);
//       print(sitess.keys);
//       print(sitess.values);
//       print(sitess[4].length);

//       // print(companySitesProv[0].shiftsList.length);
//       // print(companySitesProv[0].shiftsList[1].shiftName);

//       // print(companySitesProv.length);
//       // print(companySitesProv[0].siteName);
//       // print("shhift id ${companySitesProv[0].shiftsList[0].shifID}");

//       notifyListeners();
//     }
//   } catch (e) {
//     print(e);
//   }
// }
