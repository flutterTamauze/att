import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Settings/settings.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/UserFullData/member_tile.dart';
import 'package:qr_users/widgets/UserFullData/rounded_searchBar.dart';
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
  AutoCompleteTextField searchTextField;
  final ScrollController _scrollController = ScrollController();
  String currentShiftName;
  // void _onRefresh() async {
  //   var userProvider = Provider.of<UserData>(context, listen: false);
  //   var comProvier = Provider.of<CompanyData>(context, listen: false);

  //   // monitor network fetch
  //   print("refresh");
  //   // if failed,use refreshFailed()
  //   await Provider.of<MemberData>(context, listen: false).getAllCompanyMember(
  //       Provider.of<SiteData>(context, listen: false)
  //           .dropDownSitesList[siteIndex]
  //           .id,
  //       comProvier.com.id,
  //       userProvider.user.userToken,
  //       context,
  //       -1);
  //   refreshController.refreshCompleted();
  // }

  @override
  void didChangeDependencies() {
    var memberData = Provider.of<MemberData>(context, listen: false);
    memberData.allPageIndex = 0;
    memberData.byShiftPageIndex = 0;
    memberData.bySitePageIndex = 0;
    memberData.keepRetriving = true;

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

        if (Provider.of<MemberData>(context, listen: false).keepRetriving) {
          print("entered");
          if (siteIndex == 0) {
            await Provider.of<MemberData>(context, listen: false)
                .getAllCompanyMember(-1, comProvier.com.id,
                    userProvider.user.userToken, context, -1);
          } else if (Provider.of<SiteData>(context, listen: false)
                  .dropDownShiftIndex !=
              0) {
            await Provider.of<MemberData>(context, listen: false)
                .getAllCompanyMember(
                    Provider.of<SiteShiftsData>(context, listen: false)
                        .siteShiftList[siteIndex]
                        .siteId,
                    comProvier.com.id,
                    userProvider.user.userToken,
                    context,
                    Provider.of<SiteShiftsData>(context, listen: false)
                        .shifts[Provider.of<SiteData>(context, listen: false)
                            .dropDownShiftIndex]
                        .shiftId);
          } else {
            await Provider.of<MemberData>(context, listen: false)
                .getAllCompanyMember(
                    Provider.of<SiteShiftsData>(context, listen: false)
                        .siteShiftList[siteIndex - 1]
                        .siteId,
                    comProvier.com.id,
                    userProvider.user.userToken,
                    context,
                    -1);
          }
        }
      }
    });
    super.didChangeDependencies();
  }

  getData() async {
    var userProvider = Provider.of<UserData>(context);
    var comProvier = Provider.of<CompanyData>(context);

    if (widget.selectedIndex != -1) {
      print("widget index");
      print(widget.selectedIndex);
      siteIndex = widget.selectedIndex;
      if (widget.comingFromShifts) {
        await Provider.of<MemberData>(context, listen: false)
            .getAllCompanyMember(
                Provider.of<SiteShiftsData>(context, listen: false)
                    .siteShiftList[siteIndex == 0 ? 0 : siteIndex - 1]
                    .siteId,
                comProvier.com.id,
                userProvider.user.userToken,
                context,
                Provider.of<SiteShiftsData>(context, listen: false)
                    .shifts[Provider.of<SiteData>(context, listen: false)
                        .dropDownShiftIndex]
                    .shiftId);
      } else if (!widget.comingFromShifts) {
        Provider.of<MemberData>(context, listen: false).getAllCompanyMember(
            Provider.of<SiteShiftsData>(context, listen: false)
                .siteShiftList[siteIndex - 1]
                .siteId,
            comProvier.com.id,
            userProvider.user.userToken,
            context,
            -1);
      }
    } else {
      await Provider.of<MemberData>(context, listen: false)
          .getAllCompanyMember(
              -1, comProvier.com.id, userProvider.user.userToken, context, -1)
          .then((value) async {
        print("Got members");
      });
    }
    if (mounted)
      widget.selectedValue = Provider.of<SiteShiftsData>(context, listen: false)
          .sites[siteIndex]
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
  searchInList(String value, int siteId, int companyId) {
    if (value.isNotEmpty) {
      print(companyId);
      Provider.of<MemberData>(context, listen: false).searchUsersList(
          value,
          Provider.of<UserData>(context, listen: false).user.userToken,
          siteId,
          companyId,
          context);
    } else {
      Provider.of<MemberData>(context, listen: false).resetUsers();
    }
  }

  int getSiteIndex(String siteName) {
    var list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].siteName) {
        return i;
      }
    }
    return -1;
  }

  Settings settings = Settings();
  Timer _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    var companyProv = Provider.of<CompanyData>(context, listen: false);
    var siteProv = Provider.of<SiteShiftsData>(context, listen: false);
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () async {
            for (int i = 0; i < siteProv.sites.length; i++) {
              print(siteProv.sites[i].name);
            }
            print(siteProv.sites.length);

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
                                } else {
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
                                                    1 &&
                                                _nameController.text == "" &&
                                                Provider.of<MemberData>(context)
                                                        .loadingShifts ==
                                                    false) {
                                              Timer(
                                                Duration(milliseconds: 1),
                                                () => _scrollController.jumpTo(
                                                    _scrollController.position
                                                            .maxScrollExtent -
                                                        10),
                                              );
                                            }

                                            return Column(
                                              children: [
                                                Container(
                                                  height: 110.h,
                                                  width: 330.w,
                                                  child: RoundedSearchBar(
                                                    list: Provider.of<
                                                                SiteShiftsData>(
                                                            context,
                                                            listen: true)
                                                        .sites,
                                                    dropdownValue:
                                                        widget.selectedValue,
                                                    resetTextFieldFun: () {
                                                      setState(() {
                                                        _nameController.text =
                                                            "";
                                                      });
                                                    },
                                                    searchFun: (value) {
                                                      int siteiD = -1;
                                                      int siteindex =
                                                          getSiteIndex(Provider
                                                                  .of<SiteData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                              .siteValue);

                                                      if (siteindex != -1) {
                                                        siteiD = Provider.of<
                                                                    SiteShiftsData>(
                                                                context,
                                                                listen: false)
                                                            .siteShiftList[
                                                                siteindex]
                                                            .siteId;
                                                      }

                                                      searchInList(
                                                          value,
                                                          siteiD,
                                                          Provider.of<CompanyData>(
                                                                  context,
                                                                  listen: false)
                                                              .com
                                                              .id);
                                                      setState(() {
                                                        currentShiftName =
                                                            value;
                                                      });
                                                      // do something with query
                                                    },
                                                    textController:
                                                        _nameController,
                                                    dropdownFun: (value) {
                                                      setState(() {
                                                        widget.selectedValue =
                                                            value;
                                                        print(
                                                            "current : ${widget.selectedValue}");
                                                        currentShiftName = "";
                                                        _nameController.clear();
                                                        Provider.of<MemberData>(
                                                                context,
                                                                listen: false)
                                                            .userSearchMember
                                                            .clear();
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
                                                                Provider.of<SiteShiftsData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .sites[
                                                                        siteIndex]
                                                                    .id,
                                                                companyProv
                                                                    .com.id,
                                                                userProvider
                                                                    .user
                                                                    .userToken,
                                                                context,
                                                                -1);
                                                        setState(() {
                                                          widget.selectedValue =
                                                              siteProv
                                                                  .sites[
                                                                      siteIndex]
                                                                  .name;
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                    child: _nameController
                                                                    .text !=
                                                                null &&
                                                            _nameController
                                                                    .text !=
                                                                ""
                                                        ? Consumer<MemberData>(
                                                            builder: (context,
                                                                value, child) {
                                                              return value
                                                                      .loadingSearch
                                                                  ? Center(
                                                                      child: Lottie.asset(
                                                                          "resources/searching.json",
                                                                          width: 200
                                                                              .w,
                                                                          height:
                                                                              200.h),
                                                                    )
                                                                  : value.userSearchMember
                                                                              .length ==
                                                                          0
                                                                      ? Center(
                                                                          child:
                                                                              Text(
                                                                            "لا يوجد نتائج للبحث",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                          ),
                                                                        )
                                                                      : Container(
                                                                          alignment: Alignment
                                                                              .topCenter,
                                                                          width:
                                                                              double.infinity,
                                                                          child: ListView.builder(
                                                                              itemCount: value.userSearchMember.length,
                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                return Directionality(
                                                                                  textDirection: TextDirection.rtl,
                                                                                  child: InkWell(
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
                                                                                          child: Text(
                                                                                            value.userSearchMember[index].username,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }));
                                                            },
                                                          )
                                                        : snapshot.data ==
                                                                "noInternet"
                                                            ? CenterMessageText(
                                                                message:
                                                                    "لا يوجد اتصال بالأنترنت")
                                                            : memberData.membersList
                                                                        .length !=
                                                                    0
                                                                ? Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .topCenter,
                                                                    width: double
                                                                        .infinity,
                                                                    child: ListView.builder(
                                                                        controller: _scrollController,
                                                                        itemCount: memberData.membersListScreenDropDownSearch.length,
                                                                        itemBuilder: (BuildContext context, int index) {
                                                                          Member
                                                                              user =
                                                                              memberData.membersListScreenDropDownSearch[index];
                                                                          return MemberTile(
                                                                            index:
                                                                                index,
                                                                            user:
                                                                                memberData.membersListScreenDropDownSearch[index],
                                                                            onTapDelete:
                                                                                () {
                                                                              settings.deleteUser(context, user.id, index, user.name);
                                                                            },
                                                                            onResetMac:
                                                                                () {
                                                                              settings.resetMacAddress(context, user.id);
                                                                            },
                                                                          );
                                                                        }),
                                                                  )
                                                                : widget.selectedValue ==
                                                                            "كل المواقع" ||
                                                                        Provider.of<SiteData>(context, listen: false).dropDownShiftIndex ==
                                                                            0
                                                                    ? Center(
                                                                        child:
                                                                            AutoSizeText(
                                                                          "لا يوجد مستخدمين بهذا الموقع\nبرجاء اضافة مستخدمين",
                                                                          maxLines:
                                                                              1,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              height: 2,
                                                                              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
                                                                              fontWeight: FontWeight.w700),
                                                                        ),
                                                                      )
                                                                    : Center(
                                                                        child:
                                                                            AutoSizeText(
                                                                          "لا يوجد مستخدمين بهذه المناوبة\nبرجاء اضافة مستخدمين",
                                                                          maxLines:
                                                                              1,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              height: 2,
                                                                              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
                                                                              fontWeight: FontWeight.w700),
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
                                }
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
                          shiftIndex:
                              Provider.of<SiteData>(context, listen: false)
                                  .currentShiftIndex,
                          comingFromShifts: widget.comingFromShifts ?? false,
                          shiftName: widget.comingShiftName == ""
                              ? Provider.of<SiteData>(context).siteValue
                              : widget.comingShiftName,
                          mainTitle: 'إضافة مستخدم',
                          mainIconData: Icons.person_add,
                        )
                      : MultipleFloatingButtons(
                          shiftIndex:
                              Provider.of<SiteData>(context, listen: false)
                                  .currentShiftIndex,
                          comingFromShifts: widget.comingFromShifts,
                          shiftName: "",
                          mainTitle: "",
                          mainIconData: Icons.person_add,
                        )),
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
