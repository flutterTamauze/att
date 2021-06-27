import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/AddUserScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:shimmer/shimmer.dart';

import 'UserFullData.dart';

class RoundedSearchBar extends StatelessWidget {
  final Function searchFun;
  final Function dropdownFun;

  bool iscomingFromShifts = false;
  final String dropdownValue;
  final List<Site> list;
  final textController;

  RoundedSearchBar(
      {this.searchFun,
      this.dropdownFun,
      this.dropdownValue,
      this.iscomingFromShifts,
      this.list,
      this.textController});
  String plusSignPhone(String phoneNum) {
    int len = phoneNum.length;
    return "+ ${phoneNum.substring(0, len - 1)}";
  }

  Widget build(BuildContext context) {
    var prov = Provider.of<SiteData>(context, listen: false);

    return GestureDetector(
      onTap: () => print(prov.dropDownSitesIndex),
      child: Container(
        child: Column(
          children: [
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                  height: 44.0.h,
                  child: Center(
                    child: TextField(
                      controller: textController,
                      onChanged: searchFun,
                      style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true)),
                      decoration: kTextFieldDecorationWhite.copyWith(
                        hintText: 'اسم المستخدم',
                        hintStyle: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.grey,
                        ),
                        fillColor: Color(0xFFE9E9E9),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  )),
            ),
            SizedBox(
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
                              Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Consumer<ShiftsData>(
                                  builder: (context, value, child) {
                                    return IgnorePointer(
                                      ignoring: prov.siteValue == "كل المواقع"
                                          ? true
                                          : false,
                                      child: DropdownButton(
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          elevation: 5,
                                          items: value.shiftsBySite
                                              .map(
                                                (value) => DropdownMenuItem(
                                                    child: Container(
                                                        alignment:
                                                            Alignment.topRight,
                                                        height: 20.h,
                                                        child: AutoSizeText(
                                                          value.shiftName,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(12,
                                                                      allowFontScalingSelf:
                                                                          true),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        )),
                                                    value: value.shiftName),
                                              )
                                              .toList(),
                                          onChanged: (v) async {
                                            int holder;
                                            if (prov.siteValue !=
                                                "كل المواقع") {
                                              List<String> x = [];
                                              prov.fillCurrentShiftID(value
                                                  .shiftsBySite[0].shiftId);
                                              value.shiftsBySite
                                                  .forEach((element) {
                                                x.add(element.shiftName);
                                              });

                                              print("on changed $v");
                                              holder = x.indexOf(v);

                                              prov.setDropDownShift(holder);
                                              print(
                                                  "dropdown site index ${holder}");

                                              prov.fillCurrentShiftID(value
                                                  .shiftsBySite[holder]
                                                  .shiftId);
                                              if (prov.currentShiftID != -100) {
                                                print('i will not go there');
                                                List<Member> finalTest = [];

                                                Provider.of<MemberData>(context,
                                                        listen: false)
                                                    .copyMemberList
                                                    .forEach((element) {
                                                  if (element.shiftId ==
                                                      prov.currentShiftID) {
                                                    print(
                                                        "element id :${element.shiftId}");

                                                    finalTest.add(element);
                                                  }
                                                  Provider.of<MemberData>(
                                                          context,
                                                          listen: false)
                                                      .setMmemberList(
                                                          finalTest);
                                                });
                                              } else {
                                                List<Member> fakeList = [];
                                                fakeList =
                                                    Provider.of<MemberData>(
                                                            context,
                                                            listen: false)
                                                        .copyMemberList;
                                                Provider.of<MemberData>(context,
                                                        listen: false)
                                                    .setMmemberList(fakeList);
                                              }
                                            }
                                          },
                                          hint: Text("كل المناوبات"),
                                          value: prov.siteValue == "كل المواقع"
                                              ? null
                                              : value
                                                  .shiftsBySite[
                                                      prov.dropDownShiftIndex]
                                                  .shiftName

                                          // value
                                          ),
                                    );
                                  },
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.alarm,
                      color: Colors.orange[600],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        child: Center(
                          child: Column(
                            children: [
                              Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: Consumer<ShiftsData>(
                                  builder: (context, value, child) {
                                    return DropdownButton(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      elevation: 5,
                                      items: list
                                          .map((value) => DropdownMenuItem(
                                                child: Container(
                                                  alignment: Alignment.topRight,
                                                  height: 20,
                                                  child: AutoSizeText(
                                                    value.name,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: ScreenUtil()
                                                            .setSp(12,
                                                                allowFontScalingSelf:
                                                                    true),
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                                value: value.name,
                                              ))
                                          .toList(),
                                      onChanged: (v) async {
                                        prov.setDropDownShift(0);
                                        dropdownFun(v);
                                        if (v != "كل المواقع") {
                                          prov.setDropDownIndex(prov
                                                  .dropDownSitesStrings
                                                  .indexOf(v) -
                                              1);
                                        } else {
                                          prov.setDropDownIndex(0);
                                        }

                                        await Provider.of<ShiftsData>(context,
                                                listen: false)
                                            .findMatchingShifts(
                                                Provider.of<SiteData>(context,
                                                        listen: false)
                                                    .sitesList[
                                                        prov.dropDownSitesIndex]
                                                    .id,
                                                true);

                                        prov.fillCurrentShiftID(
                                            list[prov.dropDownSitesIndex + 1]
                                                .id);

                                        prov.setSiteValue(v);
                                        print(prov.dropDownSitesStrings);
                                      },
                                      value: dropdownValue,
                                    );
                                  },
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.location_on,
                      color: Colors.orange[600],
                    ),
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

class UsersScreen extends StatefulWidget {
  final selectedIndex;
  var comingFromShifts = false;

  UsersScreen(
    this.selectedIndex,
    this.comingFromShifts,
  );

  @override
  _UsersScreenState createState() => _UsersScreenState();
  String selectedValue = "كل المواقع";
}

class _UsersScreenState extends State<UsersScreen> {
  TextEditingController _nameController = TextEditingController();
  // AutoCompleteTextField searchTextField;

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

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    getData();
    super.didChangeDependencies();
  }

  getData() async {
    var userProvider = Provider.of<UserData>(context);
    var comProvier = Provider.of<CompanyData>(context);

    if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
      await Provider.of<SiteData>(context, listen: false)
          .getSitesByCompanyId(
              comProvier.com.id, userProvider.user.userToken, context)
          .then((value) async {
        print("Got Sites");
      });
    }
    if (Provider.of<ShiftsData>(context, listen: false).shiftsList.isEmpty) {
      await Provider.of<ShiftsData>(context, listen: false)
          .getAllCompanyShifts(
              comProvier.com.id, userProvider.user.userToken, context)
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

  int getsiteIndex(String siteName) {
    var list = Provider.of<SiteData>(context, listen: false).dropDownSitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
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

  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    var prov = Provider.of<SiteData>(context, listen: false);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () {
            print(Provider.of<SiteData>(context, listen: false)
                .dropDownShiftIndex);
            print(widget.selectedValue);
            print(widget.selectedIndex);
            print(Provider.of<SiteData>(context, listen: false).currentShiftID);
            print("____");
            for (int i = 0; i < memberData.membersList.length; i++) {
              print(memberData.membersList[i].name);
              print(memberData.membersList[i].shiftId);
            }
          },
          child: Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Header(nav: false),

                        ///Title
                        ///
                        Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: SmallDirectoriesHeader(
                            Lottie.asset("resources/user.json", repeat: false),
                            "دليل المستخدمين",
                          ),
                        ),

                        ///List OF SITES
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
                                      if (!snapshot.hasData) {
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
                                          return Container(
                                              child: buildShimmer(5));
                                        case ConnectionState.done:
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
                                                        getsiteIndex(value);
                                                    if (id != siteIndex) {
                                                      siteIndex = id;
                                                      Provider.of<MemberData>(
                                                              context,
                                                              listen: false)
                                                          .getAllCompanyMember(
                                                              Provider.of<SiteData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .dropDownSitesList[
                                                                      siteIndex]
                                                                  .id,
                                                              Provider.of<CompanyData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .com
                                                                  .id,
                                                              userProvider.user
                                                                  .userToken,
                                                              context);
                                                      setState(() {
                                                        widget.selectedValue =
                                                            Provider.of<SiteData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .dropDownSitesList[
                                                                    siteIndex]
                                                                .name;
                                                      });
                                                      print(value);
                                                    }

                                                    print(value);
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                  child:
                                                      memberData.membersList
                                                                  .length !=
                                                              0
                                                          ? Container(
                                                              child:
                                                                  SmartRefresher(
                                                                onRefresh:
                                                                    _onRefresh,
                                                                controller:
                                                                    refreshController,
                                                                enablePullDown:
                                                                    true,
                                                                header:
                                                                    WaterDropMaterialHeader(
                                                                  color: Colors
                                                                      .white,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .orange,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                        itemCount: memberData
                                                                            .membersListScreenDropDownSearch
                                                                            .length,
                                                                        itemBuilder:
                                                                            (BuildContext context,
                                                                                int index) {
                                                                          return MemberTile(
                                                                            user:
                                                                                memberData.membersListScreenDropDownSearch[index],
                                                                            onTapDelete:
                                                                                () {
                                                                              return showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return RoundedAlert(
                                                                                        onPressed: () async {
                                                                                          showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return RoundedLoadingIndicator();
                                                                                              });
                                                                                          var token = Provider.of<UserData>(context, listen: false).user.userToken;
                                                                                          if (await memberData.deleteMember(memberData.membersListScreenDropDownSearch[index].id, index, token, context) == "Success") {
                                                                                            Navigator.pop(context);
                                                                                            Fluttertoast.showToast(
                                                                                              msg: "تم الحذف بنجاح",
                                                                                              gravity: ToastGravity.CENTER,
                                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                                              timeInSecForIosWeb: 1,
                                                                                              backgroundColor: Colors.green,
                                                                                              textColor: Colors.white,
                                                                                              fontSize: 16.0,
                                                                                            );
                                                                                          } else {
                                                                                            Fluttertoast.showToast(
                                                                                              msg: "خطأ في الحذف",
                                                                                              gravity: ToastGravity.CENTER,
                                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                                              timeInSecForIosWeb: 1,
                                                                                              backgroundColor: Colors.red,
                                                                                              textColor: Colors.black,
                                                                                              fontSize: 16.0,
                                                                                            );
                                                                                          }
                                                                                          Navigator.pop(context);
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        title: 'إزالة مستخدم',
                                                                                        content: "هل تريد إزالة${memberData.membersListScreenDropDownSearch[index].name} ؟");
                                                                                  });
                                                                            },
                                                                            onTapEdit:
                                                                                () async {
                                                                              print(index);
                                                                              print(memberData.membersListScreenDropDownSearch[index].shiftId);
                                                                              print(memberData.membersListScreenDropDownSearch[index].id);
                                                                              print(memberData.membersListScreenDropDownSearch[index].phoneNumber);
                                                                              var phone = await getPhoneInEdit(memberData.membersListScreenDropDownSearch[index].phoneNumber[0] != "+" ? "+${memberData.membersListScreenDropDownSearch[index].phoneNumber}" : memberData.membersListScreenDropDownSearch[index].phoneNumber);

                                                                              Navigator.of(context).push(
                                                                                new MaterialPageRoute(
                                                                                  builder: (context) => AddUserScreen(memberData.membersListScreenDropDownSearch[index], index, true, phone[0], phone[1]),
                                                                                ),
                                                                              );
                                                                            },
                                                                            onResetMac:
                                                                                () {
                                                                              return showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return RoundedAlert(
                                                                                        onPressed: () async {
                                                                                          showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return RoundedLoadingIndicator();
                                                                                              });
                                                                                          var token = Provider.of<UserData>(context, listen: false).user.userToken;
                                                                                          if (await memberData.resetMemberMac(memberData.membersListScreenDropDownSearch[index].id, token, context) == "Success") {
                                                                                            Navigator.pop(context);
                                                                                            Fluttertoast.showToast(
                                                                                              msg: "تم التعديل بنجاح",
                                                                                              gravity: ToastGravity.CENTER,
                                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                                              timeInSecForIosWeb: 1,
                                                                                              backgroundColor: Colors.green,
                                                                                              textColor: Colors.white,
                                                                                              fontSize: 16.0,
                                                                                            );
                                                                                          } else {
                                                                                            Fluttertoast.showToast(
                                                                                              msg: "خطأ في التعديل",
                                                                                              gravity: ToastGravity.CENTER,
                                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                                              timeInSecForIosWeb: 1,
                                                                                              backgroundColor: Colors.red,
                                                                                              textColor: Colors.black,
                                                                                              fontSize: 16.0,
                                                                                            );
                                                                                          }
                                                                                          Navigator.pop(context);
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        title: 'إعادة ضبط بيانات مستخدم',
                                                                                        content: "هل تريد اعادة ضبط بيانات هاتف المستخدم؟");
                                                                                  });
                                                                            },
                                                                          );
                                                                        }),
                                                              ),
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startFloat,
              floatingActionButton: FloatingActionButton(
                tooltip: "اضافة مستخدم",
                child: Icon(
                  Icons.person_add,
                  color: Colors.black,
                  size: 30,
                ),
                backgroundColor: Colors.orange[600],
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddUserScreen(Member(), 0, false, "", "")));
                },
              )),
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

Widget buildShimmer(int count) {
  return ListView.builder(
    itemCount: count,
    itemBuilder: (context, index) {
      return Card(
        elevation: 5,
        child: Container(
          child: Align(
            alignment: Alignment.centerRight,
            child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: Row(
                  children: [
                    Shimmer.fromColors(
                        child: Container(
                          width: 64.w,
                          height: 64.h,
                          child: CircleAvatar(),
                          padding: EdgeInsets.all(5),
                        ),
                        baseColor: Colors.grey[400],
                        highlightColor: Colors.grey[300]),
                    Container(
                      child: Shimmer.fromColors(
                          child: Container(
                            height: 40.h,
                            width: 200,
                            child: SizedBox(
                              child: Text("جارى التحميل"),
                            ),
                            padding: EdgeInsets.only(top: 10.h, right: 5.w),
                          ),
                          baseColor: Colors.grey[400],
                          highlightColor: Colors.grey[300]),
                    )
                  ],
                )),
          ),
        ),
      );
    },
  );
}

class MemberTile extends StatefulWidget {
  final Member user;
  final Function onTapEdit;
  final Function onTapDelete;
  final Function onResetMac;

  MemberTile({this.user, this.onTapEdit, this.onTapDelete, this.onResetMac});

  @override
  _MemberTileState createState() => _MemberTileState();
}

class _MemberTileState extends State<MemberTile> {
  String plusSignPhone(String phoneNum) {
    int len = phoneNum.length;
    if (phoneNum[0] == "+") {
      return " ${phoneNum.substring(1, len)}+";
    } else {
      return "$phoneNum+";
    }
  }

  int getSiteListIndex(int fShiftId) {
    var fsiteIndex = Provider.of<ShiftsData>(context, listen: false)
        .shiftsList[fShiftId]
        .siteID;

    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (fsiteIndex == list[i].id) {
        return i;
      }
    }
    return -1;
  }

  String getShiftName() {
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (list[i].shiftId == widget.user.shiftId) {
        return list[i].shiftName;
      }
    }
    return "";
  }

