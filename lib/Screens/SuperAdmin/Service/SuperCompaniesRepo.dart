// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:qr_users/Screens/SuperAdmin/Service/SuperCompaniesModel.dart';
// import 'package:qr_users/constants.dart';

// class SuperCompaniesRepo {
//   Future<List<SuperCompaniesModel>> getSuperCompanies(String userToken,String adminId) async {
//     var response = await http.get(Uri.parse("$baseURL/api/Users/GetCompaniesforSuperAdmin/"), headers: {
//       'Authorization': "Bearer $userToken",
//       "Accept": "application/json"
//     });
//     if (response.statusCode == 200) {
//       List<SuperCompaniesModel> superComList = [];
//       var obJson = jsonDecode(response.body)['data'] as List;
//       superComList =
//           obJson.map((json) => SuperCompaniesModel.fromJson(json)).toList();
//       return superComList;
//     }
//     return [];
//   }
// }