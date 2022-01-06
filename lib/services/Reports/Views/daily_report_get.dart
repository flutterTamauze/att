import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import '../../Sites_data.dart';

getDailyReport(int siteIndex, String date, BuildContext context) async {
  int siteID;
  final userProvider = Provider.of<UserData>(context, listen: false);
  final comProvider = Provider.of<CompanyData>(context, listen: false);
  print("company id ${comProvider.com.id}");
  if (userProvider.user.userType == 2) {
    siteID = userProvider.user.userSiteId;
  } else {
    if (Provider.of<SiteShiftsData>(context, listen: false)
        .siteShiftList
        .isEmpty) {
      await Provider.of<SiteData>(context, listen: false)
          .getSitesByCompanyId(
        comProvider.com.id,
        userProvider.user.userToken,
        context,
      )
          .then((value) {
        print("SiteIndex $siteIndex");
      });
    }
    siteID = Provider.of<SiteShiftsData>(context, listen: false)
        .siteShiftList[siteIndex]
        .siteId;
  }
  print(siteID);
  print(date);
  await Provider.of<ReportsData>(context, listen: false)
      .getDailyReportUnits(userProvider.user.userToken, siteID, date, context);
}
