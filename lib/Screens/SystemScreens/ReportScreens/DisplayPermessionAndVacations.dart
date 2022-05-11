import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/MLmodule/widgets/HolidaysDisplay/total_holidays_screen.dart';
import 'package:qr_users/MLmodule/widgets/MissionsDisplay/CompanyMissionsDisplay.dart';
import 'package:qr_users/MLmodule/widgets/PermessionsDisplay/permessions_screen_display.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Core/constants.dart';
import 'RadioButtonWidget.dart';

class VacationAndPermessionsReport extends StatefulWidget {
  @override
  _VacationAndPermessionsReportState createState() =>
      _VacationAndPermessionsReportState();
}

TextEditingController _nameController = TextEditingController();
var radioVal2 = 1;

class _VacationAndPermessionsReportState
    extends State<VacationAndPermessionsReport> {
  @override
  void initState() {
    Provider.of<MemberData>(context, listen: false).loadingSearch = false;
    _nameController.clear();
    _sendPermRequest = false;
    _sendMissionRequest = false;
    _sendVacationRequest = false;
    super.initState();
  }

  String userName;
  searchInList(String value, int siteId, int companyId) async {
    if (value.isNotEmpty) {
      await Provider.of<MemberData>(context, listen: false).searchUsersList(
          value,
          Provider.of<UserData>(context, listen: false).user.userToken,
          siteId,
          companyId,
          context);
      focusNode.requestFocus();
    } else {
      Provider.of<MemberData>(context, listen: false).resetUsers();
    }
  }

  bool _sendPermRequest = false,
      _sendVacationRequest = false,
      _sendMissionRequest = false,
      showSearchIcon = true;
  final focusNode = FocusNode();
  Future getPerm;
  Future getMission;
  Future getHoliday;
  var userId;
  GlobalKey<AutoCompleteTextFieldState<SearchMember>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;
  @override
  Widget build(BuildContext context) {
    final comMissionProv = Provider.of<MissionsData>(context, listen: false);
    final userProv = Provider.of<UserData>(context, listen: false);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        // _nameController.text == ""
        //     ?
        //     : SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Scaffold(
          endDrawer: NotificationItem(),
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Header(
                goUserHomeFromMenu: false,
                nav: false,
                goUserMenu: false,
              ),
              SmallDirectoriesHeader(
                Lottie.asset("resources/report.json", repeat: false),
                getTranslated(context, "تقرير الأجازات و المأموريات"),
              ),
              SizedBox(
                height: 20.h,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 330.w,
                    child: Provider.of<MemberData>(context).loadingSearch
                        ? const Center(
                            child: const CircularProgressIndicator(
                            backgroundColor: Colors.orange,
                          ))
                        : searchTextField = AutoCompleteTextField<SearchMember>(
                            key: key,
                            clearOnSubmit: false,
                            focusNode: focusNode,
                            controller: _nameController,
                            suggestions: Provider.of<MemberData>(context)
                                .userSearchMember,
                            style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(16, allowFontScalingSelf: true),
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                            decoration: kTextFieldDecorationFromTO.copyWith(
                                hintStyle: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(16, allowFontScalingSelf: true),
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500),
                                hintText: getTranslated(context, 'الأسم'),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.orange,
                                )),
                            itemFilter: (item, query) {
                              return item.username
                                  .toLowerCase()
                                  .contains(query.toLowerCase());
                            },
                            textInputAction: TextInputAction.search,
                            itemSorter: (a, b) {
                              return a.username.compareTo(b.username);
                            },
                            textSubmitted: (data) {
                              setState(() {
                                showSearchIcon = false;

                                if (userProv.user.userType == 2) {
                                  searchInList(
                                      _nameController.text,
                                      userProv.user.userSiteId,
                                      Provider.of<CompanyData>(context,
                                              listen: false)
                                          .com
                                          .id);
                                } else {
                                  searchInList(
                                      _nameController.text,
                                      -1,
                                      Provider.of<CompanyData>(context,
                                              listen: false)
                                          .com
                                          .id);
                                }
                              });
                            },
                            itemSubmitted: (item) async {
                              _sendVacationRequest = false;
                              _sendMissionRequest = false;
                              _sendPermRequest = false;
                              setState(() {
                                showSearchIcon = false;
                              });
                              Provider.of<UserHolidaysData>(context,
                                      listen: false)
                                  .singleUserHoliday
                                  .clear();
                              Provider.of<UserPermessionsData>(context,
                                      listen: false)
                                  .singleUserPermessions
                                  .clear();
                              Provider.of<MissionsData>(context, listen: false)
                                  .singleUserMissionsList
                                  .clear();
                              if (_nameController.text != item.username) {
                                setState(() {
                                  userName = item.username;
                                  searchTextField.textField.controller.text =
                                      item.username;
                                });

                                userId = item.id;
                                final userProvider = Provider.of<UserData>(
                                    context,
                                    listen: false);
                                switch (radioVal2) {
                                  case 1:
                                    Provider.of<UserHolidaysData>(context,
                                            listen: false)
                                        .singleUserHoliday
                                        .clear();
                                    _sendVacationRequest = false;
                                    getHoliday = Provider.of<UserHolidaysData>(
                                            context,
                                            listen: false)
                                        .getSingleUserHoliday(item.id,
                                            userProvider.user.userToken);
                                    break;
                                  case 2:
                                    Provider.of<MissionsData>(context,
                                            listen: false)
                                        .singleUserMissionsList
                                        .clear();
                                    _sendMissionRequest = false;
                                    getMission = Provider.of<MissionsData>(
                                            context,
                                            listen: false)
                                        .getSingleUserMissions(item.id,
                                            userProvider.user.userToken);

                                    break;
                                  case 3:
                                    Provider.of<UserPermessionsData>(context,
                                            listen: false)
                                        .singleUserPermessions
                                        .clear();
                                    _sendPermRequest = false;

                                    getPerm = Provider.of<UserPermessionsData>(
                                            context,
                                            listen: false)
                                        .getSingleUserPermession(
                                            item.id,
                                            Provider.of<UserData>(context,
                                                    listen: false)
                                                .user
                                                .userToken);
                                    break;
                                  default:
                                    getHoliday = Provider.of<UserHolidaysData>(
                                            context,
                                            listen: false)
                                        .getSingleUserHoliday(item.id,
                                            userProvider.user.userToken);
                                }

                                final List<int> indexes = [];

                                for (int i = 0;
                                    i < comMissionProv.userNames.length;
                                    i++) {
                                  if (comMissionProv.userNames[i] ==
                                      item.username) {
                                    indexes.add(i);
                                  }
                                }
                                if (_nameController.text != item.username) {
                                  setState(() {
                                    userName = item.username;
                                    searchTextField.textField.controller.text =
                                        item.username;

                                    Provider.of<MissionsData>(context,
                                            listen: false)
                                        .setCopyByIndex(indexes);
                                    // isVacationselected = true;
                                  });
                                }
                              }
                            },
                            itemBuilder: (context, item) {
                              // ui for the autocompelete row
                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                  bottom: 5,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Container(
                                          height: 20.h,
                                          child: AutoSizeText(
                                            item.username,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: ScreenUtil().setSp(16,
                                                    allowFontScalingSelf: true),
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  !Provider.of<PermissionHan>(context, listen: false)
                          .isEnglishLocale()
                      ? Provider.of<MemberData>(context).loadingSearch
                          ? Container()
                          : Positioned(
                              left: 10.w,
                              top: 12.h,
                              child: showSearchIcon
                                  ? InkWell(
                                      onTap: () {
                                        if (_nameController.text.length < 3) {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(context,
                                                  "يجب ان لا يقل البحث عن 3 احرف"),
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER);
                                        } else {
                                          setState(() {
                                            showSearchIcon = false;

                                            if (userProv.user.userType == 2) {
                                              searchInList(
                                                  _nameController.text,
                                                  userProv.user.userSiteId,
                                                  Provider.of<CompanyData>(
                                                          context,
                                                          listen: false)
                                                      .com
                                                      .id);
                                            } else {
                                              searchInList(
                                                  _nameController.text,
                                                  -1,
                                                  Provider.of<CompanyData>(
                                                          context,
                                                          listen: false)
                                                      .com
                                                      .id);
                                            }
                                          });
                                        }
                                      },
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.orange,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          _nameController.clear();
                                          showSearchIcon = true;
                                        });
                                      },
                                      child: const Icon(
                                        FontAwesomeIcons.times,
                                        color: Colors.orange,
                                      ),
                                    ))
                      : Provider.of<MemberData>(context).loadingSearch
                          ? Container()
                          : Positioned(
                              right: 10.w,
                              top: 12.h,
                              child: showSearchIcon
                                  ? InkWell(
                                      onTap: () {
                                        if (_nameController.text.length < 3) {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(context,
                                                  "يجب ان لا يقل البحث عن 3 احرف"),
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER);
                                        } else {
                                          setState(() {
                                            showSearchIcon = false;

                                            if (userProv.user.userType == 2) {
                                              searchInList(
                                                  _nameController.text,
                                                  userProv.user.userSiteId,
                                                  Provider.of<CompanyData>(
                                                          context,
                                                          listen: false)
                                                      .com
                                                      .id);
                                            } else {
                                              searchInList(
                                                  _nameController.text,
                                                  -1,
                                                  Provider.of<CompanyData>(
                                                          context,
                                                          listen: false)
                                                      .com
                                                      .id);
                                            }
                                          });
                                        }
                                      },
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.orange,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          _nameController.clear();
                                          showSearchIcon = true;
                                        });
                                      },
                                      child: const Icon(
                                        FontAwesomeIcons.times,
                                        color: Colors.orange,
                                      ),
                                    ))
                ],
              ),
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RadioButtonWidg(
                        radioVal2: radioVal2,
                        radioVal: 2,
                        title: getTranslated(context, "المأموريات"),
                        onchannge: (value) {
                          setState(() {
                            if (!showSearchIcon) {
                              searchTextField.textField.controller.text =
                                  userName;
                            }
                            radioVal2 = value;
                            if (_nameController.text.isNotEmpty) {
                              if (Provider.of<MissionsData>(context,
                                          listen: false)
                                      .singleUserMissionsList
                                      .isEmpty &&
                                  _sendMissionRequest == false) {
                                _sendMissionRequest = true;
                                getMission = Provider.of<MissionsData>(context,
                                        listen: false)
                                    .getSingleUserMissions(
                                        userId,
                                        Provider.of<UserData>(context,
                                                listen: false)
                                            .user
                                            .userToken);
                              }
                            }
                          });
                        },
                      ),
                      RadioButtonWidg(
                        radioVal2: radioVal2,
                        radioVal: 1,
                        title: getTranslated(context, "الأجازات"),
                        onchannge: (value) {
                          setState(() {
                            if (!showSearchIcon) {
                              searchTextField.textField.controller.text =
                                  userName;
                            }

                            radioVal2 = value;
                            if (_nameController.text.isNotEmpty) {
                              if (Provider.of<UserHolidaysData>(context,
                                          listen: false)
                                      .singleUserHoliday
                                      .isEmpty &&
                                  _sendVacationRequest == false) {
                                _sendVacationRequest = true;
                                getHoliday = Provider.of<UserHolidaysData>(
                                        context,
                                        listen: false)
                                    .getSingleUserHoliday(
                                        userId,
                                        Provider.of<UserData>(context,
                                                listen: false)
                                            .user
                                            .userToken);
                              }
                            }
                          });
                        },
                      ),
                      RadioButtonWidg(
                        radioVal2: radioVal2,
                        radioVal: 3,
                        title: getTranslated(context, "الأذونات"),
                        onchannge: (value) {
                          setState(() {
                            if (!showSearchIcon) {
                              searchTextField.textField.controller.text =
                                  userName;
                            }

                            radioVal2 = value;
                            if (_nameController.text.isNotEmpty) {
                              if (Provider.of<UserPermessionsData>(context,
                                          listen: false)
                                      .singleUserPermessions
                                      .isEmpty &&
                                  _sendPermRequest == false) {
                                _sendPermRequest = true;
                                getPerm = Provider.of<UserPermessionsData>(
                                        context,
                                        listen: false)
                                    .getSingleUserPermession(
                                        userId,
                                        Provider.of<UserData>(context,
                                                listen: false)
                                            .user
                                            .userToken);
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              radioVal2 == 3
                  ? DisplayPermessions(_nameController, getPerm)
                  : radioVal2 == 1
                      ? DisplayHolidays(_nameController, getHoliday)
                      : DisplayCompanyMissions(_nameController, getMission)
            ],
          )),
    );
  }
}
