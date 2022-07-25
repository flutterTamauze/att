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
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/AddUserScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Settings/settings.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/UserFullData/user_properties_menu.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedButton.dart';

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
      child: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Provider.of<PermissionHan>(context, listen: false).isEnglishLocale()
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              if (widget.textController.text.length < 3) {
                                Fluttertoast.showToast(
                                    msg: getTranslated(context,
                                        "يجب ان لا يقل البحث عن 3 احرف"),
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
                                          color: const Color(0xff4a4a4a),
                                          width: 1.0),
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
                                            bottomLeft:
                                                const Radius.circular(10)),
                                        color: Colors.orange[500],
                                      ),
                                      child: const Icon(FontAwesomeIcons.times,
                                          color: Colors.white),
                                    ),
                                  ),
                          ),
                        ),
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
                                        widget.searchFun(
                                            widget.textController.text);
                                      });
                                    },
                                    onChanged: (String v) {
                                      if (v.isEmpty) {
                                        widget.resetTextFieldFun();
                                      }
                                      if (showSearchButton == false) {
                                        setState(() {
                                          showSearchButton = true;
                                        });
                                      }
                                    },
                                    controller: widget.textController,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(16,
                                            allowFontScalingSelf: true)),
                                    decoration:
                                        kTextFieldDecorationForSearch.copyWith(
                                            hintText: getTranslated(
                                                context, "اسم المستخدم"),
                                            hintStyle: TextStyle(
                                              fontSize: ScreenUtil().setSp(
                                                setResponsiveFontSize(16),
                                                allowFontScalingSelf: true,
                                              ),
                                            ),
                                            fillColor: const Color(0xFFE9E9E9),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 11,
                                                    right: 13,
                                                    top: 20,
                                                    bottom: 14),
                                            errorStyle: const TextStyle(
                                              fontSize: 13,
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
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ],
                    ),
                  )
                : Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Align(
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
                                          widget.searchFun(
                                              widget.textController.text);
                                        });
                                      },
                                      onChanged: (String v) {
                                        if (v.isEmpty) {
                                          widget.resetTextFieldFun();
                                        }
                                        if (showSearchButton == false) {
                                          setState(() {
                                            showSearchButton = true;
                                          });
                                        }
                                      },
                                      controller: widget.textController,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16,
                                              allowFontScalingSelf: true)),
                                      decoration: kTextFieldDecorationForSearch
                                          .copyWith(
                                              hintText: getTranslated(
                                                  context, "اسم المستخدم"),
                                              hintStyle: TextStyle(
                                                fontSize: ScreenUtil().setSp(
                                                  16,
                                                  allowFontScalingSelf: true,
                                                ),
                                              ),
                                              fillColor:
                                                  const Color(0xFFE9E9E9),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 11,
                                                      right: 13,
                                                      top: 20,
                                                      bottom: 14),
                                              errorStyle: const TextStyle(
                                                fontSize: 13,
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
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
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
                                      msg: getTranslated(context,
                                          "يجب ان لا يقل البحث عن 3 احرف"),
                                      backgroundColor: Colors.red,
                                      gravity: ToastGravity.CENTER);
                                } else {
                                  setState(() {
                                    showSearchButton = false;
                                    widget
                                        .searchFun(widget.textController.text);
                                  });
                                }
                              },
                              child: showSearchButton
                                  ? Container(
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
                                        child: const Icon(
                                            FontAwesomeIcons.times,
                                            color: Colors.white),
                                      ),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
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
                                        prov.setShiftValue(v);

                                        final List<String> x = [];

                                        value.shiftsList.forEach((element) {
                                          x.add(element.shiftName);
                                        });

                                        holder = x.indexOf(v);

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
                                        prov.setDropDownShift(holder);
                                      },
                                      hint: const AutoSizeText("كل المناوبات"),
                                      value: value
                                          .shiftsList[prov.dropDownShiftIndex]
                                          .shiftName);

                                  // value
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