class Shift {
  String shiftName,
      shiftFromStartTime,
      shiftFromEndTime,
      shiftToStartTime,
      shiftToEndTime;
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
      {this.shiftName,
      this.shiftStartTime,
      this.shiftEndTime,
      this.shiftQrCode,
      this.shiftType,
      this.shiftId,
      this.siteID,
      this.fridayShiftenTime,
      this.fridayShiftstTime,
      this.monShiftstTime,
      this.mondayShiftenTime,
      this.sunShiftenTime,
      this.sunShiftstTime,
      this.thursdayShiftenTime,
      this.thursdayShiftstTime,
      this.tuesdayShiftenTime,
      this.tuesdayShiftstTime,
      this.wednesDayShiftenTime,
      this.wednesDayShiftstTime,
      this.shiftFromEndTime,
      this.shiftFromStartTime,
      this.shiftToEndTime,
      this.shiftToStartTime});

  factory Shift.fromJsonQR(dynamic json) {
    return Shift(
        shiftName: json['shiftName'],
        shiftQrCode: json['shiftQRCode'],
        shiftFromStartTime: json["shiftFromStartTime"],
        shiftToStartTime: json["shiftToStartTime"],
        shiftToEndTime: json["shiftToEndTime"],
        shiftFromEndTime: json["shiftFromEndTime"]);
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
