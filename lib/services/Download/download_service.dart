import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../user_data.dart';

class DownloadService {
  Dio dio;
  var finalPath;
  String _filePath;
  bool _isLoading = false;
  String progress;

  checkReleaseDate(bool showApk, BuildContext context) {
    if (Platform.isAndroid) {
      if (showApk) {
        showApk = false;

        if (kAndroidReleaseDate.isBefore(
            Provider.of<UserData>(context, listen: false).user.apkDate)) {
          Future.delayed(Duration.zero, () {
            showDialog(
                // barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return RoundAlertUpgrade(
                      onPressed: () async {
                        // Navigator.pop(context);
                        // downloadApkFromUrl("ChilangoV3.apk", context);
                        launch(
                            "https://play.google.com/store/apps/details?id=com.tds.chilango");
                      },
                      title: "اصدار جديد",
                      content:
                          'تم تحديث نسخة التطبيق برجاء تحميل اخر اصدار لمتابعة الإستخدام');
                });
          });
        }
      }
    } else {
      if (showApk) {
        showApk = false;

        if (kiosReleaseDate.isBefore(
            Provider.of<UserData>(context, listen: false).user.iosBundleDate)) {
          Future.delayed(Duration.zero, () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RoundedAlert(
                      onPressed: () async {
                        Navigator.pop(context);
                        launch(iosDownloadLink);
                      },
                      title: 'تحديث التطبيق لأخر اصدار ؟',
                      content: "");
                });
          });
        }
      }
    }
  }

  Future downloadApkFromUrl(filename, BuildContext context) async {
    dio = Dio();
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    ProgressDialog pr;
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: "Downloading  ...");

    final path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    await pr.show();

    final file = File("$path/$filename");
    log(file.path);
    await dio.download(
      androidDownloadLink,
      file.path,
      onReceiveProgress: (count, total) {
        _isLoading = true;
        progress = ((count / total) * 100).toStringAsFixed(0) + " %";
        log(progress);
        pr.update(message: "Please wait : $progress");
      },
    );
    pr.hide();
    finalPath = file.path;
    _isLoading = false;

    await open_file.OpenFile.open(file.path);
  }
}
