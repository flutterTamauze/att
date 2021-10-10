class SuperCompaniesModel {
  String companyName;
  int companyId;
  SuperCompaniesModel({this.companyId, this.companyName});

  factory SuperCompaniesModel.fromJson(json) {
    return SuperCompaniesModel(
        companyId: json["companyId"], companyName: json["companyName"]);
  }
}
