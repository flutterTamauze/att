import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/AdminPanel/adminPanel.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserReport.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserShifts.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUsersOrders.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SuperAdmin/Service/SuperCompaniesRepo.dart';
import 'package:qr_users/Screens/SuperAdmin/widgets/SuperAdminTile.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/DaysOff.dart';

import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import '../../HomePage.dart';

class SuperAdminScreen extends StatefulWidget {
  @override
  _SuperAdminScreenState createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  SuperCompaniesRepo _superRepo = SuperCompaniesRepo();
  Future superCountries;
  @override
  void initState() {
    super.initState();
    superCountries = _superRepo.getSuperCompanies(
        Provider.of<UserData>(context, listen: false).user.userToken);
  }

  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Consumer<MemberData>(builder: (context, memberData, child) {
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
                    Header(
                      nav: false,
                      goUserMenu: false,
                      goUserHomeFromMenu:
                          Provider.of<UserData>(context, listen: false)
                                      .user
                                      .userType ==
                                  0
                              ? false
                              : true,
                    ),
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
                        child: FutureBuilder(
                            future: superCountries,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
                                );
                              }

                              return ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SuperAdminTile(
                                      compPicture: snapshot.data[index].comId,
                                      onTap: () {
                                        print(
                                          snapshot.data[index].id,
                                        );
                                      },
                                      title: snapshot.data[index].comName,
                                    );
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

  Future<bool> onWillPop() {
    if (Provider.of<UserData>(context, listen: false).user.userType != 0) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => NavScreenTwo(0)),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false);
    }
    return Future.value(false);
  }
}
