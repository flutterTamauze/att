import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Core/constants.dart';
import '../../main.dart';

class CompanyProfileScreen extends StatefulWidget {
  @override
  _CompanyProfileScreenState createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  @override
  void initState() {
    super.initState();
    getCompanyData();
  }

  Future getComData;
  getCompanyData() async {
    final CompanyData comProvider =
        Provider.of<CompanyData>(context, listen: false);
    if (comProvider.com.companySites == 0 ||
        comProvider.com.companySites == null) {
      getComData = comProvider.getCompanyProfileApi(
          comProvider.com.id,
          Provider.of<UserData>(context, listen: false).user.userToken,
          context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Company comProvider =
        Provider.of<CompanyData>(context, listen: false).com;
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipPath(
                        clipper: MyClipper(),
                        child: Container(
                          height: (MediaQuery.of(context).size.height) / 2.75,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: MyClipper(),
                        child: Container(
                          height: (MediaQuery.of(context).size.height) / 2.8,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: Center(
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.black,
                                      radius: 60,
                                      child: Container(
                                        height: 120.h,
                                        width: 120.w,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: const Color(0xffFF7E00),
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(60.0),
                                            child: CachedNetworkImage(
                                              httpHeaders: {
                                                "Authorization": "Bearer " +
                                                    Provider.of<UserData>(
                                                            context,
                                                            listen: false)
                                                        .user
                                                        .userToken
                                              },
                                              imageUrl:
                                                  Provider.of<CompanyData>(
                                                          context,
                                                          listen: true)
                                                      .com
                                                      .logo,
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                child: const CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.white,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.orange)),
                                              ),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Provider.of<UserData>(context,
                                                          listen: true)
                                                      .changedWidget,
                                            )),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Container(
                                      height: 30.h,
                                      child: AutoSizeText(
                                        Provider.of<CompanyData>(context,
                                                listen: true)
                                            .com
                                            .nameAr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(20,
                                                allowFontScalingSelf: true),
                                            color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    child: FutureBuilder(
                        future: getComData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LoadingIndicator();
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Column(
                              children: [
                                Container(
                                  child: AboutCompanyTextField(
                                    title: comProvider.nameAr,
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil()
                                      .setSp(13, allowFontScalingSelf: true),
                                ),
                                AboutCompanyTextField(
                                  title: comProvider.nameEn,
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                AboutCompanyTextField(
                                  title: comProvider.email,
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                AboutCompanyTextField(
                                  title:
                                      " ${comProvider.companySites}  ${getTranslated(context, "الحد الاقصى للمواقع")} ",
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                AboutCompanyTextField(
                                  title:
                                      " ${comProvider.companyUsers}  ${getTranslated(context, "الحد الاقصى للمستخدمين")}",
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                              ],
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 4.0.w,
            top: 4.0.h,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  locator.locator<PermissionHan>().isEnglishLocale()
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: const Color(0xffF89A41),
                  size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutCompanyTextField extends StatelessWidget {
  const AboutCompanyTextField({Key key, this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(
          fontSize: ScreenUtil().setSp(13, allowFontScalingSelf: true)),
      enabled: false,
      textInputAction: TextInputAction.next,
      decoration: kTextFieldDecorationWhite.copyWith(
          hintText: title,
          hintStyle: const TextStyle(color: Colors.black),
          suffixIcon: const Icon(
            Icons.title,
            color: Colors.orange,
          )),
    );
  }
}
