import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_data.dart';

class Settings {
  activatePrivacyPolicy() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool('appPolicy', true);
  }

  displayAppPrivacyPolicy(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ZoomIn(
            child: WillPopScope(
              onWillPop: () {
                Fluttertoast.showToast(
                  msg: getTranslated(context,
                      'يجب ان توافق على شروط Chilango حتى يمكنك الأستمرار'),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.orange,
                  fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
                );
                return Future.value(false);
              },
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15.0)), //this right here
                  child: SingleChildScrollView(
                    child: Container(
                      height: getkDeviceHeightFactor(context, 600),
                      width: getkDeviceWidthFactor(context, 500),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),
                          Image.asset(
                            appLogo,
                            width: 70.w,
                            height: 70.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                PolicyCards(
                                  policyTitle: getTranslated(context,
                                      "يجمع chilango بيانات الموقع الخاصة بك لتسجيل الحضور و الإنصراف يوميا"),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                PolicyCards(
                                  policyTitle: getTranslated(context,
                                      'يصل Chilango إلى جهات الإتصال لديك فى حالة كنت أدمن او موارد بشرية من أجل إضافة موظف من جهة الإتصال'),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                PolicyCards(
                                  policyTitle: getTranslated(context,
                                      'يأخذ Chilango صورتك الشخصية ويستخدمها إذا كنت تسجل حضورك اليومي بطريقة البطاقة ليتم الرجوع إليها عند الحاجة في التقارير'),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                PolicyCards(
                                  policyTitle: getTranslated(context,
                                      "يتصل Chilango بالكاميرا لإلتقاط صورة لك عنذ إنشاء الحساب للمرة الأولى و عند مسح الكود"),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                                PolicyCards(
                                    policyTitle: getTranslated(context,
                                        "يرسل لك Chilango إشعارات عند الحاجة")),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: RoundedButton(
                                title: getTranslated(context, 'موافق'),
                                onPressed: () async {
                                  displayToast(context, 'تمت الموافقة');
                                  await activatePrivacyPolicy();
                                  Navigator.pop(context);
                                }),
                          )
                        ],
                      ),
                    ),
                  )),
            ),
          );
        });
  }

  resetMacAddress(BuildContext context, String userid) async {
    final memberData = Provider.of<MemberData>(context);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedAlert(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                final token = Provider.of<UserData>(context, listen: false)
                    .user
                    .userToken;
                if (await memberData.resetMemberMac(userid, context) ==
                    "Success") {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: getTranslated(context, "تم اعادة الضبط بنجاح"),
                    gravity: ToastGravity.CENTER,
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "خطأ في اعادة الضبط",
                    gravity: ToastGravity.CENTER,
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.black,
                    fontSize: 16.0,
                  );
                }
                Navigator.pop(context);
                Navigator.pop(context);
              },
              title: getTranslated(context, 'إعادة ضبط بيانات مستخدم'),
              content: getTranslated(
                  context, "هل تريد اعادة ضبط بيانات هاتف المستخدم؟"));
        });
  }

  deleteUser(BuildContext context, String userId, int listIndex,
      String username) async {
    final memberData = Provider.of<MemberData>(context, listen: false);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedAlert(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                final token = Provider.of<UserData>(context, listen: false)
                    .user
                    .userToken;
                if (await memberData.deleteMember(userId, listIndex, context) ==
                    "Success") {
                  successfullDelete(context);
                  log("going to users screen");
                  await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsersScreen(-1, false, ""),
                      ));
                } else {
                  unSuccessfullDelete(context);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              },
              title: getTranslated(context, 'إزالة مستخدم'),
              content: "${getTranslated(context, "هل تريد إزالة")}$username ؟");
        });
  }

  int getsiteIndex(BuildContext context, String sitename) {
    final list = Provider.of<SiteShiftsData>(context, listen: false).sites;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (sitename == list[i].name) {
        return i;
      }
    }
    return -1;
  }
}

class PolicyCards extends StatelessWidget {
  final String policyTitle;
  const PolicyCards({
    this.policyTitle,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AutoSizeText(policyTitle),
        ),
      ),
    );
  }
}
