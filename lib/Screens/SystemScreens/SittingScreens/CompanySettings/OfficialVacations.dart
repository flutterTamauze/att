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

import 'package:qr_users/Screens/Notifications/Notifications.dart';
import 'package:qr_users/services/company.dart';

import 'package:qr_users/widgets/roundedAlert.dart';

import 'package:qr_users/Screens/SystemScreens/ReportScreens/DailyReportScreen.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';

import 'package:qr_users/constants.dart';

import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/VacationData.dart';

import 'package:qr_users/services/report_data.dart';
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
  // calculateTotalVacation() {
  //   int sum = 0;
  //   var vactionProv = Provider.of<VacationData>(context, listen: true);
  //   for (int i = 0; i < vactionProv.vactionList.length; i++) {
  //     sum += vactionProv.vactionList[i].toDate
  //             .difference(vactionProv.vactionList[i].fromDate)
  //             .inDays +
  //         1;
  //   }
  //   return sum;
  // }

  @override
  void initState() {
    super.initState();

    var now = DateTime.now();

    toDate = DateTime(now.year, DateTime.december, 30);
    fromDate = DateTime(toDate.year, DateTime.january, 1);

    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    String fromText = " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    String toText = " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
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
          // vacation.fromDate.isAfter(filterFromDate) &&
          //     vacation.toDate.isBefore(filterToDate)
        },
        child: Scaffold(
            endDrawer: NotificationItem(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton:
                Provider.of<UserData>(context).user.userType == 4
                    ? Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 4,
                              color: Colors.white,
                            ),
                            shape: BoxShape.circle),
                        child: FloatingActionButton(
                          elevation: 3,
                          tooltip: "اضافة عطلة",
                          backgroundColor: Colors.orange[600],
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddVacationScreen(
                                    edit: false,
                                  ),
                                )).then((value) => setState(() {}));
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: ScreenUtil()
                                .setSp(30, allowFontScalingSelf: true),
                          ),
                        ),
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
                        "العطلات الرسمية",
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
                                  " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                              String toText =
                                  " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
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
                                          hintText: 'المدة من / إلى',
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
                      textSubmitted: (data) => print(data),
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
                          hintText: 'اسم العطلة',
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
                          DataTableVacationHeader(),
                          Expanded(
                              child: Container(
                            child: ListView.builder(
                                itemCount: _nameController.text == ""
                                    ? vactionProv.vactionList.length
                                    : vactionProv.copyVacationList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      Slidable(
                                        actionExtentRatio: 0.10,
                                        closeOnScroll: true,
                                        controller: slidableController,
                                        actionPane: SlidableDrawerActionPane(),
                                        secondaryActions: [
                                          ZoomIn(
                                              child: InkWell(
                                            child: Container(
                                              padding: EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
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
                                                      vacationListID: index,
                                                    ),
                                                  ));
                                            },
                                          )),
                                          ZoomIn(
                                              child: InkWell(
                                            child: Container(
                                              padding: EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
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
                                                      (BuildContext context) {
                                                    return vactionProv.isLoading
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
                                                              String msg = await vactionProv.deleteVacationById(
                                                                  Provider.of<UserData>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .user
                                                                      .userToken,
                                                                  vactionProv
                                                                      .vactionList[
                                                                          index]
                                                                      .vacationId,
                                                                  index);
                                                              if (msg ==
                                                                  "Success") {
                                                                Fluttertoast.showToast(
                                                                        msg:
                                                                            "تم حذف العطلة بنجاح",
                                                                        backgroundColor:
                                                                            Colors
                                                                                .green)
                                                                    .then((value) =>
                                                                        Navigator.pop(
                                                                            context));
                                                              } else {
                                                                Fluttertoast.showToast(
                                                                        msg:
                                                                            "خطأ في حذف العطلة",
                                                                        backgroundColor:
                                                                            Colors
                                                                                .red)
                                                                    .then((value) =>
                                                                        Navigator.pop(
                                                                            context));
                                                              }
                                                            },
                                                            content:
                                                                "هل تريد مسح : ${vactionProv.vactionList[index].vacationName}؟",
                                                            onCancel: () {},
                                                            title: "حذف العطلة",
                                                          );
                                                  });
                                            },
                                          )),
                                        ],
                                        child: DataTableVacationRow(
                                          vacation: _nameController.text == ""
                                              ? vactionProv.vactionList[index]
                                              : vactionProv
                                                  .copyVacationList.first,
                                          filterFromDate: pickedRange.first,
                                          filterToDate: pickedRange.last,
                                        ),
                                      ),
                                      isDateBetweenTheRange(
                                              vactionProv.vactionList[index],
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
//                       'مجموع ايام العطلات الرسمية  :',
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
//                     calculateTotalVacation().toString() + " يوم ",
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
