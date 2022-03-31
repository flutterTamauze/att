//import 'dart:io';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//
//import 'package:ext_storage/ext_storage.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
//import 'package:pdf/pdf.dart';
//import 'package:pdf/widgets.dart' as pw;
//import 'package:printing/printing.dart';
//
///// Represents the XlsIO stateful widget class.
//class PdfExportButton extends StatefulWidget {
//  /// Initalize the instance of the [CreateExcelStatefulWidget] class.
//
//  /// title.
//  final title;
//
//  PdfExportButton(this.title);
//
//  @override
//  _PdfExportButtonState createState() => _PdfExportButtonState();
//}
//
//var path;
//
///// Represents the XlsIO widget class.
//
//void _getDownloadStorage() async {
//  path = await ExtStorage.getExternalStoragePublicDirectory(
//      ExtStorage.DIRECTORY_DOWNLOADS);
//  debugPrint(path); // /storage/emulated/0/Pictures
//}
//
//var pathDownload = path;
//
//class _PdfExportButtonState extends State<PdfExportButton> {
//  void initState() {
//    _getDownloadStorage();
//
//    super.initState();
//  }
//
//  final pdf = pw.Document();
//
//  writeOnPdf() async {
//    const imageProvider = const AssetImage('resources/reportPDFimage.png');
//    final image = await flutterImageProvider(imageProvider);
//
//    const imageProvider2 = const AssetImage('resources/image.png');
//    final image2 = await flutterImageProvider(imageProvider2);
//
//    var arabicFont =
//        pw.Font.ttf(await rootBundle.load("resources/fonts/HacenTunisia.ttf"));
//    pdf.addPage(pw.Page(
//        theme: pw.ThemeData.withFont(base: arabicFont),
//        pageFormat: PdfPageFormat.roll80,
//        build: (pw.Context context) {
//          return pw.Container(
//              child: pw.Directionality(
//                  textDirection: pw.TextDirection.rtl,
//                  child: pw.Column(children: [
//                    pw.Container(
//                      color: PdfColors.black,
//                      height: 50,
//                      child: pw.Row(
//                        mainAxisAlignment: pw.MainAxisAlignment.start,
//                        children: [
//                          pw.Padding(
//                              padding: pw.EdgeInsets.symmetric(horizontal: 5),
//                              child: pw.Container(
//                                height: 30,
//                                width: 30,
//                                decoration: pw.BoxDecoration(
//                                    border: pw.Border.all(
//                                      width: 1,
//                                      color: PdfColors.orange,
//                                    ),
//                                    shape: pw.BoxShape.circle,
//                                    image: pw.DecorationImage(
//                                      image: image2,
//                                    )),
//                              )),
//                          pw.Text(
//                            "Smart Attendance",
//                            style: pw.TextStyle(
//                                color: PdfColors.orange, fontSize: 17),
//                          ),
//                        ],
//                      ),
//                    ),
//                    pw.Row(
//                      mainAxisAlignment: pw.MainAxisAlignment.center,
//                      children: [
//                        pw.Text(
//                          widget.title,
//                          style: pw.TextStyle(
//                              color: PdfColors.orange, fontSize: 14),
//                        ),
//                        pw.Container(
//                          decoration: pw.BoxDecoration(
//                            shape: pw.BoxShape.circle,
//                          ),
//                          child: pw.Container(
//                            width: 10,
//                            decoration: pw.BoxDecoration(
//                              shape: pw.BoxShape.circle,
//                            ),
//                            child: pw.Image(image),
//                          ),
//                        ),
//                      ],
//                    ),
//                    x
//                  ])));
//        }));
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return FlatButton(
//      child: Icon(
//        FontAwesomeIcons.filePdf,
//        size: 25,
//        color: Colors.orange,
//      ),
//      onPressed: () async {
//        await writeOnPdf();
//        // await savePdf();
//
//        await Printing.layoutPdf(
//            onLayout: (PdfPageFormat format) async => pdf.save());
//
//        // await open_file.OpenFile.open('$pathDownload/example1.pdf');
//      },
//    );
//  }
//}
//
//var x = pw.Container(
//    decoration: pw.BoxDecoration(
//        color: PdfColors.orange,
//        borderRadius: pw.BorderRadius.only(
//          topLeft: pw.Radius.circular(15),
//          topRight: pw.Radius.circular(15),
//        )),
//    child: pw.Padding(
//      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
//      child: pw.Row(
//        children: [
//          pw.Container(
//              width: 10,
//              height: 10,
//              child: pw.Center(
//                  child: pw.Text(
//                'التاريخ',
//                style: pw.TextStyle(
//                    // fontWeight: pw.FontWeight.bold,
//                    fontSize: 5,
//                    color: PdfColors.black),
//              ))),
//          pw.Expanded(
//            child: pw.Row(
//              children: [
//                pw.Expanded(
//                  flex: 1,
//                  child: pw.Container(
//                      child: pw.Center(
//                          child: pw.Text(
//                    'التأخير',
//                    style: pw.TextStyle(fontSize: 5, color: PdfColors.black),
//                  ))),
//                ),
//                pw.Expanded(
//                  flex: 1,
//                  child: pw.Container(
//                      child: pw.Center(
//                          child: pw.Text(
//                    'حضور',
//                    textAlign: pw.TextAlign.center,
//                    style: pw.TextStyle(fontSize: 5, color: PdfColors.black),
//                  ))),
//                ),
//                pw.Expanded(
//                  flex: 1,
//                  child: pw.Container(
//                      child: pw.Center(
//                          child: pw.Text(
//                    'انصراف',
//                    textAlign: pw.TextAlign.center,
//                    style: pw.TextStyle(fontSize: 5, color: PdfColors.black),
//                  ))),
//                ),
//              ],
//            ),
//          )
//        ],
//      ),
//    ));
