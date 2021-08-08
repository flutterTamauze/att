import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';

import 'MyPermessionsWidget.dart';

class UserPermessionListView extends StatelessWidget {
  const UserPermessionListView({
    Key key,
    @required this.permessionsList,
  }) : super(key: key);

  final List<UserPermessions> permessionsList;

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
              ExpandedPermessionsTile(
                desc: permessionsList[index].permessionDescription,
                date: permessionsList[index].date.toString().substring(0, 11),
                permessionType: permessionsList[index].permessionType,
                orderNum: permessionsList[index].permessionId.toString(),
                adminComment: permessionsList[index].permessionDescription,
                status: permessionsList[index].permessionStatus,
                duration: permessionsList[index].duration,
              ),
              Divider()
            ],
          );
        },
        itemCount: permessionsList.length,
      ),
    ));
  }
}
