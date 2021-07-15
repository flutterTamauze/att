import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:ui' as ui;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:getwidget/components/animation/gf_animation.dart';
import 'package:getwidget/types/gf_animation_type.dart';

import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';
import 'dart:ui' as ui;

import 'package:qr_users/MLmodule/db/SqlfliteDB.dart';
import 'package:qr_users/widgets/UserProfileImageWidget.dart';
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
                        ? "الأشعارات"
                        : "لا يوجد اشعارات ",
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
                            //   switch (notifiyProv.category) {
                            //     case "المستشفيات":
                            //       {
                            //     //     BlocProvider.of<NavigationBloc>(context).add(
                            //     //         NavigationEvents.HealthCareClickedEvent);

                            //     //     break;
                            //     //   }
                            //     // case "الحج و العمرة":
                            //     //   {
                            //     //     BlocProvider.of<NavigationBloc>(context).add(
                            //     //         NavigationEvents.HegAndOmraClickedEvent);
                            //     //     break;
                            //     //   }
                            //     // default:
                            //     //   BlocProvider.of<NavigationBloc>(context)
                            //     //       .add(NavigationEvents.HomePageClickedEvent);
                            //   }
                            // },
                          },
                          child: NotificationsData(
                            notificationTitle: notifiyProv.title,
                            notoficationSubtitle: notifiyProv.message,
                            datetime: notifiyProv.dateTime,
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
                ))
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
  final isSeen;
  final indeex;
  final NotificationDataService serviceObj;
  final NotificationMessage notificationObj;
  const NotificationsData({
    this.serviceObj,
    this.notificationObj,
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

AnimationController controller;
Animation<double> animation;

class _NotificationsDataState extends State<NotificationsData>
    with TickerProviderStateMixin {
  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    animation = new CurvedAnimation(parent: controller, curve: Curves.linear);
    controller.repeat();
    super.initState();
  }

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GFAnimation(
        scaleAnimation: animation,
        controller: controller,
        type: GFAnimationType.scaleTransition,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 70.h,
          child: Row(
            children: [
              Expanded(
                child: Container(
                    padding: EdgeInsets.all(5),
                    height: 70.h,
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
                                      return Directionality(
                                        textDirection: ui.TextDirection.rtl,
                                        child: Container(
                                          child: AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            backgroundColor: Colors.white,
                                            content: Container(
                                              height: 140.h,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  NotificationPressedOptions(
                                                    iconData:
                                                        FontAwesomeIcons.times,
                                                    ontapFun: () async {
                                                      await db.deleteByID(widget
                                                          .notificationObj.id);
                                                      await widget.serviceObj
                                                          .deleteNotification(
                                                              widget
                                                                  .notificationObj
                                                                  .id);
                                                    },
                                                    title: "حذف هذا الأشعار",
                                                  ),
                                                  SizedBox(
                                                    height: 15.h,
                                                  ),
                                                  NotificationPressedOptions(
                                                    iconData:
                                                        FontAwesomeIcons.check,
                                                    ontapFun: () async {
                                                      await db.readMessage(
                                                          1,
                                                          widget.notificationObj
                                                              .id);
                                                      widget.serviceObj
                                                          .readMessage(
                                                              widget.indeex);
                                                    },
                                                    title: "قراءه هذا الأشعار",
                                                  ),
                                                  SizedBox(
                                                    height: 15.h,
                                                  ),
                                                  NotificationPressedOptions(
                                                    iconData: FontAwesomeIcons
                                                        .userTimes,
                                                    ontapFun: () async {
                                                      _firebaseMessaging
                                                          .unsubscribeFromTopic(
                                                              "nekaba")
                                                          .then((value) =>
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "تم غلق الأشعارات المتعلقة ب${widget.notificationObj.category}",
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green));
                                                    },
                                                    title:
                                                        " اغلاق الأشعارات الخاصة ب${widget.notificationObj.category}",
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
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
                                    fontSize: ScreenUtil()
                                        .setSp(12, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 245.w,
                          padding: EdgeInsets.only(top: 5),
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
                                        color: Colors.grey[300], fontSize: 11),
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

class NotificationPressedOptions extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Function ontapFun;
  NotificationPressedOptions(
      {Key key, this.iconData, this.ontapFun, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await ontapFun();
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1)),
            child: Center(
              child: FaIcon(
                iconData,
                color: Colors.black,
                size: 15,
              ),
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
          Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: ScreenUtil().setSp(13, allowFontScalingSelf: true)),
          ),
        ],
      ),
    );
  }
}
