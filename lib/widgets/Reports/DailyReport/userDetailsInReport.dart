import 'dart:ui' as ui;
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/UserFullData/user_data_fields.dart';
import 'package:qr_users/widgets/UserFullData/user_properties.dart';

import '../../../Core/constants.dart';

class UserDetailsInReport extends StatelessWidget {
  const UserDetailsInReport({
    Key key,
    @required this.userData,
  }) : super(key: key);

  final Member userData;

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: Container(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    Container(
                      height: 600.h,
                      child: Column(children: [
                        Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1,
                              color: Color(0xffFF7E00),
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
                                  ),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2, color: Color(0xffFF7E00))),
                          ),
                        ),
                        Text(
                          userData.name,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: ScreenUtil()
                                  .setSp(14, allowFontScalingSelf: true),
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Column(
                          children: [
                            UserDataFieldInReport(
                              icon: Icons.email,
                              text: userData.email,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: UserDataFieldInReport(
                                    icon: Icons.title,
                                    text: userData.jobTitle,
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Provider.of<UserData>(context, listen: false)
                                            .user
                                            .userType ==
                                        4
                                    ? Expanded(
                                        flex: 1,
                                        child: UserDataFieldInReport(
                                          icon: Icons.person,
                                          text: userData.normalizedName,
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: UserDataFieldInReport(
                                      icon: Icons.phone,
                                      text:
                                          plusSignPhone(userData.phoneNumber)),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: UserDataFieldInReport(
                                      icon: FontAwesomeIcons.moneyBill,
                                      text:
                                          "${userData.salary}  ${getTranslated(context, "جنية مصرى")}"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Provider.of<UserData>(context, listen: false)
                                            .user
                                            .userType !=
                                        2
                                    ? Expanded(
                                        flex: 1,
                                        child: UserDataFieldInReport(
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
                                const SizedBox(
                                  width: 3,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: UserDataFieldInReport(
                                      icon: Icons.query_builder,
                                      text: userData.shiftName),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            UserProperties(
                              user: userData,
                              siteIndex: 0,
                            )
                          ],
                        )
                      ]),
                    ),
                    Positioned(
                      top: 1,
                      left: 0,
                      child: IconButton(
                        icon: Icon(FontAwesomeIcons.times),
                        color: Colors.orange[600],
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
