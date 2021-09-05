import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';

import 'MyPermessionsWidget.dart';

class UserPermessionListView extends StatefulWidget {
  const UserPermessionListView({@required this.permessionsList, this.isFilter});

  final List<UserPermessions> permessionsList;
  final bool isFilter;
  @override
  _UserPermessionListViewState createState() => _UserPermessionListViewState();
}

class _UserPermessionListViewState extends State<UserPermessionListView> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    Provider.of<UserPermessionsData>(context, listen: false)
        .getSingleUserPermession(
            userProvider.user.id, userProvider.user.userToken);
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isFilter
        ? Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ExpandedPermessionsTile(
                      desc: widget.permessionsList[index].permessionDescription,
                      date: widget.permessionsList[index].date
                          .toString()
                          .substring(0, 11),
                      permessionType:
                          widget.permessionsList[index].permessionType,
                      orderNum:
                          widget.permessionsList[index].permessionId.toString(),
                      adminComment: widget.permessionsList[index].adminResponse,
                      status: widget.permessionsList[index].permessionStatus,
                      duration: widget.permessionsList[index].duration,
                    ),
                    Divider()
                  ],
                );
              },
              itemCount: widget.permessionsList.length,
            ),
          )
        : Align(
            alignment: Alignment.topCenter,
            child: SmartRefresher(
              controller: refreshController,
              onRefresh: _onRefresh,
              enablePullDown: true,
              header: WaterDropMaterialHeader(
                color: Colors.white,
                backgroundColor: Colors.orange,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ExpandedPermessionsTile(
                        desc:
                            widget.permessionsList[index].permessionDescription,
                        date: widget.permessionsList[index].date
                            .toString()
                            .substring(0, 11),
                        permessionType:
                            widget.permessionsList[index].permessionType,
                        orderNum: widget.permessionsList[index].permessionId
                            .toString(),
                        adminComment:
                            widget.permessionsList[index].adminResponse,
                        status: widget.permessionsList[index].permessionStatus,
                        duration: widget.permessionsList[index].duration,
                      ),
                      Divider()
                    ],
                  );
                },
                itemCount: widget.permessionsList.length,
              ),
            ),
          );
  }
}
