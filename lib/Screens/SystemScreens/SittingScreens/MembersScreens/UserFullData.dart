import 'dart:async';

// import 'package:audioplayers/audio_cache.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AttendProof/attend_proof.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/UserFullData/user_properties.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;

class UserFullDataScreen extends StatefulWidget {
  @override
  _UserFullDataScreenState createState() => _UserFullDataScreenState();

  const UserFullDataScreen(
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
  final int hours = (time ~/ 100);
  final int min = time - (hours * 100);
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

int levelClock = 300;

class _UserFullDataScreenState extends State<UserFullDataScreen>
    with TickerProviderStateMixin {
  Future singleUserData;
  getSingleUserData() async {
    singleUserData =
        Provider.of<MemberData>(context, listen: false).getUserById(
      widget.userId,
    );
  }

  Future<List<String>> getPhoneInEdit(String phoneNumberEdit) async {
    final intlPhone.PhoneNumber result =
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
    final now = DateTime.now();

    selectedDate = DateTime(now.year, now.month, now.day);
    fromPicked = (intToTimeOfDay(0));
    toPicked = (intToTimeOfDay(0));
    animateControllerOne = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: const Duration(milliseconds: 200),
    );
    animateControllerTwo = AnimationController(
        vsync: this, // the SingleTickerProviderStateMixin
        duration: const Duration(milliseconds: 200));
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
    final scheduleList =
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
    final scheduleList =
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
    final userType =
        Provider.of<UserData>(context, listen: false).user.userType;

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
                final userData = Provider.of<MemberData>(context).singleMember;
                if (snapshot.connectionState == ConnectionState.waiting ||
                    userData == null) {
                  return const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            backgroundColor: Colors.orange)),
                  );
                }

                return Expanded(
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
                                color: ColorManager.primary,
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
                                      width: 2, color: ColorManager.primary)),
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
                                    const SizedBox(
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
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        userType == 4
                                            ? Expanded(
                                                flex: 1,
                                                child: UserDataField(
                                                  icon: Icons.person,
                                                  text: userData.normalizedName,
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: UserDataField(
                                              icon: Icons.phone,
                                              text: userData.phoneNumber),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: UserDataField(
                                              icon: FontAwesomeIcons.moneyBill,
                                              text:
                                                  "${userData.salary} ${getTranslated(context, "جنية مصرى")}"),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
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
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 3),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AutoSizeText(
                                            getTranslated(
                                                context, "تاريخ التعيين"),
                                          ),
                                          AutoSizeText(DateFormat('yMMMd')
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
                );
              }),
        ],
      ),
    );
  }
}

String plusSignPhone(String phoneNum) {
  final int len = phoneNum.length;
  if (phoneNum[0] == "+") {
    return " ${phoneNum.substring(1, len)}+";
  } else {
    return "$phoneNum+";
  }
}
