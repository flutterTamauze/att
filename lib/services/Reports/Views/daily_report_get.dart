import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import '../../../main.dart';
import '../../Sites_data.dart';

getDailyReport(int siteIndex, String date, BuildContext context) async {
  int siteID;
  final userProvider = Provider.of<UserData>(context, listen: false);
  final comProvider = Provider.of<CompanyData>(context, listen: false);
  if (userProvider.user.userType == 2) {
    siteID = userProvider.user.userSiteId;
  } else {
    if (Provider.of<SiteShiftsData>(context, listen: false)
        .siteShiftList
        .isEmpty) {
      await locator.locator<SiteData>().getSitesByCompanyId(
            comProvider.com.id,
            userProvider.user.userToken,
            context,
          );
    }
    siteID = Provider.of<SiteShiftsData>(context, listen: false)
        .siteShiftList[siteIndex]
        .siteId;
  }
  await Provider.of<ReportsData>(context, listen: false)
      .getDailyReportUnits(userProvider.user.userToken, siteID, date, context);
}
