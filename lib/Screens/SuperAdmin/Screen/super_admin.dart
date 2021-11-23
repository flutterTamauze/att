import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SuperAdmin/widgets/SuperAdminTile.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';

import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';

class SuperAdminScreen extends StatefulWidget {
  @override
  _SuperAdminScreenState createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  getCompanyData(int comiD) async {
    var msg = await Provider.of<CompanyData>(context, listen: false)
        .getCompanyProfileApi(
            comiD,
            Provider.of<UserData>(context, listen: false).user.userToken,
            context);
    if (msg == "Success") {
      print("ana get b success");

      await Provider.of<ShiftsData>(context, listen: false).getShifts(
          Provider.of<CompanyData>(context, listen: false).com.id,
          Provider.of<UserData>(context, listen: false).user.userToken,
          context,
          4,
          0);
    }
  }

  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    UserData userProvider = Provider.of<UserData>(context, listen: false);
    CompanyData comProvider = Provider.of<CompanyData>(context, listen: false);
    var siteProv = Provider.of<SiteData>(context, listen: false);
    var memProv = Provider.of<MemberData>(context, listen: false);
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
                    SuperadminHeader(),
                    DirectoriesHeader(
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.0),
                            child: Lottie.asset("resources/CompanyLottie.json",
                                repeat: false),
                          ),
                        ),
                        "شركاتى"),
                    SizedBox(
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
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return RoundedLoadingIndicator();
                                        });
                                    await getCompanyData(userData
                                        .superCompaniesList[index].companyId);
                                    await Provider.of<SiteShiftsData>(context,
                                            listen: false)
                                        .getAllSitesAndShifts(
                                            comProvider.com.id,
                                            userData.user.userToken);
                                    await memProv.getAllCompanyMember(
                                        0,
                                        comProvider.com.id,
                                        userProvider.user.userToken,
                                        context,
                                        -1);
                                    print(
                                        "got company members for super admin");
                                    // await siteProv
                                    //     .getSitesByCompanyId(
                                    //   comProvider.com.id,
                                    //   userProvider.user.userToken,
                                    //   context,
                                    // )
                                    //     .then((value) {
                                    //   print("got sites for super admin");
                                    // });
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NavScreenTwo(0),
                                        ));
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
