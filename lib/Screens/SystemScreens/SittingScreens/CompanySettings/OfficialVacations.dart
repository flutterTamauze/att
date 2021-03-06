import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';

import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/widgets/OfficialVacations/DataTableVacationHeader.dart';

import 'package:qr_users/widgets/OfficialVacations/DataTableVacationRow.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

import 'package:qr_users/widgets/roundedAlert.dart';

import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';

import 'package:qr_users/Core/constants.dart';

import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/VacationData.dart';

import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';

import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'AddVacationScreen.dart';

class OfficialVacation extends StatefulWidget {
  @override
  _OfficialVacationState createState() => _OfficialVacationState();
}

class _OfficialVacationState extends State<OfficialVacation> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Vacation>> key = new GlobalKey();
  final SlidableController slidableController = SlidableController();
  DateTime toDate;
  DateTime fromDate;
  // bool isVacationselected = false;
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');

  String dateToString = "";
  String dateFromString = "";

  String selectedId = "";
  Site siteData;
  DateTime yesterday;

  @override
  void initState() {
    super.initState();

    var now = DateTime.now();
    Provider.of<VacationData>(context, listen: false).isLoading = false;
    toDate = DateTime(now.year, DateTime.december, 30);
    fromDate = DateTime(toDate.year, DateTime.january, 1);

    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    String fromText = " ???? ${DateFormat('yMMMd').format(fromDate).toString()}";
    String toText = " ?????? ${DateFormat('yMMMd').format(toDate).toString()}";
    print(toDate.toString());
    print(fromDate.toString());
    _dateController.text = "$fromText $toText";
  }

  @override
  Widget build(BuildContext context) {
    var vactionProv = Provider.of<VacationData>(context, listen: true);
    List<DateTime> pickedRange = [fromDate, toDate];
    return GestureDetector(
        onTap: () {
          _nameController.text == ""
              ? FocusScope.of(context).unfocus()
              : SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Scaffold(
            endDrawer: NotificationItem(),
            floatingActionButton:
                Provider.of<UserData>(context).user.userType == 4 ||
                        Provider.of<UserData>(context).user.userType == 3
                    ? MultipleFloatingButtons(
                        shiftIndex:
                            Provider.of<SiteData>(context, listen: false)
                                .currentShiftIndex,
                        comingFromShifts: false,
                        shiftName: "",
                        mainTitle: '?????????? ????????',
                        mainIconData: Icons.person_add,
                      )
                    : Container(),
            body: Container(
              child: Column(children: [
                Header(
                  nav: false,
                  goUserMenu: false,
                  goUserHomeFromMenu: false,
                ),
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallDirectoriesHeader(
                        Lottie.asset("resources/calender.json", repeat: false),
                        "?????????????? ??????????????",
                      ),
                    ],
                  ),
                ),
                Theme(
                  data: clockTheme1,
                  child: Builder(
                    builder: (context) {
                      return InkWell(
                          onTap: () async {
                            pickedRange = await DateRagePicker.showDatePicker(
                                context: context,
                                initialFirstDate: fromDate,
                                initialLastDate: toDate,
                                firstDate: new DateTime(DateTime.now().year),
                                lastDate: toDate);
                            var newString = "";
                            setState(() {
                              fromDate = pickedRange.first;
                              toDate = pickedRange.last;

                              String fromText =
                                  " ???? ${DateFormat('yMMMd').format(fromDate).toString()}";
                              String toText =
                                  " ?????? ${DateFormat('yMMMd').format(toDate).toString()}";
                              newString = "$fromText $toText";
                            });

                            if (_dateController.text != newString) {
                              _dateController.text = newString;

                              dateFromString = apiFormatter.format(fromDate);
                              dateToString = apiFormatter.format(toDate);

                              if (_nameController.text != "" ||
                                  Provider.of<UserData>(context, listen: false)
                                          .user
                                          .userType ==
                                      2) {
                                var userToken = Provider.of<UserData>(context,
                                        listen: false)
                                    .user
                                    .userToken;

                                await Provider.of<ReportsData>(context,
                                        listen: false)
                                    .getUserReportUnits(userToken, selectedId,
                                        dateFromString, dateToString, context);
                              }
                            }
                          },
                          child: Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: Container(
                              width: 330.w,
                              child: IgnorePointer(
                                child: TextFormField(
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                  textInputAction: TextInputAction.next,
                                  controller: _dateController,
                                  decoration:
                                      kTextFieldDecorationFromTO.copyWith(
                                          hintText: '?????????? ???? / ??????',
                                          prefixIcon: Icon(
                                            Icons.calendar_today_rounded,
                                            color: Colors.orange,
                                          )),
                                ),
                              ),
                            ),
                          ));
                    },
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Container(
                  width: 330.w,
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: searchTextField = AutoCompleteTextField<Vacation>(
                      key: key,
                      clearOnSubmit: false,
                      controller: _nameController,
                      suggestions: vactionProv.vactionList
                          .where((element) => isDateBetweenTheRange(
                              element, pickedRange.first, pickedRange.last))
                          .toList(),
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
                          hintText: '?????? ????????????',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.orange,
                          )),
                      itemFilter: (item, query) {
                        return item.vacationName
                            .toLowerCase()
                            .contains(query.toLowerCase());
                      },
                      itemSorter: (a, b) {
                        return a.vacationName.compareTo(b.vacationName);
                      },
                      itemSubmitted: (item) async {
                        var index = vactionProv.vactionList.indexOf(item);
                        if (_nameController.text != item.vacationName) {
                          setState(() {
                            searchTextField.textField.controller.text =
                                item.vacationName;

                            vactionProv.setCopyByIndex(index);
                            // isVacationselected = true;
                          });
                        }
                      },
                      itemBuilder: (context, item) {
                        // ui for the autocompelete row
                        return Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 10,
                              bottom: 5,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 10.w,
                                ),
                                Container(
                                  height: 20,
                                  child: AutoSizeText(
                                    item.vacationName,
                                    maxLines: 1,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(16,
                                            allowFontScalingSelf: true),
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
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
                SizedBox(
                  height: 10.h,
                ),
                Expanded(
                    child: Container(
                  color: Colors.white,
                  child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Column(
                        children: [
                          Divider(thickness: 1, color: ColorManager.primary),
                          DataTableVacationHeader(),
                          Divider(thickness: 1, color: ColorManager.primary),
                          vactionProv.isLoading
                              ? Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.orange,
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: Container(
                                  child: vactionProv.vactionList.length == 0
                                      ? Center(
                                          child: Text(
                                            "???? ???????? ?????????? ??????????",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: _nameController.text == ""
                                              ? vactionProv.vactionList.length
                                              : vactionProv
                                                  .copyVacationList.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Column(
                                              children: [
                                                Slidable(
                                                  actionExtentRatio: 0.10,
                                                  closeOnScroll: true,
                                                  controller:
                                                      slidableController,
                                                  actionPane:
                                                      SlidableDrawerActionPane(),
                                                  secondaryActions: [
                                                    ZoomIn(
                                                        child: InkWell(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(7),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.green,
                                                        ),
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 18,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AddVacationScreen(
                                                                edit: true,
                                                                vacationListID:
                                                                    index,
                                                              ),
                                                            ));
                                                      },
                                                    )),
                                                    ZoomIn(
                                                        child: InkWell(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(7),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.red,
                                                        ),
                                                        child: Icon(
                                                          Icons.delete,
                                                          size: 18,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        return showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return vactionProv
                                                                      .isLoading
                                                                  ? Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        backgroundColor:
                                                                            Colors.orange,
                                                                      ),
                                                                    )
                                                                  : RoundedAlert(
                                                                      onPressed:
                                                                          () async {
                                                                        Navigator.pop(
                                                                            context);
                                                                        String msg = await vactionProv.deleteVacationById(
                                                                            Provider.of<UserData>(context, listen: false).user.userToken,
                                                                            vactionProv.vactionList[index].vacationId,
                                                                            index);
                                                                        if (msg ==
                                                                            "Success") {
                                                                          Fluttertoast.showToast(
                                                                              msg: "???? ?????? ???????????? ??????????",
                                                                              backgroundColor: Colors.green);
                                                                        } else {
                                                                          Fluttertoast.showToast(
                                                                              msg: "?????? ???? ?????? ????????????",
                                                                              backgroundColor: Colors.red);
                                                                        }
                                                                      },
                                                                      content:
                                                                          "???? ???????? ?????? : ${vactionProv.vactionList[index].vacationName}??",
                                                                      onCancel:
                                                                          () {},
                                                                      title:
                                                                          "?????? ????????????",
                                                                    );
                                                            });
                                                      },
                                                    )),
                                                  ],
                                                  child: DataTableVacationRow(
                                                    vacation: _nameController
                                                                .text ==
                                                            ""
                                                        ? vactionProv
                                                            .vactionList[index]
                                                        : vactionProv
                                                            .copyVacationList
                                                            .first,
                                                    filterFromDate:
                                                        pickedRange.first,
                                                    filterToDate:
                                                        pickedRange.last,
                                                  ),
                                                ),
                                                isDateBetweenTheRange(
                                                        vactionProv
                                                            .vactionList[index],
                                                        pickedRange.first,
                                                        pickedRange.last)
                                                    ? Divider(
                                                        thickness: 1,
                                                      )
                                                    : Container()
                                              ],
                                            );
                                          }),
                                )),
                        ],
                      )),
                ))
              ]),
            )));
  }
}

