import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/report_data.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class XlsxExportButton extends StatefulWidget {
  final int reportType;
  final String title;
  final String site;
  final String userName;
  final String day;

  XlsxExportButton(
      {this.reportType, this.title, this.day, this.site, this.userName});

  @override
  _XlsxExportButtonState createState() => _XlsxExportButtonState();
}

var path;

void _getDownloadStorage() async {
  if (Platform.isIOS) {
    Directory directory = await getApplicationDocumentsDirectory();
    path = directory.path;
    print("path is : $path");
  } else if (Platform.isAndroid) {
    path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
  }

  print(path); // /storage/emulated/0/Pictures
}

class _XlsxExportButtonState extends State<XlsxExportButton> {
  @override
  void initState() {
    _getDownloadStorage();
    super.initState();
  }

  String dateTime;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return FlatButton(
      child: Icon(
        FontAwesomeIcons.fileCsv,
        size: 25,
        color: Colors.orange,
      ),
      onPressed: () async {
        if (await Permission.storage.isGranted) {
          generateReport();
        } else {
          await Permission.storage.request();
          if (await Permission.storage.isGranted) {
            generateReport();
          } else {
            Fluttertoast.showToast(
                msg: "برجاء تفعيل تصريح التخزين لاستخراج ملفات التقارير",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        }
      },
    );
  }

  generateReport() async {
    try {
      switch (widget.reportType) {
        case 0:
          String freePath = await getUniqueFileName("DailyReport");
          await generateDailyReportExcel(freePath);
          await open_file.OpenFile.open("$path/$freePath");
          break;
        case 1:
          String freePath = await getUniqueFileName("Late-AbsenceReport");
          await generateAbsenceReportExcel(freePath);
          await open_file.OpenFile.open("$path/$freePath");
          break;
        case 2:
          String freePath = await getUniqueFileName("UserReport");
          await generateUserReportExcel(freePath);
          await open_file.OpenFile.open("$path/$freePath");
          break;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> getUniqueFileName(String searchedFilename) async {
    var finalPath;

    int num = 1;

    finalPath = "$searchedFilename.xlsx";

    File file = new File("$path/$finalPath");

    while (await file.exists()) {
      finalPath = "$searchedFilename$num.xlsx";
      file = new File("$path/$finalPath");
      num++;
    }
    print(num);

    return finalPath;
  }

  Future<void> generateDailyReportExcel(String freePath) async {
    dateTime = DateTime.now().microsecond.toString();
    //Create a Excel document.

    print(freePath);
    //Creating a workbook.
    final Workbook workbook = Workbook();
    //Accessing via index
    final Worksheet sheet = workbook.worksheets[0];
    sheet.showGridlines = false;

    // Enable calculation for worksheet.
    sheet.enableSheetCalculations();

    //Set data in the worksheet.
    sheet.getRangeByName('A1').columnWidth = 4.82;
    sheet.getRangeByName('B1').columnWidth = 7.50;
    sheet.getRangeByName('C1').columnWidth = 7.50;
    sheet.getRangeByName('D1').columnWidth = 7.50;

    sheet.getRangeByName('E1:G1').columnWidth = 7.50;
    sheet.getRangeByName('H1').columnWidth = 4.46;

    sheet.getRangeByName('A1:H1').cellStyle.backColor = '#000000';
    sheet.getRangeByName('A2:H2').cellStyle.backColor = '#000000';
    sheet.getRangeByName('A3:H3').cellStyle.backColor = '#000000';

    sheet.getRangeByName('B1:H3').merge();

    sheet.getRangeByName('B1').setText('Chilango');
    sheet.getRangeByName('B1').cellStyle.fontSize = 24;
    sheet.getRangeByName('B1').cellStyle.fontColor = '#FF9800';

    final Range range0 = sheet.getRangeByName('D4:G6');
    range0.merge();
    range0.cellStyle.hAlign = HAlignType.right;

    sheet.getRangeByName('D4').setText(widget.title);
    sheet.getRangeByName('D4').cellStyle.fontSize = 20;

    final Range range1 = sheet.getRangeByName('E8:G8');
    final Range range2 = sheet.getRangeByName('E9:G9');

    final Range range3 = sheet.getRangeByName('F10:G10');
    final Range range4 = sheet.getRangeByName('F11:G11');

    range1.merge();
    range2.merge();
    range3.merge();
    range4.merge();

    range1.cellStyle.hAlign = HAlignType.right;
    range2.cellStyle.hAlign = HAlignType.right;
    range3.cellStyle.hAlign = HAlignType.right;
    range4.cellStyle.hAlign = HAlignType.right;

    sheet.getRangeByName('E8').setText('عن موقع');
    sheet.getRangeByName('E8').cellStyle.fontSize = 12;
    sheet.getRangeByName('E8').cellStyle.bold = true;

    sheet.getRangeByName('E9').setText('${widget.site}');
    sheet.getRangeByName('E9').cellStyle.fontSize = 9;

    sheet.getRangeByName('F10').setText('عن يوم');
    range3.cellStyle.fontSize = 12;
    sheet.getRangeByName('F10').cellStyle.bold = true;

    sheet.getRangeByName('F11').setText(widget.day);
    sheet.getRangeByName('F11').numberFormat =
        '[\$-x-sysdate]dddd, mmmm dd, yyyy';
    range4.cellStyle.fontSize = 9;

    sheet.getRangeByIndex(13, 5, 13, 7).merge();

    sheet.getRangeByIndex(13, 5).setText('الاســم');

    sheet.getRangeByName('D13').setText('التأخير');

    sheet.getRangeByName('C13').setText('الحضور');

    sheet.getRangeByName('B13').setText('الانصراف');

    sheet.getRangeByName('B13:G13').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('B13:G13').cellStyle.fontSize = 10;
    sheet.getRangeByName('B13:G13').cellStyle.bold = true;

    var reportProvider =
        Provider.of<ReportsData>(context, listen: false).dailyReport;

    var length = reportProvider.attendListUnits.length;
    var lastIndex = 14;

    for (int i = lastIndex; i < (lastIndex + length); i++) {
      sheet.getRangeByIndex(i, 5, i, 7).merge();

      sheet
          .getRangeByIndex(i, 5)
          .setText(reportProvider.attendListUnits[i - lastIndex].userName);

      sheet
          .getRangeByName('D$i')
          .setText(reportProvider.attendListUnits[i - lastIndex].lateTime);

      sheet.getRangeByName('C$i').setText(
          reportProvider.attendListUnits[i - lastIndex].timeIn == "-"
              ? "غياب"
              : reportProvider.attendListUnits[i - lastIndex].timeIn);

      sheet.getRangeByName('B$i').setText(
          reportProvider.attendListUnits[i - lastIndex].timeOut == "-"
              ? ""
              : reportProvider.attendListUnits[i - lastIndex].timeOut);

      sheet.getRangeByName('B$i:D$i').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('E$i').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B$i:G$i').cellStyle.fontSize = 10;
    }

    lastIndex = lastIndex + length;
    final Range range6 =
        sheet.getRangeByName('F${lastIndex + 1}:G${lastIndex + 1}');

    range6.merge();
    range6.cellStyle.hAlign = HAlignType.right;

    sheet.getRangeByName('F${lastIndex + 1}').setText('مجموع الحضور');
    sheet.getRangeByName('F${lastIndex + 1}').cellStyle.fontSize = 12;
    sheet.getRangeByName('F${lastIndex + 1}').cellStyle.bold = true;

    final Range range8 =
        sheet.getRangeByName('F${lastIndex + 2}:G${lastIndex + 2}');

    range8.merge();
    range8.cellStyle.hAlign = HAlignType.right;

    sheet
        .getRangeByName('F${lastIndex + 2}')
        .setText(reportProvider.totalAttend.toString());
    sheet.getRangeByName('F${lastIndex + 2}').cellStyle.fontSize = 12;
    sheet.getRangeByName('F${lastIndex + 2}').cellStyle.bold = true;

    final Range range7 =
        sheet.getRangeByName('C${lastIndex + 1}:D${lastIndex + 1}');

    range7.merge();
    range7.cellStyle.hAlign = HAlignType.right;

    sheet.getRangeByName('C${lastIndex + 1}').setText('مجموع الغياب');
    sheet.getRangeByName('C${lastIndex + 1}').cellStyle.fontSize = 12;
    sheet.getRangeByName('C${lastIndex + 1}').cellStyle.bold = true;

    final Range range9 =
        sheet.getRangeByName('C${lastIndex + 2}:D${lastIndex + 2}');

    range9.merge();
    range9.cellStyle.hAlign = HAlignType.right;

    sheet
        .getRangeByName('C${lastIndex + 2}')
        .setText(reportProvider.totalAbsent.toString());
    sheet.getRangeByName('C${lastIndex + 2}').cellStyle.fontSize = 12;
    sheet.getRangeByName('C${lastIndex + 2}').cellStyle.bold = true;

    sheet.getRangeByIndex((lastIndex + 4), 1).text =
        'Copyright 2020 - 2025 Tamauze Digital Solutions . All rights reserved';

    sheet.getRangeByIndex(lastIndex + 4, 1).cellStyle.fontSize = 8;
    sheet.getRangeByIndex(lastIndex + 4, 1).cellStyle.fontColor = "#ffffff";

    final Range range10 =
        sheet.getRangeByName('A${lastIndex + 4}:H${lastIndex + 6}');
    range10.cellStyle.backColor = '#000000';
    range10.merge();
    range10.cellStyle.hAlign = HAlignType.center;
    range10.cellStyle.vAlign = VAlignType.center;

    //Save and launch the excel.
    print("saving the excel");
    final List<int> bytes = workbook.saveAsStream();
    //Dispose the document.
    workbook.dispose();

    //Get the storage folder location using path_provider package.

    print(" ppppath :$path");
    // final String path = directory.path;
    final File file = File("$path/$freePath");
    print("$path / $freePath");
    await file.writeAsBytes(bytes);

    Fluttertoast.showToast(
        gravity: ToastGravity.CENTER,
        msg: "Download/$freePath",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> generateAbsenceReportExcel(String freePath) async {
    try {
      //Create a Excel document.
      print("free path is : $freePath");
      //Creating a workbook.
      final Workbook workbook = Workbook();
      //Accessing via index
      final Worksheet sheet = workbook.worksheets[0];
      sheet.showGridlines = false;

      // Enable calculation for worksheet.
      sheet.enableSheetCalculations();

      //Set data in the worksheet.
      sheet.getRangeByName('A1').columnWidth = 4.82;
      sheet.getRangeByName('B1').columnWidth = 8;
      sheet.getRangeByName('C1').columnWidth = 8;
      sheet.getRangeByName('D1').columnWidth = 7.50;

      sheet.getRangeByName('E1:G1').columnWidth = 7.50;
      sheet.getRangeByName('H1').columnWidth = 4.46;

      sheet.getRangeByName('A1:H1').cellStyle.backColor = '#000000';
      sheet.getRangeByName('A2:H2').cellStyle.backColor = '#000000';
      sheet.getRangeByName('A3:H3').cellStyle.backColor = '#000000';

      sheet.getRangeByName('B1:H3').merge();

      sheet.getRangeByName('B1').setText('Chilango');
      sheet.getRangeByName('B1').cellStyle.fontSize = 24;
      sheet.getRangeByName('B1').cellStyle.fontColor = '#FF9800';

      final Range range0 = sheet.getRangeByName('D4:G6');
      range0.merge();
      range0.cellStyle.hAlign = HAlignType.right;

      sheet.getRangeByName('D4').setText(widget.title);
      sheet.getRangeByName('D4').cellStyle.fontSize = 20;

      final Range range1 = sheet.getRangeByName('E8:G8');
      final Range range2 = sheet.getRangeByName('E9:G9');

      final Range range3 = sheet.getRangeByName('D10:G10');
      final Range range4 = sheet.getRangeByName('D11:G11');

      range1.merge();
      range2.merge();
      range3.merge();
      range4.merge();

      range1.cellStyle.hAlign = HAlignType.right;
      range2.cellStyle.hAlign = HAlignType.right;
      range3.cellStyle.hAlign = HAlignType.right;
      range4.cellStyle.hAlign = HAlignType.right;

      sheet.getRangeByName('E8').setText('عن موقع');
      sheet.getRangeByName('E8').cellStyle.fontSize = 12;
      sheet.getRangeByName('E8').cellStyle.bold = true;

      sheet.getRangeByName('E9').setText('${widget.site}');
      sheet.getRangeByName('E9').cellStyle.fontSize = 9;

      sheet.getRangeByName('D10').setText('عن فترة');
      range3.cellStyle.fontSize = 12;
      sheet.getRangeByName('D10').cellStyle.bold = true;

      sheet.getRangeByName('D11').setText(widget.day);

      range4.cellStyle.fontSize = 9;

      sheet.getRangeByIndex(13, 5, 13, 7).merge();

      sheet.getRangeByIndex(13, 5).setText('الاســم');

      sheet.getRangeByName('D13').setText('التأخير');

      sheet.getRangeByName('C13').setText('ايام التأخير');

      sheet.getRangeByName('B13').setText('ايام الغياب');

      sheet.getRangeByName('B13:G13').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('B13:G13').cellStyle.fontSize = 10;
      sheet.getRangeByName('B13:G13').cellStyle.bold = true;

      var reportProvider =
          Provider.of<ReportsData>(context, listen: false).lateAbsenceReport;

      var length = reportProvider.lateAbsenceReportUnitList.length;
      var lastIndex = 14;

      for (int i = lastIndex; i < (lastIndex + length); i++) {
        sheet.getRangeByIndex(i, 5, i, 7).merge();

        sheet.getRangeByIndex(i, 5).setText(
            reportProvider.lateAbsenceReportUnitList[i - lastIndex].userName);

        sheet.getRangeByName('D$i').setText(
            reportProvider.lateAbsenceReportUnitList[i - lastIndex].totalLate);

        sheet.getRangeByName('C$i').setText(reportProvider
            .lateAbsenceReportUnitList[i - lastIndex].totalLateDays);

        sheet.getRangeByName('B$i').setText(reportProvider
            .lateAbsenceReportUnitList[i - lastIndex].totalAbsence);

        sheet.getRangeByName('B$i:D$i').cellStyle.hAlign = HAlignType.center;
        sheet.getRangeByName('E$i').cellStyle.hAlign = HAlignType.right;
        sheet.getRangeByName('B$i:G$i').cellStyle.fontSize = 10;
      }

      lastIndex = lastIndex + length;
      final Range range6 =
          sheet.getRangeByName('F${lastIndex + 1}:G${lastIndex + 1}');

      range6.merge();
      range6.cellStyle.hAlign = HAlignType.right;

      sheet.getRangeByName('F${lastIndex + 1}').setText('نسبة التأخير');
      sheet.getRangeByName('F${lastIndex + 1}').cellStyle.fontSize = 12;
      sheet.getRangeByName('F${lastIndex + 1}').cellStyle.bold = true;

      final Range range8 =
          sheet.getRangeByName('F${lastIndex + 2}:G${lastIndex + 2}');

      range8.merge();
      range8.cellStyle.hAlign = HAlignType.right;

      sheet
          .getRangeByName('F${lastIndex + 2}')
          .setText(reportProvider.lateRatio);
      sheet.getRangeByName('F${lastIndex + 2}').cellStyle.fontSize = 12;
      sheet.getRangeByName('F${lastIndex + 2}').cellStyle.bold = true;

      final Range range7 =
          sheet.getRangeByName('C${lastIndex + 1}:D${lastIndex + 1}');

      range7.merge();
      range7.cellStyle.hAlign = HAlignType.right;

      sheet.getRangeByName('C${lastIndex + 1}').setText('نسبة الغياب');
      sheet.getRangeByName('C${lastIndex + 1}').cellStyle.fontSize = 12;
      sheet.getRangeByName('C${lastIndex + 1}').cellStyle.bold = true;

      final Range range9 =
          sheet.getRangeByName('C${lastIndex + 2}:D${lastIndex + 2}');

      range9.merge();
      range9.cellStyle.hAlign = HAlignType.right;

      sheet
          .getRangeByName('C${lastIndex + 2}')
          .setText(reportProvider.absentRatio);
      sheet.getRangeByName('C${lastIndex + 2}').cellStyle.fontSize = 12;
      sheet.getRangeByName('C${lastIndex + 2}').cellStyle.bold = true;

      sheet.getRangeByIndex((lastIndex + 4), 1).text =
          'Copyright 2020 - 2025 Tamauze Digital Solutions . All rights reserved';

      sheet.getRangeByIndex(lastIndex + 4, 1).cellStyle.fontSize = 8;
      sheet.getRangeByIndex(lastIndex + 4, 1).cellStyle.fontColor = "#ffffff";

      final Range range10 =
          sheet.getRangeByName('A${lastIndex + 4}:H${lastIndex + 6}');
      range10.cellStyle.backColor = '#000000';
      range10.merge();
      range10.cellStyle.hAlign = HAlignType.center;
      range10.cellStyle.vAlign = VAlignType.center;
      print("saving the excel");
      //Save and launch the excel.
      final List<int> bytes = workbook.saveAsStream();
      //Dispose the document.
      workbook.dispose();

      //Get the storage folder location using path_provider package.

      print("path after save $path");

      // final String path = directory.path;
      final File file = File("$path/$freePath");
      print(path);

      print("$path/$freePath");
      print(await file.exists());
      print("writing to it ");
      await file.writeAsBytes(bytes).catchError(((e) {
        print(e);
      }));
      print(await file.exists());
      Fluttertoast.showToast(
          msg: "Download/$freePath",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      print(e);
    }
  }

  Future<void> generateUserReportExcel(String freePath) async {
    try {
      var reportProvider =
          Provider.of<ReportsData>(context, listen: false).userAttendanceReport;

      //Create a Excel document.
      print(freePath);
      //Creating a workbook.
      final Workbook workbook = Workbook();
      //Accessing via index
      final Worksheet sheet = workbook.worksheets[0];
      sheet.showGridlines = false;

      // Enable calculation for worksheet.
      sheet.enableSheetCalculations();

      //Set data in the worksheet.
      sheet.getRangeByName('A1').columnWidth = 4.82;
      sheet.getRangeByName('B1').columnWidth = 7.5;
      sheet.getRangeByName('C1').columnWidth = 7.5;
      sheet.getRangeByName('D1').columnWidth = 7.50;

      sheet.getRangeByName('E1:G1').columnWidth = 7.50;
      sheet.getRangeByName('H1').columnWidth = 4.46;

      sheet.getRangeByName('A1:H1').cellStyle.backColor = '#000000';
      sheet.getRangeByName('A2:H2').cellStyle.backColor = '#000000';
      sheet.getRangeByName('A3:H3').cellStyle.backColor = '#000000';

      sheet.getRangeByName('B1:H3').merge();

      sheet.getRangeByName('B1').setText('Chilango');
      sheet.getRangeByName('B1').cellStyle.fontSize = 24;
      sheet.getRangeByName('B1').cellStyle.fontColor = '#FF9800';

      final Range range0 = sheet.getRangeByName('D4:G6');
      range0.merge();
      range0.cellStyle.hAlign = HAlignType.right;

      sheet.getRangeByName('D4').setText(widget.title);
      sheet.getRangeByName('D4').cellStyle.fontSize = 20;

      final Range range1 = sheet.getRangeByName('E8:G8');
      final Range range2 = sheet.getRangeByName('E9:G9');

      final Range range11 = sheet.getRangeByName('B8:D8');
      final Range range12 = sheet.getRangeByName('B9:D9');

      final Range range3 = sheet.getRangeByName('D10:G10');
      final Range range4 = sheet.getRangeByName('D11:G11');

      range1.merge();
      range2.merge();
      range3.merge();
      range4.merge();
      range11.merge();
      range12.merge();

      range1.cellStyle.hAlign = HAlignType.right;
      range2.cellStyle.hAlign = HAlignType.right;
      range3.cellStyle.hAlign = HAlignType.right;
      range4.cellStyle.hAlign = HAlignType.right;
      range11.cellStyle.hAlign = HAlignType.right;
      range12.cellStyle.hAlign = HAlignType.right;

      sheet.getRangeByName('E8').setText('عن مستخدم');
      sheet.getRangeByName('E8').cellStyle.fontSize = 12;
      sheet.getRangeByName('E8').cellStyle.bold = true;

      sheet.getRangeByName('E9').setText('${widget.userName}');
      sheet.getRangeByName('E9').cellStyle.fontSize = 9;

      sheet.getRangeByName('B8').setText('موقع');
      sheet.getRangeByName('B8').cellStyle.fontSize = 12;
      sheet.getRangeByName('B8').cellStyle.bold = true;

      sheet.getRangeByName('B9').setText('${widget.site}');
      sheet.getRangeByName('B9').cellStyle.fontSize = 9;

      sheet.getRangeByName('D10').setText('عن فترة');
      range3.cellStyle.fontSize = 12;
      sheet.getRangeByName('D10').cellStyle.bold = true;

      sheet.getRangeByName('D11').setText(widget.day);

      range4.cellStyle.fontSize = 9;

      sheet.getRangeByIndex(13, 5, 13, 7).merge();

      sheet.getRangeByIndex(13, 5).setText('التاريخ');

      sheet.getRangeByName('D13').setText('التأخير');

      sheet.getRangeByName('C13').setText('حضور');

      sheet.getRangeByName('B13').setText('انصراف');

      sheet.getRangeByName('B13:G13').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('B13:G13').cellStyle.fontSize = 10;
      sheet.getRangeByName('B13:G13').cellStyle.bold = true;

      var length = reportProvider.userAttendListUnits.length;
      var lastIndex = 14;

      for (int i = lastIndex; i < (lastIndex + length); i++) {
        sheet.getRangeByIndex(i, 5, i, 7).merge();

        sheet
            .getRangeByIndex(i, 5)
            .setText(reportProvider.userAttendListUnits[i - lastIndex].date);

        sheet
            .getRangeByName('D$i')
            .setText(reportProvider.userAttendListUnits[i - lastIndex].late);

        sheet.getRangeByName('C$i').setText(
            reportProvider.userAttendListUnits[i - lastIndex].timeIn == "-"
                ? "غياب"
                : reportProvider.userAttendListUnits[i - lastIndex].timeIn);

        sheet.getRangeByName('B$i').setText(
            reportProvider.userAttendListUnits[i - lastIndex].timeOut == "-"
                ? ""
                : reportProvider.userAttendListUnits[i - lastIndex].timeOut);

        sheet.getRangeByName('B$i:D$i').cellStyle.hAlign = HAlignType.center;
        sheet.getRangeByName('E$i').cellStyle.hAlign = HAlignType.right;
        sheet.getRangeByName('B$i:G$i').cellStyle.fontSize = 10;
      }

      lastIndex = lastIndex + length;
      final Range range6 =
          sheet.getRangeByName('F${lastIndex + 1}:G${lastIndex + 1}');

      range6.merge();
      range6.cellStyle.hAlign = HAlignType.right;

      sheet.getRangeByName('F${lastIndex + 1}').setText('ايام الغياب');
      sheet.getRangeByName('F${lastIndex + 1}').cellStyle.fontSize = 12;
      sheet.getRangeByName('F${lastIndex + 1}').cellStyle.bold = true;

      final Range range8 =
          sheet.getRangeByName('F${lastIndex + 2}:G${lastIndex + 2}');

      range8.merge();
      range8.cellStyle.hAlign = HAlignType.right;

      sheet
          .getRangeByName('F${lastIndex + 2}')
          .setText(reportProvider.totalAbsentDay.toString());
      sheet.getRangeByName('F${lastIndex + 2}').cellStyle.fontSize = 12;
      sheet.getRangeByName('F${lastIndex + 2}').cellStyle.bold = true;
// --------------------------------------------------------------------------
      final Range range13 =
          sheet.getRangeByName('D${lastIndex + 1}:E${lastIndex + 1}');

      range13.merge();
      range13.cellStyle.hAlign = HAlignType.right;

      sheet.getRangeByName('D${lastIndex + 1}').setText('ايام التأخير');
      sheet.getRangeByName('D${lastIndex + 1}').cellStyle.fontSize = 12;
      sheet.getRangeByName('D${lastIndex + 1}').cellStyle.bold = true;

      final Range range14 =
          sheet.getRangeByName('D${lastIndex + 2}:E${lastIndex + 2}');

      range14.merge();
      range14.cellStyle.hAlign = HAlignType.right;

      sheet
          .getRangeByName('D${lastIndex + 2}')
          .setText(reportProvider.totalLateDay.toString());
      sheet.getRangeByName('D${lastIndex + 2}').cellStyle.fontSize = 12;
      sheet.getRangeByName('D${lastIndex + 2}').cellStyle.bold = true;
// --------------------------------------------------------------------------
      final Range range7 =
          sheet.getRangeByName('B${lastIndex + 1}:C${lastIndex + 1}');

      range7.merge();
      range7.cellStyle.hAlign = HAlignType.right;

      sheet.getRangeByName('B${lastIndex + 1}').setText('مدة التأخير');
      sheet.getRangeByName('B${lastIndex + 1}').cellStyle.fontSize = 12;
      sheet.getRangeByName('B${lastIndex + 1}').cellStyle.bold = true;

      final Range range9 =
          sheet.getRangeByName('B${lastIndex + 2}:C${lastIndex + 2}');

      range9.merge();
      range9.cellStyle.hAlign = HAlignType.right;

      sheet
          .getRangeByName('B${lastIndex + 2}')
          .setText(reportProvider.totalLateDuration);
      sheet.getRangeByName('B${lastIndex + 2}').cellStyle.fontSize = 12;
      sheet.getRangeByName('B${lastIndex + 2}').cellStyle.bold = true;
// ------------------------------------------------------------------------
      sheet.getRangeByIndex((lastIndex + 4), 1).text =
          'Copyright 2020 - 2025 Tamauze Digital Solutions . All rights reserved';

      sheet.getRangeByIndex(lastIndex + 4, 1).cellStyle.fontSize = 8;
      sheet.getRangeByIndex(lastIndex + 4, 1).cellStyle.fontColor = "#ffffff";

      final Range range10 =
          sheet.getRangeByName('A${lastIndex + 4}:H${lastIndex + 6}');
      range10.cellStyle.backColor = '#000000';
      range10.merge();
      range10.cellStyle.hAlign = HAlignType.center;
      range10.cellStyle.vAlign = VAlignType.center;

      //Save and launch the excel.
      final List<int> bytes = workbook.saveAsStream();
      //Dispose the document.
      workbook.dispose();

      //Get the storage folder location using path_provider package.

      print(path);
      // final String path = directory.path;
      final File file = File("$path/$freePath");

      await file.writeAsBytes(bytes);

      Fluttertoast.showToast(
          msg: "Download/$freePath",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      print(e);
    }
  }
}
