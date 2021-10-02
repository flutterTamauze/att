import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';

class ExpandedPendingPermessions extends StatefulWidget {
  final String desc, userName, adminComment, duration;
  final int id;
  Function onAccept;
  Function onRefused;
  bool isAdmin = false;
  final int permessionType;
  final String date, createdOn;

  ExpandedPendingPermessions({
    this.userName,
    this.permessionType,
    this.id,
    this.onRefused,
    this.onAccept,
    this.isAdmin,
    this.duration,
    this.adminComment,
    this.desc,
    this.date,
    this.createdOn,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedPendingPermessionsState createState() =>
      _ExpandedPendingPermessionsState();
}

class _ExpandedPendingPermessionsState
    extends State<ExpandedPendingPermessions> {
  @override
  Widget build(BuildContext context) {
    var pendingList = Provider.of<UserPermessionsData>(context);
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
          data: Theme.of(context).copyWith(
              accentColor: Colors.orange, unselectedWidgetColor: Colors.black),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
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
                            widget.createdOn,
                          ),
                          FaIcon(
                            FontAwesomeIcons.hourglass,
                            color: Colors.orange,
                            size: 15,
                          )
                        ],
                      ),
                      Container(width: 3, color: Colors.orange),
                    ],
                  ),
                ),
                title: Text(
                  widget.userName,
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
                                "تاريخ الأذن : ${widget.date.substring(0, 11)}"),
                            Divider(),
                            Text(widget.permessionType == 1
                                ? "اذن حتى الساعة : ${widget.duration}"
                                : "اذن من الساعة : ${widget.duration}"),
                            widget.desc != null ? Divider() : Container(),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: [
                                Text(
                                  "قرارك",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => widget.onAccept(),
                                      child: FaIcon(
                                        FontAwesomeIcons.check,
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    InkWell(
                                      onTap: () => widget.onRefused(),
                                      child: FaIcon(
                                        FontAwesomeIcons.times,
                                        color: Colors.red,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
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