class ShiftSheduleModel {
  DateTime scheduleToTime, scheduleFromTime;
  List<int> scheduleShiftsNumber;
  List<int> scheduleSiteNumber;
  int id;
  int originalShift, originalSite;
  ShiftSheduleModel(
      {this.id,
      this.originalShift,
      this.scheduleFromTime,
      this.scheduleToTime,
      this.originalSite,
      this.scheduleSiteNumber,
      this.scheduleShiftsNumber});
  factory ShiftSheduleModel.fromJson(json) {
    return ShiftSheduleModel(
      id: json["id"],
      originalShift: json["originalShift"],
      scheduleFromTime: DateTime.tryParse(json["fromDate"]),
      scheduleToTime: DateTime.tryParse(json["toDate"]),
      originalSite: json["OriginalSiteId"],
      scheduleSiteNumber: [
        json["satSiteId"],
        json["sunSiteId"],
        json["monSiteId"],
        json["tueSiteId"],
        json["wedSiteId"],
        json["thursSiteId"],
        json["fridaySiteId"],
      ],
      scheduleShiftsNumber: [
        json["saturdayShift"],
        json["sunShift"],
        json["mondayShift"],
        json["tuesdayShift"],
        json["wednesdayShift"],
        json["thursdayShift"],
        json["fridayShift"],
      ],
    );
  }
}
