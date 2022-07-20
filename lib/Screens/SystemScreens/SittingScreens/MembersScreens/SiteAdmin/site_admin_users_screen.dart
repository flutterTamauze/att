import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/AddUserScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Settings/settings.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

import '../SiteAdminUsersScreen.dart';
import '../UserFullData.dart';

class SiteAdminUserScreen extends StatefulWidget {
  final selectedIndex;
  var comingFromShifts = false;

  String comingShiftName;
  SiteAdminUserScreen(
      this.selectedIndex, this.comingFromShifts, this.comingShiftName);

  @override
  _SiteAdminUserScreenState createState() => _SiteAdminUserScreenState();
  String selectedValue = "كل المواقع";
}

class _SiteAdminUserScreenState extends State<SiteAdminUserScreen> {
  TextEditingController _nameController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  // AutoCompleteTextField searchTextField;
  String currentShiftName;
  // void _onRefresh() async {
  //   var userProvider = Provider.of<UserData>(context, listen: false);
  //   var comProvier = Provider.of<CompanyData>(context, listen: false);

  //   // monitor network fetch
  //   debugPrint("refresh");

  //   await Provider.of<MemberData>(context, listen: false).getAllSiteMembers(
  //       userProvider.user.userSiteId, userProvider.user.userToken, context);
  //   refreshController.refreshCompleted();
  // }
  Settings settings = Settings();
  @override
  void didChangeDependencies() {
    Provider.of<MemberData>(context, listen: false).allPageIndex = 0;
    Provider.of<MemberData>(context, listen: false).byShiftPageIndex = 0;
    Provider.of<MemberData>(context, listen: false).bySitePageIndex = 0;
    Provider.of<MemberData>(context, listen: false).keepRetriving = true;
    Provider.of<MemberData>(context, listen: false).membersList.clear();
    final userProvider = Provider.of<UserData>(context, listen: false);
    final comProvier = Provider.of<CompanyData>(context, listen: false);
    if (widget.comingFromShifts == false) {
      if (mounted) if (Provider.of<UserData>(context, listen: false)
              .user
              .userType !=
          2) {
        Provider.of<SiteData>(context, listen: false)
            .setSiteValue("كل المواقع");
      }
    }

    getData();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // log("reached end of list");
        if (Provider.of<MemberData>(context, listen: false).keepRetriving) {
          await Provider.of<MemberData>(context, listen: false)
              .getAllCompanyMember(
                  userProvider.user.userSiteId,
                  comProvier.com.id,
                  userProvider.user.userToken,
                  context,
                  Provider.of<ShiftsData>(context, listen: false)
                      .shiftsList[Provider.of<SiteData>(context, listen: false)
                          .dropDownShiftIndex]
                      .shiftId);
        }
      }
    });
    super.didChangeDependencies();
  }

  getData() async {
    final userProvider = Provider.of<UserData>(context);
    final comProvier = Provider.of<CompanyData>(context);

    await Provider.of<ShiftsData>(context, listen: false)
        .getShifts(comProvier.com.id, userProvider.user.userToken, context,
            userProvider.user.userType, userProvider.user.userSiteId)
        .then((value) async {
      debugPrint("Got shifts");
    });
    log("user site id ${userProvider.user.userSiteId}");
    await Provider.of<MemberData>(context, listen: false).getAllCompanyMember(
        userProvider.user.userSiteId,
        comProvier.com.id,
        userProvider.user.userToken,
        context,
        Provider.of<ShiftsData>(context, listen: false)
            .shiftsList[Provider.of<SiteData>(context, listen: false)
                .dropDownShiftIndex]
            .shiftId);
  }

  Future<List<String>> getPhoneInEdit(String phoneNumberEdit) async {
    final intlPhone.PhoneNumber result =
        await intlPhone.PhoneNumber.getRegionInfoFromPhoneNumber(
            phoneNumberEdit);
    return [result.isoCode, result.dialCode];
  }

  int siteIndex = 0;
  String selectedId = "";

  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  searchInList(String value, int siteId, int companyId) {
    if (value.isNotEmpty) {
      Provider.of<MemberData>(context, listen: false).searchUsersList(
          value,
          Provider.of<UserData>(context, listen: false).user.userToken,
          Provider.of<UserData>(context, listen: false).user.userSiteId,
          companyId,
          context);
    } else {
      Provider.of<MemberData>(context, listen: false).resetUsers();
    }
  }

  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            endDrawer: NotificationItem(),
            backgroundColor: Colors.white,
            body: Container(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Header(
                        nav: false,
                        goUserHomeFromMenu: false,
                        goUserMenu: false,
                      ),

                      ///Title
                      ///
                      SmallDirectoriesHeader(
                        Lottie.asset("resources/user.json", repeat: false),
                        getTranslated(context, "دليل المستخدمين"),
                      ),

                      ///List OF SITES
                      Expanded(
                        child: FutureBuilder(
                            future:
                                Provider.of<MemberData>(context).futureListener,
                            builder: (context, snapshot) {
                              if (Provider.of<MemberData>(context)
                                          .membersList
                                          .length ==
                                      0 &&
                                  Provider.of<MemberData>(context)
                                      .keepRetriving) {
                                return Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Platform.isIOS
                                        ? const CupertinoActivityIndicator(
                                            radius: 20,
                                          )
                                        : const CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.orange),
                                          ),
                                  ),
                                );
                              }
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:

                                case ConnectionState.done:
                                  // if (Provider.of<MemberData>(context)
                                  //             .allPageIndex !=
                                  //         1 &&
                                  //     Provider.of<MemberData>(context)
                                  //             .bySitePageIndex !=
                                  //         1 &&
                                  //     _nameController.text == "" &&
                                  //     Provider.of<MemberData>(context)
                                  //             .loadingShifts ==
                                  //         false) {
                                  //   if (Provider.of<UserData>(context)
                                  //           .user
                                  //           .userType !=
                                  //       2) {
                                  //     if (_scrollController.hasClients) {
                                  //       Timer(
                                  //         const Duration(milliseconds: 1),
                                  //         () => _scrollController.jumpTo(
                                  //             _scrollController.position
                                  //                     .maxScrollExtent -
                                  //                 10),
                                  //       );
                                  //     }
                                  //   }
                                  // }
                                  return Column(
                                    children: [
                                      Container(
                                        height: 110.h,
                                        width: 330.w,
                                        child: RoundedSearchBarSiteAdmin(
                                          list: Provider.of<SiteData>(context,
                                                  listen: true)
                                              .dropDownSitesList,
                                          dropdownValue: widget.selectedValue,
                                          searchFun: (value) {
                                            searchInList(
                                                value,
                                                Provider.of<UserData>(context,
                                                        listen: false)
                                                    .user
                                                    .userSiteId,
                                                Provider.of<CompanyData>(
                                                        context,
                                                        listen: false)
                                                    .com
                                                    .id);
                                            setState(() {
                                              currentShiftName = value;
                                            });
                                            // do something with query
                                          },
                                          resetTextFieldFun: () {
                                            setState(() {
                                              _nameController.text = "";
                                            });
                                          },
                                          textController: _nameController,
                                          dropdownFun: (value) {
                                            setState(() {
                                              widget.selectedValue = value;
                                              debugPrint(
                                                  "current : ${widget.selectedValue}");
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                          child:
                                              _nameController.text != null &&
                                                      _nameController.text != ""
                                                  ? Consumer<MemberData>(
                                                      builder: (context, value,
                                                          child) {
                                                        return value
                                                                .loadingSearch
                                                            ? Container(
                                                                child: Center(
                                                                    child: Lottie.asset(
                                                                        "resources/searching.json",
                                                                        width: 200
                                                                            .w,
                                                                        height:
                                                                            200.h)),
                                                              )
                                                            : value.userSearchMember
                                                                        .length ==
                                                                    0
                                                                ? CenterMessageText(
                                                                    message: getTranslated(
                                                                        context,
                                                                        "لا يوجد نتائج للبحث"))
                                                                : Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .topCenter,
                                                                    width: double
                                                                        .infinity,
                                                                    child: ListView
                                                                        .builder(
                                                                            itemCount:
                                                                                value.userSearchMember.length,
                                                                            itemBuilder: (BuildContext context, int index) {
                                                                              return InkWell(
                                                                                onTap: () {
                                                                                  Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                        builder: (context) => UserFullDataScreen(
                                                                                          index: index,
                                                                                          onResetMac: () {
                                                                                            settings.resetMacAddress(context, value.userSearchMember[index].id);
                                                                                          },
                                                                                          onTapDelete: () {
                                                                                            settings.deleteUser(context, value.userSearchMember[index].id, index, value.userSearchMember[index].username);
                                                                                          },
                                                                                          siteIndex: siteIndex,
                                                                                          userId: value.userSearchMember[index].id,
                                                                                        ),
                                                                                      ));
                                                                                },
                                                                                child: Card(
                                                                                  elevation: 2,
                                                                                  child: Container(
                                                                                    alignment: Alignment.centerRight,
                                                                                    width: double.infinity,
                                                                                    height: 50.h,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(10.0),
                                                                                      child: AutoSizeText(
                                                                                        value.userSearchMember[index].username,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }));
                                                      },
                                                    )
                                                  : memberData.membersList
                                                              .length !=
                                                          0
                                                      ? Container(
                                                          child:
                                                              ListView.builder(
                                                                  controller:
                                                                      _scrollController,
                                                                  itemCount:
                                                                      memberData
                                                                          .membersListScreenDropDownSearch
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    return MemberTile(
                                                                      user: memberData
                                                                              .membersListScreenDropDownSearch[
                                                                          index],
                                                                      onTapDelete:
                                                                          () {
                                                                        return showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return RoundedAlert(
                                                                                  onPressed: () async {
                                                                                    showDialog(
                                                                                        context: context,
                                                                                        builder: (BuildContext context) {
                                                                                          return RoundedLoadingIndicator();
                                                                                        });
                                                                                    final token = Provider.of<UserData>(context, listen: false).user.userToken;
                                                                                    if (await memberData.deleteMember(memberData.membersListScreenDropDownSearch[index].id, index, context) == "Success") {
                                                                                      Navigator.pop(context);
                                                                                      successfullDelete(context);
                                                                                    } else {
                                                                                      unSuccessfullDelete(context);
                                                                                    }
                                                                                    Navigator.pop(context);
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  title: getTranslated(context, 'إزالة مستخدم'),
                                                                                  content: "${getTranslated(context, "هل تريد إزالة")}${memberData.membersListScreenDropDownSearch[index].name} ؟");
                                                                            });
                                                                      },
                                                                      onTapEdit:
                                                                          () async {
                                                                        final phone = await getPhoneInEdit(memberData.membersListScreenDropDownSearch[index].phoneNumber[0] !=
                                                                                "+"
                                                                            ? "+${memberData.membersListScreenDropDownSearch[index].phoneNumber}"
                                                                            : memberData.membersListScreenDropDownSearch[index].phoneNumber);

                                                                        Navigator.of(context)
                                                                            .push(
                                                                          new MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                AddUserScreen(
                                                                              memberData.membersListScreenDropDownSearch[index],
                                                                              index,
                                                                              true,
                                                                              phone[0],
                                                                              phone[1],
                                                                              false,
                                                                              "",
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      onResetMac:
                                                                          () {
                                                                        return showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return RoundedAlert(
                                                                                  onPressed: () async {
                                                                                    showDialog(
                                                                                        context: context,
                                                                                        builder: (BuildContext context) {
                                                                                          return RoundedLoadingIndicator();
                                                                                        });
                                                                                    final token = Provider.of<UserData>(context, listen: false).user.userToken;
                                                                                    if (await memberData.resetMemberMac(memberData.membersListScreenDropDownSearch[index].id, context) == "Success") {
                                                                                      Navigator.pop(context);
                                                                                      Fluttertoast.showToast(
                                                                                        msg: getTranslated(
                                                                                          context,
                                                                                          "تم اعادة الضبط بنجاح",
                                                                                        ),
                                                                                        gravity: ToastGravity.CENTER,
                                                                                        toastLength: Toast.LENGTH_SHORT,
                                                                                        timeInSecForIosWeb: 1,
                                                                                        backgroundColor: Colors.green,
                                                                                        textColor: Colors.white,
                                                                                        fontSize: setResponsiveFontSize(16),
                                                                                      );
                                                                                    } else {
                                                                                      Fluttertoast.showToast(
                                                                                        msg: getTranslated(context, "خطأ في اعادة الضبط"),
                                                                                        gravity: ToastGravity.CENTER,
                                                                                        toastLength: Toast.LENGTH_SHORT,
                                                                                        timeInSecForIosWeb: 1,
                                                                                        backgroundColor: Colors.red,
                                                                                        textColor: Colors.black,
                                                                                        fontSize: setResponsiveFontSize(16),
                                                                                      );
                                                                                    }
                                                                                    Navigator.pop(context);
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  title: getTranslated(context, 'إعادة ضبط بيانات مستخدم'),
                                                                                  content: getTranslated(context, "هل تريد اعادة ضبط بيانات هاتف المستخدم؟"));
                                                                            });
                                                                      },
                                                                    );
                                                                  }),
                                                        )
                                                      : Center(
                                                          child: AutoSizeText(
                                                            getTranslated(
                                                                context,
                                                                "لا يوجد مستخدمين بهذه المناوبة\nبرجاء اضافة مستخدمين"),
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                height: 2,
                                                                fontSize: ScreenUtil()
                                                                    .setSp(16,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        )),
                                    ],
                                  );
                                default:
                                  return Center(
                                    child: Platform.isIOS
                                        ? const CupertinoActivityIndicator(
                                            radius: 20,
                                          )
                                        : const CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.orange),
                                          ),
                                  );
                              }
                            }),
                      ),
                      Provider.of<MemberData>(context).membersList.length != 0
                          ? Provider.of<MemberData>(context).isLoading
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
                  Positioned(
                    left: 5.0,
                    top: 5.0,
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) => const NavScreenTwo(3),
                          ));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: MultipleFloatingButtons(
              shiftIndex: Provider.of<SiteData>(context, listen: false)
                  .currentShiftIndex,
              comingFromShifts: widget.comingFromShifts,
              shiftName: widget.comingShiftName == ""
                  ? Provider.of<SiteData>(context).siteValue
                  : widget.comingShiftName,
              mainTitle: "",
              mainIconData: Icons.person_add,
            ),
          ),
        ),
      );
    });
  }

  Future<bool> onWillPop() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NavScreenTwo(3)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}
