import 'package:flutter/cupertino.dart';

class Shift {
  String shiftName;
  int shiftStartTime;
  int shiftEndTime;
  bool shiftType;
  String shiftQrCode;
  int siteID;
  int shiftId;

  Shift(
      {@required this.shiftName,
      @required this.shiftStartTime,
      @required this.shiftEndTime,
      this.shiftQrCode,
      this.shiftType,
      @required this.shiftId,
      @required this.siteID});

  factory Shift.fromJson(dynamic json) {
    return Shift(
        shiftName: json['shiftName'],
        shiftStartTime: int.parse(json['shiftSttime']),
        shiftEndTime: int.parse(json['shiftEntime']),
        shiftQrCode: json['shiftQrcode'],
        shiftId: json['id'] as int,
        shiftType: json['type'] as bool,
        siteID: json['siteId'] as int);
  }
}
