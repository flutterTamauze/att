import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//Update Kotlin to '1.3.50' to '1.4.21'
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;

class AddUserScreen extends StatefulWidget {
  final Member member;
  final int id;
  final String editableUserPhone;
  final String editiableDial;
  final isEdit;
  AddUserScreen(this.member, this.id, this.isEdit, this.editableUserPhone,
      this.editiableDial);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  bool edit = true;
  int siteId;
  intlPhone.PhoneNumber number =
      intlPhone.PhoneNumber(dialCode: "+20", isoCode: "EG");
  @override
  void initState() {
    super.initState();
    editNumber = intlPhone.PhoneNumber(
        isoCode: widget.editableUserPhone,
        dialCode: widget.editiableDial,
        phoneNumber: widget.member.phoneNumber);
    fillTextField();
    if (widget.isEdit) {
      siteId = 0;
    } else {
      if (Provider.of<SiteData>(context, listen: false)
              .dropDownSitesList
              .length ==
          2) {
        siteId = 0;
      } else {
        siteId =
            Provider.of<SiteData>(context, listen: false).dropDownSitesIndex;
      }

      print(Provider.of<SiteData>(context, listen: false).dropDownSitesIndex);
      Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(
          Provider.of<SiteData>(context, listen: false).sitesList[siteId].id,
          false);
    }
  }

