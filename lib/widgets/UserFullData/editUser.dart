import 'package:flutter/material.dart';
//Update Kotlin to '1.3.50' to '1.4.21'
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/AddUserScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';

import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'
    as intlPhone;

class EditMember extends StatefulWidget {
  const EditMember(
      {Key key,
      this.member,
      this.shiftIndex,
      this.editNumber,
      this.phoneController,
      this.salaryController,
      this.titleController,
      this.id,
      this.userRole,
      this.emailController,
      this.userType,
      this.nameController,
      this.siteId})
      : super(key: key);
  final Member member;
  final int shiftIndex, id, siteId, userType;
  final intlPhone.PhoneNumber editNumber;
  final TextEditingController phoneController,
      salaryController,
      titleController,
      nameController,
      emailController;
  final String userRole;
  @override
  _EditMemberState createState() => _EditMemberState();
}

class _EditMemberState extends State<EditMember> {
  @override
  Widget build(BuildContext context) {
    return RoundedAlert(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundedLoadingIndicator();
              });

          var token =
              Provider.of<UserData>(context, listen: false).user.userToken;
          var msg = await Provider.of<MemberData>(context, listen: false)
              .editMember(
                  Member(
                      id: widget.member.id,
                      userType: widget.userType,
                      shiftId:
                          Provider.of<SiteShiftsData>(context, listen: false)
                              .dropDownShifts[widget.shiftIndex == 0
                                  ? 0
                                  : widget.shiftIndex - 1]
                              .shiftId,
                      phoneNumber: widget.editNumber.dialCode +
                          widget.phoneController.text.replaceAll(
                            new RegExp(r"\s+\b|\b\s"),
                            "",
                          ),
                      salary: double.parse(widget.salaryController.text),
                      jobTitle: widget.titleController.text,
                      email: widget.emailController.text.trim(),
                      name: widget.nameController.text),
                  widget.id,
                  token,
                  context,
                  getRoleName(widget.userRole));

          if (msg == "Success") {
            Fluttertoast.showToast(
                    msg: "???? ?????????? ???????????????? ??????????",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0)
                .then((value) {
              if (Provider.of<UserData>(context, listen: false).user.id ==
                  widget.member.id) {
                // Provider.of<UserData>(context, listen: false).siteName =
                //     Provider.of<SiteData>(context, listen: false)
                //         .sitesList[widget.siteId]
                //         .name;
              }
            }).then((value) => Navigator.of(context).push(
                      new MaterialPageRoute(
                        builder: (context) => UsersScreen(-1, false, ""),
                      ),
                    ));

            // setState(() {
            //   edit = false;
            // });
          } else if (msg == "exists") {
            Fluttertoast.showToast(
                msg: "?????? ???? ?????????? ????????????????: ?????? ???????????? ???????????? ??????????",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.black,
                fontSize: 16.0);
          } else if (msg == "not exist") {
            Fluttertoast.showToast(
                msg: "?????? ???? ?????????? ????????????????:???????????????? ?????? ??????????",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.black,
                fontSize: 16.0);
          } else if (msg == "failed") {
            Fluttertoast.showToast(
                msg: "?????? ???? ?????????? ????????????????",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.black,
                fontSize: 16.0);
          } else if (msg == "noInternet") {
            Fluttertoast.showToast(
                msg: "?????? ???? ?????????? ????????????????:???????????? ?????????? ??????????????????",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.black,
                fontSize: 16.0);
          } else {
            Fluttertoast.showToast(
                msg: "?????? ???? ?????????? ????????????????",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.black,
                fontSize: 16.0);
          }
          Navigator.pop(context);
          Navigator.pop(context);
        },
        title: '?????? ??????????????',
        content: "???? ???????? ?????? ?????????????? ??");
  }
}
