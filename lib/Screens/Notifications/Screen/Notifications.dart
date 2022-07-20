import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'dart:ui' as ui;

import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';

import 'package:qr_users/MLmodule/db/SqlfliteDB.dart';
import 'package:qr_users/Screens/AdminPanel/adminPanel.dart';
import 'package:qr_users/Screens/AdminPanel/pending_company_permessions.dart';
import 'package:qr_users/Screens/AdminPanel/pending_company_vacations.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUsersOrders.dart';
import 'package:qr_users/Screens/Notifications/Widgets/NotificationOnTapDialog.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:qr_users/widgets/UserProfileImageWidget.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import '../Widgets/notifications_data.dart';
//  enum CategoriesNavigation {
//   HealthCare,
//   HegOmra,

// }
DatabaseHelper db = new DatabaseHelper();

class NotificationItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
      },
      child:
          Consumer<NotificationDataService>(builder: (context, value, child) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
              bottomLeft: const Radius.circular(35),
              topLeft: Radius.circular(35)),
          child: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width / 1.2,
            child: Column(
              children: [
                Card(
                  color: Colors.black,
                  elevation: 1,
                  child: Center(
                    child: Container(
                        width: 110.w,
                        height: 110.h,
                        child: const UserPrfileImageWidget()),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                ),
                Center(
                  child: AutoSizeText(
                    value.notification.length != 0
                        ? getTranslated(context, "الأشعارات")
                        : getTranslated(context, "لا يوجد اشعارات"),
                    style:
                        boldStyle.copyWith(color: ColorManager.backGroundColor),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.topCenter,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final notifiyProv = value.notification[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        child: InkWell(
                          onTap: () async {
                            await db.readMessage(1, notifiyProv.id);
                            value.readMessage(index);
                            switch (notifiyProv.category) {
                              case "vacation":
                                {
                                  Navigator.pop(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserOrdersView(
                                          selectedOrder: getTranslated(
                                              context, "الأجازات"),
                                          ordersList: [
                                            getTranslated(context, "الأجازات"),
                                            getTranslated(context, "الأذونات")
                                          ],
                                        ),
                                      ));
                                }
                                return;

                              case "vacationRequest":
                                {
                                  Navigator.pop(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PendingCompanyVacations(),
                                      ));
                                }
                                return;
                              case "permessionRequest":
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PendingCompanyPermessions(),
                                    ));
                                return;
                              case "permession":
                                {
                                  Navigator.pop(context);
                                  final userProvider =
                                      await Provider.of<UserData>(context,
                                          listen: false);
                                  Provider.of<UserPermessionsData>(context,
                                          listen: false)
                                      .getFutureSinglePermession(
                                          userProvider.user.id,
                                          userProvider.user.userToken);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserOrdersView(
                                          selectedOrder: getTranslated(
                                              context, "الأذونات"),
                                          ordersList: [
                                            getTranslated(context, "الأجازات"),
                                            getTranslated(context, "الأذونات")
                                          ],
                                        ),
                                      ));
                                }
                                return;
                              case "attend":
                                {
                                  // DateTime notifiTime = DateTime.parse(
                                  //     value.notification[index].dateTime);
                                  // int differenceBetweenDates = notifiTime
                                  //     .difference(DateTime.now())
                                  //     .inDays;

                                  // if (differenceBetweenDates == 0) {
                                  return showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return StackedNotificaitonAlert(
                                        notificationTitle: getTranslated(
                                            context, "اثبات حضور"),
                                        notificationContent: getTranslated(
                                            context,
                                            "برجاء اثبات حضورك قبل انتهاء الوقت المحدد"),
                                        roundedButtonTitle:
                                            getTranslated(context, "اثبات"),
                                        lottieAsset:
                                            "resources/notificationalarm.json",
                                        notificationToast: getTranslated(
                                            context, "تم اثبات الحضور بنجاح"),
                                        showToast: true,
                                        popWidget: false,
                                        isFromBackground: false,
                                        repeatAnimation: true,
                                      );
                                    },
                                  );
                                }
                            }
                            return;
                            // }
                          },
                          child: NotificationsData(
                            notificationTitle: notifiyProv.title,
                            notoficationSubtitle: notifiyProv.message,
                            datetime: notifiyProv.dateTime,
                            notifiTime: notifiyProv.timeOfMessage,
                            isSeen: notifiyProv.messageSeen,
                            notificationObj: notifiyProv,
                            serviceObj: value,
                            indeex: index,
                          ),
                        ),
                      );
                    },
                    itemCount: value.notification.length,
                  ),
                )),
                Provider.of<NotificationDataService>(context, listen: true)
                        .notification
                        .isEmpty
                    ? Container()
                    : const Divider(
                        thickness: 1,
                        color: Colors.white,
                      ),
                Provider.of<NotificationDataService>(context, listen: true)
                        .notification
                        .isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                            onTap: () async {
                              return showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Directionality(
                                      textDirection: ui.TextDirection.rtl,
                                      child: RoundedAlert(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            Provider.of<NotificationDataService>(
                                                    context,
                                                    listen: false)
                                                .clearNotifications();
                                            await db.clearNotifications();
                                          },
                                          content: getTranslated(
                                            context,
                                            "حذف الأشعارات",
                                          ),
                                          onCancel: () {},
                                          title: getTranslated(context,
                                              "هل تريد حذف كل الأشعارات؟")),
                                    );
                                  });
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.trash,
                              color: Colors.white,
                            )),
                      )
              ],
            ),
          ),
        );
      }),
    );
  }
}
