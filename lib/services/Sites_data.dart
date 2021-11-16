import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/site_shifts_all.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

import 'company.dart';

class Site {
  int id;
  double lat;
  double long;
  String name;

  Site({this.lat, this.long, this.name, this.id});
  factory Site.fromJson(dynamic json) {
    return Site(
        id: json['id'],
        lat: double.parse(json['siteLat'].toString()),
        long: double.parse(json['siteLan'].toString()),
        name: json['siteName']);
  }
}

class SiteData with ChangeNotifier {
  List<Site> sitesList = [];
  int currentShiftID;
  List<Site> dropDownSitesList = [];
  Future futureListener;
  List<String> dropdownIndexes = [];
  int dropIndex = 0;
  int currentShiftIndex = 0;
  String currentSiteName = "";
  InheritDefault inherit = InheritDefault();
  String siteValue = 'كل المواقع';
  String currentShiftName = "";
  int pageIndex = 0;
  bool keepRetriving = true;
  bool isLoading = false;
  setSiteValue(String v) {
    siteValue = v;
    notifyListeners();
  }

  setShiftValue(String v) {
    currentShiftName = v;
    notifyListeners();
  }

  setCurrentSiteName(String newval) {
    currentSiteName = newval;
  }

  setDropIndex(int newValue) {
    dropIndex = newValue;
    notifyListeners();
  }

  fillCurrentShiftIndex(int index) {
    currentShiftIndex = index;
    notifyListeners();
  }

  fillCurrentShiftID(int currentINdex) {
    currentShiftID = currentINdex;
    notifyListeners();
  }

  fillDropDownIndexes() {
    dropdownIndexes = [];
  }

  int dropDownSitesIndex = 1;
  setDropDownIndex(int newIndex) {
    print("new index is $newIndex");
    dropDownSitesIndex = newIndex;
    notifyListeners();
  }

  int dropDownShiftIndex = 1;
  setDropDownShift(int newValue) {
    print("new index is $newValue");
    dropDownShiftIndex = newValue;
    notifyListeners();
  }

  List<String> dropDownSitesStrings = [];
  filSitesStringsList(BuildContext context) {
    Provider.of<SiteShiftsData>(context, listen: false)
        .sites
        .forEach((element) {
      dropDownSitesStrings.add(element.name);
    });
  }

  deleteSite(
      int id, String userToken, int listIndex, BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http.delete(Uri.parse("$baseURL/api/Sites/$id"),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await deleteSite(
            id,
            userToken,
            listIndex,
            context,
          );
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            sitesList.removeAt(listIndex);
            Provider.of<SiteShiftsData>(context, listen: false)
                .siteShiftList
                .removeAt(listIndex);
            dropDownSitesList = [...sitesList];
            dropDownSitesList.insert(
                0, Site(name: "كل المواقع", id: -1, lat: 0, long: 0));
            await sendFcmDataOnly(
                category: "reloadData",
                topicName:
                    "attend${Provider.of<CompanyData>(context, listen: false).com.id}");

            await Provider.of<SiteShiftsData>(context, listen: false)
                .getAllSitesAndShifts(
                    Provider.of<CompanyData>(context, listen: false).com.id,
                    Provider.of<UserData>(context, listen: false)
                        .user
                        .userToken);
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Fail : You must delete all shifts in site then delete site") {
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

  Future<Site> getSpecificSite(
      int id, String userToken, BuildContext context) async {
    Site site;
    if (await isConnectedToInternet()) {
      try {
        final response = await http.get(Uri.parse("$baseURL/api/Sites/$id"),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });
        print(response.statusCode);
        if (response.statusCode == 401) {
          await inherit.login(context);
          userToken =
              Provider.of<UserData>(context, listen: false).user.userToken;
          await getSpecificSite(
            id,
            userToken,
            context,
          );
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            site = Site(
                id: decodedRes['data']['id'],
                lat: double.parse(decodedRes['data']['siteLat'].toString()),
                long: double.parse(decodedRes['data']['siteLan'].toString()),
                name: decodedRes['data']['siteName']);
            sitesList = [
              Site(id: site.id, lat: site.lat, long: site.long, name: site.name)
            ];
            notifyListeners();
            return site;
          } else if (decodedRes["message"] ==
              "Fail : You must delete all shifts in site then delete site") {
            return null;
          }
        }
      } catch (e) {
        print(e);
      }
      return null;
    } else {
      return null;
    }
  }

  Future getSitesByCompanyId(
    int companyId,
    String userToken,
    BuildContext context,
  ) async {
    futureListener = getSitesByCompanyIdApi(companyId, userToken, context);
    return futureListener;
  }

