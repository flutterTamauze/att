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

  factory Shift.fromJson(dynamic json) {
    return Shift(
        fridayShiftenTime: json["FridayShiftSttime"],
        fridayShiftstTime: json["FridayShiftEntime"],
        monShiftstTime: json["MonShiftSttime"],
        mondayShiftenTime: json["MondayShiftEntime"],
        sunShiftenTime: json["SunShiftSttime"],
        sunShiftstTime: json["SunShiftEntime"],
        thursdayShiftenTime: json["ThursdayShiftSttime"],
        thursdayShiftstTime: json["ThursdayShiftEntime"],
        tuesdayShiftenTime: json["TuesdayShiftSttime"],
        tuesdayShiftstTime: json["TuesdayShiftEntime"],
        wednesDayShiftenTime: json["WednesdayShiftSttime"],
        wednesDayShiftstTime: json["WednesdayShiftEntime"],
        shiftName: json['shiftName'],
        shiftStartTime: int.parse(json['shiftSttime']),
        shiftEndTime: int.parse(json['shiftEntime']),
        shiftQrCode: json['shiftQrcode'],
        shiftId: json['id'] as int,
        shiftType: json['type'] as bool,
        siteID: json['siteId'] as int);
  }
}
