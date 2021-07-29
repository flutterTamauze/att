import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/OrdersResponseData/OrdersReponse.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/MyOrdersWidget.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'NormalUser.dart';

class UserOrdersView extends StatefulWidget {
  final String orderNumber;
  UserOrdersView({@required this.orderNumber});
  @override
  _UserOrdersViewState createState() => _UserOrdersViewState();
}

String selectedOrder = "الأجازات";
List<String> ordersList = ["الأذونات", "الأجازات"];

var isExpanded = false;
TextEditingController orderNumberController = TextEditingController();
List<OrderData> filteredOrderData = [];

class _UserOrdersViewState extends State<UserOrdersView> {
  @override
  Widget build(BuildContext context) {
    List<OrderData> provList =
        Provider.of<OrderDataProvider>(context, listen: true).ordersList;

    return WillPopScope(
      onWillPop: () {
        return Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => NormalUserMenu(),
            ),
            (Route<dynamic> route) => false);
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: Column(
            children: [
              Header(
                nav: false,
                goUserMenu: true,
                goUserHomeFromMenu: false,
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    onChanged: (value) {
                      print(value);

                      setState(() {
                        List<OrderData> x = provList
                            .where((element) =>
                                element.orderNumber ==
                                orderNumberController.text)
                            .toList();
                        filteredOrderData = x;
                      });
                    },
                    controller: orderNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'البحث برقم الطلب',
                        focusColor: Colors.orange,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange[600]))),
                  ),
                ),
              ),
              selectedOrder == "الأجازات"
                  ? orderNumberController.text == ""
                      ? Expanded(
                          child: Align(
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                            shrinkWrap: true,
                            reverse: true,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ExpandedOrderTile(
                                    index: index,
                                    adminComment: provList[index].adminComment,
                                    comments: provList[index].comments,
                                    date: provList[index].date,
                                    iconData: provList[index].status == 1
                                        ? Icons.check
                                        : FontAwesomeIcons.times,
                                    response: provList[index].statusResponse,
                                    status: provList[index].status,
                                    orderNum: provList[index].orderNumber,
                                    vacationDaysCount:
                                        provList[index].vacationDaysCount,
                                    vacationReason:
                                        provList[index].vacationReason,
                                  ),
                                  Divider()
                                ],
                              );
                            },
                            itemCount: provList.length,
                          ),
                        ))
                      : filteredOrderData == null || filteredOrderData.isEmpty
                          ? Center(
                              child: Text("لا يوجد طلب بهذا الرقم"),
                            )
                          : ExpandedOrderTile(
                              comments: filteredOrderData[0].comments,
                              date: filteredOrderData[0].date,
                              vacationDaysCount:
                                  filteredOrderData[0].vacationDaysCount,
                              vacationReason:
                                  filteredOrderData[0].vacationReason,
                              iconData: filteredOrderData[0].status == 1
                                  ? Icons.check
                                  : FontAwesomeIcons.times,
                              response: filteredOrderData[0].statusResponse,
                              status: filteredOrderData[0].status,
                              orderNum: filteredOrderData[0].orderNumber,
                            )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
