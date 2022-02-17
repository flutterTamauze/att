import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/user_data.dart';

import 'MyPermessionsWidget.dart';

class UserPermessionListView extends StatefulWidget {
  const UserPermessionListView(
      {@required this.permessionsList, this.isFilter, this.memberId});

  final List<UserPermessions> permessionsList;
  final bool isFilter;
  final String memberId;
  @override
  _UserPermessionListViewState createState() => _UserPermessionListViewState();
}

class _UserPermessionListViewState extends State<UserPermessionListView> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    final userProvider = Provider.of<UserData>(context, listen: false);

    if (widget.memberId == "" || widget.memberId == null) {
      Provider.of<UserPermessionsData>(context, listen: false)
          .getFutureSinglePermession(
              userProvider.user.id, userProvider.user.userToken);
      refreshController.refreshCompleted();
    } else {
      Provider.of<UserPermessionsData>(context, listen: false)
          .getFutureSinglePermession(
              widget.memberId, userProvider.user.userToken);
      refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isFilter
        ? Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final permList = widget.permessionsList[index];
                return Column(
                  children: [
                    ExpandedPermessionsTile(
                      isAdmin: false,
                      userPermessions: permList,
                      currentIndex: index,
                    ),
                    const Divider()
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
              header: const WaterDropMaterialHeader(
                color: Colors.white,
                backgroundColor: Colors.orange,
              ),
              child: Provider.of<UserPermessionsData>(context, listen: true)
                      .isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: ColorManager.primary),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final permList = widget.permessionsList[index];
                        return Column(
                          children: [
                            ExpandedPermessionsTile(
                              userPermessions: permList,
                              currentIndex: index,
                              isAdmin: widget.memberId == "" ? false : true,
                            ),
                            const Divider()
                          ],
                        );
                      },
                      itemCount: widget.permessionsList.length,
                    ),
            ),
          );
  }
}
