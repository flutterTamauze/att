import 'package:qr_users/services/FuturedScheduleShift.dart';

class ShiftSheduleModel {
  DateTime scheduleToTime, scheduleFromTime;
  List<int> scheduleShiftsNumber;
  List<int> scheduleSiteNumber;
  int id;
  int originalShift, originalSite;
  FutureShiftSchedule satShift,
      sunShift,
      monShift,
      tuesShift,
      wednShift,
      thurShift,
      friShift;
  ShiftSheduleModel(
      {this.id,
      this.originalShift,
      this.scheduleFromTime,
      this.scheduleToTime,
      this.originalSite,
      this.satShift,
      this.scheduleSiteNumber,
      this.friShift,
      this.monShift,
      this.sunShift,
      this.thurShift,
      this.wednShift,
      this.tuesShift,
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
  factory ShiftSheduleModel.futuredSchedule(json) {
    return ShiftSheduleModel(
      id: json["scheduleId"],
      originalShift: json["originalShiftId"] as int,
      scheduleFromTime: DateTime.tryParse(json["fromDate"]),
      scheduleToTime: DateTime.tryParse(json["toDate"]),
      originalSite: json["orginalSiteId"],
      scheduleSiteNumber: [
        json["satSiteId"],
        json["sundaySite"],
        json["mondaySite"],
        json["tuesdaySite"],
        json["wedSiteId"],
        json["thursdaySite"],
        json["fridaySite"],
      ],
      scheduleShiftsNumber: [
        json["saturdayShift"],
        json["sundayShift"],
        json["mondayShift"],
        json["tuesdayShift"],
        json["wednesdayShift"],
        json["thursdayShift"],
        json["fridayShift"],
      ],
      satShift: FutureShiftSchedule.fromJson(
        json["satShifts"],
      ),
      sunShift: FutureShiftSchedule.fromJson(
        json["sunShift"],
      ),
      monShift: FutureShiftSchedule.fromJson(
        json["monday"],
      ),
      tuesShift: FutureShiftSchedule.fromJson(
        json["tuesday"],
      ),
      wednShift: FutureShiftSchedule.fromJson(
        json["wednesday"],
      ),
      thurShift: FutureShiftSchedule.fromJson(
        json["thursday"],
      ),
      friShift: FutureShiftSchedule.fromJson(
        json["friday"],
      ),
    );
  }
}
