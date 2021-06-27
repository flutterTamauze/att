import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_mac/get_mac.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/enums/connectivity_status.dart';
import 'package:qr_users/services/company.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import 'ShiftsData.dart';

class UserData with ChangeNotifier {
  var changedWidget = Image.asset("resources/personicon.png");
  // Company com = Company(id: 0, logo: "", nameAr: "", nameEn: "");
//   var cacheValCompanyIcon = "";
// var companyDataArname="";
  String siteName;
  Position _currentPosition;
  bool changedPassword;
  bool isLoading = false;
  User user = User(
    userSiteId: 0,
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

  final _apiToken = 'ByYM000OLlMQG6VVVp1OH7Xzyr7gHuw1qvUC5dcGt3SNM';
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

  Future<int> loginPost(
      String username, String password, BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.none) {
      try {
        var stability = await isConnectedToInternet("www.google.com");
        if (stability) {
          if (await isConnectedToInternet("www.tamauzeds.com") == false) {
            return -3;
          }
          final response = await http.post("$baseURL/api/Authenticate/login",
              body: json.encode(
                {"Username": username, "Password": password},
              ),
              headers: {
                'Content-type': 'application/json',
                'x-api-key': _apiToken
              }).timeout(
              Duration(
                seconds: 40,
              ), onTimeout: () {
            return;
          });

          var decodedRes = json.decode(response.body);
          print(response.body);
          print("token is :${decodedRes["token"]}");
          if (decodedRes["message"] == "Success : ") {
            user.userToken = decodedRes["token"];
            user.id = decodedRes["userData"]["id"];
            user.userID = decodedRes["userData"]["userName"];
            user.name = decodedRes["userData"]["userName1"];
            user.userJob = decodedRes["userData"]["userJob"];
            user.email = decodedRes["userData"]["email"];
            user.phoneNum = decodedRes["userData"]["phoneNumber"];
            user.userType = decodedRes["userData"]["userType"];
            user.userSiteId = decodedRes["companyData"]["siteId"] as int;
            user.userShiftId = decodedRes["userData"]["shiftId"];
            user.userImage = "$baseURL/${decodedRes["userData"]["userImage"]}";
            changedPassword = decodedRes["userData"]["changedPassword"] as bool;
            siteName = decodedRes["companyData"]["siteName"];
            // cacheValCompanyIcon = decodedRes["companyData"]["logo"];

            var companyId = decodedRes["companyData"]["id"];
            print('com id :$companyId');
            var msg = await Provider.of<CompanyData>(context, listen: false)
                .getCompanyProfileApi(companyId, user.userToken, context);
            if (msg == "Success") {
              print("ana get b success");
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String comImageFilePath =
                  "$baseURL/${decodedRes["companyData"]["logo"]}";
              String userImage = user.userImage;

              List<String> userData = [
                user.name,
                user.userJob,
                userImage,
                decodedRes["companyData"]["nameAr"],
                comImageFilePath
              ];
              prefs.setStringList("allUserData", userData);
              print(userData[2]);
              print(userData[4]);
              loggedIn = true;
              notifyListeners();
              return user.userType;
            }
          } else if (decodedRes["message"] ==
              "Failed : user name and password not match ") {
            return -2;
          } else if (decodedRes["message"] ==
              "Fail : This Company is suspended") {
            return -4;
          }
        } else if (!stability) {
          return -5;
        }
      } catch (e) {
        print(e);
      }
      return -3;
    } else {
      return -1;
    }
  }

