import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_push/huawei_push_library.dart' as hawawi;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';
import 'package:qr_users/MLmodule/db/SqlfliteDB.dart';
import 'package:qr_users/NetworkApi/NetworkFaliure.dart';
import 'package:qr_users/Screens/SuperAdmin/Service/SuperCompaniesModel.dart';
import 'package:qr_users/Screens/SuperAdmin/Service/SuperCompaniesRepo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/MemberData/Repo/MembersRepo.dart';
import 'package:qr_users/services/company.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';

import 'ShiftsData.dart';

class UserData with ChangeNotifier {
  var changedWidget = Image.asset("resources/personicon.png");
  // Company com = Company(id: 0, logo: "", nameAr: "", nameEn: "");
//   var cacheValCompanyIcon = "";
// var companyDataArname="";
  // String siteName;
  List<SuperCompaniesModel> superCompaniesList = [];
  SuperCompaniesChartModel superCompaniesChartModel;
  String hawawiToken = "";
  Position _currentPosition;
  Location _currentHawawiLocation;
  bool changedPassword;
  bool isLoading = false;
  bool isSuperAdmin = false;
  bool isTdsAdmin = false;
  bool isTechnicalSupport = false;
  User user = User(
    userSiteId: 0,
    isAllowedToAttend: false,
    userToken: "",
    userID: "",
    name: "",
    userJob: "",
    email: "",
    phoneNum: "",
    password: "",
    userType: 0,
    id: "",
  );
  List<String> cachedUserData = [];
  setCacheduserData(List<String> cached) {
    cachedUserData = cached;
    notifyListeners();
  }

