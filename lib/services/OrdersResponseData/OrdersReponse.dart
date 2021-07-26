import 'package:flutter/material.dart';

class OrderData {
  String statusResponse, date, comments, adminComment;

  int status; //0=>hold , 1=>accepted , -1 => rejected
  List<DateTime> vacationDaysCount;
  String vacationReason;
  String orderNumber;
  OrderData(
      {this.status,
      this.comments,
      this.vacationDaysCount,
      this.vacationReason,
      this.adminComment,
      this.date,
      this.statusResponse,
      this.orderNumber});
}

class OrderDataProvider with ChangeNotifier {
  List<OrderData> ordersList = [
    OrderData(
        statusResponse: "تم قبول الأجازة",
        comments: "محتاج اجازة ضرورى",
        status: 1,
        vacationReason: "مرضى",
        vacationDaysCount: [
          DateTime.now(),
          DateTime.now().add(Duration(days: 1))
        ],
        orderNumber: "12345",
        date: "21/2/2021"),
    OrderData(
        comments: "اريد اجازة و شكرا",
        vacationReason: "مرضى",
        statusResponse: "تم قبول الأجازة",
        vacationDaysCount: [
          DateTime.now(),
          DateTime.now().add(Duration(days: 1))
        ],
        status: 1,
        orderNumber: "10293",
        date: "21/2/2021"),
    OrderData(
        statusResponse: "تم رفض الأجازة",
        vacationReason: "عارضة",
        vacationDaysCount: [
          DateTime.now(),
          DateTime.now().add(Duration(days: 3))
        ],
        status: -1,
        orderNumber: "14922",
        adminComment: "تم الرفض بسبب ضغط العمل",
        date: "30/6/2021"),
    OrderData(
        status: 0,
        date: "30/2/2021",
        orderNumber: "9998",
        vacationDaysCount: [
          DateTime.now(),
          DateTime.now().add(Duration(days: 2))
        ],
        vacationReason: "سفر"),
  ];
}
