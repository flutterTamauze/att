// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/Network/networkInfo.dart';

import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_company_pie_chart.dart';
import 'package:qr_users/Screens/SuperAdmin/widgets/SuperAdminTile.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';

import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import '../../../Core/constants.dart';
import '../../../main.dart';

class SuperAdminScreen extends StatefulWidget {
  @override
  _SuperAdminScreenState createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  Future getCompanyData(int comiD) async {
    final msg = await Provider.of<CompanyData>(context, listen: false)
        .getCompanyProfileApi(
            comiD,
            Provider.of<UserData>(context, listen: false).user.userToken,
            context);

    if (msg is Faliure) {
      debugPrint("msg faliure ${msg.code} ${msg.errorResponse}");
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    final CompanyData comProvider =
        Provider.of<CompanyData>(context, listen: false);

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Consumer<UserData>(builder: (context, userData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///Title
                    const SuperAdminHeader(),
                    DirectoriesHeader(
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.0),
                            child: Lottie.asset("resources/CompanyLottie.json",
                                repeat: false),
                          ),
                        ),
                        getTranslated(context, "شركاتى")),
                    const SizedBox(
                      height: 20,
                    ),

                    ///List OF SITES
                    Expanded(
                        child: ListView.builder(
                            itemCount: userData.superCompaniesList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return SuperAdminTile(
                                  title: userData
                                      .superCompaniesList[index].companyName,
                                  onTap: () async {
                                    locator
                                        .locator<PermissionHan>()
                                        .anyDialogOpened = true;
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return RoundedLoadingIndicator();
                                        });
                                    await getCompanyData(userData
                                            .superCompaniesList[index]
                                            .companyId)
                                        .then((value) async {
                                      if (value.toString() == "Success") {
                                        Provider.of<SiteShiftsData>(context,
                                                listen: false)
                                            .getAllSitesAndShifts(
                                                comProvider.com.id,
                                                userData.user.userToken);
                                        await userData
                                            .getSuperCompanyChart(
                                                userData.user.userToken,
                                                comProvider.com.id)
                                            .then((value) {
                                          if (value == "Success") {
                                            locator
                                                .locator<PermissionHan>()
                                                .anyDialogOpened = false;
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SuperCompanyPieChart(),
                                                ));
                                          } else {
                                            errorToast(context);
                                          }
                                        });
                                      }
                                    });

                                    //here we add the PIE CHART SCREEN//
                                  });
                            }))
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
