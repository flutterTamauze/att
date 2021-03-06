import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/UserRequests/MyOrdersWidget.dart';
import 'package:qr_users/widgets/UserRequests/UserOrdersListView.dart';
import 'package:qr_users/widgets/UserRequests/UserPermessionsListView.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'NormalUser.dart';
import 'NormalUserVacationRequest.dart';

// ignore: must_be_immutable
class UserOrdersView extends StatefulWidget {
  String selectedOrder;
  List<String> ordersList;
  UserOrdersView({@required this.selectedOrder, @required this.ordersList});
  @override
  _UserOrdersViewState createState() => _UserOrdersViewState();
}

Future userPermessions;
Future userHolidays;
var isExpanded = false;
TextEditingController orderNumberController = TextEditingController();
List<UserHolidays> filteredOrderData = [];
List<UserPermessions> filteredPermessions = [];

class _UserOrdersViewState extends State<UserOrdersView> {
  @override
  void initState() {
    final UserData userProvider = Provider.of<UserData>(context, listen: false);

    userHolidays = Provider.of<UserHolidaysData>(context, listen: false)
        .getFutureSingleUserHoliday(
            userProvider.user.id, userProvider.user.userToken);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<UserHolidays> provList =
        Provider.of<UserHolidaysData>(context, listen: true).singleUserHoliday;
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
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: FloatingActionButton(
            elevation: 4,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserVacationRequest(
                        widget.selectedOrder == "????????????????" ? 1 : 3, [
                      getTranslated(context, "?????????? ???? ????????????"),
                      getTranslated(context, "???????????? ????????")
                    ], [
                      getTranslated(context, "??????????"),
                      getTranslated(context, "??????????"),
                      getTranslated(context, "???????? ????????????")
                    ]),
                  ));
            },
            tooltip:
                widget.selectedOrder == "????????????????" ? "?????? ??????????" : "?????? ??????",
            backgroundColor: ColorManager.primary,
            child: Icon(
              Icons.add,
              color: Colors.black,
              size: ScreenUtil().setSp(30, allowFontScalingSelf: true),
            ),
          ),
          endDrawer: NotificationItem(),
          body: Column(
            children: [
              Header(
                nav: false,
                goUserMenu: Provider.of<UserData>(context, listen: false)
                            .user
                            .userType ==
                        0
                    ? false
                    : true,
                goUserHomeFromMenu: false,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmallDirectoriesHeader(
                      Lottie.asset("resources/orders.json", repeat: false),
                      getTranslated(context, "????????????")),
                ],
              ),
              Divider(),
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1)),
                          width: 150.w,
                          height: 40.h,
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                            elevation: 2,
                            isExpanded: true,
                            items: widget.ordersList.map((String x) {
                              return DropdownMenuItem<String>(
                                  value: x,
                                  child: AutoSizeText(
                                    x,
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w500),
                                  ));
                            }).toList(),
                            onChanged: (value) {
                              if (value == getTranslated(context, "????????????????")) {
                                var userProvider = Provider.of<UserData>(
                                    context,
                                    listen: false);
                                if (Provider.of<UserPermessionsData>(context,
                                        listen: false)
                                    .singleUserPermessions
                                    .isEmpty) {
                                  userPermessions =
                                      Provider.of<UserPermessionsData>(context,
                                              listen: false)
                                          .getFutureSinglePermession(
                                              userProvider.user.id,
                                              userProvider.user.userToken);
                                }
                              }
                              setState(() {
                                widget.selectedOrder = value;
                              });
                            },
                            value: widget.selectedOrder,
                          )),
                        ),
                      ),
                      AutoSizeText(
                        getTranslated(context, "?????? ??????????"),
                        style: TextStyle(
                          fontSize: setResponsiveFontSize(17),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: TextField(
                  onChanged: (value) {
                    print(value);

                    setState(() {
                      if (widget.selectedOrder == "????????????????") {
                        List<UserHolidays> order = provList
                            .where((element) =>
                                element.holidayNumber.toString() ==
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
                      hintText: getTranslated(context, "?????????? ???????? ??????????"),
                      focusColor: Colors.orange,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange[600]))),
                ),
              ),
              widget.selectedOrder == getTranslated(context, "????????????????")
                  ? FutureBuilder(
                      future: userHolidays,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.orange,
                            ),
                          );
                        } else {
                          return orderNumberController.text == ""
                              ? Expanded(
                                  child: UserOrdersListView(
                                    provList: provList,
                                    memberId: "",
                                  ),
                                )
                              : filteredOrderData == null ||
                                      filteredOrderData.isEmpty
                                  ? Center(
                                      child: AutoSizeText(getTranslated(
                                          context, "???? ???????? ?????? ???????? ??????????")),
                                    )
                                  : ExpandedOrderTile(
                                      isAdmin: false,
                                      createdDate: filteredOrderData[0]
                                          .createdOnDate
                                          .toString(),
                                      comments: filteredOrderData[0]
                                          .holidayDescription,
                                      date: filteredOrderData[0]
                                          .fromDate
                                          .toString()
                                          .substring(0, 11),
                                      vacationDaysCount: [
                                        filteredOrderData[0].fromDate,
                                        filteredOrderData[0].toDate
                                      ],
                                      holidayType:
                                          filteredOrderData[0].holidayType,
                                      iconData:
                                          filteredOrderData[0].holidayStatus ==
                                                  1
                                              ? Icons.check
                                              : FontAwesomeIcons.times,
                                      response:
                                          filteredOrderData[0].adminResponse,
                                      status:
                                          filteredOrderData[0].holidayStatus,
                                      orderNum: filteredOrderData[0]
                                          .holidayNumber
                                          .toString());
                        }
                      })
                  : //??????
                  FutureBuilder(
                      future: userPermessions,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.orange,
                            ),
                          );
                        } else {
                          return orderNumberController.text == ""
                              ? Expanded(
                                  child: UserPermessionListView(
                                      memberId: "",
                                      isFilter: false,
                                      permessionsList: permessionsList),
                                )
                              : filteredPermessions == null ||
                                      filteredPermessions.isEmpty
                                  ? Center(
                                      child: AutoSizeText(getTranslated(
                                          context, "???? ???????? ?????? ???????? ??????????")),
                                    )
                                  : UserPermessionListView(
                                      permessionsList: filteredPermessions,
                                      isFilter: true,
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
