import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/HuaweiServices/huaweiService.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Shared/HandleNetwork_ServerDown/handleState.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'Widgets/display_pending_permessions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PendingCompanyPermessions extends StatefulWidget {
  const PendingCompanyPermessions();

  @override
  _PendingCompanyPermessionsState createState() =>
      _PendingCompanyPermessionsState();
}

class _PendingCompanyPermessionsState extends State<PendingCompanyPermessions> {
  final TextEditingController textEditingController = TextEditingController();
  Future<String> pendingPermessions;
  Future getPendingPermessions() async {
    final comId = Provider.of<CompanyData>(context, listen: false).com.id;
    final String token =
        Provider.of<UserData>(context, listen: false).user.userToken;
    pendingPermessions =
        Provider.of<UserPermessionsData>(context, listen: false)
            .getPendingCompanyPermessions(comId, token);
  }

  String comment;
  @override
  void initState() {
    Provider.of<UserPermessionsData>(context, listen: false).pageIndex = 0;
    Provider.of<UserPermessionsData>(context, listen: false).isLoading = false;
    Provider.of<UserPermessionsData>(context, listen: false).keepRetriving =
        true;
    super.initState();
    getPendingPermessions();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (Provider.of<UserPermessionsData>(context, listen: false)
            .keepRetriving) {
          await getPendingPermessions();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void _onRefresh() async {
    final userPerm = Provider.of<UserPermessionsData>(context, listen: false);
    userPerm.pendingCompanyPermessions.clear();
    userPerm.pageIndex = 0;
    // ignore: cascade_invocations
    userPerm.keepRetriving = true;
    setState(() {
      getPendingPermessions();
    });
  }

  int currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context) {
    final pendingList = Provider.of<UserPermessionsData>(context);
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: MultipleFloatingButtonsNoADD(),
      endDrawer: NotificationItem(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Header(
              nav: false,
              goUserMenu: false,
              goUserHomeFromMenu: false,
            ),
            SmallDirectoriesHeader(
              Lottie.asset("resources/calender.json", repeat: false),
              getTranslated(context, "طلبات الأذونات"),
            ),
            Divider(
              color: ColorManager.primary,
              endIndent: 50.w,
            ),
            FutureBuilder(
                future: pendingPermessions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      pendingList.pendingCompanyPermessions.length == 0 &&
                      Provider.of<UserPermessionsData>(context).keepRetriving) {
                    return Expanded(
                      child: Center(
                        child: Platform.isIOS
                            ? const CupertinoActivityIndicator(
                                radius: 20,
                              )
                            : const CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                              ),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: pendingList.pendingCompanyPermessions.length == 0
                          ? Center(
                              child: AutoSizeText(
                              getTranslated(
                                  context, "لا يوجد اذونات لم يتم الرد عليها"),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: setResponsiveFontSize(16)),
                              textAlign: TextAlign.center,
                            ))
                          : SmartRefresher(
                              onRefresh: _onRefresh,
                              controller: refreshController,
                              header: const WaterDropMaterialHeader(
                                color: Colors.white,
                                backgroundColor: Colors.orange,
                              ),
                              child: ListView.builder(
                                controller: _scrollController,
                                itemBuilder: (context, index) {
                                  final pending = pendingList
                                      .pendingCompanyPermessions[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Card(
                                      child: ExpandedPendingPermessions(
                                        isAdmin: true,
                                        userPermessions: pending,
                                        index: index,
                                        id: pending.permessionId,
                                        onRefused: () {
                                          return showDialog(
                                              context: context,
                                              builder: (BuildContext ctx) {
                                                return Directionality(
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    child:
                                                        RoundedAlertWithComment(
                                                      onTapped: (e) {
                                                        comment = e;
                                                      },
                                                      hint: getTranslated(
                                                          context, "سبب الرفض"),
                                                      onPressed: () async {
                                                        Navigator.pop(ctx);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return RoundedLoadingIndicator();
                                                            });
                                                        final String msg = await pendingList
                                                            .acceptOrRefusePendingPermession(
                                                                2,
                                                                pending
                                                                    .permessionId,
                                                                pending.userID,
                                                                pending
                                                                    .permessionDescription,
                                                                Provider.of<UserData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .user
                                                                    .userToken,
                                                                comment,
                                                                pending.date);
                                                        Navigator.pop(context);

                                                        if (msg ==
                                                            "Success : User Updated!") {
                                                          await sendFcmMessage(
                                                              category:
                                                                  "permession",
                                                              topicName: "",
                                                              userToken: pending
                                                                  .fcmToken,
                                                              title: "طلب اذن",
                                                              message:
                                                                  "تم رفض طلب الأذن");

                                                          Fluttertoast.showToast(
                                                              msg: getTranslated(
                                                                  context,
                                                                  "تم الرفض بنجاح"),
                                                              backgroundColor:
                                                                  Colors.green);
                                                        } else if (msg ==
                                                            "Fail: Permission out of date!") {
                                                          Fluttertoast.showToast(
                                                              msg: getTranslated(
                                                                  context,
                                                                  "خطأ فى الرفض : انتهى وقت الطلب"),
                                                              backgroundColor:
                                                                  Colors.red);
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg: getTranslated(
                                                                  context,
                                                                  "خطأ في الرفض"),
                                                              backgroundColor:
                                                                  Colors.red);
                                                        }
                                                      },
                                                      content: getTranslated(
                                                          context,
                                                          "تأكيد رفض الأذن"),
                                                      onCancel: () {},
                                                      title:
                                                          "${getTranslated(context, "رفض  طلب")} ${pendingList.pendingCompanyPermessions[index].user} ",
                                                    ));
                                              });
                                        },
                                        onAccept: () {
                                          return showDialog(
                                              context: context,
                                              builder: (BuildContext ctx) {
                                                return RoundedAlertWithComment(
                                                  onTapped: (comm) {
                                                    comment = comm;
                                                  },
                                                  hint: getTranslated(
                                                      context, "التفاصيل"),
                                                  onPressed: () async {
                                                    Navigator.pop(ctx);
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return RoundedLoadingIndicator();
                                                        });

                                                    final String msg = await pendingList
                                                        .acceptOrRefusePendingPermession(
                                                            1,
                                                            pending
                                                                .permessionId,
                                                            pending.userID,
                                                            pending
                                                                .permessionDescription,
                                                            Provider.of<UserData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .user
                                                                .userToken,
                                                            comment,
                                                            pending.date);
                                                    Navigator.pop(context);
                                                    if (msg ==
                                                        "Success : User Updated!") {
                                                      {
                                                        await sendFcmMessage(
                                                            category:
                                                                "permession",
                                                            topicName: "",
                                                            userToken: pending
                                                                .fcmToken,
                                                            title: "طلب اذن",
                                                            message:
                                                                "تم الموافقة على طلب الأذن");
                                                      }

                                                      Fluttertoast.showToast(
                                                          msg: getTranslated(
                                                              context,
                                                              "تم الموافقة بنجاح"),
                                                          backgroundColor:
                                                              Colors.green);
                                                    } else if (msg ==
                                                        "Fail: Permission out of date!") {
                                                      Fluttertoast.showToast(
                                                          msg: getTranslated(
                                                              context,
                                                              "خطأ فى الرفض : انتهى وقت الطلب"),
                                                          backgroundColor:
                                                              Colors.red);
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg: getTranslated(
                                                              context,
                                                              "خطأ في الموافقة"),
                                                          backgroundColor:
                                                              Colors.red);
                                                    }
                                                  },
                                                  content: getTranslated(
                                                      context,
                                                      "تأكيد الموافقة على الأذن"),
                                                  onCancel: () {},
                                                  title:
                                                      "${getTranslated(context, "الموافقة على طلب")} ${pendingList.pendingCompanyPermessions[index].user} ",
                                                );
                                              });
                                        },
                                      ),
                                    ),
                                  );
                                },
                                itemCount: pendingList
                                    .pendingCompanyPermessions.length,
                              ),
                            ),
                    );
                  }
                }),
            Provider.of<UserPermessionsData>(context)
                        .pendingCompanyPermessions
                        .length !=
                    0
                ? Provider.of<UserPermessionsData>(context).paginatedLoading
                    ? Column(
                        children: [
                          const Center(
                              child: CupertinoActivityIndicator(
                            radius: 15,
                          )),
                          Container(
                            height: 30,
                          )
                        ],
                      )
                    : Container()
                : Container()
          ],
        ),
      ),
    );
  }
}