  var phoneLoading = false;
  getSiteIdByShiftId(int shiftId) {
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (shiftId == list[i].shiftId) {
        return list[i].siteID;
      }
    }
    return -1;
  }

  @override
  void dispose() {
    _phoneController?.dispose();
    super.dispose();
  }

  fillTextField() async {
    if (widget.isEdit) {
      print("edit screen");
      edit = true;
      await Provider.of<ShiftsData>(context, listen: false)
          .findMatchingShifts(getSiteIdByShiftId(widget.member.shiftId), false);

      shiftId = getShiftListIndex(widget.member.shiftId);
      siteId = getSiteListIndex(shiftId);
      _nameController.text = widget.member.name;
      _emailController.text = widget.member.email;
      _phoneController.text = widget.member.phoneNumber;
      _titleController.text = widget.member.jobTitle;
      userType = widget.member.userType;
      setState(() {});
    } else {
      await Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(
          Provider.of<SiteData>(context, listen: false).sitesList[0].id, false);
    }
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  int shiftId = 0;
  int userType = 0;
  List<Shift> shiftsList;
  intlPhone.PhoneNumber editNumber;

  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            child: GestureDetector(
              onTap: () => print(Provider.of<ShiftsData>(context, listen: false)
                  .shiftsBySite[shiftId]
                  .shiftId),
              behavior: HitTestBehavior.opaque,
              onPanDown: (_) {
                FocusScope.of(context).unfocus();
              },
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Header(nav: false),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: SmallDirectoriesHeader(
                                    Lottie.asset("resources/user.json",
                                        repeat: false),
                                    (!widget.isEdit)
                                        ? "إضافة مستخدم"
                                        : "تعديل بيانات المستخدم"),
                              ),
                              // DirectoriesHeader(
                              //     Padding(
                              //       padding: const EdgeInsets.all(10),
                              //       child: ClipRRect(
                              //         borderRadius: BorderRadius.circular(60.0),
                              //         child: Lottie.asset("resources/user.json",
                              //             repeat: false),
                              //       ),
                              //     ),
                              //     (!widget.isEdit)
                              //         ? "إضافة مستخدم"
                              //         : "تعديل بيانات المستخدم"),
                              widget.isEdit
                                  ? Container(
                                      height: 80.h,
                                      width: 80.w,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1, color: Colors.orange),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                "https://attendanceback.tamauze.com/${widget.member.userImageURL}",
                                              ),
                                              fit: BoxFit.fill)),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 10.h,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      TextFormField(
                                        enabled: edit,
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
                                                hintText: 'اسم المستخدم',
                                                suffixIcon: Icon(
                                                  Icons.person,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      TextFormField(
                                        enabled: edit,
                                        onFieldSubmitted: (_) {},
                                        textInputAction: TextInputAction.next,
                                        textAlign: TextAlign.right,
                                        validator: (text) {
                                          if (text.length == 0) {
                                            return 'مطلوب';
                                          }
                                          return null;
                                        },
                                        controller: _titleController,
                                        keyboardType: TextInputType.text,
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                                hintText: 'الوظيفة',
                                                suffixIcon: Icon(
                                                  Icons.title,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      TextFormField(
                                        enabled: edit,
                                        textInputAction: TextInputAction.next,
                                        textAlign: TextAlign.right,
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'مطلوب';
                                          } else {
                                            Pattern pattern =
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+\.[a-zA-Z]+";

                                            RegExp regex = new RegExp(pattern);
                                            if (!regex.hasMatch(text))
                                              return 'البريد الإلكترونى غير صحيح';
                                            else
                                              return null;
                                          }
                                        },
                                        controller: _emailController,
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                                hintText: 'البريد الالكترونى',
                                                suffixIcon: Icon(
                                                  Icons.email,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      widget.isEdit
                                          ? Container(
                                              child:
                                                  InternationalPhoneNumberInput(
                                                locale: "ar",
                                                isEnabled: true,
                                                countries: [
                                                  "EG",
                                                  "SA",
                                                  "BH",
                                                  "KW",
                                                  "IQ",
                                                  "JO",
                                                  "LB",
                                                  "QA",
                                                  "SY",
                                                  "AE",
                                                  "YE",
                                                  "OM",
                                                  "MA",
                                                  "LY",
                                                ],
                                                // onFieldSubmitted: (value) {
                                                //   print("a");
                                                // },
                                                // onSubmit: () {
                                                //   print("a");
                                                // },
                                                errorMessage: _phoneController
                                                        .text.isEmpty
                                                    ? "مطلوب"
                                                    : "رقم خاطئ",
                                                textAlign: TextAlign.right,
                                                inputDecoration:
                                                    kTextFieldDecorationWhite
                                                        .copyWith(
                                                            hintText:
                                                                "رقم الهاتف",
                                                            suffixIcon: Icon(
                                                              Icons.phone,
                                                              color:
                                                                  Colors.orange,
                                                            )),
                                                onInputChanged:
                                                    (intlPhone.PhoneNumber
                                                        number2) {
                                                  this.editNumber = number2;
                                                },
                                                onInputValidated:
                                                    (bool value) async {
                                                  print(value);
                                                  if (value) {
                                                    // setStateThePhone(
                                                    //     _phoneController.text);
                                                  }
                                                },
                                                spaceBetweenSelectorAndTextField:
                                                    0,
                                                selectorConfig: SelectorConfig(
                                                  showFlags: true,
                                                  useEmoji: true,
                                                  backgroundColor: Colors.black,
                                                  setSelectorButtonAsPrefixIcon:
                                                      true,
                                                  selectorType:
                                                      PhoneInputSelectorType
                                                          .DIALOG,
                                                ),
                                                cursorColor: Colors.grey,
                                                autoValidateMode:
                                                    AutovalidateMode.disabled,
                                                searchBoxDecoration:
                                                    InputDecoration(
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                        prefixIcon: Icon(
                                                          Icons.search,
                                                          color: Colors.grey,
                                                        ),
                                                        hintStyle:
                                                            TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                        hintText:
                                                            "اختر بأسم البلد او الرقم الدولى",
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0))),
                                                initialValue: editNumber,
                                                textFieldController:
                                                    _phoneController,
                                                formatInput: true,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        signed: true,
                                                        decimal: true),
                                                inputBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                onSaved: (intlPhone.PhoneNumber
                                                    number) {},
                                              ),
                                            )
                                          : Container(
                                              child:
                                                  InternationalPhoneNumberInput(
                                                isEnabled: true,
                                                locale: "ar",
                                                countries: [
                                                  "EG",
                                                  "SA",
                                                  "BH",
                                                  "KW",
                                                  "IQ",
                                                  "JO",
                                                  "LB",
                                                  "QA",
                                                  "SY",
                                                  "AE",
                                                  "YE",
                                                  "OM",
                                                  "MA",
                                                  "LY",
                                                ],
                                                onSubmit: () {},
                                                errorMessage: _phoneController
                                                        .text.isEmpty
                                                    ? "مطلوب"
                                                    : "رقم خاطئ",
                                                textAlign: TextAlign.right,
                                                inputDecoration:
                                                    kTextFieldDecorationWhite
                                                        .copyWith(
                                                            hintText:
                                                                "رقم الهاتف",
                                                            suffixIcon: Icon(
                                                              Icons.phone,
                                                              color:
                                                                  Colors.orange,
                                                            )),
                                                onInputChanged:
                                                    (intlPhone.PhoneNumber
                                                        number2) {
                                                  print(_phoneController.text);
                                                  number = number2;
                                                },
                                                onInputValidated:
                                                    (bool value) async {
                                                  if (value) {}
                                                },
                                                spaceBetweenSelectorAndTextField:
                                                    0,
                                                selectorConfig: SelectorConfig(
                                                  showFlags: true,
                                                  useEmoji: true,
                                                  backgroundColor: Colors.black,
                                                  setSelectorButtonAsPrefixIcon:
                                                      true,
                                                  selectorType:
                                                      PhoneInputSelectorType
                                                          .DIALOG,
                                                ),
                                                cursorColor: Colors.grey,
                                                autoValidateMode:
                                                    AutovalidateMode.disabled,
                                                searchBoxDecoration:
                                                    InputDecoration(
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                        prefixIcon: Icon(
                                                          Icons.search,
                                                          color: Colors.grey,
                                                        ),
                                                        hintStyle:
                                                            TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                        hintText:
                                                            "اختر بأسم البلد او الرقم الدولى",
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0))),
                                                initialValue: number,
                                                textFieldController:
                                                    _phoneController,
                                                formatInput: true,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        signed: true,
                                                        decimal: true),
                                                inputBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                onSaved: (intlPhone.PhoneNumber
                                                    number) {},
                                              ),
                                            ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      IgnorePointer(
                                        ignoring: widget.member.userType != 4
                                            ? !edit
                                            : true,
                                        child: RoundedBorderDropdown(
                                          edit: widget.member.userType != 4
                                              ? edit
                                              : false,
                                          list: Provider.of<MemberData>(context,
                                                  listen: false)
                                              .rolesList,
                                          colour: Colors.white,
                                          icon: Icons.person,
                                          borderColor: Colors.black,
                                          hint: "مديرين",
                                          hintColor: Colors.black,
                                          onChange: (value) {
                                            userType = getRoleId(value);
                                            print(value);
                                          },
                                          selectedvalue:
                                              Provider.of<MemberData>(context,
                                                      listen: false)
                                                  .rolesList[userType],
                                          textColor: Colors.orange,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      IgnorePointer(
                                        ignoring: !edit,
                                        child: SiteDropdown(
                                          edit: edit,
                                          list: Provider.of<SiteData>(context)
                                              .sitesList,
                                          colour: Colors.white,
                                          icon: Icons.location_on,
                                          borderColor: Colors.black,
                                          hint: "الموقع",
                                          hintColor: Colors.black,
                                          onChange: (value) {
                                            // print()

                                            siteId = getSiteId(value);
                                            Provider.of<ShiftsData>(context,
                                                    listen: false)
                                                .findMatchingShifts(
                                                    Provider.of<SiteData>(
                                                            context,
                                                            listen: false)
                                                        .sitesList[siteId]
                                                        .id,
                                                    false);
                                            setState(() {
                                              shiftId = 0;
                                            });
                                            Provider.of<SiteData>(context,
                                                    listen: false)
                                                .setSiteValue("كل المواقع");
                                            Provider.of<SiteData>(context,
                                                    listen: false)
                                                .setDropDownIndex(0);
                                            Provider.of<SiteData>(context,
                                                    listen: false)
                                                .setDropDownShift(0);
                                            print(siteId);
                                            print(value);
                                          },
                                          selectedvalue:
                                              Provider.of<SiteData>(context)
                                                  .sitesList[siteId]
                                                  .name,
                                          textColor: Colors.orange,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      IgnorePointer(
                                        ignoring: !edit,
                                        child: ShiftsDropDown(
                                          edit: edit,
                                          list: Provider.of<ShiftsData>(context,
                                                  listen: true)
                                              .shiftsBySite,
                                          colour: Colors.white,
                                          icon: Icons.location_on,
                                          borderColor: Colors.black,
                                          hint: "المناوبة",
                                          hintColor: Colors.black,
                                          onChange: (value) {
                                            // print()
                                            Provider.of<SiteData>(context,
                                                    listen: false)
                                                .setSiteValue("كل المواقع");
                                            Provider.of<SiteData>(context,
                                                    listen: false)
                                                .setDropDownIndex(0);
                                            Provider.of<SiteData>(context,
                                                    listen: false)
                                                .setDropDownShift(0);
                                            shiftId = getShiftid(value);
                                            print("shiftid..... =    $shiftId");
                                          },
                                          selectedvalue:
                                              Provider.of<ShiftsData>(context)
                                                  .shiftsBySite[shiftId]
                                                  .shiftName,
                                          textColor: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              RoundedButton(
                                onPressed: () async {
                                  // setStateThePhone(_phoneController.text);
                                  if (!widget.isEdit) {
                                    if (_formKey.currentState.validate()) {
                                      if (Provider.of<ShiftsData>(context,
                                                  listen: false)
                                              .shiftsBySite[shiftId]
                                              .shiftStartTime ==
                                          -1) {
                                        Fluttertoast.showToast(
                                            msg: "برجاء اختيار مناوبة",
                                            gravity: ToastGravity.CENTER,
                                            toastLength: Toast.LENGTH_SHORT,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: 16.0);
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return RoundedLoadingIndicator();
                                            });

                                        var token = Provider.of<UserData>(
                                                context,
                                                listen: false)
                                            .user
                                            .userToken;

                                        Provider.of<SiteData>(context,
                                                listen: false)
                                            .setDropDownIndex(0);
                                        Provider.of<SiteData>(context,
                                                listen: false)
                                            .setDropDownShift(0);
                                        var msg = await Provider.of<MemberData>(
                                                context,
                                                listen: false)
                                            .addMember(
                                                Member(
                                                    userType: userType,
                                                    shiftId: Provider.of<
                                                                ShiftsData>(
                                                            context,
                                                            listen: false)
                                                        .shiftsBySite[shiftId]
                                                        .shiftId,
                                                    jobTitle: _titleController
                                                        .text
                                                        .trim(),
                                                    email: _emailController.text
                                                        .trim(),
                                                    phoneNumber: number
                                                            .dialCode +
                                                        _phoneController.text
                                                            .replaceAll(
                                                          new RegExp(
                                                              r"\s+\b|\b\s"),
                                                          "",
                                                        ),
                                                    name: _nameController.text
                                                        .trim()),
                                                token,
                                                context);
                                        Navigator.pop(context);
                                        if (msg == "Success") {
                                          Fluttertoast.showToast(
                                              msg: "تم اضافة المستخدم بنجاح",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                          Provider.of<SiteData>(context,
                                                  listen: false)
                                              .setSiteValue("كل المواقع");
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              UsersScreen(-1,
                                                                  false)),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        } else if (msg == "exists") {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "خطأ في اضافة المستخدم:البريد الإلكتروني مستخدم مسبقا",
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize: 16.0);
                                        } else if (msg == "Limit Reached") {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "لقد وصلت الى الحد المسموح بة من المستخدمين",
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize: 16.0);
                                        } else if (msg == "failed") {
                                          Fluttertoast.showToast(
                                              msg: "خطأ في اضافة المستخدم",
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize: 16.0);
                                        } else if (msg == "noInternet") {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "خطأ في اضافة المستخدم:لايوجد اتصال بالانترنت",
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize: 16.0);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "خطأ في اضافة المستخدم",
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              gravity: ToastGravity.CENTER,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.black,
                                              fontSize: 16.0);
                                        }
                                      }
                                    }
                                  } else {
                                    if (edit) {
                                      if (_formKey.currentState.validate()) {
                                        if (Provider.of<ShiftsData>(context,
                                                    listen: false)
                                                .shiftsBySite[shiftId]
                                                .shiftStartTime ==
                                            -1) {
                                          Fluttertoast.showToast(
                                              msg: "برجاء اختيار مناوبة",
                                              toastLength: Toast.LENGTH_SHORT,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize: 16.0);
                                        } else {
                                          // setStateThePhone(
                                          //     _phoneController.text);
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) =>
                                                SingleChildScrollView(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                  ),
                                                  height: 200,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      RoundedButton(
                                                        onPressed: () async {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return RoundedLoadingIndicator();
                                                              });

                                                          var token = Provider
                                                                  .of<UserData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                              .user
                                                              .userToken;
                                                          var msg = await Provider.of<MemberData>(
                                                                  context,
                                                                  listen: false)
                                                              .editMember(
                                                                  Member(
                                                                      id: widget
                                                                          .member
                                                                          .id,
                                                                      userType:
                                                                          userType,
                                                                      shiftId: Provider.of<ShiftsData>(context, listen: false)
                                                                          .shiftsBySite[
                                                                              shiftId]
                                                                          .shiftId,
                                                                      phoneNumber: editNumber
                                                                              .dialCode +
                                                                          _phoneController.text
                                                                              .replaceAll(
                                                                            new RegExp(r"\s+\b|\b\s"),
                                                                            "",
                                                                          ),
                                                                      jobTitle:
                                                                          _titleController
                                                                              .text,
                                                                      email: _emailController
                                                                          .text
                                                                          .trim(),
                                                                      name: _nameController
                                                                          .text),
                                                                  widget.id,
                                                                  token,
                                                                  context);

                                                          if (msg ==
                                                              "Success") {
                                                            Fluttertoast.showToast(
                                                                    msg:
                                                                        "تم تعديل المستخدم بنجاح",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity: ToastGravity
                                                                        .CENTER,
                                                                    timeInSecForIosWeb:
                                                                        1,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .green,
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        16.0)
                                                                .then((value) {
                                                              if (Provider.of<UserData>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .user
                                                                      .id ==
                                                                  widget.member
                                                                      .id) {
                                                                Provider.of<UserData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .siteName = Provider.of<
                                                                            SiteData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .sitesList[
                                                                        siteId]
                                                                    .name;
                                                              }
                                                            }).then((value) =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      new MaterialPageRoute(
                                                                        builder: (context) => UsersScreen(
                                                                            -1,
                                                                            false),
                                                                      ),
                                                                    ));

                                                            setState(() {
                                                              edit = false;
                                                            });
                                                          } else if (msg ==
                                                              "exists") {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ في اضافة المستخدم:البريد الإلكتروني مستخدم مسبقا",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                textColor:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 16.0);
                                                          } else if (msg ==
                                                              "failed") {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ في تعديل المستخدم",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                textColor:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 16.0);
                                                          } else if (msg ==
                                                              "noInternet") {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ في تعديل المستخدم:لايوجد اتصال بالانترنت",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                textColor:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 16.0);
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "خطأ في تعديل المستخدم",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                textColor:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 16.0);
                                                          }
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        title: "حفظ ؟",
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        edit = true;
                                      });
                                    }
                                  }
                                },
                                title: (!widget.isEdit)
                                    ? "إضافة"
                                    : edit
                                        ? "حفظ"
                                        : "تعديل",
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: InkWell(
                                  onTap: () async {
                                    final PhoneContact contact =
                                        await FlutterContactPicker
                                                .pickPhoneContact()
                                            .catchError((e) {
                                      print(e);
                                    });
                                    if (contact != null) {
                                      getPhoneNumber(contact.phoneNumber.number,
                                          contact.fullName);
                                    }
                                  },
                                  child: Container(
                                    height: 20,
                                    child: AutoSizeText(
                                      "اضافة من جهات الاتصال",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          color: Colors.orange),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
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
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => UsersScreen(-1, false)),
                              (Route<dynamic> route) => false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setStateThePhone(String phoneNumber) async {
    // if (phoneNumber[0] != "+") {
    //   phoneNumber = "+20$phoneNumber";
    // }
    print(widget.editiableDial);
    intlPhone.PhoneNumber number3 =
        await intlPhone.PhoneNumber.getRegionInfoFromPhoneNumber(
            "+${widget.editiableDial}$phoneNumber");

    print(number3.phoneNumber);
    print(number3.dialCode);
    print(number3.isoCode);
    setState(() {
      this.editNumber = number3;
      _phoneController.text = editNumber.phoneNumber;
    });
  }

  void getPhoneNumber(String phoneNumber, String name) async {
    if (!widget.isEdit) {
      if (phoneNumber[0] != "+") {
        phoneNumber = "+20$phoneNumber";
      }
      print(number.isoCode);
      intlPhone.PhoneNumber number2 =
          await intlPhone.PhoneNumber.getRegionInfoFromPhoneNumber(
              phoneNumber, number.isoCode);
      print(number.isoCode);
      print(number2.phoneNumber);
      print(number2.dialCode);
      print(number2.isoCode);
      setState(() {
        this.number = number2;
        _phoneController.text = number2.phoneNumber;
        _nameController.text = name.trim() ?? "";
      });
    } else {
      if (phoneNumber[0] != "+") {
        phoneNumber = "+20$phoneNumber";
      }
      print(number.isoCode);
      intlPhone.PhoneNumber number2 =
          await intlPhone.PhoneNumber.getRegionInfoFromPhoneNumber(
              phoneNumber, editNumber.isoCode);
      print(number.isoCode);
      print(number2.phoneNumber);
      print(number2.dialCode);
      print(number2.isoCode);
      setState(() {
        this.editNumber = number2;
        _phoneController.text = number2.phoneNumber;
        _nameController.text = name.trim() ?? "";
      });
    }
  }

  int getSiteId(String siteName) {
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
  }

  int getSiteListIndex(int fShiftId) {
    var fSiteId = Provider.of<ShiftsData>(context, listen: false)
        .shiftsBySite[fShiftId]
        .siteID;

    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (fSiteId == list[i].id) {
        return i;
      }
    }
    return -1;
  }

  int getShiftListIndex(int shiftId) {
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsBySite;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (shiftId == list[i].shiftId) {
        return i;
      }
    }
    return -1;
  }

  int getShiftid(String shiftName) {
    print("shiftName getShiftId $shiftName");
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsBySite;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (shiftName == list[i].shiftName) {
        return i;
      }
    }
    return -1;
  }

  int getRoleId(String role) {
    var rolesList = Provider.of<MemberData>(context, listen: false).rolesList;
    int index = rolesList.length;
    for (int i = 0; i < index; i++) {
      if (role == rolesList[i]) {
        return i;
      }
    }
    return -1;
  }

  Future<bool> onWillPop() async {
    print("back");

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => UsersScreen(-1, false)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class LocationTile extends StatelessWidget {
  final String title;

  final Function onTapLocation;
  final Function onTapEdit;
  final Function onTapDelete;
  LocationTile(
      {this.title, this.onTapEdit, this.onTapDelete, this.onTapLocation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5.w),
      child: Card(
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Container(
              width: double.infinity,
              height: 60.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircularIconButton(
                        icon: Icons.delete,
                        onTap: onTapDelete,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      CircularIconButton(
                        icon: Icons.edit,
                        onTap: onTapEdit,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      CircularIconButton(
                        icon: Icons.location_on,
                        onTap: onTapLocation,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AutoSizeText(
                        title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
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
            size: 25,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
