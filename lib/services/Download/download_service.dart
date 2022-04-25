import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_version/new_version.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadService {
  Dio dio;
  var finalPath;
  // String _filePath;
  // bool _isLoading = false;
  String progress;

  checkReleaseDate(bool showApk, BuildContext context) async {
    final newVersion = NewVersion();
    final status = await newVersion.getVersionStatus();

    if (showApk) {
      showApk = false;

      if (status.canUpdate) {
        debugPrint("there is an update found");
        Future.delayed(Duration.zero, () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return RoundAlertUpgrade(
                    onPressed: () async {
                      launch(status.appStoreLink);
                    },
                    title: getTranslated(context, "إصدار جديد"),
                    content: getTranslated(context,
                        'تم تحديث نسخة التطبيق برجاء تحميل اخر اصدار لمتابعة الإستخدام'));
              });
        });
      } else {
        debugPrint("There is no update available");
        debugPrint(status.localVersion.toString());
        debugPrint(status.storeVersion.toString());
      }
    }
  }

  // Future downloadApkFromUrl(filename, BuildContext context) async {
  //   dio = Dio();
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }
  //   ProgressDialog pr;
  //   pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
  //   pr.style(message: "Downloading  ...");

  //   final path = await ExtStorage.getExternalStoragePublicDirectory(
  //       ExtStorage.DIRECTORY_DOWNLOADS);
  //   await pr.show();

  //   final file = File("$path/$filename");
  //   log(file.path);
  //   await dio.download(
  //     androidDownloadLink,
  //     file.path,
  //     onReceiveProgress: (count, total) {
  //       _isLoading = true;
  //       progress = ((count / total) * 100).toStringAsFixed(0) + " %";
  //       log(progress);
  //       pr.update(message: "Please wait : $progress");
  //     },
  //   );
  //   pr.hide();
  //   finalPath = file.path;
  //   _isLoading = false;

  //   await open_file.OpenFile.open(file.path);
  // }
}
