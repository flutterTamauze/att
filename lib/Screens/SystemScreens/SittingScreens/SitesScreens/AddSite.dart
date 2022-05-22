import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/SelectOnMapScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/SitesScreen.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Core/constants.dart';

class AddSiteScreen extends StatefulWidget {
  final Site site;
  final int id;
  final isEdit;
  final hasData;

  const AddSiteScreen(this.site, this.id, this.isEdit, this.hasData);

  @override
  _AddSiteScreenState createState() => _AddSiteScreenState();
}

class _AddSiteScreenState extends State<AddSiteScreen> {
  bool edit = true;

  @override
  void initState() {
    super.initState();
    fillTextField();
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _lat = TextEditingController();
  TextEditingController _long = TextEditingController();
  TextEditingController _title = TextEditingController();

  fillTextField() {
    _lat.text = widget.site.lat.toString();
    _long.text = widget.site.long.toString();
    if (widget.isEdit) {
      _title.text = widget.site.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
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
                      goUserMenu: false,
                      goUserHomeFromMenu: false,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SmallDirectoriesHeader(
                                Lottie.asset("resources/locaitonss.json",
                                    repeat: false),
                                (!widget.isEdit)
                                    ? getTranslated(context, "إضافة مواقع")
                                    : getTranslated(context, "تعديل مواقع")),
                            Divider(
                              color: ColorManager.primary,
                              endIndent: 50.w,
                            ),
                            SizedBox(
                              height: 30.h,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    TextFormField(
                                      enabled: edit,
                                      onFieldSubmitted: (_) {},
                                      textInputAction: TextInputAction.done,
                                      validator: (text) {
                                        if (text.length == 0) {
                                          return getTranslated(
                                              context, "مطلوب");
                                        } else if (text.length > 35) {
                                          return "يجب ان لا يزيد اسم الموقع عن 35 حرف";
                                        }
                                        return null;
                                      },
                                      controller: _title,
                                      decoration:
                                          kTextFieldDecorationWhite.copyWith(
                                              hintText: getTranslated(
                                                  context, 'اسم الموقع'),
                                              suffixIcon: const Icon(
                                                Icons.title,
                                                color: Colors.orange,
                                              )),
                                    ),
                                    SizedBox(
                                      height: 10.0.h,
                                    ),
                                    IgnorePointer(
                                      ignoring: !edit,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddLocationMapScreen(
                                                        widget.site,
                                                        widget.id)),
                                          );
                                        },
                                        child: TextFormField(
                                          enabled: false,
                                          textInputAction: TextInputAction.next,
                                          controller: _lat,
                                          decoration: kTextFieldDecorationWhite
                                              .copyWith(
                                                  hintText: 'Latitude',
                                                  suffixIcon: Icon(
                                                    Icons.location_on,
                                                    color: ColorManager.primary,
                                                  )),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0.h,
                                    ),
                                    IgnorePointer(
                                      ignoring: !edit,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddLocationMapScreen(
                                                        widget.site,
                                                        widget.id)),
                                          );
                                        },
                                        child: TextFormField(
                                          enabled: false,
                                          textInputAction: TextInputAction.next,
                                          controller: _long,
                                          decoration: kTextFieldDecorationWhite
                                              .copyWith(
                                                  hintText: 'Longitude',
                                                  suffixIcon: const Icon(
                                                    Icons.location_on,
                                                    color: Colors.orange,
                                                  )),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: RoundedButton(
                                onPressed: () async {
                                  if (!widget.isEdit) {
                                    if (_formKey.currentState.validate()) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return RoundedLoadingIndicator();
                                          });
                                      final Company com =
                                          Provider.of<CompanyData>(context,
                                                  listen: false)
                                              .com;
                                      final userToken = Provider.of<UserData>(
                                              context,
                                              listen: false)
                                          .user
                                          .userToken;
                                      final msg = await Provider.of<SiteData>(
                                              context,
                                              listen: false)
                                          .addSite(
                                              Site(
                                                  name: _title.text,
                                                  long: widget.site.long,
                                                  lat: widget.site.lat),
                                              com.id,
                                              userToken,
                                              context);
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
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));

                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SitesScreen()),
                                                (Route<dynamic> route) =>
                                                    false);
                                      } else if (msg == "exists") {
                                        Fluttertoast.showToast(
                                            msg: getTranslated(context,
                                                "خطأ في اضافة الموقع: اسم الموقع مضاف مسبقا"),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                      } else if (msg == "Limit Reached") {
                                        Fluttertoast.showToast(
                                            msg: getTranslated(context,
                                                "لقد وصلت الى الحد المسموح بة من المواقع"),
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                      } else if (msg == "failed") {
                                        Fluttertoast.showToast(
                                            msg: getTranslated(
                                              context,
                                              "خطأ في اضافة الموقع",
                                            ),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                      } else if (msg == "noInternet") {
                                        Fluttertoast.showToast(
                                            msg: getTranslated(context,
                                                "خطأ في اضافة الموقع:لايوجد اتصال بالانترنت"),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: getTranslated(
                                                context, "خطأ في اضافة الموقع"),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                      }
                                      // Navigator.pop(context);
                                    }
                                  } else {
                                    if (edit) {
                                      if (_formKey.currentState.validate()) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return RoundedAlert(
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return RoundedLoadingIndicator();
                                                      });

                                                  final Company com =
                                                      Provider.of<CompanyData>(
                                                              context,
                                                              listen: false)
                                                          .com;
                                                  final userToken =
                                                      Provider.of<UserData>(
                                                              context,
                                                              listen: false)
                                                          .user
                                                          .userToken;
                                                  final msg = await Provider.of<
                                                              SiteData>(context,
                                                          listen: false)
                                                      .editSite(
                                                          Site(
                                                              id: widget
                                                                  .site.id,
                                                              name: _title.text,
                                                              long: widget
                                                                  .site.long,
                                                              lat: widget
                                                                  .site.lat),
                                                          com.id,
                                                          userToken,
                                                          widget.id,
                                                          context);

                                                  if (msg == "Success") {
                                                    Fluttertoast.showToast(
                                                            msg: getTranslated(
                                                                context, "تم التعديل بنجاح"),
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            gravity: ToastGravity
                                                                .CENTER,
                                                            backgroundColor:
                                                                Colors.green,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: ScreenUtil()
                                                                .setSp(16,
                                                                    allowFontScalingSelf:
                                                                        true))
                                                        .then((value) => Navigator.of(context)
                                                            .pushAndRemoveUntil(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            SitesScreen()),
                                                                (Route<dynamic> route) =>
                                                                    false));

                                                    setState(() {
                                                      edit = false;
                                                    });
                                                  } else if (msg == "exists") {
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "خطأ في تعديل الموقع: اسم الموقع مضاف مسبقا"),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor: Colors.black,
                                                        fontSize: ScreenUtil()
                                                            .setSp(16,
                                                                allowFontScalingSelf:
                                                                    true));
                                                  } else if (msg == "failed") {
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "خطأ في تعديل الموقع"),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor: Colors.black,
                                                        fontSize: ScreenUtil()
                                                            .setSp(16,
                                                                allowFontScalingSelf:
                                                                    true));
                                                  } else if (msg ==
                                                      "noInternet") {
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                            context,
                                                            "خطأ في تعديل الموقع:لايوجد اتصال بالانترنت"),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        timeInSecForIosWeb: 1,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor: Colors.black,
                                                        fontSize: ScreenUtil()
                                                            .setSp(16,
                                                                allowFontScalingSelf:
                                                                    true));
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg: getTranslated(
                                                          context,
                                                          "خطأ في تعديل الموقع",
                                                        ),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor: Colors.black,
                                                        fontSize: ScreenUtil()
                                                            .setSp(16,
                                                                allowFontScalingSelf:
                                                                    true));
                                                  }
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                title: getTranslated(
                                                    context, 'حفظ التعديل'),
                                                content: getTranslated(context,
                                                    "هل تريد حفظ التعديل ؟"));
                                          },
                                        );
                                      }
                                    } else {}
                                    setState(() {
                                      edit = true;
                                    });
                                  }
                                },
                                title: (!widget.isEdit)
                                    ? getTranslated(context, "إضافة")
                                    : edit
                                        ? getTranslated(context, "حفظ")
                                        : getTranslated(context, "تعديل"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  left: 5.0.w,
                  top: 5.0.h,
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => SitesScreen()),
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
    );
  }

  Future<bool> onWillPop() {
    debugPrint("back");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SitesScreen()),
        (Route<dynamic> route) => false);
    return Future.value(false);
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
            size: ScreenUtil().setSp(25, allowFontScalingSelf: true),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