// class VacationTableEnd extends StatelessWidget {
//   final List<DateTime> range;
//   VacationTableEnd(this.range);
//   @override
//   Widget build(BuildContext context) {
//     calculateTotalVacation() {
//       int sum = 0;
//       List<Vacation> vactionProv = listAfterFilter(
//           Provider.of<VacationData>(context, listen: true).vactionList,
//           range.first,
//           range.last);

//       for (int i = 0; i < vactionProv.length; i++) {
//         sum +=
//             vactionProv[i].toDate.difference(vactionProv[i].fromDate).inDays +
//                 1;
//       }
//       return sum;
//     }

//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.orange,
//           borderRadius: BorderRadius.only(
//             bottomRight: Radius.circular(15),
//             bottomLeft: Radius.circular(15),
//           )),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 10),
//         child: Container(
//           height: 50.h,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     height: 20,
//                     child: AutoSizeText(
//                       '?????????? ???????? ?????????????? ??????????????  :',
//                       maxLines: 1,
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: ScreenUtil()
//                               .setSp(16, allowFontScalingSelf: true),
//                           color: Colors.black),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 4.w,
//                   ),
//                   Text(
//                     calculateTotalVacation().toString() + " ?????? ",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize:
//                             ScreenUtil().setSp(16, allowFontScalingSelf: true),
//                         color: Colors.black),
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
