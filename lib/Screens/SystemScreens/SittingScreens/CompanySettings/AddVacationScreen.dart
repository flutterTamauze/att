import 'dart:ui' as ui;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
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
  TextEditingController _nameController = TextEditingController();
  AutoCompleteTextField searchTextField;
  String selectedDateString;

  String date;
  DateTime selectedDate;
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
    final now = DateTime.now();
    if (widget.edit) {
      selectedDate = Provider.of<VacationData>(context, listen: false)
          .copyVacationList[widget.vacationListID]
          .vacationDate;
      selectedDateString = Provider.of<VacationData>(context, listen: false)
          .copyVacationList[widget.vacationListID]
          .vacationDate
          .toString();
    }

    Provider.of<VacationData>(context, listen: false).isLoading = false;
    yesterday = DateTime(now.year, now.month, now.day - 1);

    if (widget.edit) {
      _nameController.text =
          vacationProv.vactionList[widget.vacationListID].vacationName;
    }
  }

  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    final userProvider = Provider.of<UserData>(context);
    final companyProvider = Provider.of<CompanyData>(context, listen: false);
    return Scaffold(
      endDrawer: NotificationItem(),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Container(
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
                            SmallDirectoriesHeader(
                                Lottie.asset("resources/shiftLottie.json",
                                    repeat: false),
                                !widget.edit
                                    ? getTranslated(context, "إضافة عطلة")
                                    : getTranslated(context, "تعديل عطلة")),
                            Divider(),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.0.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 10.0.h,
                                  ),
                                  Row(
                                    children: [
                                      widget.edit
                                          ? Container()
                                          : Expanded(
                                              flex: 2,
                                              child: Container(
                                                child: TextFormField(
                                                  controller:
                                                      _textEditingController,
                                                  validator: (text) {
                                                    if (text == null ||
                                                        text.isEmpty) {
                                                      return getTranslated(
                                                          context, 'مطلوب');
                                                    } else {
                                                      Pattern pattern =
                                                          "\\b([1-9]|10)\\b";
                                                      RegExp regex =
                                                          new RegExp(pattern);
                                                      if (!regex.hasMatch(text))
                                                        return 'يجب ان يكون العدد من 1 - 10';
                                                      else
                                                        return null;
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: kTextFieldDecorationTime
                                                      .copyWith(
                                                          hintStyle:
                                                              TextStyle(),
                                                          hintText: getTranslated(
                                                              context,
                                                              'عدد ايام العطلة'),
                                                          prefixIcon: Icon(
                                                            FontAwesomeIcons
                                                                .calendar,
                                                            color:
                                                                Colors.orange,
                                                          )),
                                                ),
                                              )),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child: Container(
                                            child: Theme(
                                              data: clockTheme,
                                              child: DateTimePicker(
                                                initialValue:
                                                    selectedDateString,

                                                onChanged: (value) {
                                                  if (value != date) {
                                                    date = value;
                                                    selectedDateString = date;

                                                    setState(() {
                                                      selectedDate =
                                                          DateTime.parse(
                                                              selectedDateString);
                                                    });
                                                  }
                                                },
                                                type: DateTimePickerType.date,
                                                firstDate: DateTime(
                                                    DateTime.now().year,
                                                    DateTime.january,
                                                    1),
                                                lastDate: DateTime(
                                                    DateTime.now().year,
                                                    DateTime.december,
                                                    31),
                                                //controller: _endTimeController,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(
                                                        14,
                                                        allowFontScalingSelf:
                                                            true),
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w400),

                                                decoration:
                                                    kTextFieldDecorationTime
                                                        .copyWith(
                                                            hintStyle:
                                                                TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            hintText:
                                                                getTranslated(
                                                                    context,
                                                                    'اليوم'),
                                                            prefixIcon: Icon(
                                                              Icons.access_time,
                                                              color:
                                                                  Colors.orange,
                                                            )),
                                                validator: (val) {
                                                  if (val.length == 0) {
                                                    return getTranslated(
                                                        context, 'مطلوب');
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0.h,
                                  ),
                                  TextFormField(
                                    onFieldSubmitted: (_) {},
                                    textInputAction: TextInputAction.next,
                                    validator: (text) {
                                      if (text.length == 0) {
                                        return getTranslated(context, 'مطلوب');
                                      } else if (text.length > 40) {
                                        return getTranslated(context,
                                            "يجب ان لا يتخطي الأسم عن 40 حرف");
                                      }
                                      return null;
                                    },
                                    controller: _nameController,
                                    decoration:
                                        kTextFieldDecorationWhite.copyWith(
                                            hintText: getTranslated(
                                                context, "أسم العطلة"),
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
                              child: Provider.of<VacationData>(context)
                                      .isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.orange,
                                      ),
                                    )
                                  : RoundedButton(
                                      title: widget.edit
                                          ? getTranslated(context, "تعديل")
                                          : getTranslated(context, "إضافة"),
                                      onPressed: () async {
                                        final vactionProv =
                                            Provider.of<VacationData>(context,
                                                listen: false);

                                        if (widget.edit) {
                                          final String msg =
                                              await vactionProv.updateVacation(
                                                  widget.vacationListID,
                                                  Vacation(
                                                      vacationId: Provider.of<
                                                                  VacationData>(
                                                              context,
                                                              listen: false)
                                                          .vactionList[widget
                                                              .vacationListID]
                                                          .vacationId,
                                                      vacationName:
                                                          _nameController.text,
                                                      vacationDate:
                                                          selectedDate),
                                                  Provider.of<UserData>(context,
                                                          listen: false)
                                                      .user
                                                      .userToken);
                                          Navigator.pop(context);
                                          if (msg == "Success") {
                                            Fluttertoast.showToast(
                                                msg: getTranslated(context,
                                                    "تم التعديل بنجاح"),
                                                backgroundColor: Colors.green);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: getTranslated(context,
                                                    "خطأ فى تعديل العطلة"),
                                                backgroundColor: Colors.red);
                                          }
                                        } else {
                                          if (!_formKey.currentState
                                              .validate()) {
                                            return;
                                          } else {
                                            final String msg =
                                                await vactionProv.addVacation(
                                                    Vacation(
                                                      vacationDate:
                                                          selectedDate,
                                                      vacationName:
                                                          _nameController.text,
                                                    ),
                                                    userProvider.user.userToken,
                                                    companyProvider.com.id,
                                                    int.parse(
                                                        _textEditingController
                                                            .text));
                                            if (msg == "Success") {
                                              Fluttertoast.showToast(
                                                  msg: getTranslated(context,
                                                      "تم الإضافة بنجاح"),
                                                  backgroundColor:
                                                      Colors.green);

                                              Navigator.pop(context);
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: getTranslated(context,
                                                      "خطأ فى اضافة العطلة"),
                                                  backgroundColor: Colors.red);

                                              Navigator.pop(context);
                                            }
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
      ),
    );
  }
}
