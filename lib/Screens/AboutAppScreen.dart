import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:open_file/open_file.dart' as open_file;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Notifications/Notifications.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String _filePath;
  bool _isLoading = false;
  String progress;
  Dio dio;
  @override
  void initState() {
    dio = Dio();
    super.initState();
  }

  var finalPath;
  Future _downloadFromUrl(filename) async {
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
      "https://www.ostora.tv/download/v4/ostora_v4.8.apk",
      file.path,
      onReceiveProgress: (count, total) {
        setState(() {
          _isLoading = true;
          progress = ((count / total) * 100).toStringAsFixed(0) + " %";
          log(progress);
          pr.update(message: "Please wait : $progress");
        });
      },
    );
    pr.hide();
    setState(() {
      finalPath = file.path;
      _isLoading = false;
    });
    final snackBar = SnackBar(
      content: Text(
        'تم التحميل بنجاح',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        textAlign: TextAlign.right,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await open_file.OpenFile.open(file.path);
  }

  Widget build(BuildContext context) {
    return Consumer<UserData>(builder: (context, userData, child) {
      return SafeArea(
        child: Scaffold(
            endDrawer: NotificationItem(),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipPath(
                                clipper: MyClipper(),
                                child: Container(
                                  height: (MediaQuery.of(context).size.height) /
                                      2.75,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                              ClipPath(
                                clipper: MyClipper(),
                                child: Container(
                                  height: (MediaQuery.of(context).size.height) /
                                      2.8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  width: 1.w,
                                                  color: Color(0xffFF7E00),
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 60,
                                                child: Container(
                                                  width: 200.w,
                                                  decoration: BoxDecoration(
                                                    // image: DecorationImage(
                                                    //   image: headerImage,
                                                    //   fit: BoxFit.fill,
                                                    // ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            75.0),
                                                    child: Image.asset(
                                                        "resources/image.png"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Container(
                                              height: 20,
                                              child: AutoSizeText(
                                                "Chilango",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: ScreenUtil().setSp(
                                                        20,
                                                        allowFontScalingSelf:
                                                            true),
                                                    color: Colors.orange),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          height: 20,
                                          child: AutoSizeText("Version 2.0.0",
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: Color(0xFF3b3c40),
                                                fontSize: ScreenUtil().setSp(16,
                                                    allowFontScalingSelf: true),
                                              )),
                                        ),
                                        SizedBox(
                                          height: 10.0.h,
                                        ),
                                        AboutUsCard(
                                          child: ListTile(
                                            onTap: () {
                                              Share.share(
                                                  'https://play.google.com/store/apps/dev?id=6238642369026075010');
                                            },
                                            title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Expanded(
                                                      flex: 6,
                                                      child: Container(
                                                        height: 20,
                                                        child: AutoSizeText(
                                                            "شارك التطبيق",
                                                            maxLines: 1,
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF3b3c40),
                                                                fontSize: ScreenUtil()
                                                                    .setSp(16,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      )),
                                                  SizedBox(
                                                    width: 5.w,
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Transform(
                                                        transform:
                                                            Matrix4.rotationY(
                                                                math.pi),
                                                        alignment:
                                                            Alignment.center,
                                                        child: IconButton(
                                                          onPressed: () {},
                                                          icon: Icon(
                                                            Icons.share,
                                                            color: Color(
                                                                0xFF3b3c40),
                                                          ),
                                                        ),
                                                      ))
                                                ]),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0.h,
                                        ),
                                        MyListTile(
                                          title: "قيم التطبيق",
                                          rotated: false,
                                          icon: FontAwesomeIcons.googlePlay,
                                          link:
                                              'https://play.google.com/store/apps/dev?id=6238642369026075010',
                                        ),
                                        SizedBox(
                                          height: 10.0.h,
                                        ),
                                        MyListTile(
                                          rotated: true,
                                          title: 'للشكاوى و المقترحات',
                                          icon: Icons.email,
                                          link: 'mailto:info@tamauzeds.com',
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  Platform.isAndroid
                                      ? TextButton(
                                          onPressed: () {
                                            _downloadFromUrl("ChilangoV3.apk");
                                          },
                                          child:
                                              Text("تحميل اخر نسخة من التطبيق"))
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 5.0.w,
                  top: 5.0.h,
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    color: Colors.black,
                    child: IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: Color(0xffF89A41),
                          size: ScreenUtil()
                              .setSp(40, allowFontScalingSelf: true),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ),
              ],
            )),
      );
    });
  }
}

class AboutUsCard extends StatelessWidget {
  final Widget child;

  AboutUsCard({this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        color: Colors.white,
        child: child);
  }
}

class MyListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String link;
  final bool rotated;
  MyListTile({this.title, this.icon, this.link, this.rotated});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      color: Colors.white,
      child: ListTile(
        onTap: () {
          launch(link);
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 6,
                child: Container(
                  height: 20,
                  child: AutoSizeText(title,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Color(0xFF3b3c40),
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          fontWeight: FontWeight.bold)),
                )),
            SizedBox(
              width: 5.w,
            ),
            Expanded(
                flex: 1,
                child: Transform(
                  transform: rotated
                      ? Matrix4.rotationY(math.pi)
                      : Matrix4.rotationX(0),
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      icon,
                      color: Color(0xFF3b3c40),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class CircletTile extends StatelessWidget {
  final IconData icon;
  final String link;
  final iconColor;
  CircletTile({this.icon, this.link, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: IconButton(
        onPressed: () {
          launch(link);
        },
        icon: Icon(
          icon,
          color: Color(0xffFF7E00),
        ),
      ),
    );
  }
}
