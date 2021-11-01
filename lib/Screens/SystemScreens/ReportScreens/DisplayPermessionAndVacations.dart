import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/widgets/HolidaysDisplay/total_holidays_screen.dart';
import 'package:qr_users/MLmodule/widgets/MissionsDisplay/CompanyMissionsDisplay.dart';
import 'package:qr_users/MLmodule/widgets/PermessionsDisplay/permessions_screen_display.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants.dart';
import 'RadioButtonWidget.dart';

class VacationAndPermessionsReport extends StatefulWidget {
  @override
  _VacationAndPermessionsReportState createState() =>
      _VacationAndPermessionsReportState();
}

TextEditingController _nameController = TextEditingController();
var radioVal2 = 1;

class _VacationAndPermessionsReportState
    extends State<VacationAndPermessionsReport> {
  @override
  void initState() {
    super.initState();
  }

  searchInList(String value, int siteId, int companyId) async {
    if (value.isNotEmpty) {
      print(companyId);
      await Provider.of<MemberData>(context, listen: false).searchUsersList(
          value,
          Provider.of<UserData>(context, listen: false).user.userToken,
          siteId,
          companyId,
          context);
      focusNode.requestFocus();
    } else {
      Provider.of<MemberData>(context, listen: false).resetUsers();
    }
  }

  final focusNode = FocusNode();
  Future getPerm;
  Future getMission;
  Future getHoliday;
  var userId;
  GlobalKey<AutoCompleteTextFieldState<SearchMember>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;
  @override
  Widget build(BuildContext context) {
    var comMissionProv = Provider.of<MissionsData>(context, listen: false);

    return GestureDetector(
      onTap: () {
        print(_nameController.text);
        _nameController.text == ""
            ? FocusScope.of(context).unfocus()
            : SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Scaffold(
          endDrawer: NotificationItem(),
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Header(
                goUserHomeFromMenu: false,
                nav: false,
                goUserMenu: false,
              ),
              SmallDirectoriesHeader(
                Lottie.asset("resources/report.json", repeat: false),
                "تقرير الأجازات و المأموريات",
              ),
              SizedBox(
                height: 20.h,
              ),
              Container(
                width: 330.w,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Provider.of<MemberData>(context).loadingSearch
                      ? Center(
                          child: CircularProgressIndicator(
                          color: Colors.orange,
                        ))
                      : searchTextField = AutoCompleteTextField<SearchMember>(
                          key: key,
                          clearOnSubmit: false,
                          focusNode: focusNode,
                          controller: _nameController,
                          suggestions:
                              Provider.of<MemberData>(context).userSearchMember,
                          style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                          decoration: kTextFieldDecorationFromTO.copyWith(
                              hintStyle: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(16, allowFontScalingSelf: true),
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500),
                              hintText: 'الأسم',
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    searchInList(
                                        _nameController.text,
                                        -1,
                                        Provider.of<CompanyData>(context,
                                                listen: false)
                                            .com
                                            .id);
                                  });
                                },
                                child: Icon(
                                  Icons.search,
                                  color: Colors.orange,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.orange,
                              )),
                          itemFilter: (item, query) {
                            return item.username
                                .toLowerCase()
                                .contains(query.toLowerCase());
                          },
                          itemSorter: (a, b) {
                            return a.username.compareTo(b.username);
                          },
                          itemSubmitted: (item) async {
                            if (_nameController.text != item.username) {
                              setState(() {
                                searchTextField.textField.controller.text =
                                    item.username;
                              });
                              print("user id");
                              print(item.id);
                              userId = item.id;
                              var userProvider =
                                  Provider.of<UserData>(context, listen: false);
                              getPerm = Provider.of<UserPermessionsData>(
                                      context,
                                      listen: false)
                                  .getSingleUserPermession(
                                      item.id,
                                      Provider.of<UserData>(context,
                                              listen: false)
                                          .user
                                          .userToken);
                              getMission = Provider.of<MissionsData>(context,
                                      listen: false)
                                  .getSingleUserMissions(
                                      item.id, userProvider.user.userToken);
                              getHoliday = Provider.of<UserHolidaysData>(
                                      context,
                                      listen: false)
                                  .getSingleUserHoliday(
                                      item.id, userProvider.user.userToken);

                              List<int> indexes = [];

                              print(comMissionProv.userNames.length);
                              for (int i = 0;
                                  i < comMissionProv.userNames.length;
                                  i++) {
                                if (comMissionProv.userNames[i] ==
                                    item.username) {
                                  indexes.add(i);
                                }
                              }
                              if (_nameController.text != item.username) {
                                setState(() {
                                  print(item.username);
                                  searchTextField.textField.controller.text =
                                      item.username;

                                  Provider.of<MissionsData>(context,
                                          listen: false)
                                      .setCopyByIndex(indexes);
                                  // isVacationselected = true;
                                });
                              }
                              // selectedId = item.id;

                              // await Provider.of<ReportsData>(context,
                              //         listen: false)
                              //     .getUserReportUnits(
                              //         Provider.of<UserData>(context,
                              //                 listen: false)
                              //             .user
                              //             .userToken,
                              //         item.id,
                              //         dateFromString,
                              //         dateToString,
                              //         context);
                            }
                          },
                          itemBuilder: (context, item) {
                            // ui for the autocompelete row
                            return Directionality(
                              textDirection: TextDirection.rtl,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                  bottom: 5,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Container(
                                          height: 20,
                                          child: AutoSizeText(
                                            item.username,
                                            maxLines: 1,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: ScreenUtil().setSp(16,
                                                    allowFontScalingSelf: true),
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RadioButtonWidg(
                      radioVal2: radioVal2,
                      radioVal: 2,
                      title: "المأموريات",
                      onchannge: (value) {
                        setState(() {
                          radioVal2 = value;
                          getMission = Provider.of<MissionsData>(context,
                                  listen: false)
                              .getSingleUserMissions(
                                  userId,
                                  Provider.of<UserData>(context, listen: false)
                                      .user
                                      .userToken);
                        });
                      },
                    ),
                    RadioButtonWidg(
                      radioVal2: radioVal2,
                      radioVal: 1,
                      title: "الأجازات",
                      onchannge: (value) {
                        setState(() {
                          radioVal2 = value;
                          getHoliday = Provider.of<UserHolidaysData>(context,
                                  listen: false)
                              .getSingleUserHoliday(
                                  userId,
                                  Provider.of<UserData>(context, listen: false)
                                      .user
                                      .userToken);
                        });
                      },
                    ),
                    RadioButtonWidg(
                      radioVal2: radioVal2,
                      radioVal: 3,
                      title: "الأذونات",
                      onchannge: (value) {
                        setState(() {
                          radioVal2 = value;
                          getPerm = Provider.of<UserPermessionsData>(context,
                                  listen: false)
                              .getSingleUserPermession(
                                  userId,
                                  Provider.of<UserData>(context, listen: false)
                                      .user
                                      .userToken);
                        });
                      },
                    ),
                  ],
                ),
              ),
              radioVal2 == 3
                  ? DisplayPermessions(_nameController, getPerm)
                  : radioVal2 == 1
                      ? DisplayHolidays(_nameController, getHoliday)
                      : DisplayCompanyMissions(_nameController, getMission)
            ],
          )),
    );
  }
}
