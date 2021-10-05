import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:qr_users/constants.dart';
import 'package:open_file/open_file.dart' as open_file;

class DownloadService {
  Dio dio;
  var finalPath;
  String _filePath;
  bool _isLoading = false;
  String progress;
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
