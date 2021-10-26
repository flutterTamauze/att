import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import '../user_data.dart';

class Settings {
  resetMacAddress(BuildContext context, String userid) async {
    var memberData = Provider.of<MemberData>(context);
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
                var token = Provider.of<UserData>(context, listen: false)
                    .user
                    .userToken;
                if (await memberData.resetMemberMac(userid, token, context) ==
                    "Success") {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: "تم اعادة الضبط بنجاح",
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
              title: 'إعادة ضبط بيانات مستخدم',
              content: "هل تريد اعادة ضبط بيانات هاتف المستخدم؟");
        });
  }

  deleteUser(BuildContext context, String userId, int listIndex,
      String username) async {
    var memberData = Provider.of<MemberData>(context, listen: false);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: RoundedAlert(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return RoundedLoadingIndicator();
                      });
                  var token = Provider.of<UserData>(context, listen: false)
                      .user
                      .userToken;
                  if (await memberData.deleteMember(
                          userId, listIndex, token, context) ==
                      "Success") {
                    log("going to users screen");
                    await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UsersScreen(-1, false, ""),
                        )).then((value) => successfullDelete());
                  } else {
                    unSuccessfullDelete();
                  }
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                title: 'إزالة مستخدم',
                content: "هل تريد إزالة $username ؟"),
          );
        });
  }

  int getsiteIndex(BuildContext context, String sitename) {
    var list = Provider.of<SiteData>(context, listen: false).dropDownSitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (sitename == list[i].name) {
        return i;
      }
    }
    return -1;
  }
}