  Future<String> forgetPassword(String username, String email) async {
    if (await isConnectedToInternet("www.google.com")) {
      try {
        final response = await http.put("$baseURL/api/Users/ForgetPassword",
            body: json.encode(
              {"UserName": username, "Email": email.trim()},
            ),
            headers: {
              'Content-type': 'application/json',
              'x-api-key': _apiToken
            });

        var decodedRes = json.decode(response.body);
        print(decodedRes["message"]);

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
        final response = await http.put("$baseURL/api/Users/NewPassword",
            body: json.encode(
              {
                "UserName": username,
                "Code": pinCode,
                "NewPassword": password,
              },
            ),
            headers: {
              'Content-type': 'application/json',
              'x-api-key': _apiToken
            });

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
    print(image.lengthSync());
    String msg;
    print("uploading image......$cardCode...${cardCode.length}...");
    if (await isConnectedToInternet("www.google.com")) {
      int locationService = await getCurrentLocation();
      if (locationService == 0) {
        var stream = new http.ByteStream(Stream.castFrom(image.openRead()));
        var length = await image.length();
        var uri = Uri.parse("$baseURL/api/AttendLogin");

        var request = new http.MultipartRequest("POST", uri);
        Map<String, String> headers = {
          'Authorization': "Bearer ${user.userToken}"
        };
        request.headers.addAll(headers);
        var multipartFile = new http.MultipartFile('UserImage', stream, length,
            filename: basename(image.path));
        request.files.add(multipartFile);
        request.fields['Userid'] = "0";
        request.fields['Qrcode'] = cardCode;
        request.fields['Longitude'] = _currentPosition.longitude.toString();
        request.fields['Latitude'] = _currentPosition.latitude.toString();
        request.fields['userLogintype'] = "1";

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
        identifier = await GetMac.macAddress; //UUID for Android
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
    print("attend --${user.userID}----$qrCode");
    String msg;
    if (await isConnectedToInternet("www.google.com")) {
      int locationService = await getCurrentLocation();
      if (locationService == 0) {
        String imei = await getDeviceUUID();
        print("imei is : $imei");
        final uri = '$baseURL/api/AttendLogin';
        print(
            "Request:- URL:$uri Qrcode:$qrCode UserID:${user.id} long:${_currentPosition.longitude.toString()} lat:${_currentPosition.latitude.toString()} UserMacAdd: $imei token:${user.userToken} ");
        final headers = {
          'Authorization': "Bearer ${user.userToken}",
          "Accept": "application/json"
        };
        try {
          http.Response response = await http.post(
            uri,
            headers: headers,
            body: {
              'Userid': user.id,
              'Qrcode': qrCode,
              'Longitude': _currentPosition.longitude.toString(),
              'Latitude': _currentPosition.latitude.toString(),
              'userLogintype': "0",
              'UserMac': imei,
            },
          );
          String responseBody = response.body;
          print(response.body);
          msg = jsonDecode(responseBody)['message'];
          print(
              "-----------------------------${jsonDecode(responseBody)}-----------------------");
          print("imei after attend is : $imei");
          print("msg after attend is :$msg");
        } catch (e) {
          print(e);
        }
      } else if (locationService == 1) {
        msg = 'mock';
      } else {
        msg = 'off';
      }
    } else {
      msg = 'noInternet';
    }

    return msg;
  }

  Future<String> uploadImage(File _image, String id) async {
    String data = "";
    print("uploading image..$id...");

    var stream = new http.ByteStream(Stream.castFrom(_image.openRead()));
    var length = await _image.length();

    var uri = Uri.parse("$baseURL/api/Users/UpdateImage/$id");

    var request = new http.MultipartRequest("PUT", uri);
    Map<String, String> headers = {'Authorization': "Bearer ${user.userToken}"};
    request.headers.addAll(headers);
    var multipartFile = new http.MultipartFile('image', stream, length,
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
          url = "$baseURL/$value";
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
        final response = await http.put("$baseURL/api/Users/UpdatePassword",
            body: json.encode(
              {"Id": user.id, "Password": password},
            ),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer ${user.userToken}"
            });

        var decodedRes = json.decode(response.body);
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

  Future<String> changePassword(String password) async {
    String imei = await getDeviceUUID();
    print("${user.id} -----edit-- $password --- mac$imei ");

    if (await isConnectedToInternet("www.google.com")) {
      try {
        final response = await http.put("$baseURL/api/Users/UpdatePassword",
            body: json.encode(
              {"Id": user.id, "Password": password, "MacAddress": imei},
            ),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer ${user.userToken}"
            });

        var decodedRes = json.decode(response.body);
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

  DefaultCacheManager manager = new DefaultCacheManager();

  //clears all data in cache.
  logout() async {
    loggedIn = false;
    manager.emptyCache().whenComplete(() => print("deletedSuccessfuly"));
    PaintingBinding.instance.imageCache.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    changedWidget = Image.asset("resources/personicon.png");
    prefs.setStringList('userData', []);
    notifyListeners();
  }

  // checkPermissions() async {
  //   if (await Permission.location.status != PermissionStatus.granted) {
  //     print("not");
  //     Permission.location.request();
  //   } else {
  //     print("location granted");
  //   }
  // }
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
    //await checkPermissions();

    bool enabled = await Geolocator.isLocationServiceEnabled();
    print("enable locaiton : $enabled");
    var pos = await TrustLocation.getLatLong.catchError(((e) {
      print(e);
    }));

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

class User {
  String userToken;
  String userID;
  String name;
  int userSiteId;
  int userType;
  int userShiftId;
  String email;
  String phoneNum;
  String userJob;
  String password;
  String userImage;
  String id;

  User({
    this.userToken,
    this.id,
    this.userImage,
    this.userShiftId,
    this.userSiteId,
    this.userID,
    this.name,
    this.userJob,
    this.email,
    this.userType,
    this.phoneNum,
    this.password,
  });
}
