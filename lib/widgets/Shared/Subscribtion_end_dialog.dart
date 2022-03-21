import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/CompanySettings/companySettings.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/roundedButton.dart';

class DisplaySubscrtibitionEndDialog extends StatelessWidget {
  const DisplaySubscrtibitionEndDialog({
    Key key,
    @required CompanySettingsService companyService,
  })  : _companyService = companyService,
        super(key: key);

  final CompanySettingsService _companyService;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Dialog(
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)), //this right here
          child: Container(
            height: 200.h,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                  AutoSizeText(
                    getTranslated(context, "تنبية !"),
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: setResponsiveFontSize(18),
                        fontWeight: FontWeight.bold),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        getTranslated(context,
                            "نعتذر لقد تم انتهاء اشتراك الشركة بتاريخ"),
                        style: TextStyle(
                            fontSize: setResponsiveFontSize(16),
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      AutoSizeText(
                        _companyService.suspentionTime
                            .toString()
                            .substring(0, 11),
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: setResponsiveFontSize(15),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      RoundedButton(
                          title: getTranslated(context, "إغلاق"),
                          onPressed: () async {
                            try {
                              var userData =
                                  Provider.of<UserData>(context, listen: false);

                              if (userData.user.userType == 3 ||
                                  userData.user.userType == 4 ||
                                  userData.isSuperAdmin) {
                                final FirebaseMessaging _firebaseMessaging =
                                    FirebaseMessaging.instance;
                                bool isError = false;
                                await _firebaseMessaging
                                    .getToken()
                                    .catchError((e) {
                                  print(e);
                                  isError = true;
                                });
                                if (isError == false) {
                                  print("topic name : ");
                                  print(
                                      "attend${Provider.of<CompanyData>(context, listen: false).com.id}");
                                  await _firebaseMessaging.unsubscribeFromTopic(
                                      "attend${Provider.of<CompanyData>(context, listen: false).com.id}");
                                }
                              }
                            } catch (e) {
                              print(e);
                            }

                            Provider.of<UserData>(context, listen: false)
                                .logout();

                            Provider.of<SiteShiftsData>(context, listen: false)
                                .shifts = [];

                            // Phoenix.rebirth(context);
                          })
                    ],
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
