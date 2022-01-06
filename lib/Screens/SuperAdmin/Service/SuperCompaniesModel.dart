class SuperCompaniesModel {
  String companyName;
  int companyId;
  SuperCompaniesModel({this.companyId, this.companyName});

  factory SuperCompaniesModel.fromJson(json) {
    return SuperCompaniesModel(
        companyId: json["companyId"], companyName: json["companyName"]);
  }
}

class SuperCompaniesChartModel {
  int totalEmp,
      totalPermessions,
      totalHolidays,
      totalAttend,
      totalAbsent,
      totalExternalMissions;
  bool isHoliday, isOfficialVac;
  double totalAttendRatio,
      totalAbsentRatio,
      totalHolidaysRatio,
      totalExternalMissionRatio;
  SuperCompaniesChartModel(
      {this.totalAbsentRatio,
      this.totalAttendRatio,
      this.totalEmp,
      this.totalExternalMissionRatio,
      this.totalHolidays,
      this.totalPermessions,
      this.totalAbsent,
      this.totalAttend,
      this.totalExternalMissions,
      this.totalHolidaysRatio,
      this.isHoliday,
      this.isOfficialVac});
  factory SuperCompaniesChartModel.fromJson(json) {
    return SuperCompaniesChartModel(
        totalAbsentRatio: json["totalAbsentRatio"] + 0.0 as double,
        totalAttendRatio: json["totalAttendRatio"] + 0.0 as double,
        totalExternalMissionRatio:
            json["totalExternalMissionsRatio"] + 0.0 as double,
        totalHolidays: json["totalHolidays"],
        totalAbsent: json["totalAbsent"],
        totalAttend: json["totalAttend"],
        totalExternalMissions: json["totalExternalMissions"],
        totalHolidaysRatio: json["totalHolidaysRatio"] + 0.0 as double,
        totalPermessions: json["totalPermissions"],
        isHoliday: json["isHoliday"],
        isOfficialVac: json["isOfficialVacation"],
        totalEmp: json["totalEmployee"]);
  }
}
