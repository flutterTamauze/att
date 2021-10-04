import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'Widgets/display_pending_permessions.dart';

class PendingCompanyPermessions extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();
  PendingCompanyPermessions();
  String comment;
  @override
  Widget build(BuildContext context) {
    var pendingList = Provider.of<UserPermessionsData>(context);
    return GestureDetector(
      onTap: () {
        print(textEditingController.text);
      },
      child: Scaffold(
        endDrawer: NotificationItem(),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Header(
                nav: false,
                goUserMenu: false,
                goUserHomeFromMenu: false,
              ),
              SmallDirectoriesHeader(
                Lottie.asset("resources/calender.json", repeat: false),
                "طلبات الأذنات",
              ),
              Expanded(
                  child: pendingList.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.orange,
                          ),
                        )
                      : pendingList.pendingCompanyPermessions.length == 0
                          ? Center(
                              child: Text(
                              "لا يوجد اذنات لم يتم الرد عليها",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ))
                          : ListView.builder(
                              itemBuilder: (context, index) {
                                var pending = pendingList
                                    .pendingCompanyPermessions[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      ExpandedPendingPermessions(
                                        isAdmin: true,
                                        createdOn: pending.createdOn
                                            .toString()
                                            .substring(0, 11),
                                        date: pending.date
                                            .toString()
                                            .substring(0, 11),
                                        id: pending.permessionId,
                                        desc: pending.permessionDescription,
                                        permessionType: pending.permessionType,
                                        userName: pending.user.toString(),
                                        duration: pending.duration,
                                        onRefused: () {
                                          return showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Directionality(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  child:
                                                      RoundedAlertWithComment(
                                                    onTapped: (e) {
                                                      comment = e;
                                                    },
                                                    hint: "سبب الرفض",
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      String msg = await pendingList
                                                          .acceptOrRefusePendingPermession(
                                                              2,
                                                              pending
                                                                  .permessionId,
                                                              pending.userID,
                                                              pending
                                                                  .permessionDescription,
                                                              Provider.of<UserData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .user
                                                                  .userToken,
                                                              comment,
                                                              pending.date);

                                                      if (msg ==
                                                          "Success : User Updated!") {
                                                        HuaweiServices _huawei =
                                                            HuaweiServices();
                                                        if (pending.osType ==
                                                            3) {
                                                          await _huawei
                                                              .huaweiPostNotification(
                                                                  pending
                                                                      .fcmToken,
                                                                  "طلب اذن",
                                                                  "تم رفض طلب الأذن",
                                                                  "permession");
                                                        } else {
                                                          await sendFcmMessage(
                                                              category:
                                                                  "permession",
                                                              topicName: "",
                                                              userToken: pending
                                                                  .fcmToken,
                                                              title: "طلب اذن",
                                                              message:
                                                                  "تم رفض طلب الأذن");
                                                        }

                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "تم الرفض بنجاح",
                                                            backgroundColor:
                                                                Colors.green);
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg: "خطأ في الرفض",
                                                            backgroundColor:
                                                                Colors.red);
                                                      }
                                                    },
                                                    content: "تأكيد رفض الأذن",
                                                    onCancel: () {},
                                                    title:
                                                        "رفض  طلب ${pendingList.pendingCompanyPermessions[index].user} ",
                                                  ),
                                                );
                                              });
                                        },
                                        onAccept: () {
                                          return showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Directionality(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  child:
                                                      RoundedAlertWithComment(
                                                    onTapped: (comm) {
                                                      comment = comm;
                                                    },
                                                    hint: "التفاصيل",
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      String msg = await pendingList
                                                          .acceptOrRefusePendingPermession(
                                                              1,
                                                              pending
                                                                  .permessionId,
                                                              pending.userID,
                                                              pending
                                                                  .permessionDescription,
                                                              Provider.of<UserData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .user
                                                                  .userToken,
                                                              comment,
                                                              pending.date);

                                                      if (msg ==
                                                          "Success : User Updated!") {
                                                        HuaweiServices _huawei =
                                                            HuaweiServices();
                                                        if (pending.osType ==
                                                            3) {
                                                          await _huawei
                                                              .huaweiPostNotification(
                                                                  pending
                                                                      .fcmToken,
                                                                  "طلب اذن",
                                                                  "تم الموافقة على طلب الأذن",
                                                                  "permession");
                                                        } else {
                                                          await sendFcmMessage(
                                                              category:
                                                                  "permession",
                                                              topicName: "",
                                                              userToken: pending
                                                                  .fcmToken,
                                                              title: "طلب اذن",
                                                              message:
                                                                  "تم الموافقة على طلب الأذن");
                                                        }

                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "تم الموافقة بنجاح",
                                                            backgroundColor:
                                                                Colors.green);
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "خطأ في الموافقة",
                                                            backgroundColor:
                                                                Colors.red);
                                                      }
                                                    },
                                                    content:
                                                        "تأكيد الموافقة على الأذن",
                                                    onCancel: () {},
                                                    title:
                                                        "الموافقة على طلب ${pendingList.pendingCompanyPermessions[index].user} ",
                                                  ),
                                                );
                                              });
                                        },
                                      )
                                    ],
                                  ),
                                );
                              },
                              itemCount:
                                  pendingList.pendingCompanyPermessions.length,
                            ))
            ],
          ),
        ),
      ),
    );
  }
}
