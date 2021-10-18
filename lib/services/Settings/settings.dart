import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import '../user_data.dart';

class Settings {
  resetMacAddress(BuildContext context, Member user) async {
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
                if (await memberData.resetMemberMac(user.id, token, context) ==
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

  deleteUser(BuildContext context, Member user, int listIndex) async {
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
                if (await memberData.deleteMember(
                        user.id, listIndex, token, context) ==
                    "Success") {
                  Navigator.pop(context);
                  successfullDelete();
                } else {
                  unSuccessfullDelete();
                }
                Navigator.pop(context);
                Navigator.pop(context);
              },
              title: 'إزالة مستخدم',
              content: "هل تريد إزالة${user.name} ؟");
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
