import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/services/AllSiteShiftsData/site_shifts_all.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:qr_users/services/Sites_data.dart';

import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'package:qr_users/widgets/roundedButton.dart';

import '../../../../../Core/constants.dart';

class ReAllocateUsers extends StatefulWidget {
  final Member member;
  final bool isEdit;
  final int index;

  const ReAllocateUsers(
    this.member,
    this.isEdit,
    this.index,
  );
  @override
  _ReAllocateUsersState createState() => _ReAllocateUsersState();
}

class _ReAllocateUsersState extends State<ReAllocateUsers> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (widget.isEdit) {
      final scheduleList = Provider.of<ShiftsData>(context, listen: false)
          .firstAvailableSchedule;
      _fromDate = scheduleList.scheduleFromTime;
      _toDate = scheduleList.scheduleToTime;
      _fromText = " من ${DateFormat('yMMMd').format(_fromDate).toString()}";
      _toText = " إلى ${DateFormat('yMMMd').format(_toDate).toString()}";
      _dateController.text = "$_fromText $_toText";
      print("length");
    } else {
      final now = DateTime.now();
      _dateController.text = "";
      _fromDate = DateTime(now.year, now.month, now.day);
      _toDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    }
    userProvider = Provider.of<UserData>(context, listen: false);
    _picked = null;
    lastDatee = DateTime(DateTime.now().year + 2, DateTime.december, 31);

    Provider.of<ShiftsData>(context, listen: false).isLoading = false;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var lastDatee;
  var _picked;
  var _toDate;
  UserData userProvider;
  var _fromDate;
  String _toText, _fromText;
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  TextEditingController _dateController = TextEditingController();

  int getShiftid(String shiftName) {
    final list = Provider.of<SiteShiftsData>(context, listen: false).shifts;
    final List<Shifts> currentShift =
        list.where((element) => element.shiftName == shiftName).toList();
    return currentShift[0].shiftId;
  }

  int getsiteIDbyName(String siteName) {
    final list = Provider.of<SiteShiftsData>(context, listen: false).sites;
    final List<Site> currentSite =
        list.where((element) => element.name == siteName).toList();
    return currentSite[0].id;
  }

  @override
  Widget build(BuildContext context) {
    var selectedVal;
    if (userProvider.user.userType != 2) {
      final prov = Provider.of<SiteShiftsData>(context, listen: false);
      selectedVal = prov.sites[1].name;
      final list = Provider.of<SiteShiftsData>(context, listen: true).sites;
    } else {
      selectedVal = "";
    }
    final list =
        Provider.of<SiteShiftsData>(context, listen: true).siteShiftList;
    final prov = Provider.of<SiteData>(context, listen: false);
    final daysofflist = Provider.of<DaysOffData>(context, listen: true);
    final scheduleList =
        Provider.of<ShiftsData>(context, listen: true).firstAvailableSchedule;
    final List<String> sites =
        Provider.of<ShiftsData>(context, listen: true).sitesSchedules;
    final List<String> shifts =
        Provider.of<ShiftsData>(context, listen: true).shiftSchedules;
    final ShiftsData shiftProv = Provider.of<ShiftsData>(context, listen: true);
    return GestureDetector(
        onTap: () {
          for (int i = 0; i < list.length; i++) {
            print(list[i].siteName);
          }
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Header(
                    nav: false,
                    goUserMenu: false,
                    goUserHomeFromMenu: false,
                  ),
                  Expanded(
                    child: Container(
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SmallDirectoriesHeader(
                              Lottie.asset("resources/calender.json",
                                  repeat: false),
                              getTranslated(context, "جدولة المناوبات"),
                            ),
                          ],
                        ),
                        VacationCardHeader(
                          header:
                              "${getTranslated(context, "جدولة المناوبات للمستخدم")}: ${widget.member.name} ",
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                            child: Theme(
                          data: clockTheme1,
                          child: Builder(
                            builder: (context) {
                              return InkWell(
                                  onTap: userProvider.user.userType == 2
                                      ? () {}
                                      : () async {
                                          _picked = await DateRagePicker
                                              .showDatePicker(
                                                  context: context,
                                                  initialFirstDate: widget
                                                          .isEdit
                                                      ? _fromDate
                                                      : DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          DateTime.now().day),
                                                  initialLastDate: _toDate,
                                                  firstDate: widget.isEdit
                                                      ? _fromDate
                                                      : DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          DateTime.now().day),
                                                  lastDate: lastDatee);
                                          var newString = "";
                                          setState(() {
                                            _fromDate = _picked.first;
                                            _toDate = _picked.last;

                                            _fromText =
                                                " من ${DateFormat('yMMMd').format(_fromDate).toString()}";
                                            _toText =
                                                " إلى ${DateFormat('yMMMd').format(_toDate).toString()}";
                                            newString = "$_fromText $_toText";
                                          });

                                          if (_dateController.text !=
                                              newString) {
                                            _dateController.text = newString;

                                            dateFromString =
                                                apiFormatter.format(_fromDate);
                                            dateToString =
                                                apiFormatter.format(_toDate);
                                          }
                                        },
                                  child: Container(
                                    // width: 330,
                                    width: 365.w,
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                        textInputAction: TextInputAction.next,
                                        controller: _dateController,
                                        decoration:
                                            kTextFieldDecorationFromTO.copyWith(
                                                hintText: getTranslated(
                                                    context, 'المدة من / إلى'),
                                                prefixIcon: const Icon(
                                                  Icons.calendar_today_rounded,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                    ),
                                  ));
                            },
                          ),
                        )),
                        Expanded(
                            child: ListView.builder(
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Stack(
                                        children: [
                                          Card(
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              width: 250.w,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  AutoSizeText(widget.isEdit
                                                      ? shifts[index]
                                                      : daysofflist
                                                          .reallocateUsers[
                                                              index]
                                                          .shiftname),
                                                  AutoSizeText(widget.isEdit
                                                      ? sites[index]
                                                      : daysofflist
                                                          .reallocateUsers[
                                                              index]
                                                          .sitename),
                                                ],
                                              ),
                                            ),
                                          ),
                                          userProvider.user.userType == 2
                                              ? Container()
                                              : Positioned(
                                                  child: InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Dialog(child:
                                                            StatefulBuilder(
                                                          builder: (context,
                                                              setState) {
                                                            return Container(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                              height: 200.h,
                                                              width: double
                                                                  .infinity,
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              20),
                                                                      child:
                                                                          AutoSizeText(
                                                                        getTranslated(
                                                                            context,
                                                                            "اختر الموقع و المناوبة"),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.orange,
                                                                            fontWeight: FontWeight.w600),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      )),
                                                                  Container(
                                                                    height:
                                                                        60.h,
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Flexible(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Container(
                                                                              child: Center(
                                                                                child: Column(
                                                                                  children: [
                                                                                    Consumer<SiteShiftsData>(
                                                                                      builder: (context, value, child) {
                                                                                        return DropdownButton(
                                                                                            isExpanded: true,
                                                                                            underline: const SizedBox(),
                                                                                            elevation: 5,
                                                                                            items: value.shifts
                                                                                                .map(
                                                                                                  (value) => DropdownMenuItem(
                                                                                                      child: Container(
                                                                                                          alignment: Alignment.topRight,
                                                                                                          height: 40.h,
                                                                                                          child: AutoSizeText(
                                                                                                            value.shiftName,
                                                                                                            style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.w700),
                                                                                                          )),
                                                                                                      value: value.shiftName),
                                                                                                )
                                                                                                .where((element) => element.value != "لا يوجد مناوبات بهذا الموقع")
                                                                                                .toList(),
                                                                                            onChanged: (v) async {
                                                                                              int holder;
                                                                                              if (selectedVal != "كل المواقع") {
                                                                                                final List<String> x = [];

                                                                                                value.shifts.forEach((element) {
                                                                                                  x.add(element.shiftName);
                                                                                                });

                                                                                                print("on changed $v");
                                                                                                holder = x.indexOf(v);
                                                                                                setState(() {
                                                                                                  prov.setDropDownShift(holder);
                                                                                                });

                                                                                                print("dropdown site index $holder");
                                                                                              }
                                                                                            },
                                                                                            value: value.shifts[prov.dropDownShiftIndex].shiftName

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
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Icon(
                                                                            Icons.alarm,
                                                                            color:
                                                                                ColorManager.primary,
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                20,
                                                                          ),
                                                                          Flexible(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Container(
                                                                              child: Center(
                                                                                child: Column(
                                                                                  children: [
                                                                                    Consumer<ShiftsData>(
                                                                                      builder: (context, value, child) {
                                                                                        return DropdownButton(
                                                                                          isExpanded: true,
                                                                                          underline: const SizedBox(),
                                                                                          elevation: 5,
                                                                                          items: list
                                                                                              .map((value) => DropdownMenuItem(
                                                                                                    child: Container(
                                                                                                      alignment: Alignment.topRight,
                                                                                                      height: 40.h,
                                                                                                      child: AutoSizeText(
                                                                                                        value.siteName,
                                                                                                        style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.w700),
                                                                                                      ),
                                                                                                    ),
                                                                                                    value: value.siteName,
                                                                                                  ))
                                                                                              .toList(),
                                                                                          onChanged: (v) async {
                                                                                            print(v);
                                                                                            prov.setDropDownShift(0);

                                                                                            // ignore: cascade_invocations
                                                                                            for (int i = 0; i < prov.dropDownSitesStrings.length; i++) {
                                                                                              print(prov.dropDownSitesStrings[i]);
                                                                                            }
                                                                                            prov.setDropDownIndex(prov.dropDownSitesStrings.indexOf(v) - 1);

                                                                                            // await Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(Provider.of<SiteData>(context, listen: false).sitesList[prov.dropDownSitesIndex].id, false);
                                                                                            print("drop down site index ${prov.dropDownSitesIndex}");
                                                                                            Provider.of<SiteShiftsData>(context, listen: false).getShiftsList(Provider.of<SiteShiftsData>(context, listen: false).siteShiftList[prov.dropDownSitesIndex ?? 0].siteName, false);
                                                                                            prov.fillCurrentShiftID(list[prov.dropDownSitesIndex].siteId);

                                                                                            prov.setSiteValue(v);
                                                                                            setState(() {
                                                                                              selectedVal = v;
                                                                                            });
                                                                                            print(prov.dropDownSitesStrings);
                                                                                          },
                                                                                          value: selectedVal,
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
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Icon(
                                                                            Icons.location_on,
                                                                            color:
                                                                                Colors.orange[600],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const Spacer(),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        bottom:
                                                                            20.h),
                                                                    child: RoundedButton(
                                                                        title: getTranslated(context, "حفظ"),
                                                                        onPressed: () async {
                                                                          final String
                                                                              shiftName =
                                                                              Provider.of<SiteShiftsData>(context, listen: false).shifts[prov.dropDownShiftIndex].shiftName;
                                                                          final String
                                                                              siteName =
                                                                              Provider.of<SiteShiftsData>(context, listen: false).siteShiftList[prov.dropDownSitesIndex].siteName;
                                                                          if (widget
                                                                              .isEdit)
                                                                            Provider.of<ShiftsData>(context, listen: false).setScheduleSiteAndShift(
                                                                                widget.index,
                                                                                index,
                                                                                siteName,
                                                                                shiftName);

                                                                          await Provider.of<DaysOffData>(context, listen: false).setSiteAndShift(
                                                                              index,
                                                                              selectedVal,
                                                                              shiftName,
                                                                              getShiftid(shiftName),
                                                                              getsiteIDbyName(siteName));

                                                                          prov.setDropDownIndex(
                                                                              0);
                                                                          Provider.of<SiteShiftsData>(context, listen: false).getShiftsList(
                                                                              Provider.of<SiteShiftsData>(context, listen: false).siteShiftList[prov.dropDownSitesIndex].siteName,
                                                                              false);

                                                                          // await Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(
                                                                          //     Provider.of<SiteData>(context, listen: false).sitesList[Provider.of<SiteData>(context, listen: false).dropDownSitesIndex].id,
                                                                          //     false);
                                                                          Navigator.pop(
                                                                              context);
                                                                        }),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ));
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 20.w,
                                                    height: 20.h,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                Colors.orange,
                                                            shape: BoxShape
                                                                .circle),
                                                    child: const Icon(
                                                      Icons.edit,
                                                      size: 15,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(1),
                                                  ),
                                                ))
                                        ],
                                      ),
                                      AutoSizeText(
                                          daysofflist
                                              .reallocateUsers[index].dayName,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize:
                                                  setResponsiveFontSize(16))),
                                    ],
                                  ),
                                  const Divider()
                                ],
                              ),
                            );
                          },
                          itemCount: daysofflist.reallocateUsers.length,
                        ))
                      ]),
                    ),
                  ),
                  shiftProv.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          backgroundColor: Colors.orange,
                        ))
                      : userProvider.user.userType == 2
                          ? Container()
                          : Row(
                              mainAxisAlignment: widget.isEdit
                                  ? MainAxisAlignment.spaceEvenly
                                  : MainAxisAlignment.center,
                              children: [
                                !widget.isEdit
                                    ? Container()
                                    : RoundedButton(
                                        title: "حذف",
                                        onPressed: () {
                                          return showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return RoundedAlert(
                                                  onPressed: () async {
                                                    final String msg =
                                                        await Provider.of<
                                                                    ShiftsData>(
                                                                context,
                                                                listen: false)
                                                            .deleteShiftScheduleById(
                                                      scheduleList.id,
                                                      Provider.of<UserData>(
                                                              context,
                                                              listen: false)
                                                          .user
                                                          .userToken,
                                                    );
                                                    Navigator.pop(context);
                                                    if (msg == "Success") {
                                                      Fluttertoast.showToast(
                                                          msg: getTranslated(
                                                              context,
                                                              "تم الحذف بنجاح"),
                                                          backgroundColor:
                                                              Colors.green,
                                                          gravity: ToastGravity
                                                              .CENTER);
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg: getTranslated(
                                                              context,
                                                              "خطأ فى الحذف"),
                                                          backgroundColor:
                                                              Colors.red,
                                                          gravity: ToastGravity
                                                              .CENTER);
                                                    }

                                                    Navigator.pop(context);
                                                  },
                                                  content: getTranslated(
                                                      context,
                                                      getTranslated(context,
                                                          "هل تريد حذف الجدولة")),
                                                  onCancel: () {},
                                                  title: getTranslated(
                                                      context, "حذف الجدولة"),
                                                );
                                              });
                                        }),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RoundedButton(
                                    onPressed: () async {
                                      if (_fromText == null ||
                                          _toText == null) {
                                        Fluttertoast.showToast(
                                            msg: getTranslated(
                                              context,
                                              "برجاء ادخال المدة",
                                            ),
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.red);
                                      } else {
                                        if (widget.isEdit) {
                                          final String msg = await Provider.of<
                                                      ShiftsData>(context,
                                                  listen: false)
                                              .editShiftSchedule(
                                                  daysofflist.reallocateUsers,
                                                  userProvider.user.userToken,
                                                  widget.member.id,
                                                  widget.member.shiftId,
                                                  _fromDate,
                                                  _toDate,
                                                  widget.member.siteId,
                                                  scheduleList.id);
                                          if (msg == "Success") {
                                            Fluttertoast.showToast(
                                                msg: "تم التعديل بنجاح",
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.green);

                                            Navigator.pop(context);
                                          } else if (msg == "less than today") {
                                            Fluttertoast.showToast(
                                                msg: getTranslated(context,
                                                    "خطأ : تاريخ اليوم  اقل من بداية تاريخ الجدولة"),
                                                gravity: ToastGravity.CENTER,
                                                toastLength: Toast.LENGTH_LONG,
                                                backgroundColor: Colors.red);
                                          } else if (msg == "not exists") {
                                            Fluttertoast.showToast(
                                                msg: "لا يوجد جدولة",
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.red);
                                          } else {
                                            errorToast(context);
                                          }
                                        } else {
                                          final String msg = await Provider.of<
                                                      ShiftsData>(context,
                                                  listen: false)
                                              .addShiftSchedule(
                                                  daysofflist.reallocateUsers,
                                                  userProvider.user.userToken,
                                                  widget.member.id,
                                                  widget.member.shiftId,
                                                  _fromDate,
                                                  _toDate,
                                                  widget.member.siteId);
                                          if (msg == "Success") {
                                            await sendFcmMessage(
                                              topicName: "",
                                              title: "جدولة مناوبة",
                                              category: "schedule",
                                              userToken: widget.member.fcmToken,
                                              message:
                                                  "تم وضع جدولة مناوبات لك ",
                                            );

                                            Fluttertoast.showToast(
                                                msg: "تم الإضافة بنجاح",
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.green);
                                            Navigator.pop(context);
                                          } else if (msg == "exists") {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "تم طلب جدولة لهذا المستخدم مسبقا",
                                                backgroundColor: Colors.red);
                                          } else {
                                            errorToast(context);
                                          }
                                        }
                                      }
                                    },
                                    title: widget.isEdit
                                        ? getTranslated(context, "تعديل")
                                        : getTranslated(context, "حفظ"),
                                  ),
                                ),
                              ],
                            )
                ],
              ),
            ),
          ),
        ));
  }

  Widget showEditWidget() {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)), //this right here
        child: Container(
          height: 200.h,
          child: Text("d"),
        ));
  }
}
