import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExpandedPermessionsTile extends StatefulWidget {
  final String response, orderNum, adminComment, duration;
  final IconData iconData;
  final String comments, vacationReason;
  final int status;

  final int permessionType;
  final String date;

  ExpandedPermessionsTile({
    this.comments,
    this.orderNum,
    this.permessionType,
    this.vacationReason,
    this.duration,
    this.iconData,
    this.adminComment,
    this.response,
    this.status,
    this.date,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedOrderTileState createState() => _ExpandedOrderTileState();
}

class _ExpandedOrderTileState extends State<ExpandedPermessionsTile> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
          data: Theme.of(context).copyWith(
              accentColor: Colors.orange, unselectedWidgetColor: Colors.black),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              child: ExpansionTile(
                trailing: Container(
                  width: 80.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            widget.date,
                          ),
                          FaIcon(
                            widget.status == 0
                                ? FontAwesomeIcons.hourglass
                                : widget.status == 1
                                    ? FontAwesomeIcons.check
                                    : FontAwesomeIcons.times,
                            color: widget.status == 0
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
                        color: widget.status == -1
                            ? Colors.red
                            : widget.status == 0
                                ? Colors.orange
                                : Colors.green,
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
                            widget.comments == "" ? Container() : Divider(),
                            widget.comments != null
                                ? widget.comments == ""
                                    ? Container()
                                    : Text(
                                        "تفاصيل الطلب : ${widget.comments}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                : Container(),
                            Text(
                                "تاريخ الأذن : ${widget.date.substring(0, 11)}"),
                            Divider(),
                            Text(widget.permessionType == 1
                                ? "اذن حتى الساعة : ${widget.duration}"
                                : "اذن من الساعة : ${widget.duration}"),
                            Divider(),
                            widget.comments != null ? Divider() : Container(),
                            widget.status != 0
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          widget.response,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                widget.iconData == Icons.check
                                                    ? Colors.green[700]
                                                    : Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      widget.status == -1
                                          ? Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 10.h),
                                              child: Text(
                                                "سبب الرفض : ${widget.adminComment}",
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )
                                          : Container(),
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
          ),
        ));
  }
}
