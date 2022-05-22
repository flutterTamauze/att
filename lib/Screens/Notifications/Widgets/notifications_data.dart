import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'dart:ui' as ui;

import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';

import 'package:qr_users/Screens/Notifications/Widgets/NotificationOnTapDialog.dart';

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
                      padding: const EdgeInsets.all(5),
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
                                  child: const Icon(
                                    Icons.menu_sharp,
                                    color: Colors.white,
                                  ),
                                ),
                                AutoSizeText(
                                  widget.datetime,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: ScreenUtil().setSp(12,
                                          allowFontScalingSelf: true),
                                      fontWeight: FontWeight.w400),
                                ),
                                AutoSizeText(
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
                                    child: AutoSizeText(
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
                                const SizedBox(height: 3),
                                Container(
                                  child: Directionality(
                                    textDirection: ui.TextDirection.rtl,
                                    child: AutoSizeText(
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
                          : const Color(0XFF2C2C2C).withOpacity(0.4)),
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
