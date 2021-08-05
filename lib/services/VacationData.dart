import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_users/constants.dart';

class VacationData with ChangeNotifier {
  List<Vacation> vactionList = [
    Vacation(
        fromDate: DateTime.now().subtract(Duration(days: 4)),
        toDate: DateTime.now().subtract(Duration(days: 2)),
        vacationName: "عيد الفطر المبارك"),
    Vacation(
        fromDate: DateTime.now().subtract(Duration(days: 4)),
        toDate: DateTime.now().subtract(Duration(days: 2)),
        vacationName: "عيد العمال"),
    Vacation(
        fromDate: DateTime.now().subtract(Duration(days: 3)),
        toDate: DateTime.now().subtract(Duration(days: 1)),
        vacationName: "عيد تحرير سيناء")
  ];
  List<Vacation> copyVacationList = [
    Vacation(
        fromDate: DateTime.now().subtract(Duration(days: 4)),
        toDate: DateTime.now().subtract(Duration(days: 2)),
        vacationName: "عيد الفطر المبارك"),
    Vacation(
        fromDate: DateTime.now().subtract(Duration(days: 4)),
        toDate: DateTime.now().subtract(Duration(days: 2)),
        vacationName: "عيد العمال"),
    Vacation(
        fromDate: DateTime.now().subtract(Duration(days: 3)),
        toDate: DateTime.now().subtract(Duration(days: 1)),
        vacationName: "عيد تحرير سيناء")
  ];
  removeVacation(Vacation vacation) {
    vactionList.remove(vacation);
    notifyListeners();
  }

  updateVacation(int vacationIndex, Vacation vacation) {
    vactionList.removeAt(vacationIndex);
    vactionList.insert(vacationIndex, vacation);
    notifyListeners();
    print("updated successfully");
  }

  setCopy(int index) {
    copyVacationList.clear();
    copyVacationList.add(vactionList[index]);
  }
}

class Vacation {
  String vacationName;
  DateTime fromDate;
  DateTime toDate;
  Vacation({this.fromDate, this.toDate, this.vacationName});
}
