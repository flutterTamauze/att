import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import '../../Sites_data.dart';

getDailyReport(int siteIndex, String date, BuildContext context) async {
  int siteID;
  var userProvider = Provider.of<UserData>(context, listen: false);
  var comProvider = Provider.of<CompanyData>(context, listen: false);
  if (userProvider.user.userType == 2) {
    if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
      await Provider.of<SiteData>(context, listen: false).getSpecificSite(
          userProvider.user.userSiteId, userProvider.user.userToken, context);
    }
  } else {
    if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
      await Provider.of<SiteData>(context, listen: false)
          .getSitesByCompanyId(
              comProvider.com.id, userProvider.user.userToken, context)
          .then((value) {
        siteID = Provider.of<SiteData>(context, listen: false)
            .sitesList[siteIndex]
            .id;
        print("SiteIndex $siteIndex");
      });
    } else {
      siteID =
          Provider.of<SiteData>(context, listen: false).sitesList[siteIndex].id;
    }
  }
  print(siteID);
  print(date);
  await Provider.of<ReportsData>(context, listen: false).getDailyReportUnits(
      userProvider.user.userToken,
      userProvider.user.userType == 2 ? userProvider.user.userSiteId : siteID,
      date,
      context);
}
