import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/DaysOff.dart';

import 'package:qr_users/services/ShiftsData.dart';

import 'package:qr_users/services/Sites_data.dart';

import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import 'package:qr_users/widgets/roundedButton.dart';

import '../../../constants.dart';

class AdvancedShiftSettings extends StatefulWidget {
  TimeOfDay from, to;
  bool edit;
  AdvancedShiftSettings({this.from, this.to, this.edit});
  @override
  _AdvancedShiftSettingsState createState() => _AdvancedShiftSettingsState();
}

class _AdvancedShiftSettingsState extends State<AdvancedShiftSettings> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    getDaysOff();
  }

  @override
  void dispose() {
    super.dispose();
  }

  TextEditingController _timeInController = TextEditingController();
  TextEditingController _timeOutController = TextEditingController();
  Future getDaysOff() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);
    await Provider.of<DaysOffData>(context, listen: false)
        .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
  }

  @override
  Widget build(BuildContext context) {
    var selectedVal = "كل المواقع";
    var list = Provider.of<SiteData>(context, listen: true).dropDownSitesList;
    var daysofflist = Provider.of<DaysOffData>(context, listen: true);
    var prov = Provider.of<SiteData>(context, listen: false);

    return Expanded(
      child: FutureBuilder(
          future: Provider.of<DaysOffData>(context).future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Platform.isIOS
                      ? CupertinoActivityIndicator(
                          radius: 20,
                        )
                      : CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                ),
              );
            }

            return Container(
                child: ListView.builder(
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        daysofflist.reallocateUsers[index].isDayOff
                            ? Card(
                                elevation: 2,
                                child: Container(
                                  width: 200.w,
                                  padding: EdgeInsets.all(10),
                                  child: Text("يوم عطلة",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                      textAlign: TextAlign.center),
                                ),
                              )
                            : Stack(
                                children: [
                                  Card(
                                    elevation: 2,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      width: 200.w,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(daysofflist.advancedShift[index]
                                                      .toDate ==
                                                  null
                                              ? "${widget.to.format(context).replaceAll(" ", "")}"
                                              : "${daysofflist.advancedShift[index].toDate.format(context).replaceAll(" ", "")}"),
                                          Text(daysofflist.advancedShift[index]
                                                      .fromDate ==
                                                  null
                                              ? "${widget.from.format(context).replaceAll(" ", "")}"
                                              : "${daysofflist.advancedShift[index].fromDate.format(context).replaceAll(" ", "")}")
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(child: StatefulBuilder(
                                            builder: (context, setState) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                height: 200.h,
                                                width: double.infinity,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        child: Text(
                                                          "ادخل فترة المناوبة ",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.orange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                          textAlign:
                                                              TextAlign.center,
                                                        )),
                                                    Container(
                                                      height: 60.h,
                                                      child: Container(
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                  child: Theme(
                                                                data:
                                                                    clockTheme,
                                                                child: Builder(
                                                                  builder:
                                                                      (context) {
                                                                    return InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          if (widget
                                                                              .edit) {
                                                                            var from =
                                                                                await showTimePicker(
                                                                              context: context,
                                                                              initialTime: widget.from,
                                                                              builder: (BuildContext context, Widget child) {
                                                                                return MediaQuery(
                                                                                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                                                                  child: child,
                                                                                );
                                                                              },
                                                                            );
                                                                            MaterialLocalizations
                                                                                localizations =
                                                                                MaterialLocalizations.of(context);
                                                                            String
                                                                                formattedTime =
                                                                                localizations.formatTimeOfDay(from, alwaysUse24HourFormat: false);

                                                                            if (from !=
                                                                                null) {
                                                                              widget.from = from;
                                                                              setState(() {
                                                                                if (Platform.isIOS) {
                                                                                  _timeOutController.text = formattedTime;
                                                                                } else {
                                                                                  _timeOutController.text = "${widget.from.format(context).replaceAll(" ", "")}";
                                                                                }
                                                                              });
                                                                            }
                                                                          }
                                                                        },
                                                                        child:
                                                                            Directionality(
                                                                          textDirection: ui
                                                                              .TextDirection
                                                                              .rtl,
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                IgnorePointer(
                                                                              child: TextFormField(
                                                                                enabled: widget.edit,
                                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                                                                textInputAction: TextInputAction.next,
                                                                                controller: _timeOutController,
                                                                                decoration: kTextFieldDecorationFromTO.copyWith(
                                                                                    hintText: 'الى',
                                                                                    prefixIcon: Icon(
                                                                                      Icons.alarm,
                                                                                      color: Colors.orange,
                                                                                    )),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ));
                                                                  },
                                                                ),
                                                              )),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                  child: Theme(
                                                                data:
                                                                    clockTheme,
                                                                child: Builder(
                                                                  builder:
                                                                      (context) {
                                                                    return InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          if (widget
                                                                              .edit) {
                                                                            var from =
                                                                                await showTimePicker(
                                                                              context: context,
                                                                              initialTime: widget.from,
                                                                              builder: (BuildContext context, Widget child) {
                                                                                return MediaQuery(
                                                                                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                                                                  child: child,
                                                                                );
                                                                              },
                                                                            );
                                                                            MaterialLocalizations
                                                                                localizations =
                                                                                MaterialLocalizations.of(context);
                                                                            String
                                                                                formattedTime =
                                                                                localizations.formatTimeOfDay(from, alwaysUse24HourFormat: false);

                                                                            if (from !=
                                                                                null) {
                                                                              widget.from = from;
                                                                              setState(() {
                                                                                if (Platform.isIOS) {
                                                                                  _timeInController.text = formattedTime;
                                                                                } else {
                                                                                  _timeInController.text = "${widget.from.format(context).replaceAll(" ", "")}";
                                                                                }
                                                                              });
                                                                            }
                                                                          }
                                                                        },
                                                                        child:
                                                                            Directionality(
                                                                          textDirection: ui
                                                                              .TextDirection
                                                                              .rtl,
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                IgnorePointer(
                                                                              child: TextFormField(
                                                                                // enabled:
                                                                                //     edit,
                                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                                                                textInputAction: TextInputAction.next,
                                                                                controller: _timeInController,
                                                                                decoration: kTextFieldDecorationFromTO.copyWith(
                                                                                    hintText: 'من',
                                                                                    prefixIcon: Icon(
                                                                                      Icons.alarm,
                                                                                      color: Colors.orange,
                                                                                    )),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ));
                                                                  },
                                                                ),
                                                              )),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      child: RoundedButton(
                                                          title: "حفظ",
                                                          onPressed: () async {
                                                            await Provider.of<
                                                                        DaysOffData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .setFromAndTo(
                                                                    index,
                                                                    widget.from,
                                                                    widget.to);

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
                                      decoration: BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle),
                                      child: Icon(
                                        Icons.edit,
                                        size: 15,
                                      ),
                                      padding: EdgeInsets.all(1),
                                    ),
                                  ))
                                ],
                              ),
                        Text(daysofflist.reallocateUsers[index].dayName,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                    Divider()
                  ],
                );
              },
              itemCount: daysofflist.reallocateUsers.length,
            ));
          }),
    );
  }

  Widget showEditWidget() {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)), //this right here
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Container(
            height: 200.h,
            child: Text("d"),
          ),
        ));
  }
}
