import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/Core/constants.dart';

class VacationData with ChangeNotifier {
  List<Vacation> vactionList = [];
  var isLoading = false;
  List<Vacation> copyVacationList = [];
  removeVacation(Vacation vacation) {
    vactionList.remove(vacation);
    notifyListeners();
  }

  Future<String> deleteVacationById(
      String token, int id, int vacationIndex) async {
    isLoading = true;
    notifyListeners();
    final response = await http.delete(
      Uri.parse("$baseURL/api/OfficialVacations/Del_OfficialVacationbyId/$id"),
      headers: {
        'Content-type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );
    isLoading = false;
    vactionList.removeAt(vacationIndex);

    debugPrint(response.statusCode.toString());
    notifyListeners();
    return jsonDecode(response.body)["message"];
  }

  Future<String> addVacation(
      Vacation vacation, String token, int companyId, int vacationCount) async {
    isLoading = true;
    notifyListeners();
    final response = await http.post(
        Uri.parse("$baseURL/api/OfficialVacations/Add/$vacationCount"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $token"
        },
        body: json.encode({
          "companyId": companyId,
          "name": vacation.vacationName,
          "date": vacation.vacationDate.toIso8601String()
        }));
    isLoading = false;

    vactionList.add(vacation);
    notifyListeners();
    return jsonDecode(response.body)["message"];
  }

  Future<String> updateVacation(
      int vacationIndex, Vacation vacation, String token) async {
    isLoading = true;
    notifyListeners();
    final response = await http.put(
        Uri.parse("$baseURL/api/OfficialVacations/Edit/${vacation.vacationId}"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $token"
        },
        body: json.encode({
          "id": vacation.vacationId,
          "name": vacation.vacationName,
          "date": vacation.vacationDate.toIso8601String()
        }));
    isLoading = false;
    vactionList.removeAt(vacationIndex);

    vactionList.insert(vacationIndex, vacation);
    notifyListeners();
    return jsonDecode(response.body)["message"];
  }

  setCopy() {
    copyVacationList = [];

    copyVacationList = vactionList;

    notifyListeners();
  }

  setCopyByIndex(int index) {
    debugPrint(vactionList.length.toString());
    copyVacationList = [];

    copyVacationList.add(vactionList[index]);

    notifyListeners();
  }

  getOfficialVacations(int companyId, String token) async {
    vactionList = [];
    isLoading = true;
    debugPrint(DateTime.now().year.toString());
    notifyListeners();
    final response = await http.get(
        Uri.parse(
            "$baseURL/api/OfficialVacations/GetAllVacationsByCompanyId/$companyId/${DateTime.now().year}"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $token"
        });
    final decodedRes = json.decode(response.body);
    isLoading = false;
    if (jsonDecode(response.body)["message"] == "Success") {
      final vacObjJson = jsonDecode(response.body)['data'] as List;
      vactionList = vacObjJson.map((json) => Vacation.fromJson(json)).toList();
      copyVacationList = vactionList;

      notifyListeners();
    }

    notifyListeners();
  }
}

class Vacation {
  String vacationName;
  int vacationId;
  DateTime vacationDate;

  Vacation({this.vacationName, this.vacationDate, this.vacationId});

  factory Vacation.fromJson(dynamic json) {
    return Vacation(
        vacationId: json["id"],
        vacationDate: DateTime.tryParse(json["date"]),
        vacationName: json["name"]);
  }
}
