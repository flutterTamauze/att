import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:qr_users/services/UserHolidays/user_holidays.dart';

import 'MyOrdersWidget.dart';

class UserOrdersListView extends StatelessWidget {
  const UserOrdersListView({
    Key key,
    @required this.provList,
  }) : super(key: key);

  final List<UserHolidays> provList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                adminComment: provList[index].adminResponse,
                comments: provList[index].holidayDescription,
                date: provList[index].fromDate.toString(),
                iconData: provList[index].holidayStatus == 1
                    ? Icons.check
                    : FontAwesomeIcons.times,
                response: provList[index].adminResponse,
                status: provList[index].holidayStatus,
                orderNum: provList[index].holidayNumber.toString(),
                vacationDaysCount: [
                  provList[index].fromDate,
                  provList[index].toDate
                ],
                holidayType: provList[index].holidayType,
              ),
              Divider()
            ],
          );
        },
        itemCount: provList.length,
      ),
    ));
  }
}