  bool loggedIn = false;
  Future<bool> isConnectedToInternet(String url) async {
    try {
      final result = await InternetAddress.lookup(url);
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

  // Future<String> _fileFromImageUrl(String path, String name) async {
  //   final response = await http.get(path);

  //   final documentDirectory = await getApplicationDocumentsDirectory();

  //   final file = File(join(documentDirectory.path, '$name.png'));

  //   file.writeAsBytesSync(response.bodyBytes);

  //   return file.path;
  // }

  Future<int> loginPost(String username, String password, BuildContext context,
      bool cacheLogin) async {
    if (await isConnectedToInternet("www.wikipedia.org")) {
      int userType;
      var decodedRes;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      var token;
      bool isHuawei = false;

      final HuaweiServices _huawei = HuaweiServices();
      if (Platform.isAndroid) {
        if (await _huawei.isHuaweiDevice()) {
          token = hawawiToken;
          isHuawei = true;
        }
      } else {
        bool isError = false;
        String isnull = await firebaseMessaging.getToken().catchError((e) {
          token = "null";
          isError = true;
        });

        if (isError == false) {
          token = await firebaseMessaging.getToken();
        }
      }
      const rolesConstUrl =
          "http://schemas.microsoft.com/ws/2008/06/identity/claims/role";
      final response =
          await MemberRepo().getMemberData(username, password, token, isHuawei);
      if (response is Faliure) {
        print("faliure occured");
        return response.code;
      } else {
        log(response);
        print("not faliure");
        // log(response);
        decodedRes = json.decode(response);

        if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return -2;
        } else if (decodedRes["message"] ==
            "Fail : This Company is suspended") {
          return -4;
        }
        final Map<String, dynamic> decodedToken =
            JwtDecoder.decode(decodedRes["token"]);
        isSuperAdmin =
            decodedToken[rolesConstUrl].toString().contains("SuperAdmin");
        isTdsAdmin =
            decodedToken[rolesConstUrl].toString().contains("TDS_Admin");
        isTechnicalSupport =
            decodedToken[rolesConstUrl].toString().contains("TDSTechSupport");

        if (decodedRes["message"] == "Success : ") {
          changedPassword = decodedRes["userData"]["changedPassword"] as bool;
          user = User.fromJson(decodedRes);
          final companyId = decodedRes["companyData"]["id"];
          await Provider.of<CompanyData>(context, listen: false)
              .getCompanyDataFromLogin(decodedRes);
          final String comImageFilePath =
              "$imageUrl${decodedRes["companyData"]["logo"]}";

          final String userImage = user.userImage;
          final CompanyData comProv =
              Provider.of<CompanyData>(context, listen: false);
          if (isSuperAdmin) {
            print(decodedRes['superAdminCompanies']);
            var obJson = decodedRes['superAdminCompanies'] as List;
            superCompaniesList.add(SuperCompaniesModel(
                companyId: comProv.com.id, companyName: comProv.com.nameAr));
            final List<SuperCompaniesModel> tempComp = obJson
                .map((json) => SuperCompaniesModel.fromJson(json))
                .toList();
            superCompaniesList.addAll(tempComp);
          } else if (isTdsAdmin || isTechnicalSupport) {
            print(decodedRes['tdsadminCompanies']);
            var obJson = decodedRes['tdsadminCompanies'] as List;

            superCompaniesList = obJson
                .map((json) => SuperCompaniesModel.fromJson(json))
                .toList();
          } else if (user.userType == 4 || user.userType == 3) {
            Provider.of<SiteShiftsData>(context, listen: false)
                .getAllSitesAndShifts(companyId, user.userToken);
          }

          final List<String> userData = [
            user.name,
            user.userJob,
            userImage,
            decodedRes["companyData"]["nameAr"],
            comImageFilePath
          ];
          prefs.setStringList("allUserData", userData);

          loggedIn = true;
          final List<String> notifyList =
              await prefs.getStringList('bgNotifyList');
          print("notifi status :$notifyList ");

          if (notifyList != null && notifyList.length != 0) {
            await db.insertNotification(
                NotificationMessage(
                    category: notifyList[0],
                    dateTime: notifyList[1],
                    message: notifyList[2],
                    messageSeen: 0,
                    timeOfMessage: notifyList[4],
                    title: notifyList[3]),
                context);
          }
          if (cacheLogin) {
            await initializeNotification(context);
          } else {
            Provider.of<NotificationDataService>(context, listen: false)
                .notification
                .clear();
            await db.clearNotifications();
          }

          userType = user.userType;
          prefs.setStringList(('bgNotifyList'), []);
          if (isSuperAdmin || isTdsAdmin || isTechnicalSupport) {
            return 6;
          } else if (userType == 2) {
            print("get site admin shifts");
            Provider.of<ShiftsData>(context, listen: false).getShifts(
                Provider.of<UserData>(context, listen: false).user.userSiteId,
                Provider.of<UserData>(context, listen: false).user.userToken,
                context,
                userType,
                Provider.of<UserData>(context, listen: false).user.userSiteId);
          }

          log("user type ${(user.userType)}");
          if (user.userType == 4 || user.userType == 3) {
            print("getting super chart");
            await Provider.of<UserData>(context, listen: false)
                .getSuperCompanyChart(user.userToken, companyId);
          }
          notifyListeners();
          return user.userType;
        }
      }
      return NO_INTERNET;
    } else {
      return NO_INTERNET;
    }
  }

  initializeNotification(BuildContext context) async {
    if (await db.checkNotificationStatus()) {
      Provider.of<NotificationDataService>(context, listen: false)
          .notification = await db.getAllNotifications();
    }
  }

  Future<String> forgetPassword(String username, String phone) async {
    if (await isConnectedToInternet("www.google.com")) {
      try {
        final response = await http.put(
            Uri.parse("$baseURL/api/Users/ForgetPassword"),
            body: json.encode(
              {"UserName": username, "PhoneNo": phone.trim()},
            ),
            headers: {'Content-type': 'application/json', 'x-api-key': apiKey});
        print(response.body);
        var decodedRes = json.decode(response.body);

        if (decodedRes["message"] == "Verification code send to account ") {
          notifyListeners();
          return "success";
        } else if (decodedRes["message"] == "You enter invaild account") {
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

  Future<String> setPassword(
      {String pinCode, String username, String password}) async {
    if (await isConnectedToInternet("www.google.com")) {
      try {
        final response = await http.put(
            Uri.parse("$baseURL/api/Users/NewPassword"),
            body: json.encode(
              {
                "UserName": username,
                "Code": pinCode,
                "NewPassword": password,
              },
            ),
            headers: {'Content-type': 'application/json', 'x-api-key': apiKey});

        var decodedRes = json.decode(response.body);
        print(decodedRes["message"]);

        if (decodedRes["message"] == "Password Updated Successfully ") {
          notifyListeners();
          return "success";
        } else if (decodedRes["message"] == "Invaild pin code") {
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

  Future<String> attendByCard(
      {File image, String qrCode, String cardCode}) async {
    final HuaweiServices _huawei = HuaweiServices();
    bool isHawawi = false;
    if (Platform.isAndroid) {
      isHawawi = await _huawei.isHuaweiDevice();
    }

    print(image.lengthSync());
    log("image ${image.path}");
    String msg;
    print("card code $cardCode");
    print("qr code : $qrCode");
    if (await isConnectedToInternet("www.google.com")) {
      final int locationService = await getCurrentLocation();
      if (locationService == 0) {
        final stream = new http.ByteStream(Stream.castFrom(image.openRead()));
        final length = await image.length();
        final uri = Uri.parse("$baseURL/api/AttendLogin");

        final request = new http.MultipartRequest("POST", uri);
        Map<String, String> headers = {
          'Authorization': "Bearer ${user.userToken}"
        };
        request.headers.addAll(headers);
        final multipartFile = new http.MultipartFile(
            'UserImage', stream, length,
            filename: basename(image.path));
        request.files.add(multipartFile);
        request.fields['Userid'] = "0";
        request.fields['Qrcode'] = cardCode;
        request.fields['Longitude'] = isHawawi
            ? _currentHawawiLocation.longitude.toString()
            : _currentPosition.longitude.toString();
        request.fields['Latitude'] = isHawawi
            ? _currentHawawiLocation.latitude.toString()
            : _currentPosition.latitude.toString();
        request.fields['userLogintype'] = "1";
        print("card code :$cardCode");
        print("**************");
        await request.send().then((response) async {
          response.stream.transform(utf8.decoder).listen((value) {
            print(value);
            Map<String, dynamic> responesDedoded = json.decode(value);
            msg = responesDedoded['message'];
            print("msg is $msg");
          });
        }).catchError((e) {
          print(e);
        });
      } else if (locationService == 1) {
        msg = 'mock';
      } else {
        msg = 'off';
      }
    } else {
      msg = 'noInternet';
    }
    print("msg2 is $msg");
    return msg;
  }

  static Future<String> getDeviceUUID() async {
    String identifier;

    try {
      if (Platform.isAndroid) {
        identifier = await FlutterUdid.udid; //UUID for Android
      } else if (Platform.isIOS) {
        final storage = new FlutterSecureStorage();
        identifier = await storage.read(key: "deviceMac"); //UUID for iOS
      }
    } catch (e) {
      print('Failed to get platform version');
    }
//if (!mounted) return;
    return identifier;
  }

  Future<String> attend({String qrCode}) async {
    print("attend --${user.id}----$qrCode");
    String msg;
    try {
      if (await isConnectedToInternet("www.google.com")) {
        final int locationService = await getCurrentLocation();
        final HuaweiServices _huawei = HuaweiServices();
        bool isHawawi = false;
        if (Platform.isAndroid) {
          isHawawi = await _huawei.isHuaweiDevice();
        }

        if (locationService == 0) {
          final String imei = await getDeviceUUID();
          print("imei is : $imei");
          final uri = '$baseURL/api/AttendLogin';

          final headers = {
            'Authorization': "Bearer ${user.userToken}",
            "Accept": "application/json"
          };

          final http.Response response = await http.post(
            Uri.parse(uri),
            headers: headers,
            body: {
              'Userid': user.id,
              'Qrcode': qrCode,
              'Longitude': isHawawi
                  ? _currentHawawiLocation.longitude.toString()
                  : _currentPosition.longitude.toString(),
              'Latitude': isHawawi
                  ? _currentHawawiLocation.latitude.toString()
                  : _currentPosition.latitude.toString(),
              'userLogintype': "0",
              'UserMac': imei,
            },
          );
          final String responseBody = response.body;
          print(response.body);
          msg = jsonDecode(responseBody)['message'];
          print(
              "-----------------------------${jsonDecode(responseBody)}-----------------------");
          print("imei after attend is : $imei");
          print("msg after attend is :$msg");
        } else if (locationService == 1) {
          msg = 'mock';
        } else {
          msg = 'off';
        }
      } else {
        msg = 'noInternet';
      }
    } catch (e) {
      print(e);
    }

    return msg;
  }

  Future getSuperCompanyChart(String token, int comID) async {
    if (await isConnectedToInternet("www.google.com")) {
      var response =
          await SuperCompaniesChartRepo().getSuperCharts(token, comID);

      if (response is Faliure) {
        print("faliure occured");
        return response;
      } else {
        print(response);
        final decodedRes = json.decode(response);
        if (decodedRes["message"] == "Success") {
          superCompaniesChartModel =
              SuperCompaniesChartModel.fromJson(decodedRes["data"]);
          notifyListeners();
          return "Success";
        } else if (decodedRes["message"] == "Success : No data") {
          return "No data";
        } else {
          return "fail";
        }
      }
    }
    {
      return "noInternet";
    }
  }

  Future<String> uploadImage(File _image, String id) async {
    String data = "";
    print("uploading image..$id...");
    print(_image.path);
    var stream = new http.ByteStream(Stream.castFrom(_image.openRead()));
    var length = await _image.length();

    var uri = Uri.parse("$baseURL/api/Users/UpdateImage/$id");

    var request = new http.MultipartRequest("PUT", uri);
    Map<String, String> headers = {'Authorization': "Bearer ${user.userToken}"};
    request.headers.addAll(headers);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(_image.path));
    request.files.add(multipartFile);

    await request.send().then((response) async {
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        Map<String, dynamic> responesDedoded = json.decode(value);

        if (responesDedoded['message'] == "Success : Image updated success") {
          print(responesDedoded['message']);
          data = responesDedoded['data'];
          return data;
        } else {
          return "";
        }
      });
    }).catchError((e) {
      print(e);
    });
    return data;
  }

  Future<String> updateProfileImgFile(String imgPath) async {
    File _image = File(imgPath);
    print(_image.lengthSync());
    var url = "";

    if (await isConnectedToInternet("www.google.com")) {
      await uploadImage(_image, user.id).then((value) async {
        if (value != "") {
          print("path :$value");
          url = "$imageUrl/$value";
          print("lunch url $url");
          user.userImage = url;
          print("success =  $value");

          changedWidget = Image.file(File(imgPath));
          // cachedUserData[2] = imgPath;
          notifyListeners();
        }
      });
      if (url != "") {
        return "success";
      } else {
        return "";
      }
    } else {
      return 'noInternet';
    }
  }

  Future<String> editProfile(String password) async {
    print("${user.id} -----edit-- $password");
    if (await isConnectedToInternet("www.google.com")) {
      try {
        isLoading = true;
        notifyListeners();
        final response = await http.put(
            Uri.parse("$baseURL/api/Users/UpdatePassword"),
            body: json.encode(
              {
                "Id": user.id,
                "Password": password,
              },
            ),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer ${user.userToken}"
            });
        print(response.body);
        isLoading = false;
        var decodedRes = json.decode(response.body);
        print(response.body);
        print(decodedRes["message"]);
        notifyListeners();
        if (decodedRes["message"] == "Success : password updated successfuly") {
          return "success";
        } else {
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

  Future<String> changePassword(String password) async {
    String imei = await getDeviceUUID();
    print("${user.id} -----edit-- $password --- mac$imei ");

    if (await isConnectedToInternet("www.google.com")) {
      try {
        final response = await http.put(
            Uri.parse("$baseURL/api/Users/UpdatePassword"),
            body: json.encode(
              {"Id": user.id, "Password": password, "MacAddress": imei},
            ),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer ${user.userToken}"
            });

        var decodedRes = json.decode(response.body);
        print(response.statusCode);
        print(response.body);
        print(decodedRes["message"]);

        if (decodedRes["message"] == "Success : password updated successfuly") {
          return "success";
        } else {
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

  final DatabaseHelper db = DatabaseHelper();
  DefaultCacheManager manager = new DefaultCacheManager();

  //clears all data in cache.
  logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userData', []);
    if (db != null) {
      await db.clearNotifications();
    }

    loggedIn = false;
    // manager.emptyCache().whenComplete(() => print("deletedSuccessfuly"));
    PaintingBinding.instance.imageCache.clear();

    changedWidget = Image.asset("resources/personicon.png");

    // notifyListeners();
  }

  static Future<bool> detectJailBreak() async {
    bool jaibreak;

    try {
      jaibreak = await FlutterJailbreakDetection.jailbroken;
    } on PlatformException {
      jaibreak = true;
    }

    return jaibreak;
  }

  Future<int> getCurrentLocation() async {
    // await checkPermissions();
    HuaweiServices _huawei = HuaweiServices();
    bool enabled = true;
    bool isHawawi = false;
    if (Platform.isAndroid) {
      isHawawi = await _huawei.isHuaweiDevice();
    }

    if (!isHawawi) {
      enabled = await Geolocator.isLocationServiceEnabled();
    }
    print("userdata");
    print("enable locaiton : $enabled");

    // && pos[0] != null
    if (Platform.isIOS) {
      if (enabled) {
        bool isMock = await detectJailBreak();

        if (!isMock) {
          await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.best)
              .then((Position position) {
            _currentPosition = position;
          }).catchError((e) {
            print(e);
          });
          return 0;
        } else {
          return 1;
        }
      } else {
        return 2;
      }
    } else {
      HuaweiServices _huawei = HuaweiServices();
      if (isHawawi) {
        await _huawei.getHuaweiCurrentLocation().then((currentLoc) {
          _currentHawawiLocation = currentLoc;
        });

        return 0;
      } else {
        if (enabled) {
          bool isMockLocation = await TrustLocation.isMockLocation;

          if (!isMockLocation) {
            await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.best)
                .then((Position position) {
              _currentPosition = position;
            }).catchError((e) {
              print(e);
            });
            return 0;
          } else {
            return 1;
          }
        } else {
          return 2;
        }
      }
    }
  }
}

class User {
  String userToken,
      fcmToken,
      userID,
      email,
      phoneNum,
      userJob,
      password,
      userImage,
      id,
      name;

  double salary;
  bool isAllowedToAttend;
  int userSiteId, osType;
  int userType;
  int userShiftId;

  DateTime createdOn, apkDate, iosBundleDate;

  User(
      {this.userToken,
      this.fcmToken,
      this.id,
      this.userImage,
      this.salary,
      this.isAllowedToAttend,
      this.userShiftId,
      this.userSiteId,
      this.userID,
      this.name,
      this.createdOn,
      this.userJob,
      this.email,
      this.userType,
      this.phoneNum,
      this.password,
      this.osType,
      this.apkDate,
      this.iosBundleDate});

  factory User.fromJson(dynamic json) {
    return User(
      userToken: json["token"],
      id: json["userData"]["id"],
      userID: json["userData"]["userName"],
      name: json["userData"]["userName1"],
      userJob: json["userData"]["userJob"],
      email: json["userData"]["email"],
      phoneNum: json["userData"]["phoneNumber"],
      userType: json["userData"]["userType"],
      // fcmToken: json["userData"]["fcmToken"],
      // osType: json["userData"]["mobileOS"],
      salary: json["userData"]["salary"],
      createdOn: DateTime.tryParse(json["userData"]["createdOn"]),
      apkDate: DateTime.tryParse(json["apkDate"]["apkDate"]),
      iosBundleDate: DateTime.tryParse(json["apkDate"]["ios"]),
      userSiteId: json["userData"]["siteId"] as int,
      userShiftId: json["userData"]["shiftId"],
      // isAllowedToAttend: json["userData"]["isAllowtoAttend"],
      userImage: "$imageUrl${json["userData"]["userImage"]}",
      // userImage: "$imageUrl${json["userData"]["userName"]}.png",
    );
  }
}
