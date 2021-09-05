class ShiftSheduleModel {
  DateTime scheduleToTime, scheduleFromTime;
  List<int> scheduleShiftsNumber;
  int id;
  int originalShift;
  ShiftSheduleModel(
      {this.id,
      this.originalShift,
      this.scheduleFromTime,
      this.scheduleToTime,
      this.scheduleShiftsNumber});
  factory ShiftSheduleModel.fromJson(dynamic json) {
    return ShiftSheduleModel(
        id: json["id"],
        originalShift: json["originalShift"],
        scheduleFromTime: DateTime.tryParse(json["fromDate"]),
        scheduleToTime: DateTime.tryParse(json["toDate"]),
        scheduleShiftsNumber: [
          json["saturdayShift"],
          json["sunShift"],
          json["mondayShift"],
          json["tuesdayShift"],
          json["wednesdayShift"],
          json["thursdayShift"],
          json["fridayShift"],
        ]);
  }
}
