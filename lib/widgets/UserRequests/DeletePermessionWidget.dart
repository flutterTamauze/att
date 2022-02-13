import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';

import '../roundedAlert.dart';

class RemovePermession extends StatelessWidget {
  final int permId, index;

  const RemovePermession({Key key, this.permId, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedAlert(
                onPressed: () async {
                  Navigator.pop(context);
                  final String msg = await Provider.of<UserPermessionsData>(
                          context,
                          listen: false)
                      .deleteUserPermession(
                          int.parse(permId.toString()),
                          Provider.of<UserData>(context, listen: false)
                              .user
                              .userToken,
                          index);

                  if (msg == "Success : Permission Deleted!") {
                    Fluttertoast.showToast(
                        msg: getTranslated(
                            navigatorKey.currentState.overlay.context,
                            "تم الحذف بنجاح"),
                        backgroundColor: Colors.green);
                  } else {
                    Fluttertoast.showToast(
                        msg: getTranslated(
                            navigatorKey.currentState.overlay.context,
                            "خطأ في الحذف"),
                        backgroundColor: Colors.red);
                  }
                },
                content: getTranslated(
                  context,
                  "هل تريد حذف الطلب",
                ),
                onCancel: () {},
                title: getTranslated(context, "حذف الطلب"),
              );
            });
      },
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2, color: Colors.red)),
        child: const Icon(
          FontAwesomeIcons.times,
          color: Colors.red,
          size: 15,
        ),
      ),
    );
  }
}
