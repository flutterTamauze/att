import 'dart:io';
import 'dart:ui' as ui;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AddVacationScreen extends StatefulWidget {
  bool edit = false;
  final int vacationListID;
  AddVacationScreen({this.edit, this.vacationListID});
  @override
  _AddVacationScreenState createState() => _AddVacationScreenState();
}

class _AddVacationScreenState extends State<AddVacationScreen> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  AutoCompleteTextField searchTextField;

  DateTime toDate;
  DateTime fromDate;

  final DateFormat apiFormatter = DateFormat('yMMMd');

  String dateToString = "";
  String dateFromString = "";

  String selectedId = "";

  DateTime yesterday;
  var vacationProv;
  @override
  void initState() {
    super.initState();
    vacationProv = Provider.of<VacationData>(context, listen: false);
    var now = DateTime.now();

    toDate = widget.edit
        ? vacationProv.vactionList[widget.vacationListID].toDate
        : DateTime(now.year, now.month, now.day);
    fromDate = widget.edit
        ? vacationProv.vactionList[widget.vacationListID].fromDate
        : DateTime.now().subtract(Duration(days: 1));

    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    String fromText = " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    String toText = " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
    print(toDate.toString());
    print(fromDate.toString());
    _dateController.text = "$fromText $toText";
    if (widget.edit) {
      _nameController.text =
          vacationProv.vactionList[widget.vacationListID].vacationName;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return Scaffold(
      endDrawer: NotificationItem(),
      backgroundColor: Colors.white,
      body: Container(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (_) {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Header(
                    nav: false,
                    goUserHomeFromMenu: false,
                    goUserMenu: false,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: SmallDirectoriesHeader(
                                Lottie.asset("resources/shiftLottie.json",
                                    repeat: false),
                                !widget.edit ? "إضافة عطلة" : "تعديل عطلة"),
                          ),
                          Divider(),
                          SizedBox(
                            height: 30.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.0.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                Theme(
                                  data: clockTheme1,
                                  child: Builder(
                                    builder: (context) {
                                      return InkWell(
                                          onTap: () async {
                                            final List<DateTime> picked =
                                                await DateRagePicker
                                                    .showDatePicker(
                                                        context: context,
                                                        initialFirstDate:
                                                            fromDate,
                                                        initialLastDate: toDate,
                                                        firstDate:
                                                            new DateTime(2021),
                                                        lastDate: toDate);
                                            var newString = "";
                                            setState(() {
                                              fromDate = picked.first;
                                              toDate = picked.last;
                                              // selectedDuration = kCalcDateDifferance(
                                              //     fromDate.toString(), toDate.toString());
                                              // selectedDuration += 1;
                                              String fromText =
                                                  " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                                              String toText =
                                                  " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
                                              newString = "$fromText $toText";
                                            });
                                            if (_dateController.text !=
                                                newString) {
                                              _dateController.text = newString;

                                              dateFromString =
                                                  apiFormatter.format(fromDate);
                                              dateToString =
                                                  apiFormatter.format(toDate);
                                            }
                                          },
                                          child: Directionality(
                                            textDirection: ui.TextDirection.rtl,
                                            child: Container(
                                              width: 330.w,
                                              child: IgnorePointer(
                                                child: TextFormField(
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  controller: _dateController,
                                                  decoration:
                                                      kTextFieldDecorationFromTO
                                                          .copyWith(
                                                              hintText:
                                                                  'المدة من / إلى',
                                                              prefixIcon: Icon(
                                                                Icons
                                                                    .calendar_today_rounded,
                                                                color: Colors
                                                                    .orange,
                                                              )),
                                                ),
                                              ),
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                TextFormField(
                                  onFieldSubmitted: (_) {},
                                  textInputAction: TextInputAction.next,
                                  textAlign: TextAlign.right,
                                  validator: (text) {
                                    if (text.length == 0) {
                                      return 'مطلوب';
                                    }
                                    return null;
                                  },
                                  controller: _nameController,
                                  decoration:
                                      kTextFieldDecorationWhite.copyWith(
                                          hintText: 'اسم العطلة',
                                          suffixIcon: Icon(
                                            Icons.title,
                                            color: Colors.orange,
                                          )),
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: RoundedButton(
                                title: widget.edit ? "تعديل" : "أضافة",
                                onPressed: () async {
                                  var vactionProv = Provider.of<VacationData>(
                                      context,
                                      listen: false);

                                  if (widget.edit) {
                                    vactionProv.updateVacation(
                                        widget.vacationListID,
                                        Vacation(
                                            vacationName: _nameController.text,
                                            fromDate: fromDate,
                                            toDate: toDate));
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg: "تم تعديل العطلة بنجاح",
                                        backgroundColor: Colors.green);
                                  } else {
                                    if (_nameController.text.isEmpty) {
                                      Fluttertoast.showToast(
                                          msg: "برجاء إدخال اسم العطلة",
                                          backgroundColor: Colors.red);
                                    } else {
                                      vactionProv.vactionList.add(Vacation(
                                          vacationName: _nameController.text,
                                          fromDate: fromDate,
                                          toDate: toDate));
                                      Fluttertoast.showToast(
                                          msg: "تم اضافة العطلة بنجاح",
                                          backgroundColor: Colors.green);

                                      Navigator.pop(context);
                                    }
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
