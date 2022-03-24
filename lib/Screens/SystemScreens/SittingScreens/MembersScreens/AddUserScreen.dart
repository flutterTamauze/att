import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/UserFullData/editUser.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';

import 'UsersScreen.dart';

class AddUserScreen extends StatefulWidget {
  final Member member;
  final int id;
  final String editableUserPhone;
  final String editiableDial;
  final isEdit;
  String selectedRole;

  bool comingFromShifts = false;
  final String shiftNameIncoming;
  AddUserScreen(this.member, this.id, this.isEdit, this.editableUserPhone,
      this.editiableDial, this.comingFromShifts, this.shiftNameIncoming,
      [this.selectedRole]);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  bool edit = true;
  int siteId;

  intlPhone.PhoneNumber number =
      intlPhone.PhoneNumber(dialCode: "+20", isoCode: "EG");

  int getShiftIndex() {
    int holder = 0;
    final List<String> x = [];
    print(Provider.of<SiteData>(context, listen: false).currentShiftName);
    Provider.of<SiteShiftsData>(context, listen: false)
        .shifts
        .forEach((element) {
      x.add(element.shiftName);
    });

    holder = x.indexOf(
        Provider.of<SiteData>(context, listen: false).currentShiftName);
    log(holder.toString());
    if (holder != null && holder != -1) {
      return holder;
    } else {
      return 0;
    }
  }

  getSiteIndex(siteId) {
    final sites = Provider.of<SiteShiftsData>(context, listen: false).sites;
    for (int i = 0; i < sites.length; i++) {
      if (siteId == sites[i].id) {
        return i - 1;
      }
    }
  }

  List<String> rolesList = [];
  @override
  void didChangeDependencies() {
    rolesList = [
      getTranslated(context, "مستخدم"),
      getTranslated(context, "مسئول تسجيل"),
      getTranslated(context, "مدير موقع"),
      getTranslated(context, "موارد بشرية"),
      getTranslated(context, "ادمن"),
    ];
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    print("selected role ${widget.selectedRole}");
    userRole = widget.selectedRole;
    print(widget.comingFromShifts);
    if (widget.comingFromShifts) {
      print("shift incoming =${widget.shiftNameIncoming}");
      shiftIndex = getShiftid(widget.shiftNameIncoming);
    } else {
      shiftIndex =
          Provider.of<SiteData>(context, listen: false).dropDownShiftIndex;
      print("current shift index $shiftIndex");
    }

    editNumber = intlPhone.PhoneNumber(
        isoCode: widget.editableUserPhone,
        dialCode: widget.editiableDial,
        phoneNumber: widget.member.phoneNumber);
    fillTextField();
    if (widget.isEdit) {
      siteId = getSiteIndex(widget.member.siteId);
      print(siteId);
    } else {
      if (Provider.of<SiteShiftsData>(context, listen: false).sites.length ==
          2) {
        siteId = 0;
      } else {
        siteId =
            Provider.of<SiteData>(context, listen: false).dropDownSitesIndex;
      }

      print(
          "dropdownindex ${Provider.of<SiteData>(context, listen: false).dropDownSitesIndex}");
      if (!widget.comingFromShifts) {
        Provider.of<SiteShiftsData>(context, listen: false).getShiftsList(
            widget.shiftNameIncoming == "كل المواقع"
                ? Provider.of<SiteShiftsData>(context, listen: false)
                    .siteShiftList[0]
                    .siteName
                : widget.shiftNameIncoming,
            false);
        // Provider.of<ShiftsData>(context, listen: false).findMatchingShifts(
        //     Provider.of<SiteData>(context, listen: false).sitesList[siteId].id,
        //     false);
      }
    }
  }

  var phoneLoading = false;

  @override
  void dispose() {
    _phoneController?.dispose();
    super.dispose();
  }

