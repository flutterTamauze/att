import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/constants.dart';
import 'package:qr_users/services/permissions_data.dart';

class RoundedAlert extends StatelessWidget {
  final String title;
  final String content;
  final Function onPressed;
  final Function onCancel;

  RoundedAlert(
      {this.title, this.content, @required this.onPressed, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)), //this right here
        child: Container(
          height: getkDeviceHeightFactor(context, 170),
          width: getkDeviceWidthFactor(context, 330),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: <Widget>[
                      Center(
                          child: Container(
                        height: 30.h,
                        child: AutoSizeText(
                          title,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 18,
                              height: 1.8,
                              color: Colors.orange,
                              fontWeight: FontWeight.w900),
                        ),
                      )),
                      SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Container(
                          height: 20,
                          child: AutoSizeText(
                            content,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        elevation: 5.0,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15.0),
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onCancel();
                          },
                          minWidth: 120,
                          height: 30,
                          child: Container(
                            height: 20,
                            child: AutoSizeText(
                              "لا",
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Material(
                        elevation: 5.0,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15.0),
                        child: MaterialButton(
                          onPressed: onPressed,
                          minWidth: 120,
                          height: 30,
                          child: Container(
                            height: 20,
                            child: AutoSizeText(
                              "نعم",
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ));
  }
}

class RoundedAlertEn extends StatelessWidget {
  final String title;
  final String content;
  final Function onPressed;
  final Function onCancel;

  RoundedAlertEn(
      {this.title, this.content, @required this.onPressed, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)), //this right here
        child: Container(
          height: getkDeviceHeightFactor(context, 170),
          width: getkDeviceWidthFactor(context, 330),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: <Widget>[
                      Center(
                          child: Container(
                        height: 20,
                        child: AutoSizeText(
                          title,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.orange,
                              fontWeight: FontWeight.w900),
                        ),
                      )),
                      SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Container(
                          height: 20,
                          child: AutoSizeText(
                            content,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        elevation: 5.0,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15.0),
                        child: MaterialButton(
                          onPressed: onPressed,
                          minWidth: 120,
                          height: 30,
                          child: Container(
                            height: 20,
                            child: AutoSizeText(
                              "Yes",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Material(
                        elevation: 5.0,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15.0),
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onCancel();
                          },
                          minWidth: 120,
                          height: 30,
                          child: Container(
                            height: 20,
                            child: AutoSizeText("No",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ));
  }
}

class PermissionAlert extends StatefulWidget {
  final String title;
  final String content;
  final Function allAccepted;

  PermissionAlert({
    this.title,
    this.content,
    @required this.allAccepted,
  });

  @override
  _PermissionAlertState createState() => _PermissionAlertState();
}

class _PermissionAlertState extends State<PermissionAlert> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionHan>(builder: (context, permissionHan, child) {
      return Container(
        height: getkDeviceHeightFactor(context, 300),
        width: getkDeviceWidthFactor(context, 330),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                    child: Container(
                  height: 20,
                  child: AutoSizeText(
                    widget.title,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.orange,
                        fontWeight: FontWeight.w900),
                  ),
                )),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: Container(
                    height: 20,
                    child: AutoSizeText(
                      widget.content,
                      maxLines: 1,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: permissionHan.permissionsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PermissionWidget(
                          permissionData: permissionHan.permissionsList[index],
                          onTap: () async {
                            print(index);
                            await requestPermission(
                                permissionHan.permissionsList[index].permission,
                                index);
                            // if (await permissionHan.permissionsList[index]
                            //         .permission.status ==
                            //     PermissionStatus.granted) {
                            //   permissionHan.filterList();
                            // }
                            //await filterList();
                          },
                        );
                      }),
                )
              ]),
        ),
      );
    });
  }

  Future<void> requestPermission(Permission permission, int index) async {
    if (await Permission.camera.status == PermissionStatus.granted &&
        await Permission.locationWhenInUse.status == PermissionStatus.granted) {
      setState(() {
        widget.allAccepted();
      });
    }
  }
}

class PermissionWidget extends StatefulWidget {
  PermissionWidget({this.permissionData, this.onTap});

  final PrData permissionData;
  final Function onTap;

  @override
  _PermissionState createState() => _PermissionState(permissionData);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this.permissionData);

  final PrData permissionData;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await _listenForPermissionStatus();
  }

  void initState() {
    super.initState();
  }

  Future _listenForPermissionStatus() async {
    final status = await permissionData.permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color getPermissionSubColor() {
    switch (_permissionStatus) {
      case PermissionStatus.permanentlyDenied:
        return Colors.redAccent.shade100;
      case PermissionStatus.denied:
        return Colors.redAccent.shade100;
      case PermissionStatus.granted:
        return Colors.lightGreenAccent;
      default:
        return Colors.blueGrey;
    }
  }

  bool getPermissionStatue() {
    switch (_permissionStatus) {
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.denied:
        return false;
      case PermissionStatus.granted:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                permissionData.icon,
                color: Colors.orange,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 3,
                    color: Colors.grey,
                  ),
                ),
              ),
              Switch(
                value: getPermissionStatue(),
                onChanged: (value) async {
                  print("sdas");
                  if (await permissionData.permission.isPermanentlyDenied) {
                    openAppSettings();
                  } else if (await permissionData.permission.isUndetermined) {
                    await requestPermission(permissionData.permission);
                    if (await permissionData.permission.isGranted) {
                      widget.onTap();
                    }
                  } else if (await permissionData.permission.isGranted) {
                    widget.onTap();
                  } else {
                    openAppSettings();
                  }
                },
                activeTrackColor: getPermissionSubColor(),
                activeColor: getPermissionColor(),
                inactiveTrackColor: getPermissionSubColor(),
                // inactiveTrackColor: Colors.redAccent,
                inactiveThumbColor: getPermissionColor(),
              ),
            ],
          ),
        ),
      ),

      // trailing: IconButton(
      //     icon: const Icon(Icons.info),
      //     onPressed: () {
      //       checkServiceStatus(context, permissionData.permission);
      //     }),
    );
  }

  void checkServiceStatus(BuildContext context, Permission permission) async {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Container(
        height: 20,
        child: AutoSizeText(
          (await permission.status).toString(),
          maxLines: 1,
        ),
      ),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    print("req");
    final status = await permission.request();
    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}

class RoundedAlertOkOnly extends StatelessWidget {
  final String title;
  final String content;
  final Function onPressed;

  RoundedAlertOkOnly({this.title, this.content, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)), //this right here
        child: Container(
          height: 200.h,
          width: 250.w,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: <Widget>[
                      Center(
                          child: Container(
                        height: 20.h,
                        child: AutoSizeText(
                          title,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.orange,
                              fontWeight: FontWeight.w900),
                        ),
                      )),
                      SizedBox(
                        height: 15.h,
                      ),
                      Center(
                        child: Container(
                          height: 20.h,
                          child: AutoSizeText(
                            content,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        elevation: 5.0,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15.0),
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          minWidth: 130,
                          height: 30,
                          child: Container(
                            height: 20,
                            child: AutoSizeText(
                              "الغاء",
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ));
  }
}

class RoundedLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)), //this right here
        child: Container(
          height: 120,
          width: 250,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 20,
                  child: AutoSizeText(
                    "برجاء الانتظار",
                    style: TextStyle(color: Color(0xffffad00), fontSize: 20),
                    maxLines: 1,
                  ),
                ),
                Container(
                    color: Colors.black,
                    child: Lottie.asset("resources/loading.json",
                        width: 80, height: 80)),
              ],
            ),
          ),
        ));
  }
}
