import 'package:flutter/cupertino.dart';

class Shift {
  String shiftName;
  int shiftStartTime;
  int shiftEndTime;
  int sunShiftstTime,
      sunShiftenTime,
      monShiftstTime,
      mondayShiftenTime,
      tuesdayShiftstTime,
      tuesdayShiftenTime,
      wednesDayShiftstTime,
      wednesDayShiftenTime,
      thursdayShiftstTime,
      thursdayShiftenTime,
      fridayShiftstTime,
      fridayShiftenTime;
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
      @required this.siteID,
      @required this.fridayShiftenTime,
      @required this.fridayShiftstTime,
      @required this.monShiftstTime,
      @required this.mondayShiftenTime,
      @required this.sunShiftenTime,
      @required this.sunShiftstTime,
      @required this.thursdayShiftenTime,
      @required this.thursdayShiftstTime,
      @required this.tuesdayShiftenTime,
      @required this.tuesdayShiftstTime,
      @required this.wednesDayShiftenTime,
      @required this.wednesDayShiftstTime});

  factory Shift.fromJsonQR(dynamic json) {
    return Shift(
        shiftName: json['shiftName'],
        shiftStartTime: int.parse(json['shiftSttime']),
        shiftEndTime: int.parse(json['shiftEntime']),
        shiftQrCode: json['shiftQrcode'],
        shiftId: json['id'] as int,
        shiftType: json['type'] as bool,
        siteID: json['siteId'] as int);
  }
  factory Shift.fromJson(dynamic json) {
    return Shift(
        fridayShiftenTime: int.parse(json["fridayShiftEntime"]),
        fridayShiftstTime: int.parse(json["fridayShiftSttime"]),
        monShiftstTime: int.parse(json["monShiftSttime"]),
        mondayShiftenTime: int.parse(json["mondayShiftEntime"]),
        sunShiftenTime: int.parse(json["sunShiftEntime"]),
        sunShiftstTime: int.parse(json["sunShiftSttime"]),
        thursdayShiftenTime: int.parse(json["thursdayShiftEntime"]),
        thursdayShiftstTime: int.parse(json["thursdayShiftSttime"]),
        tuesdayShiftenTime: int.parse(json["tuesdayShiftEntime"]),
        tuesdayShiftstTime: int.parse(json["tuesdayShiftSttime"]),
        wednesDayShiftenTime: int.parse(json["wednesdayShiftEntime"]),
        wednesDayShiftstTime: int.parse(json["wednesdayShiftSttime"]),
        shiftName: json['shiftName'],
        shiftStartTime: int.parse(json['shiftSttime']),
        shiftEndTime: int.parse(json['shiftEntime']),
        shiftQrCode: json['shiftQrcode'],
        shiftId: json['id'] as int,
        shiftType: json['type'] as bool,
        siteID: json['siteId'] as int);
  }
}
