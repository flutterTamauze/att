import 'package:flutter/material.dart';

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

class UserPermessions {
  String user;
  // User user;
  String permessionType;
  String date;
  String duration;
  UserPermessions({this.date, this.duration, this.permessionType, this.user});
}

class UserPermessionsData with ChangeNotifier {
  List<UserPermessions> permessionsList = [
    UserPermessions(
        user: "احمد محمود عبد الحميد",
        date: "6-6-2021",
        duration: "12AM",
        permessionType: "انصراف مبكر"),
    UserPermessions(
        user: "احمد رضوان  ",
        date: "6-6-2021",
        duration: "8AM",
        permessionType: "انصراف مبكر"),
    UserPermessions(
        user: "خالد كمال عبد المجيد",
        date: "6-9-2021",
        duration: "8AM",
        permessionType: "تأخير عن الحضور"),
    UserPermessions(
        user: "على صلاح",
        date: "6-6-2021",
        duration: "3PM",
        permessionType: "انصراف مبكر")
  ];
}
