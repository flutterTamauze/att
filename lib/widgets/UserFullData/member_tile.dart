import 'dart:ui' as ui;

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/AddUserScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/UserFullData/user_properties_menu.dart';

import 'package:qr_users/widgets/roundedButton.dart';

import '../roundedAlert.dart';

class MemberTile extends StatefulWidget {
  final Member user;
  final Function onTapEdit;
  final Function onTapDelete;
  final Function onResetMac;
  final int index;

  MemberTile(
      {this.user,
      this.onTapEdit,
      this.onTapDelete,
      this.onResetMac,
      this.index});

  @override
  _MemberTileState createState() => _MemberTileState();
}

final SlidableController slidableController = SlidableController();

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

  Future<List<String>> getPhoneInEdit(String phoneNumberEdit) async {
    intlPhone.PhoneNumber result =
        await intlPhone.PhoneNumber.getRegionInfoFromPhoneNumber(
            phoneNumberEdit);
    return [result.isoCode, result.dialCode];
  }

  int getShiftListIndex(int shiftId) {
    print("my shift = $shiftId");
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      print(list[i].shiftId);
      if (shiftId == list[i].shiftId) {
        return i;
      }
    }
    return -1;
  }

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
          print(widget.user.id);
          print(widget.user.name);

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserFullDataScreen(
                  onResetMac: widget.onResetMac,
                  onTapDelete: widget.onTapDelete,
                  onTapEdit: widget.onTapEdit,
                  // siteIndex: siteIndex,
                  userId: widget.user.id,
                  index: widget.index,
                ),
              ));
          // showUserDetails(widget.user);
        },
        child: Slidable(
          enabled:
              Provider.of<UserData>(context, listen: false).user.userType == 4,
          actionExtentRatio: 0.10,
          closeOnScroll: true,
          controller: slidableController,
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: [
            ZoomIn(
                child: InkWell(
              child: Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(width: 2, color: Colors.orange)),
                child: Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.orange,
                ),
              ),
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                await Provider.of<MemberData>(context, listen: false)
                    .getUserById(
                        widget.user.id,
                        Provider.of<UserData>(context, listen: false)
                            .user
                            .userToken);
                var phone = await getPhoneInEdit(Provider.of<MemberData>(
                                context,
                                listen: false)
                            .singleMember
                            .phoneNumber[0] !=
                        "+"
                    ? "+${Provider.of<MemberData>(context, listen: false).singleMember.phoneNumber}"
                    : Provider.of<MemberData>(context, listen: false)
                        .singleMember
                        .phoneNumber);
                List<String> rolesList = [
                  getTranslated(context, "مستخدم"),
                  getTranslated(context, "مسئول تسجيل"),
                  getTranslated(context, "مدير موقع"),
                  getTranslated(context, "موارد بشرية"),
                  getTranslated(context, "ادمن"),
                ];
                Navigator.of(context).push(
                  new MaterialPageRoute(
                    builder: (context) => AddUserScreen(
                        Provider.of<MemberData>(context, listen: false)
                            .singleMember,
                        widget.index,
                        true,
                        phone[0],
                        phone[1],
                        false,
                        "",
                        rolesList[
                            Provider.of<MemberData>(context, listen: false)
                                .singleMember
                                .userType]),
                  ),
                );
              },
            )),
            Provider.of<UserData>(context, listen: false).user.id ==
                    widget.user.id
                ? Container()
                : ZoomIn(
                    child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(width: 2, color: Colors.red)),
                      child: Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      widget.onTapDelete();
                    },
                  )),
          ],
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
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border:
                                    Border.all(width: 2, color: Colors.orange)),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  child: Image(
                                    width: 90.w,
                                    height: 90.h,
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
                                      '$imageUrl${widget.user.userImageURL}',
                                    ),
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
                                        '$imageUrl${widget.user.userImageURL}',
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
                )),
          );
        });
  }
}
