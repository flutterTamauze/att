import 'package:animate_do/animate_do.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/OrdersResponseData/OrdersReponse.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserOrdersView extends StatefulWidget {
  @override
  _UserOrdersViewState createState() => _UserOrdersViewState();
}

String selectedOrder = "الأجازات";
List<String> ordersList = ["الأذونات", "الأجازات"];

var isExpanded = false;

class _UserOrdersViewState extends State<UserOrdersView> {
  @override
  Widget build(BuildContext context) {
    var provList =
        Provider.of<OrderDataProvider>(context, listen: false).ordersList;
    return Scaffold(
      body: Column(
        children: [
          Header(
            nav: false,
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmallDirectoriesHeader(
                    Lottie.asset("resources/orders.json", repeat: false),
                    "طلباتى"),
              ],
            ),
          ),
          Divider(),
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1)),
                          width: 150.w,
                          height: 40.h,
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                            elevation: 2,
                            isExpanded: true,
                            items: ordersList.map((String x) {
                              return DropdownMenuItem<String>(
                                  value: x,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      x,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedOrder = value;
                              });
                            },
                            value: selectedOrder,
                          )),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "عرض طلبات",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          selectedOrder == "الأجازات"
              ? Expanded(
                  child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ExpandedOrderTile(
                          index: index,
                          comments: provList[index].comments,
                          date: provList[index].date,
                          iconData: provList[index].accepted
                              ? Icons.check
                              : FontAwesomeIcons.times,
                          status: provList[index].statusResponse,
                        ),
                        Divider()
                      ],
                    );
                  },
                  itemCount: provList.length,
                ))
              : Container()
        ],
      ),
    );
  }
}

class ExpandedOrderTile extends StatefulWidget {
  final String status;
  final IconData iconData;
  final String comments;
  int index;
  final String date;
  ExpandedOrderTile({
    this.comments,
    this.iconData,
    this.status,
    this.index,
    this.date,
    Key key,
  }) : super(key: key);

  @override
  _ExpandedOrderTileState createState() => _ExpandedOrderTileState();
}

class _ExpandedOrderTileState extends State<ExpandedOrderTile> {
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
                title: Text(
                  widget.date,
                ),
                children: [
                  SlideInDown(
                    child: Container(
                      height: 200.h,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Text(
                            "حالة الطلب",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                widget.status,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: widget.iconData == Icons.check
                                      ? Colors.green[700]
                                      : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                widget.iconData,
                                color: widget.iconData == Icons.check
                                    ? Colors.green
                                    : Colors.red,
                              )
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "التعليقات",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              widget.comments,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w200),
                            ),
                          ),
                        ],
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
