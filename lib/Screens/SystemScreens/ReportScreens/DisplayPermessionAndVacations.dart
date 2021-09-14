import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/widgets/HolidaysDisplay/total_holidays_screen.dart';
import 'package:qr_users/MLmodule/widgets/MissionsDisplay/CompanyMissionsDisplay.dart';
import 'package:qr_users/MLmodule/widgets/PermessionsDisplay/permessions_screen_display.dart';
import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);
    if (Provider.of<MemberData>(context, listen: false).membersList.isEmpty) {
      Provider.of<MemberData>(context, listen: false).getAllCompanyMember(
          -1, comProvider.com.id, userProvider.user.userToken, context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                "تقرير الأجازات و الأذونات",
              ),
              VacationCardHeader(
                header: "نوع الطلب",
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
                        });
                      },
                    ),
                    RadioButtonWidg(
                      radioVal2: radioVal2,
                      radioVal: 3,
                      title: "الأذنات",
                      onchannge: (value) {
                        setState(() {
                          radioVal2 = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              radioVal2 == 3
                  ? DisplayPermessions(_nameController)
                  : radioVal2 == 1
                      ? DisplayHolidays(_nameController)
                      : DisplayCompanyMissions(_nameController)
            ],
          )),
    );
  }
}
