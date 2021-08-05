import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_users/services/OrdersResponseData/OrdersReponse.dart';

import 'MyOrdersWidget.dart';

class UserOrdersListView extends StatelessWidget {
  const UserOrdersListView({
    Key key,
    @required this.provList,
  }) : super(key: key);

  final List<OrderData> provList;

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
                adminComment: provList[index].adminComment,
                comments: provList[index].comments,
                date: provList[index].date,
                iconData: provList[index].status == 1
                    ? Icons.check
                    : FontAwesomeIcons.times,
                response: provList[index].statusResponse,
                status: provList[index].status,
                orderNum: provList[index].orderNumber,
                vacationDaysCount: provList[index].vacationDaysCount,
                vacationReason: provList[index].vacationReason,
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