  fillTextField() async {
    if (widget.isEdit) {
      edit = true;
      Provider.of<SiteShiftsData>(context, listen: false)
          .getShiftsList(widget.member.siteName, false);

      shiftIndex = getShiftListIndex(widget.member.shiftId) + 1;
      print(shiftIndex);

      Provider.of<SiteData>(context, listen: false)
          .setDropDownShift(shiftIndex); //to match the -1 bec of all shifts

      print("shift index $shiftIndex");
      // log("shift index displayed ${Provider.of<SiteData>(context, listen: false).dropDownShiftIndex}");
      // siteId = getSiteListIndex(shiftIndex);
      _nameController.text = widget.member.name;
      _emailController.text = widget.member.email;
      _phoneController.text = widget.member.phoneNumber;
      _titleController.text = widget.member.jobTitle;
      _salaryController.text = widget.member.salary.toString();
      userType = widget.member.userType;
      setState(() {});
    } else {
      print(widget.comingFromShifts);
      if (!widget.comingFromShifts) {
        Provider.of<SiteShiftsData>(context, listen: false)
            .getShiftsList(widget.shiftNameIncoming, false);
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _salaryController = TextEditingController();

  int shiftIndex = 0;
  int userType = 0;
  String userRole = "";
  List<Shift> shiftsList;
  intlPhone.PhoneNumber editNumber;

  bool userImageFailed = false;
  @override
  Widget build(BuildContext context) {
    String userImage = "$imageUrl${widget.member.userImageURL}";
    final siteData = Provider.of<SiteData>(context, listen: false);
    final siteShiftData = Provider.of<SiteShiftsData>(context);
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        endDrawer: NotificationItem(),
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            child: GestureDetector(
              onTap: () {
                print(shiftIndex);
                print(Provider.of<SiteShiftsData>(context, listen: false)
                    .dropDownShifts[siteData.dropDownShiftIndex == 0
                        ? 0
                        : siteData.dropDownShiftIndex - 1]
                    .shiftName);
                print(siteData.dropDownShiftIndex);
              },
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
                                  Lottie.asset("resources/user.json",
                                      repeat: false),
                                  (!widget.isEdit)
                                      ? getTranslated(context, "إضافة مستخدم")
                                      : getTranslated(
                                          context, "تعديل بيانات المستخدم")),
                              widget.isEdit
                                  ? Container(
                                      height: 80.h,
                                      width: 80.w,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1, color: Colors.orange),
                                          image: DecorationImage(
                                              image: !userImageFailed
                                                  ? NetworkImage(
                                                      "$imageUrl${widget.member.userImageURL}",
                                                      headers: {
                                                        "Authorization": "Bearer " +
                                                            Provider.of<UserData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .user
                                                                .userToken
                                                      },
                                                    )
                                                  : AssetImage(
                                                      "resources/personicon.png"),
                                              onError: (exception, stackTrace) {
                                                setState(() {
                                                  userImageFailed = true;
                                                });
                                              },
                                              fit: BoxFit.fill)),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 10.h,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      TextFormField(
                                        enabled: edit,
                                        onFieldSubmitted: (_) {},
                                        textInputAction: TextInputAction.next,
                                        validator: (text) {
                                          if (text.length == 0) {
                                            return getTranslated(
                                                context, "مطلوب");
                                          } else if (text.length > 80) {
                                            return "يجب ان لا يتخطي اسم المستخدم عن 80 حرف";
                                          }
                                          return null;
                                        },
                                        controller: _nameController,
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                                hintText: getTranslated(
                                                    context, 'اسم المستخدم'),
                                                suffixIcon: const Icon(
                                                  Icons.person,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      TextFormField(
                                        enabled: edit,
                                        onFieldSubmitted: (_) {},
                                        textInputAction: TextInputAction.next,
                                        validator: (text) {
                                          if (text.length == 0) {
                                            return getTranslated(
                                                context, "مطلوب");
                                          }
                                          return null;
                                        },
                                        controller: _titleController,
                                        keyboardType: TextInputType.text,
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                                hintText: getTranslated(
                                                    context, 'الوظيفة'),
                                                suffixIcon: const Icon(
                                                  Icons.title,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      TextFormField(
                                        enabled: edit,
                                        textInputAction: TextInputAction.next,
                                        validator: (text) {
                                          if (text != "") {
                                            const Pattern pattern =
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+\.[a-zA-Z]+";

                                            final RegExp regex =
                                                new RegExp(pattern);
                                            if (!regex.hasMatch(text))
                                              return getTranslated(context,
                                                  'البريد الإلكترونى غير صحيح');
                                          } else if (text.length == 0) {
                                            return getTranslated(
                                                context, "مطلوب");
                                          } else if (text.length > 80) {
                                            return getTranslated(context,
                                                "يجب ان لا يتخطي البريد الإلكترةني عن 80 حرف");
                                          }
                                          return null;
                                        },
                                        controller: _emailController,
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                                hintText: getTranslated(context,
                                                    'البريد الالكترونى'),
                                                suffixIcon: const Icon(
                                                  Icons.email,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      widget.isEdit
                                          ? Container(
                                              child:
                                                  InternationalPhoneNumberInput(
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
                                                    ? getTranslated(
                                                        context, "مطلوب")
                                                    : "رقم خاطئ",
                                                inputDecoration:
                                                    kTextFieldDecorationWhite
                                                        .copyWith(
                                                            hintText:
                                                                getTranslated(
                                                                    context,
                                                                    "رقم الهاتف"),
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
                                                selectorConfig:
                                                    const SelectorConfig(
                                                  showFlags: true,
                                                  useEmoji: true,
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
                                                                const BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                        prefixIcon: const Icon(
                                                          Icons.search,
                                                          color: Colors.grey,
                                                        ),
                                                        hintStyle:
                                                            TextStyle(
                                                                color: Colors
                                                                    .grey,
                                                                fontSize:
                                                                    setResponsiveFontSize(
                                                                        15),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                        hintText: getTranslated(
                                                            context,
                                                            "اختر بأسم البلد او الرقم الدولى"),
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0))),
                                                initialValue: editNumber,
                                                textFieldController:
                                                    _phoneController,
                                                formatInput: true,
                                                keyboardType:
                                                    const TextInputType
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
                                                    ? getTranslated(
                                                        context, "مطلوب")
                                                    : "رقم خاطئ",
                                                inputDecoration:
                                                    kTextFieldDecorationWhite
                                                        .copyWith(
                                                            hintText:
                                                                getTranslated(
                                                                    context,
                                                                    "رقم الهاتف"),
                                                            suffixIcon:
                                                                const Icon(
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
                                                selectorConfig:
                                                    const SelectorConfig(
                                                  showFlags: true,
                                                  useEmoji: true,
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
                                                                const BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                        prefixIcon: const Icon(
                                                          Icons.search,
                                                          color: Colors.grey,
                                                        ),
                                                        hintStyle:
                                                            TextStyle(
                                                                color: Colors
                                                                    .grey,
                                                                fontSize:
                                                                    setResponsiveFontSize(
                                                                        15),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                        hintText: getTranslated(
                                                            context,
                                                            "اختر بأسم البلد او الرقم الدولى"),
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0))),
                                                initialValue: number,
                                                textFieldController:
                                                    _phoneController,
                                                formatInput: true,
                                                keyboardType:
                                                    const TextInputType
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
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      TextFormField(
                                        enabled: edit,
                                        onFieldSubmitted: (_) {},
                                        textInputAction: TextInputAction.next,
                                        validator: (text) {
                                          if (text.length == 0) {
                                            return getTranslated(
                                                context, "مطلوب");
                                          }
                                          return null;
                                        },
                                        controller: _salaryController,
                                        keyboardType: TextInputType.number,
                                        decoration:
                                            kTextFieldDecorationWhite.copyWith(
                                                hintText: getTranslated(
                                                    context, 'المرتب'),
                                                suffixIcon: const Icon(
                                                  Icons.money,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                      const SizedBox(
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
                                          list: rolesList,
                                          colour: Colors.white,
                                          icon: Icons.person,
                                          borderColor: Colors.black,
                                          hint: "مديرين",
                                          hintColor: Colors.black,
                                          onChange: (String value) {
                                            userType = getRoleId(value);
                                            widget.selectedRole = value;
                                            userRole = value;
                                          },
                                          selectedvalue: widget.selectedRole,
                                          textColor: Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      IgnorePointer(
                                        ignoring: !edit,
                                        child: SiteDropdown(
                                          edit: edit,
                                          list: Provider.of<SiteShiftsData>(
                                                  context)
                                              .siteShiftList,
                                          colour: Colors.white,
                                          icon: Icons.location_on,
                                          borderColor: Colors.black,
                                          hint:
                                              getTranslated(context, "الموقع"),
                                          hintColor: Colors.black,
                                          onChange: (value) {
                                            // print()
                                            siteId = getSiteId(value);
                                            Provider.of<SiteShiftsData>(context,
                                                    listen: false)
                                                .getShiftsList(value, true);

                                            setState(() {
                                              shiftIndex = 0;
                                            });
                                            siteData
                                              ..setSiteValue("كل المواقع")
                                              ..setDropDownIndex(0)
                                              ..setDropDownShift(0);

                                            print(siteId);
                                            print(value);
                                          },
                                          selectedvalue:
                                              Provider.of<SiteShiftsData>(
                                                      context)
                                                  .siteShiftList[siteId]
                                                  .siteName,
                                          textColor: Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      IgnorePointer(
                                        ignoring: !edit,
                                        child: ShiftsDropDown(
                                          edit: edit,
                                          list: Provider.of<SiteShiftsData>(
                                                  context,
                                                  listen: true)
                                              .dropDownShifts,
                                          colour: Colors.white,
                                          icon: Icons.location_on,
                                          borderColor: Colors.black,
                                          hint: "المناوبة",
                                          hintColor: Colors.black,
                                          onChange: (value) {
                                            // print()
                                            log(value);
                                            siteData
                                              ..setSiteValue("كل المواقع")
                                              ..setDropDownIndex(0)
                                              ..setDropDownShift(
                                                  getShiftid(value));

                                            shiftIndex = getShiftid(value);

                                            print(
                                                "shiftid..... =    $shiftIndex");
                                          },
                                          selectedvalue: !widget.isEdit
                                              ? siteData.dropDownShiftIndex == 0
                                                  ? siteShiftData
                                                      .dropDownShifts[siteData
                                                          .dropDownShiftIndex]
                                                      .shiftName
                                                  : siteShiftData
                                                      .dropDownShifts[siteData
                                                              .dropDownShiftIndex -
                                                          1] //-1 because كل المناوبات is counted in shift index
                                                      .shiftName
                                              : siteShiftData
                                                  .dropDownShifts[siteData
                                                          .dropDownShiftIndex -
                                                      1]
                                                  .shiftName,
                                          textColor: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              RoundedButton(
                                onPressed: () async {
                                  // setStateThePhone(_phoneController.text);
                                  if (!widget.isEdit) {
                                    if (_formKey.currentState.validate()) {
                                      if (Provider.of<SiteShiftsData>(context,
                                                  listen: false)
                                              .shifts[
                                                  Provider.of<SiteShiftsData>(
                                                                  context,
                                                                  listen: false)
                                                              .shifts
                                                              .length ==
                                                          1
                                                      ? 0
                                                      : Provider.of<SiteData>(
                                                              context,
                                                              listen: false)
                                                          .dropDownShiftIndex]
                                              .shiftName ==
                                          "لا يوجد مناوبات بهذا الموقع") {
                                        Fluttertoast.showToast(
                                            msg: "لا يوجد مناوبات بهذا الموقع",
                                            backgroundColor: Colors.red,
                                            gravity: ToastGravity.CENTER);
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return RoundedLoadingIndicator();
                                            });

                                        siteData
                                          ..setDropDownIndex(0)
                                          ..setDropDownShift(0);

                                        final String msg = await Provider.of<MemberData>(
                                                context,
                                                listen: false)
                                            .addMember(
                                                Member(
                                                    userType: userType,
                                                    shiftId:
                                                        Provider.of<SiteShiftsData>(
                                                                context,
                                                                listen: false)
                                                            .dropDownShifts[
                                                                shiftIndex == 0
                                                                    ? 0
                                                                    : shiftIndex -
                                                                        1]
                                                            .shiftId,
                                                    jobTitle: _titleController
                                                        .text
                                                        .trim(),
                                                    email: _emailController.text
                                                        .trim(),
                                                    salary: double.parse(
                                                        _salaryController.text),
                                                    phoneNumber: number.dialCode +
                                                        _phoneController.text.replaceAll(
                                                          new RegExp(
                                                              r"\s+\b|\b\s"),
                                                          "",
                                                        ),
                                                    name: _nameController.text.trim()),
                                                context,
                                                getRoleName(userRole));
                                        Navigator.pop(context);

                                        if (msg == "Success") {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(
                                                  context, "تم الإضافة بنجاح"),
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize:
                                                  setResponsiveFontSize(16));
                                          Provider.of<SiteData>(context,
                                                  listen: false)
                                              .setSiteValue("كل المواقع");
                                          await Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UsersScreen(-1, false, ""),
                                              ));
                                        } else if (msg == "exists") {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(context,
                                                  "خطأ في اضافة المستخدم : رقم الهاتف  مستخدم مسبقا"),
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize:
                                                  setResponsiveFontSize(16));
                                        } else if (msg == "user exists") {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(context,
                                                  "خطأ في اضافة المستخدم : المستخدم موجود بالفعل"),
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize:
                                                  setResponsiveFontSize(16));
                                        } else if (msg == "Limit Reached") {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(context,
                                                  "لقد وصلت الى الحد المسموح بة من المستخدمين"),
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize: 16.0);
                                        } else if (msg == "failed") {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(context,
                                                  "خطأ في اضافة المستخدم"),
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize:
                                                  setResponsiveFontSize(16));
                                        } else if (msg == "noInternet") {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(
                                                context,
                                                "خطأ في اضافة المستخدم:لايوجد اتصال بالانترنت",
                                              ),
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER,
                                              textColor: Colors.black,
                                              fontSize:
                                                  setResponsiveFontSize(16));
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(context,
                                                  "خطأ في اضافة المستخدم"),
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 1,
                                              gravity: ToastGravity.CENTER,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.black,
                                              fontSize:
                                                  setResponsiveFontSize(16));
                                        }
                                      }
                                    }
                                  } else {
                                    if (edit) {
                                      if (_formKey.currentState.validate()) {
                                        if (Provider.of<SiteShiftsData>(context,
                                                    listen: false)
                                                .shifts[
                                                    Provider.of<SiteShiftsData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .shifts
                                                                .length ==
                                                            1
                                                        ? 0
                                                        : Provider.of<SiteData>(
                                                                context,
                                                                listen: false)
                                                            .dropDownShiftIndex]
                                                .shiftName ==
                                            "لا يوجد مناوبات بهذا الموقع") {
                                          Fluttertoast.showToast(
                                              msg: getTranslated(context,
                                                  "لا يوجد مناوبات بهذا الموقع"),
                                              backgroundColor: Colors.red,
                                              gravity: ToastGravity.CENTER);
                                        } else {
                                          return showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return EditMember(
                                                  editNumber: editNumber,
                                                  emailController:
                                                      _emailController,
                                                  id: widget.id,
                                                  member: widget.member,
                                                  userType: userType,
                                                  nameController:
                                                      _nameController,
                                                  salaryController:
                                                      _salaryController,
                                                  phoneController:
                                                      _phoneController,
                                                  shiftIndex: shiftIndex,
                                                  siteId: siteId,
                                                  titleController:
                                                      _titleController,
                                                  userRole: userRole,
                                                );
                                              });
                                        }
                                      }
                                      // }
                                    } else {
                                      setState(() {
                                        edit = true;
                                      });
                                    }
                                  }
                                },
                                title: (!widget.isEdit)
                                    ? getTranslated(context, "إضافة")
                                    : edit
                                        ? getTranslated(context, "حفظ")
                                        : getTranslated(context, "تعديل"),
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
                                    margin: EdgeInsets.only(right: 20.w),
                                    height: 20,
                                    child: AutoSizeText(
                                      getTranslated(
                                          context, "إضافة من جهات الاتصال"),
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: setResponsiveFontSize(15),
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
                                  builder: (context) =>
                                      UsersScreen(-1, false, "")),
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
    final intlPhone.PhoneNumber number3 =
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
      final intlPhone.PhoneNumber number2 =
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
      final intlPhone.PhoneNumber number2 =
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
    final list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].siteName) {
        return i;
      }
    }
    return -1;
  }

  // int getSiteListIndex(int fShiftId) {
  //   var fSiteId = Provider.of<ShiftsData>(context, listen: false)
  //       .shiftsBySite[fShiftId]
  //       .siteID;

  //   var list = Provider.of<SiteData>(context, listen: false).sitesList;
  //   int index = list.length;
  //   for (int i = 0; i < index; i++) {
  //     if (fSiteId == list[i].id) {
  //       return i;
  //     }
  //   }
  //   return -1;
  // }

  int getShiftListIndex(int shiftId) {
    final list =
        Provider.of<SiteShiftsData>(context, listen: false).dropDownShifts;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (shiftId == list[i].shiftId) {
        return i;
      }
    }
    return -1;
  }

  int getShiftid(String shiftName) {
    print("shiftName getShiftId $shiftName");
    final list = Provider.of<SiteShiftsData>(context, listen: false).shifts;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (shiftName == list[i].shiftName) {
        return i;
      }
    }
    return -1;
  }

  int getRoleId(String role) {
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
    Provider.of<SiteData>(context, listen: false).setSiteValue("كل المواقع");
    Provider.of<SiteData>(context, listen: false).setDropDownIndex(0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => UsersScreen(-1, false, "")),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

String getRoleName(String role) {
  switch (role) {
    case "مستخدم":
    case "User":
      return "User";
      break;
    case "مسئول تسجيل":
    case "Registry Administrator":
      return "Attend_Admin";
      break;
    case "مدير موقع":
    case "Site Admin":
      return "Site_Admin";
      break;
    case "موارد بشرية":
    case "HR":
      return "HR";
      break;
    case "ادمن":
    case "Admin":
      return "Admin";
      break;

    default:
      return "";
  }
}

class LocationTile extends StatelessWidget {
  final String title;

  final Function onTapLocation;
  final Function onTapEdit;
  final Function onTapDelete;
  const LocationTile(
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
                      const SizedBox(
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
                            fontSize: setResponsiveFontSize(16),
                            fontWeight: FontWeight.w600),
                      ),
                      const Icon(
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

  const CircularIconButton({this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
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
