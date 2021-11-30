class CompanyMissions {
  int id;
  DateTime fromdate;
  DateTime toDate;
  String userName;
  String sitename;
  String shiftName;
  int typeId;

  CompanyMissions(
      {this.id,
      this.typeId,
      this.fromdate,
      this.toDate,
      this.userName,
      this.sitename,
      this.shiftName});

  CompanyMissions.fromJsonInternal(Map<String, dynamic> json) {
    id = json['id'];
    fromdate = DateTime.tryParse(json['fromdate']);
    toDate = DateTime.tryParse(json['toDate']);
    userName = json['userName'];
    sitename = json['sitename'];
    shiftName = json['shiftName'];
  }
  CompanyMissions.fromJsonExternal(Map<String, dynamic> json) {
    id = json['id'];
    fromdate = DateTime.tryParse(json['fromdate']);
    toDate = DateTime.tryParse(json['toDate']);
    userName = json['userName'];
  }
}
