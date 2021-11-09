import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:qr_users/Screens/NormalUserMenu/NormalUserShifts.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QrAttendDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var shiftApiConsumer = Provider.of<ShiftApi>(context);
    var shiftDataProvider =
        Provider.of<ShiftApi>(context, listen: true).currentShift;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: shiftApiConsumer.isConnected
                ? shiftApiConsumer.permissionOff
                    ? shiftApiConsumer.isLocationServiceOn != 0
                        ? shiftApiConsumer.isLocationServiceOn != 2
                            ? shiftApiConsumer.isOnLocation
                                ? shiftApiConsumer.isOnShift
                                    ? Column(
                                        children: <Widget>[
                                          Container(
                                            child: Column(
                                              children: [
                                                FlutterAnalogClock(
                                                  dateTime: shiftApiConsumer
                                                      .currentCountryDate,
                                                  dialPlateColor: Colors.white,
                                                  hourHandColor: Colors.orange,
                                                  minuteHandColor:
                                                      Colors.orange,
                                                  secondHandColor: Colors.black,
                                                  numberColor: Colors.black,
                                                  borderColor: Colors.black,
                                                  centerPointColor:
                                                      Colors.black,
                                                  showMinuteHand: true,
                                                  showSecondHand: true,
                                                  showNumber: true,
                                                  borderWidth: 4.0,
                                                  isLive: true,
                                                  width: 120.0,
                                                  height: 120.0,
                                                  decoration:
                                                      const BoxDecoration(),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  DateTime.now()
                                                      .toString()
                                                      .substring(0, 11),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 210.h,
                                            child: Center(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 2.w,
                                                        color: Colors.black)),
                                                child: FadeIn(
                                                  child: QrImage(
                                                    foregroundColor:
                                                        Colors.black,
                                                    backgroundColor:
                                                        Colors.white,
                                                    //plce where the QR Image will be shown
                                                    data: shiftDataProvider
                                                        .shiftQrCode,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 20.h,
                                            child: AutoSizeText(
                                              "تسجيل عن طريق مسح الكود",
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                shiftApiConsumer
                                                    .shiftsListProvider[0]
                                                    .shiftName,
                                                style: TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Directionality(
                                                textDirection:
                                                    ui.TextDirection.rtl,
                                                child: AutoSizeText(
                                                  " تسجيل الحضور من ${amPmChanger(int.parse(shiftApiConsumer.currentShiftSTtime[0]))} الى ${amPmChanger(int.parse(shiftApiConsumer.currentShiftSTtime[1]))} \n تسجيل الانصراف من ${amPmChanger(int.parse(shiftApiConsumer.currentShiftEndTime[0]))} الى ${amPmChanger(int.parse(shiftApiConsumer.currentShiftEndTime[1]))}",
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1.5,
                                                      fontSize: ScreenUtil().setSp(
                                                          15,
                                                          allowFontScalingSelf:
                                                              true)),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    : Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          150),
                                                  border: Border.all(
                                                      color: Colors.orange,
                                                      width: 2)),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          150),
                                                  child: Image.network(
                                                    '${Provider.of<CompanyData>(context, listen: true).com.logo}',
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.white,
                                                          valueColor:
                                                              new AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors
                                                                      .orange),
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                  )),
                                              height: 150.h,
                                              width: 150.w,
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Directionality(
                                              textDirection:
                                                  ui.TextDirection.rtl,
                                              child: Container(
                                                height: 45.h,
                                                child: AutoSizeText(
                                                  " تسجيل الحضور من ${amPmChanger(shiftApiConsumer.shiftsListProvider[0].shiftStartTime)} إلى ${amPmChanger(shiftApiConsumer.shiftsListProvider[0].shiftEndTime)} \n تسجيل الانصراف من ${amPmChanger(shiftApiConsumer.shiftsListProvider[1].shiftStartTime)} إلى ${amPmChanger((shiftApiConsumer.shiftsListProvider[1].shiftEndTime) % 2400)}",
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: ScreenUtil().setSp(
                                                          18,
                                                          allowFontScalingSelf:
                                                              true)),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                : Column(
                                    children: [
                                      Lottie.asset(
                                          "resources/wrongLocation.json",
                                          repeat: false,
                                          width: 120.w,
                                          height: 120.h),
                                      Container(
                                        height: 100,
                                        child: AutoSizeText(
                                          "برجاء التواجد بالموقع المخصص لك\n${Provider.of<UserData>(context, listen: true).siteName}",
                                          textAlign: TextAlign.center,
                                          maxLines: 4,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              height: 2,
                                              fontSize: ScreenUtil().setSp(18,
                                                  allowFontScalingSelf: true)),
                                        ),
                                      ),
                                    ],
                                  )
                            : Column(
                                children: [
                                  Container(
                                    height: 100,
                                    child: AutoSizeText(
                                      "برجاء التواجد بالموقع المخصص لك\n${Provider.of<UserData>(context, listen: true).siteName}",
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          height: 2,
                                          fontSize: ScreenUtil().setSp(18,
                                              allowFontScalingSelf: true)),
                                    ),
                                  ),
                                ],
                              )
                        : Container(
                            height: 20,
                            child: AutoSizeText(
                              "برجاء تفعيل الموقع الجغرافى للهاتف ",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil()
                                      .setSp(18, allowFontScalingSelf: true)),
                            ),
                          )
                    : Container(
                        height: 20,
                        child: AutoSizeText(
                          "برجاء تفعيل تصريح الموقع الجغرافي ",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(18, allowFontScalingSelf: true)),
                        ),
                      )
                : Column(
                    children: [
                      Container(
                        child: Lottie.asset(
                            "resources/21485-wifi-outline-icon.json",
                            repeat: false),
                        height: 200.h,
                        width: 200.w,
                      ),
                      Container(
                        height: 20,
                        child: AutoSizeText(
                          "لا يوجد اتصال بالانترنت ",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(18, allowFontScalingSelf: true)),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
