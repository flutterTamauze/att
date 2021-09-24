import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/services/MemberData.dart';

import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/user_data.dart';

import 'MyOrdersWidget.dart';

class UserOrdersListView extends StatefulWidget {
  const UserOrdersListView({Key key, @required this.provList, this.memberId})
      : super(key: key);
  final String memberId;
  final List<UserHolidays> provList;

  @override
  _UserOrdersListViewState createState() => _UserOrdersListViewState();
}

class _UserOrdersListViewState extends State<UserOrdersListView> {
  @override
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    if (widget.memberId == "" || widget.memberId == null) {
      Provider.of<UserHolidaysData>(context, listen: false)
          .getSingleUserHoliday(
              userProvider.user.id, userProvider.user.userToken);
      refreshController.refreshCompleted();
    } else {
      Provider.of<UserHolidaysData>(context, listen: false)
          .getSingleUserHoliday(widget.memberId, userProvider.user.userToken);
      refreshController.refreshCompleted();
    }
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SmartRefresher(
        onRefresh: _onRefresh,
        enablePullDown: true,
        header: WaterDropMaterialHeader(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
        controller: refreshController,
        child: Provider.of<UserHolidaysData>(
          context,
        ).isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      widget.memberId == ""
                          ? ExpandedOrderTile(
                              approveDate: widget.provList[index].approvedDate
                                  .toString(),
                              createdDate: widget.provList[index].createdOnDate
                                  .toString(),
                              index: index,
                              isAdmin: widget.memberId == "" ? false : true,
                              adminComment:
                                  widget.provList[index].adminResponse,
                              comments:
                                  widget.provList[index].holidayDescription,
                              date: widget.provList[index].fromDate.toString(),
                              iconData:
                                  widget.provList[index].holidayStatus == 1
                                      ? Icons.check
                                      : FontAwesomeIcons.times,
                              response: widget.provList[index].adminResponse,
                              status: widget.provList[index].holidayStatus,
                              orderNum: widget.provList[index].holidayNumber
                                  .toString(),
                              vacationDaysCount: [
                                widget.provList[index].fromDate,
                                widget.provList[index].toDate
                              ],
                              holidayType: widget.provList[index].holidayType,
                            )
                          : widget.provList[index].holidayStatus != 2
                              ? ExpandedOrderTile(
                                  approveDate: widget
                                      .provList[index].approvedDate
                                      .toString(),
                                  index: index,
                                  createdDate: widget
                                      .provList[index].createdOnDate
                                      .toString(),
                                  isAdmin: widget.memberId == "" ? false : true,
                                  adminComment:
                                      widget.provList[index].adminResponse,
                                  comments:
                                      widget.provList[index].holidayDescription,
                                  date: widget.provList[index].fromDate
                                      .toString(),
                                  iconData:
                                      widget.provList[index].holidayStatus == 1
                                          ? Icons.check
                                          : FontAwesomeIcons.times,
                                  response:
                                      widget.provList[index].adminResponse,
                                  status: widget.provList[index].holidayStatus,
                                  orderNum: widget.provList[index].holidayNumber
                                      .toString(),
                                  vacationDaysCount: [
                                    widget.provList[index].fromDate,
                                    widget.provList[index].toDate
                                  ],
                                  holidayType:
                                      widget.provList[index].holidayType,
                                )
                              : Container(),
                      Divider()
                    ],
                  );
                },
                itemCount: widget.provList.length,
              ),
      ),
    );
  }
}
