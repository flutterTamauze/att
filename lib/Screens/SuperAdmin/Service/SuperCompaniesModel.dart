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
      totalAttendRatio,
      totalAbsentRatio,
      totalExternalMissionRatio,
      totalPermessions,
      totalHolidays,
      totalAttend,
      totalAbsent,
      totalExternalMissions,
      totalHolidaysRatio;
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
      this.totalHolidaysRatio});
  factory SuperCompaniesChartModel.fromJson(json) {
    return SuperCompaniesChartModel(
        totalAbsentRatio: json["totalAbsentRatio"],
        totalAttendRatio: json["totalAttendRatio"],
        totalExternalMissionRatio: json["totalExternalMissionsRatio"],
        totalHolidays: json["totalHolidays"],
        totalAbsent: json["totalAbsent"],
        totalAttend: json["totalAttend"],
        totalExternalMissions: json["totalExternalMissions"],
        totalHolidaysRatio: json["totalHolidaysRatio"],
        totalPermessions: json["totalPermissions"],
        totalEmp: json["totalEmployee"]);
  }
}
