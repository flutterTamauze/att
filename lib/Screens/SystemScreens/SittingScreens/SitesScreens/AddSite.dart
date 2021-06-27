import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/SelectOnMapScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/SitesScreen.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddSiteScreen extends StatefulWidget {
  final Site site;
  final int id;
  final isEdit;
  final hasData;

  AddSiteScreen(this.site, this.id, this.isEdit, this.hasData);

  @override
  _AddSiteScreenState createState() => _AddSiteScreenState();
}

class _AddSiteScreenState extends State<AddSiteScreen> {
  bool edit = true;

  @override
  void initState() {
    // TODO: implement initState
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
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: SmallDirectoriesHeader(
                                  Lottie.asset("resources/locaitonss.json",
                                      repeat: false),
                                  (!widget.isEdit)
                                      ? "إضافة مواقع"
                                      : "تعديل المواقع"),
                            ),
                            SizedBox(
                              height: 30.h,
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
                                      textInputAction: TextInputAction.done,
                                      textAlign: TextAlign.right,
                                      validator: (text) {
                                        if (text.length == 0) {
                                          return 'مطلوب';
                                        }
                                        return null;
                                      },
                                      controller: _title,
                                      decoration:
                                          kTextFieldDecorationWhite.copyWith(
                                              hintText: 'اسم الموقع',
                                              suffixIcon: Icon(
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
                                          textAlign: TextAlign.right,
                                          controller: _lat,
                                          decoration: kTextFieldDecorationWhite
                                              .copyWith(
                                                  hintText: 'Latitude',
                                                  suffixIcon: Icon(
                                                    Icons.location_on,
                                                    color: Colors.orange,
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
                                          textAlign: TextAlign.right,
                                          controller: _long,
                                          decoration: kTextFieldDecorationWhite
                                              .copyWith(
                                                  hintText: 'Longitude',
                                                  suffixIcon: Icon(
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
                                      Company com = Provider.of<CompanyData>(
                                              context,
                                              listen: false)
                                          .com;
                                      var userToken = Provider.of<UserData>(
                                              context,
                                              listen: false)
                                          .user
                                          .userToken;
                                      var msg = await Provider.of<SiteData>(
                                              context,
                                              listen: false)
                                          .addSite(
                                              Site(
                                                  name: _title.text,
                                                  long: widget.site.long,
                                                  lat: widget.site.lat),
                                              com.id,
                                              userToken,context);
                                      Navigator.pop(context);
                                      if (msg == "Success") {
                                        Fluttertoast.showToast(
                                            msg: "تم اضافة الموقع بنجاح",
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
                                            msg:
                                                "خطأ في اضافة الموقع: اسم الموقع مضاف مسبقا",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                      } else if (msg == "Limit Reached") {
                                        Fluttertoast.showToast(
                                            msg:
                                                "لقد وصلت الى الحد المسموح بة من المواقع",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                      } else if (msg == "failed") {
                                        Fluttertoast.showToast(
                                            msg: "خطأ في اضافة الموقع",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                      } else if (msg == "noInternet") {
                                        Fluttertoast.showToast(
                                            msg:
                                                "خطأ في اضافة الموقع:لايوجد اتصال بالانترنت",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.black,
                                            fontSize: ScreenUtil().setSp(16,
                                                allowFontScalingSelf: true));
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "خطأ في اضافة الموقع",
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
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) =>
                                              SingleChildScrollView(
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                ),
                                                height: 200.h,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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

                                                        Company com = Provider.of<
                                                                    CompanyData>(
                                                                context,
                                                                listen: false)
                                                            .com;
                                                        var userToken = Provider
                                                                .of<UserData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                            .user
                                                            .userToken;
                                                        var msg = await Provider.of<
                                                                    SiteData>(
                                                                context,
                                                                listen: false)
                                                            .editSite(
                                                                Site(
                                                                    id: widget
                                                                        .site
                                                                        .id,
                                                                    name: _title
                                                                        .text,
                                                                    long: widget
                                                                        .site
                                                                        .long,
                                                                    lat: widget
                                                                        .site
                                                                        .lat),
                                                                com.id,
                                                                userToken,
                                                                widget.id,context);

                                                        if (msg == "Success") {
                                                          Fluttertoast.showToast(
                                                                  msg:
                                                                      "تم تعديل الموقع بنجاح",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  textColor: Colors
                                                                      .white,
                                                                  fontSize: ScreenUtil()
                                                                      .setSp(16,
                                                                          allowFontScalingSelf:
                                                                              true))
                                                              .then((value) => Navigator.of(
                                                                      context)
                                                                  .pushAndRemoveUntil(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              SitesScreen()),
                                                                      (Route<dynamic> route) =>
                                                                          false));

                                                          setState(() {
                                                            edit = false;
                                                          });
                                                        } else if (msg ==
                                                            "exists") {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "خطأ في تعديل الموقع: اسم الموقع مضاف مسبقا",
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
                                                                  Colors.black,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(16,
                                                                      allowFontScalingSelf:
                                                                          true));
                                                        } else if (msg ==
                                                            "failed") {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "خطأ في تعديل الموقع",
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
                                                                  Colors.black,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(16,
                                                                      allowFontScalingSelf:
                                                                          true));
                                                        } else if (msg ==
                                                            "noInternet") {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "خطأ في تعديل الموقع:لايوجد اتصال بالانترنت",
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              timeInSecForIosWeb:
                                                                  1,
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              textColor:
                                                                  Colors.black,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(16,
                                                                      allowFontScalingSelf:
                                                                          true));
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "خطأ في تعديل الموقع",
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
                                                                  Colors.black,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(16,
                                                                      allowFontScalingSelf:
                                                                          true));
                                                        }
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
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
                                    } else {}
                                    setState(() {
                                      edit = true;
                                    });
                                  }
                                },
                                title: (!widget.isEdit)
                                    ? "إضافة"
                                    : edit
                                        ? "حفظ"
                                        : "تعديل",
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
    print("back");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SitesScreen()),
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
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: double.infinity.w,
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
                        width: 5.w,
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
                      Container(
                        height: 20,
                        child: AutoSizeText(
                          title,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.location_on,
                        size:
                            ScreenUtil().setSp(40, allowFontScalingSelf: true),
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
            size: ScreenUtil().setSp(25, allowFontScalingSelf: true),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
