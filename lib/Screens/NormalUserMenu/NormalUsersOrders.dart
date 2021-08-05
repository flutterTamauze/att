import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/OrdersResponseData/OrdersReponse.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/UserRequests/MyOrdersWidget.dart';
import 'package:qr_users/widgets/UserRequests/MyPermessionsWidget.dart';
import 'package:qr_users/widgets/UserRequests/UserOrdersListView.dart';
import 'package:qr_users/widgets/UserRequests/UserPermessionsListView.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'NormalUser.dart';

class UserOrdersView extends StatefulWidget {
  @override
  _UserOrdersViewState createState() => _UserOrdersViewState();
}

String selectedOrder = "الأجازات";
List<String> ordersList = ["الأذونات", "الأجازات"];
Future userPermessions;
var isExpanded = false;
TextEditingController orderNumberController = TextEditingController();
List<OrderData> filteredOrderData = [];
List<UserPermessions> filteredPermessions = [];

class _UserOrdersViewState extends State<UserOrdersView> {
  @override
  void initState() {
    var userProvider = Provider.of<UserData>(context, listen: false);
    userPermessions = Provider.of<UserPermessionsData>(context, listen: false)
        .getSingleUserPermession(
            Provider.of<UserData>(context, listen: false).user.id,
            userProvider.user.userToken);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<OrderData> provList =
        Provider.of<OrderDataProvider>(context, listen: true).ordersList;
    var permessionsList = Provider.of<UserPermessionsData>(
      context,
    ).singleUserPermessions;
    return WillPopScope(
      onWillPop: () {
        return Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => NormalUserMenu(),
            ),
            (Route<dynamic> route) => false);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          print(permessionsList.length);
        },
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
                        if (selectedOrder == "الأجازات") {
                          List<OrderData> order = provList
                              .where((element) =>
                                  element.orderNumber ==
                                  orderNumberController.text)
                              .toList();
                          filteredOrderData = order;
                        } else {
                          List<UserPermessions> permessions = permessionsList
                              .where((element) =>
                                  element.permessionId.toString() ==
                                  orderNumberController.text)
                              .toList();
                          filteredPermessions = permessions;
                        }
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
                      ? UserOrdersListView(provList: provList)
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
                  : //اذن
                  FutureBuilder(
                      future: userPermessions,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          );
                        } else {
                          return orderNumberController.text == ""
                              ? UserPermessionListView(
                                  permessionsList: permessionsList)
                              : filteredPermessions == null ||
                                      filteredPermessions.isEmpty
                                  ? Center(
                                      child: Text("لا يوجد طلب بهذا الرقم"),
                                    )
                                  : UserPermessionListView(
                                      permessionsList: filteredPermessions,
                                    );
                        }
                      })
            ],
          ),
        ),
      ),
    );
  }
}
