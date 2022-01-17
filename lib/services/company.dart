import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:huawei_location/location/location.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/defaultClass.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:trust_location/trust_location.dart';

import '../Core/constants.dart';

class Company {
  String nameAr;
  String nameEn;
  int id;
  String logo;
  int legalComDate;
  String email;
  int companyUsers;
  int companySites;
  DateTime createdOn;
  String adminPhoneNumber;

  Company({
    this.createdOn,
    this.nameAr,
    this.nameEn,
    this.id,
    this.logo,
    this.legalComDate,
    this.email,
    this.companySites,
    this.companyUsers,
    this.adminPhoneNumber,
  });
  factory Company.fromJson(decodedRes) {
    return Company(
        id: decodedRes["data"]["id"],
        nameAr: decodedRes["data"]["nameAr"],
        nameEn: decodedRes["data"]["nameEn"],
        logo: "$imageUrl${decodedRes["data"]["logo"]}",
        email: decodedRes["data"]["companyEmail"] ?? "",
        companyUsers: decodedRes["data"]["companyUsers"],
        companySites: decodedRes["data"]["companySites"],
        createdOn: DateTime.tryParse(decodedRes["data"]["createdOn"]),
        legalComDate: decodedRes["data"]["monthStartDate"]);
  }
  factory Company.fromLogin(decodedRes) {
    return Company(
        id: decodedRes["companyData"]["id"],
        nameAr: decodedRes["companyData"]["nameAr"],
        logo: "$imageUrl${decodedRes["companyData"]["logo"]}",
        createdOn: DateTime.tryParse(decodedRes["companyData"]["createdOn"]),
        legalComDate: decodedRes["companyData"]["monthStartDate"]);
  }
}

class CompanyData extends ChangeNotifier {
  final _apiToken = 'ByYM000OLlMQG6VVVp1OH7Xzyr7gHuw1qvUC5dcGt3SNM';
  InheritDefault inheritDefault = InheritDefault();
  Position _currentPosition;
  Location _currentHawawiLocation;
  int companyId = -1;
  Company com = Company(
      id: 0,
      nameEn: "",
      nameAr: "",
      logo: "",
      email: "",
      legalComDate: 1,
      companySites: 0,
      companyUsers: 0);

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

  getCompanyDataFromLogin(decodedRes) {
    com = Company.fromLogin(decodedRes);

    notifyListeners();
  }

