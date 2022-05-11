import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Screen/Notifications.dart';
import 'notifications_data.dart';

class NotificationOnTapDialog extends StatelessWidget {
  const NotificationOnTapDialog({
    Key key,
    @required this.widget,
  }) : super(key: key);

  final NotificationsData widget;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
          content: Container(
            height: 90.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotificationPressedOptions(
                  iconData: FontAwesomeIcons.times,
                  ontapFun: () async {
                    await db.deleteByID(widget.notificationObj.id);
                    await widget.serviceObj
                        .deleteNotification(widget.notificationObj.id);
                  },
                  title: "حذف هذا الأشعار",
                ),
                SizedBox(
                  height: 15.h,
                ),
                NotificationPressedOptions(
                  iconData: FontAwesomeIcons.check,
                  ontapFun: () async {
                    await db.readMessage(1, widget.notificationObj.id);
                    widget.serviceObj.readMessage(widget.indeex);
                  },
                  title: "قراءه هذا الأشعار",
                ),
              ],
            ),
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
          AutoSizeText(
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
