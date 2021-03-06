import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'dart:ui' as ui;

import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';

import 'package:qr_users/MLmodule/db/SqlfliteDB.dart';
import 'package:qr_users/Screens/AdminPanel/adminPanel.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUsersOrders.dart';
import 'package:qr_users/Screens/Notifications/NotificationOnTapDialog.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:qr_users/widgets/UserProfileImageWidget.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
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
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35), topLeft: Radius.circular(35)),
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
                        child: UserPrfileImageWidget()),
                  ),
                ),
                Divider(
                  color: Colors.white,
                ),
                Center(
                  child: Text(
                    value.notification.length != 0
                        ? "??????????????????"
                        : getTranslated(context, "???? ???????? ??????????????"),
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.topCenter,
                  child: ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    primary: true,
                    itemBuilder: (context, index) {
                      var notifiyProv = value.notification[index];

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 3),
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
                                          selectedOrder: "????????????????",
                                        ),
                                      ));
                                }
                                return;

                              case "vacationRequest":
                              case "permessionRequest":
                                {
                                  Navigator.pop(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AdminPanel()));
                                }
                                return;

                              case "permession":
                                {
                                  Navigator.pop(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserOrdersView(
                                          selectedOrder: "????????????????",
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
                                        notificationTitle: "?????????? ????????",
                                        notificationContent:
                                            "?????????? ?????????? ?????????? ?????? ???????????? ?????????? ????????????",
                                        roundedButtonTitle: "??????????",
                                        lottieAsset:
                                            "resources/notificationalarm.json",
                                        notificationToast:
                                            "???? ?????????? ???????????? ??????????",
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
                    : Divider(
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
                                          content: "?????? ??????????????????",
                                          onCancel: () {},
                                          title: "???? ???????? ?????? ???? ????????????????????"),
                                    );
                                  });
                            },
                            child: FaIcon(
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

class NotificationsData extends StatefulWidget {
  final String notificationTitle;
  final String notoficationSubtitle;
  final String datetime;
  final String notifiTime;

  final isSeen;
  final indeex;
  final NotificationDataService serviceObj;
  final NotificationMessage notificationObj;
  const NotificationsData({
    this.serviceObj,
    this.notificationObj,
    this.notifiTime,
    this.indeex,
    this.isSeen,
    this.datetime,
    this.notificationTitle,
    this.notoficationSubtitle,
    Key key,
  }) : super(key: key);

  @override
  _NotificationsDataState createState() => _NotificationsDataState();
}

class _NotificationsDataState extends State<NotificationsData>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FadeInUp(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 70.h,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (context) {
                      return NotificationOnTapDialog(widget: widget);
                    },
                  ),
                  child: Container(
                      padding: EdgeInsets.all(5),
                      height: 90.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return NotificationOnTapDialog(
                                            widget: widget);
                                      },
                                    );
                                  },
                                  child: Icon(
                                    Icons.menu_sharp,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  widget.datetime,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: ScreenUtil().setSp(12,
                                          allowFontScalingSelf: true),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  widget.notifiTime ?? "",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: ScreenUtil().setSp(12,
                                          allowFontScalingSelf: true),
                                      fontWeight: FontWeight.w400),
                                ),

                                // Text(      DateFormat('kk:mm:a').format(      widget.datetime  );)
                              ],
                            ),
                          ),
                          Container(
                            width: 245.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  child: Directionality(
                                    textDirection: ui.TextDirection.rtl,
                                    child: Text(
                                      widget.notificationTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(13,
                                            allowFontScalingSelf: true),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 3),
                                Container(
                                  child: Directionality(
                                    textDirection: ui.TextDirection.rtl,
                                    child: Text(
                                      widget.notoficationSubtitle,
                                      style: TextStyle(
                                          color: Colors.grey[300],
                                          height: 1.2,
                                          fontSize: 11),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      color: widget.isSeen == 1
                          ? Colors.black45
                          : Color(0XFF2C2C2C).withOpacity(0.4)),
                ),
              ),
              Container(
                height: 70.h,
                width: 3,
                color: widget.isSeen == 1 ? Colors.grey : Colors.orange[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
