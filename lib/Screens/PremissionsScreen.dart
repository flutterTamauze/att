import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PermissionScreen extends StatefulWidget {
  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool isAllGranted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionHan>(builder: (context, permissionHan, child) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              HeaderBeforeLogin(),
              isAllGranted
                  ? Container()
                  : Container(
                      height: 20,
                      child: AutoSizeText(
                        getTranslated(context, "برجاء قبول التصريحات التالية"),
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: ScreenUtil()
                                .setSp(14, allowFontScalingSelf: true),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
              Expanded(
                child: Container(
                  height: 500.h,
                  child: ListView.builder(
                      itemCount: permissionHan.permissionsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PermissionWidget(
                          permissionData: permissionHan.permissionsList[index],
                          onTap: () async {
                            debugPrint(index.toString());
                            await requestPermission(
                                permissionHan.permissionsList[index].permission,
                                index);
                          },
                        );
                      }),
                ),
              ),
              isAllGranted
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FlatButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                              splashColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                width: 80.w,
                                height: 80.h,
                                child: Icon(
                                  Icons.check,
                                  size: ScreenUtil()
                                      .setSp(75, allowFontScalingSelf: true),
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      );
    });
  }

  Future<void> requestPermission(Permission permission, int index) async {
    if (await Permission.camera.status == PermissionStatus.granted &&
        await Permission.locationWhenInUse.status == PermissionStatus.granted &&
        await Permission.photos.status == PermissionStatus.granted) {
      setState(() {
        isAllGranted = true;
      });
    }
  }
}

/// Permission widget which displays a permission and allows users to request
/// the permissions.
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
  PermissionStatus _permissionStatus;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await permissionData.permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String getPermissionText() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return "مرفوض";
      case PermissionStatus.granted:
        return "مقبول";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    // return (Container(
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.end,
    //     children: [
    //       AutoSizeText(
    //         permissionData.interfaceName,
    //         style: TextStyle(fontSize: 14),
    //       ),
    //       AutoSizeText(
    //         getPermissionText(),
    //         style: TextStyle(color: getPermissionColor(), fontSize: 9),
    //       )
    //     ],
    //   ),
    // ));
    return ListTile(
        title: Container(
          height: 20,
          child: AutoSizeText(
            permissionData.interfaceName,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        subtitle: Container(
          height: 20,
          child: AutoSizeText(
            getPermissionText(),
            textAlign: TextAlign.right,
            maxLines: 1,
            style: TextStyle(color: getPermissionColor()),
          ),
        ),
        // trailing: IconButton(
        //     icon: const Icon(Icons.info),
        //     onPressed: () {
        //       checkServiceStatus(context, permissionData.permission);
        //     }),

        onTap: () async {
          await requestPermission(permissionData.permission);

          widget.onTap();
        });
  }

  void checkServiceStatus(BuildContext context, Permission permission) async {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Container(
          height: 20,
          child: AutoSizeText((await permission.status).toString())),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      debugPrint(status.toString());
      _permissionStatus = status;
      debugPrint(_permissionStatus.toString());
    });
  }
}