  getCompanyProfileApi(
      int companyId, String userToken, BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        DateTime preTime = DateTime.now();
        final response = await http.get(
            Uri.parse("$baseURL/api/Company/GetCompanyInfoById/$companyId"),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $userToken"
            });
        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final decodedRes = json.decode(response.body);
          print("COMPANY MSG }");
          print(decodedRes["message"]);
          if (decodedRes["message"] == "Success") {
            com = Company.fromJson(decodedRes);
            DateTime postTime = DateTime.now();
            print(
                "company data Request Code : ${response.statusCode} time : ${postTime.difference(preTime).inMilliseconds} ms ");
            notifyListeners();
            return "Success";
          } else if (decodedRes["message"] ==
              "Failed : user name and password not match ") {
            return "wrong";
          }
        }
        return "failed";
      } catch (e) {
        print(e);
      }
    } else {
      return 'noInternet';
    }
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
    //await checkPermissions();

    if (Platform.isAndroid) {
      HuaweiServices _huawei = HuaweiServices();
      bool isHawawi = false;
      if (Platform.isAndroid) {
        isHawawi = await _huawei.isHuaweiDevice();
      }

      bool enabled;
      if (isHawawi) {
        enabled = await Geolocator.isLocationServiceEnabled();
      }

      print("company");
      print("enable locaiton : $enabled");

      // && pos[0] != null
      if (isHawawi) {
        await _huawei.getHuaweiCurrentLocation().then((currentLoc) {
          _currentHawawiLocation = currentLoc;
        }).catchError((e) {
          print(e);
        });

        return 0;
      } else {
        if (enabled) {
          bool isMockLocation = await TrustLocation.isMockLocation;
          // bool isEmulator= await FlutterIsEmulator.isDeviceAnEmulatorOrASimulator;
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
    } else if (Platform.isIOS) {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      print("company");
      print("enable locaiton : $enabled");
      var pos = await TrustLocation.getLatLong;
      print("--------------${pos[0]}------------");
      // && pos[0] != null
      if (enabled) {
        bool isMockLocation = await detectJailBreak();

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

  Future<String> guestTokaen() async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http.post(
            Uri.parse("$baseURL/api/Authenticate/login"),
            body: json.encode(
              {"Username": "GUEST67", "Password": "Amh*1234"},
            ),
            headers: {
              'Content-type': 'application/json',
              'x-api-key': _apiToken
            });

        var decodedRes = json.decode(response.body);
        print(response.body);

        if (decodedRes["message"] == "Success : ") {
          return decodedRes["token"];
        } else if (decodedRes["message"] ==
            "Failed : user name and password not match ") {
          return "-2";
        } else if (decodedRes["message"] ==
            "Fail : This Company is suspended") {
          return "-4";
        }
      } catch (e) {
        print(e);
      }
      return "-3";
    } else {
      return "-1";
    }
  }

  // Future<String> addGuestCompany(
  //     {File image, Company company, BuildContext context}) async {
  //   String msg;
  //   if (await isConnectedToInternet()) {
  //     String guestToken = await guestTokaen();
  //     msg = await createCompany(
  //         image: image,
  //         company: company,
  //         context: context,
  //         guestToken: guestToken);

  //     if (msg == "Success") {
  //       msg = await getdefualtShiftAndCreateUser(
  //           guestToken, companyId, context, company);

  //       return msg;
  //     } else if (msg == "nameExists") {
  //       msg = "nameExists";
  //       return msg;
  //     }
  //   } else {
  //     msg = 'noInternet';
  //     return msg;
  //   }
  //   return msg;
  // }

  Future<String> createCompany(
      {File image,
      Company company,
      BuildContext context,
      String guestToken}) async {
    print(company.nameAr);
    print(company.nameEn);
    print(company.email);
    print(company.nameEn.replaceAll(" ", "").toUpperCase());
    print(company.adminPhoneNumber);

    print(image.lengthSync());
    String msg;
    if (await isConnectedToInternet()) {
      var stream = new http.ByteStream(Stream.castFrom(image.openRead()));
      var length = await image.length();
      var uri = Uri.parse("$baseURL/api/Company");

      var request = new http.MultipartRequest("POST", uri);
      Map<String, String> headers = {'Authorization': "Bearer $guestToken"};
      request.headers.addAll(headers);

      request.fields['NameAr'] = company.nameAr;
      request.fields['NameEn'] = company.nameEn;
      request.fields['NormalizedName'] =
          company.nameEn.replaceAll(" ", "").toUpperCase();

      var multipartFile = new http.MultipartFile('Logo', stream, length,
          filename: basename(image.path));
      request.files.add(multipartFile);
      request.fields['CompanyEmail'] = company.email;
      request.fields['AdminUserName'] = company.nameAr;
      request.fields['AdminPhoneNumber'] = company.adminPhoneNumber;

      await request.send().then((response) async {
        response.stream.transform(utf8.decoder).listen((value) async {
          print(value);
          Map<String, dynamic> responesDedoded = json.decode(value);

          if (responesDedoded['message'] == "Creat Company Success") {
            //companyId
            companyId = responesDedoded['data']['id'];
            msg = "Success";
            return msg;
          } else if (responesDedoded['message'] ==
              "Fail : The same Company name already exists") {
            print('nameExists');
            msg = "nameExists";
            return msg;
          }
        });
      }).catchError((e) {
        print(e);
      });
    } else {
      msg = 'noInternet';
    }
    return msg;
  }

  // getdefualtShiftAndCreateUser(String guestToken, int companyId,
  //     BuildContext context, Company company) async {
  //   final response = await http.get(
  //       Uri.parse(
  //           "$baseURL/api/Shifts/GetAllShiftInCompany?companyId=$companyId"),
  //       headers: {
  //         'Content-type': 'application/json',
  //         'Authorization': "Bearer $guestToken"
  //       });

  //   var decodedRes = json.decode(response.body);
  //   print(response.body);

  //   if (decodedRes["message"] == "Success") {
  //     var shiftObjJson = jsonDecode(response.body)['data'] as List;
  //     int defaultShiftID = shiftObjJson[0]['id'];
  //     var msg = await Provider.of<MemberData>(context, listen: false)
  //         .addMember(
  //             Member(
  //                 name: company.nameAr,
  //                 jobTitle: "ادمن",
  //                 phoneNumber: company.adminPhoneNumber,
  //                 email: company.email,
  //                 shiftId: defaultShiftID,
  //                 userType: 4),
  //             guestToken,
  //             context,
  //             "Admin")
  //         .then((value) async {
  //       return value;
  //     });
  //     return msg;
  //   }
  // }

  Future<String> editCompanyProfile(
      Company com, String token, BuildContext context) async {
    if (await isConnectedToInternet()) {
      try {
        final response = await http.put(
            Uri.parse("$baseURL/api/Users/UpdatePassword"),
            body: json.encode(
              {
                "NameAr": com.nameAr,
                "NameEn": com.nameEn,
                "CompanyEmail": com.email,
                "logo": com.logo
              },
            ),
            headers: {
              'Content-type': 'application/json',
              'Authorization': "Bearer $token"
            });

        var decodedRes = json.decode(response.body);
        print(response.body);
        print(decodedRes["message"]);
        if (response.statusCode == 401) {
          await inheritDefault.login(context);
          await editCompanyProfile(com, token, context);
        }
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

  Future<String> uploadImage(File _image, String token) async {
    String data = "";
    print("uploading image....");

    var stream = new http.ByteStream(Stream.castFrom(_image.openRead()));
    var length = await _image.length();

    var uri = Uri.parse("$baseURL/api/Company/${com.id}");

    var request = new http.MultipartRequest("PUT", uri);
    request.headers.addAll({'Authorization': "Bearer $token"});
    var multipartFile = new http.MultipartFile('logo', stream, length,
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

  Future<String> updateProfileImgFile(String imgPath, String token) async {
    File _image = File(imgPath);
    print(_image.lengthSync());
    var url = "";

    if (await isConnectedToInternet()) {
      await uploadImage(_image, token).then((value) async {
        if (value != "") {
          print("path :$value");
          url = "$baseURL/$value";
          print("lunch url $url");
          com.logo = url;
          print("success =  $value");

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
}
