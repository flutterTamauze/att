import 'package:flutter/material.dart';

class OrderData {
  String statusResponse, date, comments;
  bool accepted = false;
  OrderData({this.accepted, this.comments, this.date, this.statusResponse});
}

class OrderDataProvider with ChangeNotifier {
  List<OrderData> ordersList = [
    OrderData(
        statusResponse: "تم قبول الأجازة",
        comments: "تم القبول و نتمنى اجازة سعيدة لحضراتكم",
        accepted: true,
        date: "21/2/2021"),
    OrderData(
        statusResponse: "تم رفض الأجازة",
        comments: "تم رفض الأجازة نظرا لضغط العمل",
        accepted: false,
        date: "30/6/2021"),
  ];
}
