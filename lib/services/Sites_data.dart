import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';

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
  String currentSiteName = "";
InheritDefault inherit = InheritDefault();
  String siteValue = 'كل المواقع';
  setSiteValue(String v) {
    siteValue = v;
    notifyListeners();
  }

  setCurrentSiteName(String newval) {
    currentSiteName = newval;
  }

  setDropIndex(int newValue) {
    dropIndex = newValue;
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
  filSitesStringsList() {
    dropDownSitesList.forEach((element) {
      dropDownSitesStrings.add(element.name);
    });
  }

  deleteSite(int id, String userToken, int listIndex,BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http.delete("$baseURL/api/Sites/$id", headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });

  if (response.statusCode==401)
        {
        await  inherit.login(context);
        userToken=Provider.of<UserData>(context,listen: false).user.userToken;
        await deleteSite(id, userToken,listIndex, context,);
        }
        else if (response.statusCode==200 || response.statusCode==201)
        {      var decodedRes = json.decode(response.body);
        print(response.body);


        if (decodedRes["message"] == "Success") {
          sitesList.removeAt(listIndex);

          dropDownSitesList = [...sitesList];
          dropDownSitesList.insert(
              0, Site(name: "كل المواقع", id: -1, lat: 0, long: 0));

          notifyListeners();
          return "Success";
        } else if (decodedRes["message"] ==
            "Fail : You must delete all shifts in site then delete site") {
          return "hasData";
        }}
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }

  Future<Site> getSpecificSite(int id, String userToken,BuildContext context) async {
    Site site;
    if (await isConnectedToInternet()) {
      try {
        final response = await http.get("$baseURL/api/Sites/$id", headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });

        if (response.statusCode==401)
        {
        await  inherit.login(context);
        userToken=Provider.of<UserData>(context,listen: false).user.userToken;
        await getSpecificSite(id, userToken, context,);
        }
        else if (response.statusCode==200 || response.statusCode==201)
        {      var decodedRes = json.decode(response.body);
        print(response.body);


        if (decodedRes["message"] == "Success") {
          site = Site(
              id: decodedRes['data']['id'],
              lat: double.parse(decodedRes['data']['siteLat'].toString()),
              long: double.parse(decodedRes['data']['siteLan'].toString()),
              name: decodedRes['data']['siteName']);

          return site;
        } else if (decodedRes["message"] ==
            "Fail : You must delete all shifts in site then delete site") {
          return null;
        }}
      } catch (e) {
        print(e);
      }
      return null;
    } else {
      return null;
    }
  }

  Future getSitesByCompanyId(int companyId, String userToken,BuildContext context) async {
    futureListener = getSitesByCompanyIdApi(companyId, userToken,context);
    return futureListener;
  }

  getSitesByCompanyIdApi(int companyId, String userToken,BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        dropDownSitesStrings = [];
        final response = await http.get(
            "$baseURL/api/Sites/GetAllSitesInCompany?companyId=$companyId",
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });

   if (response.statusCode==401)
        {
        await  inherit.login(context);
        userToken=Provider.of<UserData>(context,listen: false).user.userToken;
        await getSitesByCompanyIdApi(companyId, userToken, context,);
        }
        else if (response.statusCode==200 || response.statusCode==201)
        {      var decodedRes = json.decode(response.body);
        print(response.body);

        if (decodedRes["message"] == "Success") {
          var sitesNewList = jsonDecode(response.body)['data'] as List;
          sitesNewList =
              sitesNewList.map((siteJson) => Site.fromJson(siteJson)).toList();
          print("sitesNewList.length = ${sitesNewList.length}");
          sitesList = sitesNewList;

          dropDownSitesList = [...sitesNewList];
          dropDownSitesList.insert(
              0, Site(name: "كل المواقع", id: -1, lat: 0, long: 0));
          filSitesStringsList();
          print(dropDownSitesStrings);
          notifyListeners();
          return sitesList;
        } else if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return null;
        }}
      } catch (e) {
        print(e);
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

  addSite(Site site, int companyId, String userToken,BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        dropDownSitesStrings = [];
        final response = await http.post("$baseURL/api/Sites",
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

   if (response.statusCode==401)
        {
        await  inherit.login(context);
        userToken=Provider.of<UserData>(context,listen: false).user.userToken;
        await addSite(site, companyId,userToken, context,);
        }
        else if (response.statusCode==200 || response.statusCode==201)
        {      var decodedRes = json.decode(response.body);
        print(response.body);


        if (decodedRes["message"] == "Success") {
          Site newSite = Site(
              id: decodedRes['data']['id'] as int,
              lat: double.parse(decodedRes['data']['siteLat'].toString()),
              long: double.parse(decodedRes['data']['siteLan'].toString()),
              name: decodedRes['data']['siteName']);

          sitesList.add(newSite);
          dropDownSitesList.add(newSite);
          filSitesStringsList();
          notifyListeners();
          return "Success";
        } else if (decodedRes["message"] ==
            "Fail : The same site name already exists in company") {
          return "exists";
        } else if (decodedRes["message"] == "Fail : Sites Limit Reached") {
          return "Limit Reached";
        }}
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }

  editSite(Site site, int companyId, String userToken, int id,BuildContext context) async {
    print(
        " id:${site.id}  name:${site.name} long:${site.long} lat:${site.lat} comId:$companyId , listId:$id");

    if (await isConnectedToInternet()) {
      try {
        dropDownSitesStrings = [];
        final response = await http.put("$baseURL/api/Sites/${site.id}",
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

 
   if (response.statusCode==401)
        {
        await  inherit.login(context);
        userToken=Provider.of<UserData>(context,listen: false).user.userToken;
        await editSite(site, companyId,userToken,id, context,);
        }
        else if (response.statusCode==200 || response.statusCode==201)
        {      var decodedRes = json.decode(response.body);
        print(response.body);


        if (decodedRes["message"] == "Success") {
          Site newSite = Site(
              id: decodedRes['data']['id'] as int,
              lat: double.parse(decodedRes['data']['siteLat'].toString()),
              long: double.parse(decodedRes['data']['siteLan'].toString()),
              name: decodedRes['data']['siteName']);

          sitesList[id] = newSite;

          dropDownSitesList = [...sitesList];
          dropDownSitesList.insert(
              0, Site(name: "كل المواقع", id: -1, lat: 0, long: 0));
          filSitesStringsList();
          notifyListeners();
          return "Success";
        } else if (decodedRes["message"] ==
            "Fail : The same Site name already exists in company") {
          return "exists";
        }}
      } catch (e) {
        print(e);
      }
      return "failed";
    } else {
      return 'noInternet';
    }
  }
}
