import 'dart:async';

// import 'package:audioplayers/audio_cache.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/AddUserScreen.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/AttendProof/attend_proof.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/UserFullData/user_properties.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:qr_users/widgets/roundedButton.dart';

class UserFullDataScreen extends StatefulWidget {
  @override
  _UserFullDataScreenState createState() => _UserFullDataScreenState();

  UserFullDataScreen(
      {this.userId,
      this.onResetMac,
      this.onTapDelete,
      this.index,
      this.onTapEdit,
      this.siteIndex});
  final String userId;
  final int siteIndex;
  final int index;
  final Function onTapEdit;
  final Function onTapDelete;
  final Function onResetMac;
}

bool isSAved = false;
bool allowToAttendBox = false;
bool noShowInReport = false;
TimeOfDay intToTimeOfDay(int time) {
  int hours = (time ~/ 100);
  int min = time - (hours * 100);
  return TimeOfDay(hour: hours, minute: min);
}

String date;
// AudioCache player = AudioCache();
AttendProof attendObj = AttendProof();
// AudioPlayer instance;
TextEditingController timeInController = TextEditingController();
TextEditingController timeOutController = TextEditingController();
String selectedDateString;
var radioVal1 = 1;
DateTime selectedDate;
final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
TimeOfDay fromPicked;
TimeOfDay toPicked;

AnimationController _controller;
int levelClock = 300;

class _UserFullDataScreenState extends State<UserFullDataScreen>
    with TickerProviderStateMixin {
  Future singleUserData;
  getSingleUserData() async {
    singleUserData = Provider.of<MemberData>(context, listen: false)
        .getUserById(widget.userId,
            Provider.of<UserData>(context, listen: false).user.userToken);
  }

  Future<List<String>> getPhoneInEdit(String phoneNumberEdit) async {
    intlPhone.PhoneNumber result =
        await intlPhone.PhoneNumber.getRegionInfoFromPhoneNumber(
            phoneNumberEdit);
    return [result.isoCode, result.dialCode];
  }

  void initState() {
    super.initState();

    getSingleUserData();
    levelClock = 300;

    timeOutController.text = "12:00AM";
    date = apiFormatter.format(DateTime.now());
    isSAved = false;
    selectedDateString = DateTime.now().toString();
    var now = DateTime.now();

    selectedDate = DateTime(now.year, now.month, now.day);
    fromPicked = (intToTimeOfDay(0));
    toPicked = (intToTimeOfDay(0));
    animateControllerOne = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(milliseconds: 200),
    );
    animateControllerTwo = AnimationController(
        vsync: this, // the SingleTickerProviderStateMixin
        duration: Duration(milliseconds: 200));
  }

  // String getShiftName(int shiftId) {
  //   var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
  //   int index = list.length;
  //   for (int i = 0; i < index; i++) {
  //     if (list[i].shiftId == shiftId) {
  //       return list[i].shiftName;
  //     }
  //   }
  //   return "";
  // }

  List<String> sitesList = [], shiftsList = [];
  fillSitesList() {
    sitesList = [];
    var scheduleList =
        Provider.of<ShiftsData>(context, listen: false).firstAvailableSchedule;
    sitesList = [
      scheduleList.satShift.siteName,
      scheduleList.sunShift.siteName,
      scheduleList.monShift.siteName,
      scheduleList.tuesShift.siteName,
      scheduleList.wednShift.siteName,
      scheduleList.thurShift.siteName,
      scheduleList.friShift.siteName
    ];
  }

  fillScheduleShiftsList() {
    shiftsList = [];
    var scheduleList =
        Provider.of<ShiftsData>(context, listen: false).firstAvailableSchedule;
    shiftsList = [
      scheduleList.satShift.shiftName,
      scheduleList.sunShift.shiftName,
      scheduleList.monShift.shiftName,
      scheduleList.tuesShift.shiftName,
      scheduleList.wednShift.shiftName,
      scheduleList.thurShift.shiftName,
      scheduleList.friShift.shiftName
    ];
  }

  AnimationController animateControllerOne;
  AnimationController animateControllerTwo;
  @override
  Widget build(BuildContext context) {
    var userType = Provider.of<UserData>(context, listen: false).user.userType;

    return Scaffold(
      endDrawer: NotificationItem(),
      body: Column(
        children: [
          Header(
            nav: false,
            goUserMenu: false,
            goUserHomeFromMenu: false,
          ),
          FutureBuilder(
              future: singleUserData,
              builder: (context, snapshot) {
                var userData = Provider.of<MemberData>(context).singleMember;
                if (snapshot.connectionState == ConnectionState.waiting ||
                    userData == null) {
                  return Expanded(
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.orange)),
                  );
                }

                return Expanded(
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Container(
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
                                        '$imageUrl${userData.userImageURL}',
                                      ),
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2, color: Color(0xffFF7E00))),
                              ),
                            ),
                            Container(
                              height: 20,
                              child: AutoSizeText(
                                userData.name,
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
                                        icon: Icons.email,
                                        text: userData.email,
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: UserDataField(
                                              icon: Icons.title,
                                              text: userData.jobTitle,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          userType == 4
                                              ? Expanded(
                                                  flex: 1,
                                                  child: UserDataField(
                                                    icon: Icons.person,
                                                    text:
                                                        userData.normalizedName,
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: UserDataField(
                                                icon: Icons.phone,
                                                text: plusSignPhone(
                                                        userData.phoneNumber)
                                                    .replaceAll(
                                                        new RegExp(
                                                            r"\s+\b|\b\s"),
                                                        "")),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: UserDataField(
                                                icon:
                                                    FontAwesomeIcons.moneyBill,
                                                text:
                                                    "${userData.salary} جنية مصرى"),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        children: [
                                          userType != 2
                                              ? Expanded(
                                                  flex: 1,
                                                  child: UserDataField(
                                                      icon: Icons.location_on,
                                                      text:
                                                          //  Provider.of<SiteData>(
                                                          //         context,
                                                          //         listen: true)
                                                          //     .sitesList[
                                                          //         widget.siteIndex]
                                                          //     .name,
                                                          userData.siteName),
                                                )
                                              : Container(),
                                          Expanded(
                                            flex: 1,
                                            child: UserDataField(
                                                icon: Icons.query_builder,
                                                text: userData.shiftName),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 3),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "تاريخ التعيين",
                                            ),
                                            Text(DateFormat('yMMMd')
                                                .format(userData.hiredDate)
                                                .toString()),
                                          ],
                                        ),
                                      ),
                                      UserProperties(
                                        siteIndex: widget.siteIndex,
                                        user: userData,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

String plusSignPhone(String phoneNum) {
  int len = phoneNum.length;
  if (phoneNum[0] == "+") {
    return " ${phoneNum.substring(1, len)}+";
  } else {
    return "$phoneNum+";
  }
}
