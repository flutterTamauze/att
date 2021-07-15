import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_users/services/user_data.dart';

class VacationData with ChangeNotifier {
  List<Vacation> vactionList = [
    Vacation(
        fromDate: DateFormat('yMMMd').format(DateTime.now()).toString(),
        toDate: DateFormat('yMMMd').format(DateTime.now()).toString(),
        vacationName: "عيد الفطر المبارك"),
    Vacation(
        fromDate: DateFormat('yMMMd')
            .format(DateTime(DateTime.now().year, DateTime.january, 1))
            .toString(),
        toDate: DateFormat('yMMMd').format(DateTime.now()).toString(),
        vacationName: "عيد العمال"),
    Vacation(
        fromDate: DateFormat('yMMMd')
            .format(DateTime(DateTime.now().year, DateTime.december, 1))
            .toString(),
        toDate: DateFormat('yMMMd').format(DateTime.now()).toString(),
        vacationName: "عيد تحرير سيناء")
  ];
  List<Vacation> copyVacationList = [
    Vacation(
        fromDate: DateFormat('yMMMd').format(DateTime.now()).toString(),
        toDate: DateFormat('yMMMd').format(DateTime.now()).toString(),
        vacationName: "عيد الفطر المبارك"),
    Vacation(
        fromDate: DateFormat('yMMMd')
            .format(DateTime(DateTime.now().year, DateTime.january, 1))
            .toString(),
        toDate: DateFormat('yMMMd').format(DateTime.now()).toString(),
        vacationName: "عيد العمال"),
    Vacation(
        fromDate: DateFormat('yMMMd')
            .format(DateTime(DateTime.now().year, DateTime.december, 1))
            .toString(),
        toDate: DateFormat('yMMMd').format(DateTime.now()).toString(),
        vacationName: "عيد تحرير سيناء")
  ];
  setCopy(int index) {
    copyVacationList.clear();
    copyVacationList.add(vactionList[index]);
  }
}

class Vacation {
  String vacationName;
  String fromDate;
  String toDate;
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