  int getShiftListIndex(int shiftId) {
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (shiftId == list[i].shiftId) {
        return i;
      }
    }
    return -1;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // shiftId = getShiftListIndex(widget.user.shiftId);
    // siteIndex = getSiteListIndex(shiftId);
    // Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(
    //     Provider.of<SiteData>(context, listen: false)
    //         .sitesList[Provider.of<SiteData>(context, listen: false)
    //             .dropDownSitesIndex]
    //         .id,
    //     true,
    //     true);
  }

  int shiftId;
  int siteIndex;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: InkWell(
        onTap: () {
          shiftId = getShiftListIndex(widget.user.shiftId);
          siteIndex = getSiteListIndex(shiftId);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserFullDataScreen(
                  onResetMac: widget.onResetMac,
                  onTapDelete: widget.onTapDelete,
                  onTapEdit: widget.onTapEdit,
                  siteIndex: siteIndex,
                  user: widget.user,
                ),
              ));
          // showUserDetails(widget.user);
        },
        child: Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
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
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes
                                            : null,
                                      )),
                                    );
                                  },
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                    '$baseURL/${widget.user.userImageURL}',
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
              ),
            )),
      ),
    );
  }

  showUserDetails(Member member) {
    var userType = Provider.of<UserData>(context, listen: false).user.userType;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => print(member.shiftId),
            child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0)), //this right here
                child: Directionality(
                  textDirection: ui.TextDirection.rtl,
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
                                    color: Color(0xffFF7E00),
                                  ),
                                ),
                                child: Container(
                                  width: 120.w,
                                  height: 120.h,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                          '$baseURL/${widget.user.userImageURL}',
                                        ),
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 2, color: Color(0xffFF7E00))),
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                height: 20,
                                child: AutoSizeText(
                                  widget.user.name,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: ScreenUtil().setSp(14,
                                          allowFontScalingSelf: true),
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 5.h),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                                                text:
                                                    widget.user.normalizedName,
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
                                    Provider.of<UserData>(context,
                                                    listen: false)
                                                .user
                                                .id ==
                                            member.id
                                        ? Container()
                                        : Expanded(
                                            child: RounderButton(
                                                "حذف", widget.onTapDelete))
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
                            child: Icon(
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
                            child: Icon(
                              Icons.repeat,
                              color: Colors.orange,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          );
        });
  }
}

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final onTap;

  CircularIconButton({this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          backgroundColor: Colors.orange,
          radius: 20,
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class UserDataField extends StatelessWidget {
  final IconData icon;
  final String text;

  UserDataField({this.icon, this.text});

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12, width: 1)),
      height: 40.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 3.h),
              child: Icon(
                icon,
                color: Colors.orange,
                size: 19,
              ),
            ),
            SizedBox(
              width: 15.w,
            ),
            Expanded(
                child: Container(
              height: 20.h,
              child: AutoSizeText(
                text ?? "",
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class RounderButton extends StatelessWidget {
  @override
  final text;
  final onTap;

  RounderButton(this.text, this.onTap);

  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.orange),
        padding: EdgeInsets.all(5),
        child: Center(
          child: Container(
            height: 20,
            child: AutoSizeText(
              text,
              maxLines: 1,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true)),
            ),
          ),
        ),
      ),
    );
  }
}
