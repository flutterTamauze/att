class SuperCompaniesModel {
  String companyName, companyImage;
  int companyId;
  SuperCompaniesModel({this.companyId, this.companyImage, this.companyName});

  factory SuperCompaniesModel.fromJson(json) {
    return SuperCompaniesModel(
        companyId: json["comid"],
        companyImage: json["comImg"],
        companyName: json["comName"]);
  }
}
