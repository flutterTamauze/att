import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';

import '../roundedAlert.dart';

class ExpandedPermessionsTile extends StatefulWidget {
  final String desc, orderNum, adminComment, duration;
  final IconData iconData;
  final String vacationReason;
  final int status;
  bool isAdmin = false;
  final int permessionType;
  final DateTime date;

  ExpandedPermessionsTile({
    this.orderNum,
    this.permessionType,
    this.vacationReason,
    this.isAdmin,
    this.duration,
    this.iconData,
    this.adminComment,
    this.desc,
    this.status,
    this.date,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedOrderTileState createState() => _ExpandedOrderTileState();
}

class _ExpandedOrderTileState extends State<ExpandedPermessionsTile> {
  bool checkDeleteAllowed() {
    if (DateTime.now().isBefore(widget.date) && widget.status == 3) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
          data: Theme.of(context).copyWith(
              accentColor: Colors.orange, unselectedWidgetColor: Colors.black),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Stack(
              children: [
                Container(
                  child: ExpansionTile(
                    initiallyExpanded: widget.isAdmin,
                    trailing: Container(
                      width: 80.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                widget.date.toString().substring(0, 11),
                              ),
                              FaIcon(
                                widget.status == 3
                                    ? FontAwesomeIcons.hourglass
                                    : widget.status == 1
                                        ? FontAwesomeIcons.check
                                        : FontAwesomeIcons.times,
                                color: widget.status == 3
                                    ? Colors.orange
                                    : widget.status == 1
                                        ? Colors.green
                                        : Colors.red,
                                size: 15,
                              )
                            ],
                          ),
                          Container(
                            width: 3,
                            color: widget.status == 3
                                ? Colors.orange
                                : widget.status == 1
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      widget.orderNum,
                    ),
                    children: [
                      SlideInDown(
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: 300.w,
                            margin: EdgeInsets.all(15),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "نوع الأذن : ${widget.permessionType == 1 ? "تأخير عن الحضور" : "انصراف مبكر"} ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                widget.desc == "" ? Container() : Divider(),
                                widget.desc != null
                                    ? widget.desc == ""
                                        ? Container()
                                        : Text(
                                            "تفاصيل الطلب : ${widget.desc}",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                    : Container(),
                                widget.desc != null
                                    ? widget.desc == ""
                                        ? Container()
                                        : Divider()
                                    : Container(),
                                Text(
                                    "تاريخ الأذن : ${widget.date.toString().substring(0, 11)}"),
                                Divider(),
                                Text(widget.permessionType == 1
                                    ? "اذن حتى الساعة : ${widget.duration}"
                                    : "اذن من الساعة : ${widget.duration}"),
                                widget.desc != null ? Divider() : Container(),
                                widget.status != 3
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          widget.status == 2
                                              ? widget.adminComment == "" ||
                                                      widget.adminComment ==
                                                          null
                                                  ? Container()
                                                  : Container(
                                                      padding: EdgeInsets.only(
                                                          bottom: 10.h),
                                                      child: Text(
                                                        "سبب الرفض : ${widget.adminComment}",
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    )
                                              : widget.adminComment == null ||
                                                      widget.adminComment == ""
                                                  ? Container()
                                                  : Text(
                                                      "تعليق الأدمن  : ${widget.adminComment}",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                        ],
                                      )
                                    : Container(
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'تم ارسال الطلب برجاء انتظار الرد',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                checkDeleteAllowed()
                    ? Positioned(
                        child: InkWell(
                          onTap: () {
                            return showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: RoundedAlert(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        String msg = await Provider.of<
                                                    UserPermessionsData>(
                                                context,
                                                listen: false)
                                            .deleteUserPermession(
                                                int.parse(widget.orderNum),
                                                Provider.of<UserData>(context,
                                                        listen: false)
                                                    .user
                                                    .userToken);

                                        if (msg ==
                                            "Success : Permission Deleted!") {
                                          Fluttertoast.showToast(
                                              msg: "تم الحذف بنجاح",
                                              backgroundColor: Colors.green);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "خطأ في الحذف",
                                              backgroundColor: Colors.red);
                                        }
                                      },
                                      content: "هل تريد حذف الطلب",
                                      onCancel: () {},
                                      title: "حذف الطلب",
                                    ),
                                  );
                                });
                          },
                          child: Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 2, color: Colors.red)),
                            child: Icon(
                              FontAwesomeIcons.times,
                              color: Colors.red,
                              size: 15,
                            ),
                          ),
                        ),
                        top: 0,
                        right: 0,
                      )
                    : Container()
              ],
            ),
          ),
        ));
  }
}
