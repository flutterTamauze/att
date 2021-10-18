import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/AddUserScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/Settings/settings.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Shared/shimmer_builder.dart';
import 'package:qr_users/widgets/UserFullData/member_tile.dart';
import 'package:qr_users/widgets/UserFullData/rounded_searchBar.dart';
import 'package:qr_users/widgets/UserFullData/user_properties_menu.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

class UsersScreen extends StatefulWidget {
  final selectedIndex;
  var comingFromShifts = false;

  String comingShiftName;
  UsersScreen(this.selectedIndex, this.comingFromShifts, this.comingShiftName);

  @override
  _UsersScreenState createState() => _UsersScreenState();
  String selectedValue = "كل المواقع";
}

class _UsersScreenState extends State<UsersScreen> {
  TextEditingController _nameController = TextEditingController();
  // AutoCompleteTextField searchTextField;
  final ScrollController _scrollController = ScrollController();
  String currentShiftName;
  void _onRefresh() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvier = Provider.of<CompanyData>(context, listen: false);

    // monitor network fetch
    print("refresh");
    // if failed,use refreshFailed()
    await Provider.of<MemberData>(context, listen: false).getAllCompanyMember(
        Provider.of<SiteData>(context, listen: false)
            .dropDownSitesList[siteIndex]
            .id,
        comProvier.com.id,
        userProvider.user.userToken,
        context);
    refreshController.refreshCompleted();
  }

  bool goMaxScroll = true;
  @override
  void didChangeDependencies() {
    Provider.of<MemberData>(context, listen: false).allPageIndex = 0;
    Provider.of<MemberData>(context, listen: false).bySitePageIndex = 0;
    Provider.of<MemberData>(context, listen: false).keepRetriving = true;
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvier = Provider.of<CompanyData>(context, listen: false);
    if (widget.comingFromShifts == false) {
      if (mounted)
        Provider.of<SiteData>(context, listen: false)
            .setSiteValue("كل المواقع");
    }

    getData();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        log("reached end of list");
        if (goMaxScroll) {
          if (Provider.of<MemberData>(context, listen: false).keepRetriving) {
            print("entered");

            await Provider.of<MemberData>(context, listen: false)
                .getAllCompanyMember(
                    Provider.of<SiteData>(context, listen: false)
                        .dropDownSitesList[siteIndex]
                        .id,
                    comProvier.com.id,
                    userProvider.user.userToken,
                    context);
          }
        }
        goMaxScroll = true;
      }
    });
    super.didChangeDependencies();
  }

  getData() async {
    var userProvider = Provider.of<UserData>(context);
    var comProvier = Provider.of<CompanyData>(context);

    if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
      await Provider.of<SiteData>(context, listen: false)
          .getSitesByCompanyId(
        comProvier.com.id,
        userProvider.user.userToken,
        context,
      )
          .then((value) async {
        print("Got Sites");
      });
    }
    if (Provider.of<ShiftsData>(context, listen: false).shiftsList.isEmpty) {
      await Provider.of<ShiftsData>(context, listen: false)
          .getShifts(comProvier.com.id, userProvider.user.userToken, context,
              userProvider.user.userType, userProvider.user.userSiteId)
          .then((value) async {
        print("Got shifts");
      });
    }
    if (widget.selectedIndex != -1) {
      siteIndex = widget.selectedIndex;
      if (widget.comingFromShifts) {
        print(
          "eeeE  ${Provider.of<SiteData>(context, listen: false).dropDownSitesList[siteIndex].id}",
        );
        await Provider.of<MemberData>(context, listen: false)
            .getAllCompanyMember(
                Provider.of<SiteData>(context, listen: false)
                    .dropDownSitesList[siteIndex]
                    .id,
                comProvier.com.id,
                userProvider.user.userToken,
                context);

        List<Member> finalTest = [];

        Provider.of<MemberData>(context, listen: false)
            .copyMemberList
            .forEach((element) {
          if (element.shiftId ==
              Provider.of<SiteData>(context, listen: false).currentShiftID) {
            finalTest.add(element);
          }
        });
        Provider.of<MemberData>(context, listen: false)
            .setMmemberList(finalTest);
      } else if (!widget.comingFromShifts) {
        print(
          "eeeE  ${Provider.of<SiteData>(context, listen: false).dropDownSitesList[siteIndex].id}",
        );
        Provider.of<MemberData>(context, listen: false).getAllCompanyMember(
            Provider.of<SiteData>(context, listen: false)
                .dropDownSitesList[siteIndex]
                .id,
            comProvier.com.id,
            userProvider.user.userToken,
            context);
      }
    } else {
      await Provider.of<MemberData>(context, listen: false)
          .getAllCompanyMember(
              -1, comProvier.com.id, userProvider.user.userToken, context)
          .then((value) async {
        print("Got members");
      });
    }

    widget.selectedValue = Provider.of<SiteData>(context, listen: false)
        .dropDownSitesList[siteIndex]
        .name;
  }

  Future<List<String>> getPhoneInEdit(String phoneNumberEdit) async {
    intlPhone.PhoneNumber result =
        await intlPhone.PhoneNumber.getRegionInfoFromPhoneNumber(
            phoneNumberEdit);
    return [result.isoCode, result.dialCode];
  }

  int siteIndex = 0;
  String selectedId = "";

  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  searchInList(String value) {
    if (value.isNotEmpty) {
      Provider.of<MemberData>(context, listen: false).searchUsersList(value);
    } else {
      Provider.of<MemberData>(context, listen: false).resetUsers();
    }
  }

  Settings settings = Settings();
  Widget build(BuildContext context) {
    var companyProv = Provider.of<CompanyData>(context, listen: false);
    var siteProv = Provider.of<SiteData>(context, listen: false);
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () {},
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
                        Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: SmallDirectoriesHeader(
                            Lottie.asset("resources/user.json", repeat: false),
                            "دليل المستخدمين",
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder(
                              future:
                                  Provider.of<SiteData>(context).futureListener,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    color: Colors.white,
                                    child: Center(
                                      child: Platform.isIOS
                                          ? CupertinoActivityIndicator()
                                          : CircularProgressIndicator(
                                              backgroundColor: Colors.white,
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(Colors.orange),
                                            ),
                                    ),
                                  );
                                }

                                return FutureBuilder(
                                    future: Provider.of<MemberData>(context)
                                        .futureListener,
                                    builder: (context, snapshot) {
                                      if ((!snapshot.hasData ||
                                              snapshot.connectionState ==
                                                  ConnectionState.waiting) &&
                                          Provider.of<MemberData>(context)
                                                  .membersList
                                                  .length ==
                                              0 &&
                                          Provider.of<MemberData>(context)
                                              .keepRetriving) {
                                        return Container(
                                          color: Colors.white,
                                          child: Center(
                                            child: Platform.isIOS
                                                ? CupertinoActivityIndicator(
                                                    radius: 20,
                                                  )
                                                : CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.white,
                                                    valueColor:
                                                        new AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.orange),
                                                  ),
                                          ),
                                        );
                                      }
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:

                                        case ConnectionState.done:
                                          if (Provider.of<MemberData>(context)
                                                      .allPageIndex !=
                                                  1 &&
                                              Provider.of<MemberData>(context)
                                                      .bySitePageIndex !=
                                                  1) {
                                            goMaxScroll = false;
                                            Timer(
                                              Duration(milliseconds: 1),
                                              () => _scrollController.jumpTo(
                                                  _scrollController.position
                                                      .maxScrollExtent),
                                            );
                                          }

                                          return Column(
                                            children: [
                                              Container(
                                                height: 110.h,
                                                width: 330.w,
                                                child: RoundedSearchBar(
                                                  list: Provider.of<SiteData>(
                                                          context,
                                                          listen: true)
                                                      .dropDownSitesList,
                                                  dropdownValue:
                                                      widget.selectedValue,
                                                  searchFun: (value) {
                                                    print(value);
                                                    searchInList(value);
                                                    currentShiftName = value;
                                                  },
                                                  textController:
                                                      _nameController,
                                                  dropdownFun: (value) {
                                                    setState(() {
                                                      widget.selectedValue =
                                                          value;
                                                      print(
                                                          "current : ${widget.selectedValue}");
                                                    });

                                                    var userProvider =
                                                        Provider.of<UserData>(
                                                            context,
                                                            listen: false);
                                                    var id =
                                                        settings.getsiteIndex(
                                                            context, value);
                                                    if (id != siteIndex) {
                                                      siteIndex = id;
                                                      Provider.of<MemberData>(
                                                              context,
                                                              listen: false)
                                                          .allPageIndex = 0;
                                                      Provider.of<MemberData>(
                                                              context,
                                                              listen: false)
                                                          .bySitePageIndex = 0;
                                                      Provider.of<MemberData>(
                                                              context,
                                                              listen: false)
                                                          .keepRetriving = true;
                                                      Provider.of<MemberData>(
                                                              context,
                                                              listen: false)
                                                          .getAllCompanyMember(
                                                              siteProv
                                                                  .dropDownSitesList[
                                                                      siteIndex]
                                                                  .id,
                                                              companyProv
                                                                  .com.id,
                                                              userProvider.user
                                                                  .userToken,
                                                              context);
                                                      setState(() {
                                                        widget.selectedValue =
                                                            siteProv
                                                                .dropDownSitesList[
                                                                    siteIndex]
                                                                .name;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                  child:
                                                      memberData.membersList
                                                                  .length !=
                                                              0
                                                          ? Container(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              width: double
                                                                  .infinity,
                                                              child: ListView
                                                                  .builder(
                                                                      controller:
                                                                          _scrollController,
                                                                      itemCount: memberData
                                                                          .membersListScreenDropDownSearch
                                                                          .length,
                                                                      itemBuilder:
                                                                          (BuildContext context,
                                                                              int index) {
                                                                        Member
                                                                            user =
                                                                            memberData.membersListScreenDropDownSearch[index];
                                                                        return InkWell(
                                                                          onLongPress:
                                                                              () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return Container(
                                                                                  child: UserPropertiesMenu(
                                                                                    user: user,
                                                                                  ),
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                          child:
                                                                              MemberTile(
                                                                            user:
                                                                                memberData.membersListScreenDropDownSearch[index],
                                                                            onTapDelete:
                                                                                () {
                                                                              settings.deleteUser(context, user, index);
                                                                            },
                                                                            onTapEdit:
                                                                                () async {
                                                                              var phone = await getPhoneInEdit(user.phoneNumber[0] != "+" ? "+${memberData.membersListScreenDropDownSearch[index].phoneNumber}" : memberData.membersListScreenDropDownSearch[index].phoneNumber);
                                                                              Navigator.of(context).push(
                                                                                new MaterialPageRoute(
                                                                                  builder: (context) => AddUserScreen(user, index, true, phone[0], phone[1], false, ""),
                                                                                ),
                                                                              );
                                                                            },
                                                                            onResetMac:
                                                                                () {
                                                                              settings.resetMacAddress(context, user);
                                                                            },
                                                                          ),
                                                                        );
                                                                      }),
                                                            )
                                                          : Center(
                                                              child:
                                                                  AutoSizeText(
                                                                "لا يوجد مستخدمين بهذا الموقع\nبرجاء اضافة مستخدمين",
                                                                maxLines: 1,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    height: 2,
                                                                    fontSize: ScreenUtil().setSp(
                                                                        16,
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
                                                ? CupertinoActivityIndicator(
                                                    radius: 20,
                                                  )
                                                : CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.white,
                                                    valueColor:
                                                        new AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.orange),
                                                  ),
                                          );
                                      }
                                    });
                              }),
                        ),
                        Provider.of<MemberData>(context).membersList.length != 0
                            ? Provider.of<MemberData>(context).isLoading
                                ? Column(
                                    children: [
                                      Center(
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
                  ],
                ),
              ),
              floatingActionButton:
                  Provider.of<UserData>(context, listen: false).user.userType ==
                          4
                      ? MultipleFloatingButtons(
                          comingFromShifts: widget.comingFromShifts,
                          shiftName: widget.comingShiftName,
                          mainTitle: 'إضافة مستخدم',
                          mainIconData: Icons.person_add,
                        )
                      : Container()),
        ),
      );
    });
  }

  Future<bool> onWillPop() {
    Provider.of<MemberData>(context, listen: false).allPageIndex = 0;
    Provider.of<MemberData>(context, listen: false).bySitePageIndex = 0;
    Provider.of<MemberData>(context, listen: false).keepRetriving = true;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NavScreenTwo(3)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}
