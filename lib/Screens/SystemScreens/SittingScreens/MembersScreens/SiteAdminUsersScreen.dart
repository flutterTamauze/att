import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';

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
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/UserFullData/user_properties_menu.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedButton.dart';

import 'UserFullData.dart';

class RoundedSearchBarSiteAdmin extends StatefulWidget {
  final Function searchFun;
  final Function dropdownFun;
  final Function resetTextFieldFun;
  bool iscomingFromShifts = false;
  final String dropdownValue;
  final List<Site> list;
  final textController;

  RoundedSearchBarSiteAdmin(
      {this.searchFun,
      this.dropdownFun,
      this.dropdownValue,
      this.resetTextFieldFun,
      this.iscomingFromShifts,
      this.list,
      this.textController});

  @override
  _RoundedSearchBarSiteAdminState createState() =>
      _RoundedSearchBarSiteAdminState();
}

class _RoundedSearchBarSiteAdminState extends State<RoundedSearchBarSiteAdmin> {
  String plusSignPhone(String phoneNum) {
    final int len = phoneNum.length;
    return "+ ${phoneNum.substring(0, len - 1)}";
  }

  bool showSearchButton = true;

  Widget build(BuildContext context) {
    final prov = Provider.of<SiteData>(context, listen: false);
    return GestureDetector(
      onTap: () => print(prov.dropDownSitesIndex),
      child: Container(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                        decoration: const BoxDecoration(),
                        height: 44.0.h,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            TextFormField(
                              onFieldSubmitted: (_) async {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  showSearchButton = false;
                                  widget.searchFun(widget.textController.text);
                                });
                              },
                              onChanged: (String v) {
                                print(v);
                                if (v.isEmpty) {
                                  widget.resetTextFieldFun();
                                }
                                print(showSearchButton);
                                if (showSearchButton == false) {
                                  setState(() {
                                    showSearchButton = true;
                                  });
                                }
                              },
                              controller: widget.textController,
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(16, allowFontScalingSelf: true)),
                              decoration:
                                  kTextFieldDecorationForSearch.copyWith(
                                      hintText: 'اسم المستخدم',
                                      hintStyle: TextStyle(
                                        fontSize: ScreenUtil().setSp(16,
                                            allowFontScalingSelf: true),
                                      ),
                                      fillColor: Color(0xFFE9E9E9),
                                      contentPadding: EdgeInsets.only(
                                          left: 11,
                                          right: 13,
                                          top: 20,
                                          bottom: 14),
                                      errorStyle: TextStyle(
                                        fontSize: setResponsiveFontSize(13),
                                        height: 0.7,
                                      ),
                                      errorMaxLines: 4),
                            ),
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: Container(
                                width: 1.3,
                                height: 50,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            )
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.textController.text.length < 3) {
                          Fluttertoast.showToast(
                              msg: "يجب ان لا يقل البحث عن 3 احرف",
                              backgroundColor: Colors.red,
                              gravity: ToastGravity.CENTER);
                        } else {
                          setState(() {
                            showSearchButton = false;
                            widget.searchFun(widget.textController.text);
                          });
                        }
                      },
                      child: showSearchButton
                          ? Container(
                              height: 44.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xff4a4a4a), width: 1.0),
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                                color: Colors.orange[500],
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  showSearchButton = true;
                                });
                                widget.resetTextFieldFun();
                              },
                              child: Container(
                                height: 44.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xff4a4a4a),
                                      width: 1.0),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10)),
                                  color: Colors.orange[500],
                                ),
                                child: const Icon(FontAwesomeIcons.times,
                                    color: Colors.white),
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              child: Flexible(
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        child: Center(
                          child: Column(
                            children: [
                              Consumer<ShiftsData>(
                                builder: (context, value, child) {
                                  return DropdownButton(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      elevation: 5,
                                      items: value.shiftsList
                                          .map(
                                            (value) => DropdownMenuItem(
                                                child: Container(
                                                    alignment:
                                                        Alignment.topRight,
                                                    height: 20.h,
                                                    child: AutoSizeText(
                                                      value.shiftName,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: ScreenUtil()
                                                              .setSp(12,
                                                                  allowFontScalingSelf:
                                                                      true),
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    )),
                                                value: value.shiftName),
                                          )
                                          .toList(),
                                      onChanged: (v) async {
                                        int holder;
                                        print(v);
                                        prov.setShiftValue(v);

                                        final List<String> x = [];

                                        value.shiftsList.forEach((element) {
                                          x.add(element.shiftName);
                                        });

                                        holder = x.indexOf(v);
                                        print(value.shiftsList[holder].shiftId);
                                        if (value.shiftsList[holder].shiftId ==
                                            -100) {
                                          Provider.of<MemberData>(context,
                                                  listen: false)
                                              .bySitePageIndex = 0;
                                          Provider.of<MemberData>(context,
                                                  listen: false)
                                              .keepRetriving = true;
                                        }
                                        Provider.of<MemberData>(context,
                                                listen: false)
                                            .byShiftPageIndex = 0;
                                        Provider.of<MemberData>(context,
                                                listen: false)
                                            .keepRetriving = true;
                                        Provider.of<MemberData>(context,
                                                listen: false)
                                            .getAllCompanyMember(
                                                Provider.of<UserData>(context,
                                                        listen: false)
                                                    .user
                                                    .userSiteId,
                                                Provider.of<CompanyData>(
                                                        context,
                                                        listen: false)
                                                    .com
                                                    .id,
                                                Provider.of<UserData>(context,
                                                        listen: false)
                                                    .user
                                                    .userToken,
                                                context,
                                                value.shiftsList[holder]
                                                            .shiftId ==
                                                        -100
                                                    ? -1
                                                    : value.shiftsList[holder]
                                                        .shiftId);
                                        print(holder);
                                        prov.setDropDownShift(holder);
                                      },
                                      hint: const AutoSizeText("كل المناوبات"),
                                      value: value
                                          .shiftsList[prov.dropDownShiftIndex]
                                          .shiftName

                                      // value
                                      );
                                },
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.alarm, color: ColorManager.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  //   print("refresh");

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
      print("Got shifts");
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

  int getsiteIndex(String siteName) {
    final list =
        Provider.of<SiteData>(context, listen: false).dropDownSitesList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
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
      print(companyId);
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
                                  return const Center(
                                    child: const LoadingIndicator(),
                                  );
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
                                    if (Provider.of<UserData>(context)
                                            .user
                                            .userType !=
                                        2) {
                                      Timer(
                                        const Duration(milliseconds: 1),
                                        () => _scrollController.jumpTo(
                                            _scrollController
                                                    .position.maxScrollExtent -
                                                10),
                                      );
                                    }
                                  }
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
                                              print(
                                                  "current : ${widget.selectedValue}");
                                            });

                                            print(value);
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
                                                            : Container(
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                                width: double
                                                                    .infinity,
                                                                child: ListView
                                                                    .builder(
                                                                        itemCount: value
                                                                            .userSearchMember
                                                                            .length,
                                                                        itemBuilder:
                                                                            (BuildContext context,
                                                                                int index) {
                                                                          return InkWell(
                                                                            onTap:
                                                                                () {
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
                                                                            child:
                                                                                Card(
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
                                                                                    if (await memberData.deleteMember(memberData.membersListScreenDropDownSearch[index].id, index, token, context) == "Success") {
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
                                                                                    if (await memberData.resetMemberMac(memberData.membersListScreenDropDownSearch[index].id, token, context) == "Success") {
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
                                                          child: InkWell(
                                                            onTap: () {
                                                              print(memberData
                                                                  .membersList
                                                                  .length);
                                                            },
                                                            child: AutoSizeText(
                                                              getTranslated(
                                                                  context,
                                                                  "لا يوجد مستخدمين بهذا الموقع"),
                                                              maxLines: 2,
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
                            builder: (context) => NavScreenTwo(3),
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
        MaterialPageRoute(builder: (context) => NavScreenTwo(3)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class MemberTile extends StatefulWidget {
  final Member user;
  final Function onTapEdit;
  final Function onTapDelete;
  final Function onResetMac;

  const MemberTile(
      {this.user, this.onTapEdit, this.onTapDelete, this.onResetMac});

  @override
  _MemberTileState createState() => _MemberTileState();
}

class _MemberTileState extends State<MemberTile> {
  String plusSignPhone(String phoneNum) {
    final int len = phoneNum.length;
    if (phoneNum[0] == "+") {
      return " ${phoneNum.substring(1, len)}+";
    } else {
      return "$phoneNum+";
    }
  }

  int getSiteListIndex(int fShiftId) {
    final fsiteIndex = Provider.of<ShiftsData>(context, listen: false)
        .shiftsList[fShiftId]
        .siteID;

    final list = Provider.of<SiteData>(context, listen: false).sitesList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (fsiteIndex == list[i].id) {
        return i;
      }
    }
    return -1;
  }

  String getShiftName() {
    final list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (list[i].shiftId == widget.user.shiftId) {
        return list[i].shiftName;
      }
    }
    return "";
  }

  int getShiftListIndex(int shiftId) {
    final list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (shiftId == list[i].shiftId) {
        return i;
      }
    }
    return -1;
  }

  TextEditingController _nameController = TextEditingController();
  int shiftId;
  int siteIndex;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: InkWell(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) {
              return Container(
                child: UserPropertiesMenu(
                  user: widget.user,
                ),
              );
            },
          );
        },
        onTap: () {
          shiftId = getShiftListIndex(widget.user.shiftId);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserFullDataScreen(
                  onResetMac: widget.onResetMac,
                  onTapDelete: widget.onTapDelete,
                  onTapEdit: widget.onTapEdit,
                  siteIndex: siteIndex,
                  userId: widget.user.id,
                ),
              ));
          // showUserDetails(widget.user);
        },
        child: Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Container(
                width: double.infinity,
                height: 65.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 55.w,
                          height: 55.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  Border.all(width: 2, color: Colors.orange)),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image(
                                width: 55.w,
                                height: 55.h,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 55.w,
                                    height: 55.h,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.orange),
                                      value: loadingProgress
                                                  .expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes
                                          : null,
                                    )),
                                  );
                                },
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                  '$imageUrl${widget.user.userImageURL}',
                                  headers: {
                                    "Authorization": "Bearer " +
                                        Provider.of<UserData>(context,
                                                listen: false)
                                            .user
                                            .userToken
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                          height: 30.h,
                          child: AutoSizeText(
                            widget.user.name,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(15, allowFontScalingSelf: true),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  showUserDetails(Member member) {
    final userType =
        Provider.of<UserData>(context, listen: false).user.userType;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _nameController.text = "";
              });
            },
            child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0)), //this right here
                child: Stack(
                  children: [
                    Container(
                      height: 500.h,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Container(
                              width: 100.w,
                              height: 100.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 1,
                                  color: const Color(0xffFF7E00),
                                ),
                              ),
                              child: Container(
                                width: 120.w,
                                height: 120.h,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                        '$imageUrl${widget.user.userImageURL}',
                                        headers: {
                                          "Authorization": "Bearer " +
                                              Provider.of<UserData>(context,
                                                      listen: false)
                                                  .user
                                                  .userToken
                                        },
                                      ),
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2,
                                        color: const Color(0xffFF7E00))),
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Container(
                              height: 20,
                              child: AutoSizeText(
                                widget.user.name,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: ScreenUtil()
                                        .setSp(14, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      UserDataField(
                                        icon: Icons.title,
                                        text: widget.user.jobTitle,
                                      ),
                                      SizedBox(
                                        height: 10.0.h,
                                      ),
                                      UserDataField(
                                        icon: Icons.email,
                                        text: widget.user.email,
                                      ),
                                      SizedBox(
                                        height: 10.0.h,
                                      ),
                                      userType == 4
                                          ? UserDataField(
                                              icon: Icons.person,
                                              text: widget.user.normalizedName,
                                            )
                                          : Container(),
                                      userType == 4
                                          ? SizedBox(
                                              height: 10.0.h,
                                            )
                                          : Container(),
                                      UserDataField(
                                          icon: Icons.phone,
                                          text: plusSignPhone(
                                                  widget.user.phoneNumber)
                                              .replaceAll(
                                                  new RegExp(r"\s+\b|\b\s"),
                                                  "")),
                                      SizedBox(
                                        height: 10.0.h,
                                      ),
                                      UserDataField(
                                        icon: Icons.location_on,
                                        text: Provider.of<SiteData>(context,
                                                listen: true)
                                            .sitesList[siteIndex]
                                            .name,
                                      ),
                                      SizedBox(
                                        height: 10.0.h,
                                      ),
                                      UserDataField(
                                          icon: Icons.query_builder,
                                          text: getShiftName())
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: RounderButton(
                                          "تعديل", widget.onTapEdit)),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  Provider.of<UserData>(context, listen: false)
                                              .user
                                              .id ==
                                          member.id
                                      ? Container()
                                      : Expanded(
                                          child: RounderButton(
                                              getTranslated(context, "حذف"),
                                              widget.onTapDelete))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 5.0.w,
                      top: 5.0.h,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.orange,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5.0,
                      top: 5.0,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            widget.onResetMac();
                          },
                          child: const Icon(
                            Icons.repeat,
                            color: Colors.orange,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          );
        });
  }
}