  getSitesByCompanyIdApi(
      int companyId, String userToken, BuildContext context) async {
    if (await isConnectedToInternet()) {
      // dropDownSitesStrings = [];
      if (pageIndex == 0) {
        sitesList = [];
        dropDownSitesList = [];
      }
      pageIndex++;
      isLoading = true;

      notifyListeners();

      if (pageIndex > 1) {
        notifyListeners();
      }
      print(("printing the page index $pageIndex"));

      final response = await http.get(
          Uri.parse(
              "$baseURL/api/Sites/GetAllSitesInCompany?companyId=$companyId&pageNumber=$pageIndex&pageSize=9"),
          headers: {
            'Content-type': 'application/json',
            'Authorization': "Bearer $userToken"
          });
      print(response.request.url);
      print(response.body);
      print("status code ${response.statusCode}");
      if (response.statusCode == 401) {
        await inherit.login(context);
        userToken =
            Provider.of<UserData>(context, listen: false).user.userToken;
        await getSitesByCompanyIdApi(
          companyId,
          userToken,
          context,
        );
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        var decodedRes = json.decode(response.body);
        print(response.body);

        if (decodedRes["message"] == "Success") {
          var sitesNewList = jsonDecode(response.body)['data'] as List;
          if (sitesNewList.isEmpty) {
            keepRetriving = false;
            notifyListeners();
          }
          if (keepRetriving) {
            sitesList.addAll(sitesNewList
                .map((siteJson) => Site.fromJson(siteJson))
                .toList());
            // sitesList = sitesNewList;

            dropDownSitesList = [...sitesList];
          }
          isLoading = false;
          dropDownSitesList.insert(
              0, Site(name: "كل المواقع", id: -1, lat: 0, long: 0));

          filSitesStringsList(context);

          notifyListeners();

          return sitesList;
        } else if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return null;
        }
      }

      return null;
    } else {
      return "noInternet";
    }
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

  addSite(
      Site site, int companyId, String userToken, BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        dropDownSitesStrings = [];
        final response = await http.post(Uri.parse("$baseURL/api/Sites"),
            body: json.encode(
              {
                "siteLan": site.long,
                "siteLat": site.lat,
                "siteName": site.name,
                "companyId": companyId
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
          await addSite(
            site,
            companyId,
            userToken,
            context,
          );
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            Site newSite = Site(
                id: decodedRes['data']['id'] as int,
                lat: double.parse(decodedRes['data']['siteLat'].toString()),
                long: double.parse(decodedRes['data']['siteLan'].toString()),
                name: decodedRes['data']['siteName']);
            Provider.of<SiteShiftsData>(context, listen: false)
                .siteShiftList
                .add(SiteShiftsModel(
                    shifts: [], siteId: newSite.id, siteName: newSite.name));
            sitesList.add(newSite);
            dropDownSitesList.add(newSite);
            filSitesStringsList(context);
            await sendFcmDataOnly(
                category: "reloadData",
                topicName:
                    "attend${Provider.of<CompanyData>(context, listen: false).com.id}");
            await Provider.of<SiteShiftsData>(context, listen: false)
                .getAllSitesAndShifts(
                    Provider.of<CompanyData>(context, listen: false).com.id,
                    Provider.of<UserData>(context, listen: false)
                        .user
                        .userToken);
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Fail : The same site name already exists in company") {
            return "exists";
          } else if (decodedRes["message"] == "Fail : Sites Limit Reached") {
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

  editSite(Site site, int companyId, String userToken, int id,
      BuildContext context) async {
    print(
        " id:${site.id}  name:${site.name} long:${site.long} lat:${site.lat} comId:$companyId , listId:$id");

    if (await isConnectedToInternet()) {
      try {
        dropDownSitesStrings = [];
        final response = await http.put(
            Uri.parse("$baseURL/api/Sites/${site.id}"),
            body: json.encode(
              {
                "id": site.id,
                "siteLan": site.long,
                "siteLat": site.lat,
                "siteName": site.name,
                "companyId": companyId
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
          await editSite(
            site,
            companyId,
            userToken,
            id,
            context,
          );
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          var decodedRes = json.decode(response.body);
          print(response.body);

          if (decodedRes["message"] == "Success") {
            Site newSite = Site(
                id: decodedRes['data']['id'] as int,
                lat: double.parse(decodedRes['data']['siteLat'].toString()),
                long: double.parse(decodedRes['data']['siteLan'].toString()),
                name: decodedRes['data']['siteName']);

            sitesList[id] = newSite;
            Provider.of<SiteShiftsData>(context, listen: false)
                .siteShiftList[id]
                .siteId = newSite.id;
            Provider.of<SiteShiftsData>(context, listen: false)
                .siteShiftList[id]
                .siteName = newSite.name;

            dropDownSitesList = [...sitesList];
            dropDownSitesList.insert(
                0, Site(name: "كل المواقع", id: -1, lat: 0, long: 0));
            filSitesStringsList(context);
            await sendFcmDataOnly(
                category: "reloadData",
                topicName:
                    "attend${Provider.of<CompanyData>(context, listen: false).com.id}");

            await Provider.of<SiteShiftsData>(context, listen: false)
                .getAllSitesAndShifts(
                    Provider.of<CompanyData>(context, listen: false).com.id,
                    Provider.of<UserData>(context, listen: false)
                        .user
                        .userToken);
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Fail : The same Site name already exists in company") {
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
